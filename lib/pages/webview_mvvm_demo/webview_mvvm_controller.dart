import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io' show Platform;
import '../../utils/url_launcher_util.dart';
import '../../utils/webview_bridge_manager.dart';
import 'package:flutter/material.dart';

/// WebView MVVM Controller
class WebViewMvvmController extends GetxController {
  // WebView Controller
  late WebViewController webViewController;
  
  // 桥接管理器
  WebViewBridgeManager? bridgeManager;
  
  // 响应式状态
  final isLoading = true.obs;
  final loadingProgress = 0.0.obs;
  final errorMessage = Rx<String?>(null);
  final currentUrl = ''.obs;
  final canGoBack = false.obs;
  final canGoForward = false.obs;
  
  // 配置参数
  final String initialUrl;
  final bool enableBridge;
  
  // 防止快速重复点击
  final Set<String> _processingSchemes = {};
  
  WebViewMvvmController({
    required this.initialUrl,
    this.enableBridge = true,
  });

  @override
  void onInit() {
    super.onInit();
    initializeWebView();
  }

  @override
  void onClose() {
    bridgeManager?.dispose();
    super.onClose();
  }

  /// 初始化 WebView
  void initializeWebView() {
    // Android 平台启用调试
    if (Platform.isAndroid) {
      AndroidWebViewController.enableDebugging(true);
    }
    
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
      );
    
    // 添加 JavaScript 通道（H5 调用 Flutter）
    if (enableBridge) {
      webViewController.addJavaScriptChannel(
        'FlutterJavaScriptChannel',
        onMessageReceived: (JavaScriptMessage message) {
          bridgeManager?.handleMessage(message.message);
        },
      );
    }
    
    // 设置导航代理
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          loadingProgress.value = progress / 100.0;
        },
        onPageStarted: (url) {
          isLoading.value = true;
          loadingProgress.value = 0.0;
          errorMessage.value = null;
          currentUrl.value = url;
          _updateNavigationState();
        },
        onPageFinished: (url) async {
          isLoading.value = false;
          loadingProgress.value = 1.0;
          errorMessage.value = null;
          currentUrl.value = url;
          _updateNavigationState();
          
          // 初始化桥接
          if (enableBridge) {
            bridgeManager = WebViewBridgeManager(webViewController);
            await bridgeManager!.initializeBridge();
            debugPrint('WebView 桥接已启用');
          }
        },
        onWebResourceError: (error) {
          handleWebResourceError(error);
        },
        onNavigationRequest: (NavigationRequest request) {
          return handleNavigationRequest(request);
        },
      ),
    );

    // Android 特定配置
    if (Platform.isAndroid) {
      final androidController = webViewController.platform as AndroidWebViewController;
      androidController
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setGeolocationPermissionsPromptCallbacks(
          onShowPrompt: (request) async {
            return GeolocationPermissionsResponse(
              allow: false,
              retain: false,
            );
          },
        );
    }

    // 延迟加载 URL
    Future.delayed(const Duration(milliseconds: 300), () {
      loadUrl(initialUrl);
    });
  }

  /// 加载 URL
  void loadUrl(String url) {
    try {
      webViewController.loadRequest(
        Uri.parse(url),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'URL 格式错误: $e';
    }
  }

  /// 刷新页面
  void reload() {
    errorMessage.value = null;
    isLoading.value = true;
    webViewController.reload();
  }

  /// 返回上一页
  Future<void> goBack() async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
    }
  }

  /// 前进下一页
  Future<void> goForward() async {
    if (await webViewController.canGoForward()) {
      webViewController.goForward();
    }
  }

  /// 更新导航状态
  Future<void> _updateNavigationState() async {
    canGoBack.value = await webViewController.canGoBack();
    canGoForward.value = await webViewController.canGoForward();
  }

  /// 处理返回键
  Future<bool> handleBackPressed() async {
    // 如果有错误，直接退出
    if (errorMessage.value != null) {
      return true;
    }
    
    // 检查是否可以返回上一页
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return false;
    }
    
    return true;
  }

  /// 处理 Web 资源错误
  void handleWebResourceError(WebResourceError error) {
    debugPrint('WebView Error - Code: ${error.errorCode}, Description: ${error.description}, isForMainFrame: ${error.isForMainFrame}');
    
    // 只处理主 frame 的错误
    if (error.isForMainFrame != true) {
      return;
    }
    
    // 忽略特定错误
    if (_shouldIgnoreError(error)) {
      return;
    }
    
    // 显示错误
    final errorCode = error.errorCode;
    if (errorCode < 0 && errorCode >= -20) {
      isLoading.value = false;
      errorMessage.value = formatErrorMessage(error);
    }
  }

  /// 判断是否应该忽略该错误
  bool _shouldIgnoreError(WebResourceError error) {
    final desc = error.description;
    
    // 跨域资源阻止
    if (desc.contains('ERR_BLOCKED_BY_ORB')) return true;
    
    // 缓存相关
    if (desc.contains('ERR_CACHE_MISS') || desc.contains('ERR_CACHE_')) return true;
    
    // 访问被拒绝
    if (desc.contains('ERR_ACCESS_DENIED')) return true;
    
    // JavaScript 错误
    if (desc.contains('Uncaught') || 
        desc.contains('ReferenceError') ||
        desc.contains('TypeError') ||
        desc.contains('SyntaxError')) return true;
    
    // 未知协议
    if (error.errorCode == -10 || desc.contains('ERR_UNKNOWN_URL_SCHEME')) return true;
    
    return false;
  }

  /// 格式化错误消息
  String formatErrorMessage(WebResourceError error) {
    switch (error.errorCode) {
      case -2:
        return '网址无法访问\n请检查网址是否正确';
      case -6:
        return '连接被拒绝\n网站服务器拒绝了连接';
      case -7:
        return '连接超时\n请检查网络连接后点击重试';
      case -8:
        return '连接超时\n网络响应时间过长\n请检查网络后重试';
      case -10:
        return '不支持的链接类型';
      default:
        String desc = error.description;
        
        if (desc.contains('TIMED_OUT') || desc.contains('TIMEOUT')) {
          return '连接超时\n网络响应时间过长\n请检查网络后重试';
        }
        
        if (desc.contains('ERR_')) {
          final match = RegExp(r'ERR_[A-Z_]+').firstMatch(desc);
          if (match != null) {
            final errorType = match.group(0)!;
            switch (errorType) {
              case 'ERR_NAME_NOT_RESOLVED':
                return '域名解析失败\n无法找到该网站';
              case 'ERR_INTERNET_DISCONNECTED':
                return '网络已断开\n请检查网络连接';
              case 'ERR_CONNECTION_RESET':
                return '连接被重置\n请重试';
              case 'ERR_CONNECTION_CLOSED':
                return '连接已关闭\n请重试';
              default:
                return '网页加载失败\n$errorType';
            }
          }
        }
        return '网页加载失败\n${error.description}';
    }
  }

  /// 处理导航请求
  NavigationDecision handleNavigationRequest(NavigationRequest request) {
    final uri = Uri.parse(request.url);
    
    // 非 http/https 协议，尝试外部处理
    if (uri.scheme != 'http' && 
        uri.scheme != 'https' && 
        uri.scheme != 'about' && 
        uri.scheme != 'data') {
      debugPrint('拦截特殊协议: ${uri.scheme}://${uri.host}${uri.path}');
      handleSpecialScheme(request.url, uri);
      return NavigationDecision.prevent;
    }
    
    return NavigationDecision.navigate;
  }

  /// 处理特殊协议
  Future<void> handleSpecialScheme(String url, Uri uri) async {
    try {
      final scheme = uri.scheme;
      
      // 防止快速重复点击
      if (_processingSchemes.contains(scheme)) {
        debugPrint('协议 $scheme 正在处理中，忽略重复请求');
        return;
      }
      
      _processingSchemes.add(scheme);
      
      try {
        switch (uri.scheme) {
          case 'tel':
            await UrlLauncherUtil.makePhoneCall(uri.path);
            break;
          case 'mailto':
            await UrlLauncherUtil.sendEmail(to: uri.path);
            break;
          case 'sms':
            await UrlLauncherUtil.sendSms(uri.path);
            break;
          case 'market':
            await UrlLauncherUtil.openUrl(url);
            break;
          default:
            final result = await UrlLauncherUtil.canOpenUrl(url);
            if (result) {
              await UrlLauncherUtil.openUrl(url);
            }
        }
      } finally {
        Future.delayed(const Duration(milliseconds: 500), () {
          _processingSchemes.remove(scheme);
        });
      }
    } catch (e) {
      debugPrint('处理特殊协议失败: $e');
    }
  }

  /// 清除缓存
  Future<void> clearCache({bool includeDiskFiles = true}) async {
    try {
      debugPrint('WebView: 开始清除缓存...');
      
      // 清除 Cookies
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint('WebView: Cookies 已清除');
      
      // 清除 LocalStorage 和 SessionStorage
      await webViewController.runJavaScript('''
        if (window.localStorage) {
          window.localStorage.clear();
          console.log('LocalStorage cleared');
        }
        if (window.sessionStorage) {
          window.sessionStorage.clear();
          console.log('SessionStorage cleared');
        }
        if (window.indexedDB && window.indexedDB.databases) {
          window.indexedDB.databases().then(function(dbs) {
            dbs.forEach(function(db) {
              window.indexedDB.deleteDatabase(db.name);
            });
            console.log('IndexedDB cleared');
          });
        }
      ''');
      debugPrint('WebView: LocalStorage/SessionStorage 已清除');
      
      // Android 平台清除磁盘缓存
      if (Platform.isAndroid && includeDiskFiles) {
        final androidController = webViewController.platform as AndroidWebViewController;
        await androidController.clearCache();
        debugPrint('WebView: Android 缓存文件已清除');
      }
      
      debugPrint('WebView: 缓存清除完成');
    } catch (e) {
      debugPrint('WebView: 清除缓存失败 - $e');
      rethrow;
    }
  }

  /// 清除 Cookies
  Future<void> clearCookies() async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint('WebView: Cookies 已清除');
    } catch (e) {
      debugPrint('WebView: 清除 Cookies 失败 - $e');
      rethrow;
    }
  }

  /// 清除 LocalStorage
  Future<void> clearLocalStorage() async {
    try {
      await webViewController.runJavaScript('''
        if (window.localStorage) {
          window.localStorage.clear();
          console.log('LocalStorage cleared');
        }
      ''');
      debugPrint('WebView: LocalStorage 已清除');
    } catch (e) {
      debugPrint('WebView: 清除 LocalStorage 失败 - $e');
      rethrow;
    }
  }
}
