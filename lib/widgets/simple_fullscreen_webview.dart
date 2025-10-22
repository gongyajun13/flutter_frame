import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io' show Platform;
import '../utils/url_launcher_util.dart';
import '../utils/webview_bridge_manager.dart';

/// 简单的全屏 WebView 组件
class SimpleFullScreenWebView extends StatefulWidget {
  final String url;
  final String title;
  
  /// 是否启用桥接功能（默认启用）
  final bool enableBridge;
  
  /// 自定义桥接方法注册回调
  final void Function(WebViewBridgeManager)? onBridgeReady;

  const SimpleFullScreenWebView({
    super.key,
    required this.url,
    required this.title,
    this.enableBridge = true,
    this.onBridgeReady,
  });

  @override
  State<SimpleFullScreenWebView> createState() => _SimpleFullScreenWebViewState();
  
  /// 静态方法：清除所有 WebView 缓存
  /// 
  /// 这是一个全局方法，会清除所有 WebView 的缓存数据
  /// 适用于退出登录、切换账号等场景
  static Future<void> clearAllCache() async {
    try {
      debugPrint('WebView: 开始清除全局缓存...');
      
      // 清除所有 Cookies
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint('WebView: 全局 Cookies 已清除');
      
      debugPrint('WebView: 全局缓存清除完成');
    } catch (e) {
      debugPrint('WebView: 清除全局缓存失败 - $e');
      rethrow;
    }
  }
}

class _SimpleFullScreenWebViewState extends State<SimpleFullScreenWebView> {
  late WebViewController _controller;
  WebViewBridgeManager? _bridgeManager;
  bool _isLoading = true;
  double _loadingProgress = 0.0; // 加载进度 0.0 - 1.0
  String? _error;
  
  // 防止快速点击：记录正在处理的协议
  final Set<String> _processingSchemes = {};

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  @override
  void dispose() {
    _bridgeManager?.dispose();
    super.dispose();
  }

  /// 清除 WebView 缓存
  /// 
  /// 包括：
  /// - Cookie
  /// - 本地存储（LocalStorage）
  /// - 会话存储（SessionStorage）
  /// - 缓存文件
  /// - 离线 Web 应用缓存
  /// 
  /// [includeDiskFiles] 是否清除磁盘缓存文件（默认 true）
  Future<void> clearCache({bool includeDiskFiles = true}) async {
    try {
      debugPrint('WebView: 开始清除缓存...');
      
      // 1. 清除所有 Cookies
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint('WebView: Cookies 已清除');
      
      // 2. 清除 LocalStorage 和 SessionStorage
      await _controller.runJavaScript('''
        // 清除 LocalStorage
        if (window.localStorage) {
          window.localStorage.clear();
          console.log('LocalStorage cleared');
        }
        
        // 清除 SessionStorage
        if (window.sessionStorage) {
          window.sessionStorage.clear();
          console.log('SessionStorage cleared');
        }
        
        // 清除 IndexedDB（如果有）
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
      
      // 3. Android 平台特定的缓存清理
      if (Platform.isAndroid && includeDiskFiles) {
        final androidController = _controller.platform as AndroidWebViewController;
        await androidController.clearCache();
        debugPrint('WebView: Android 缓存文件已清除');
      }
      
      debugPrint('WebView: 缓存清除完成');
    } catch (e) {
      debugPrint('WebView: 清除缓存失败 - $e');
      rethrow;
    }
  }

  /// 仅清除 Cookies
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

  /// 仅清除 LocalStorage
  Future<void> clearLocalStorage() async {
    try {
      await _controller.runJavaScript('''
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

  /// 获取当前 WebView 的 Controller（供外部使用）
  WebViewController get controller => _controller;

  /// 获取桥接管理器（供外部使用）
  WebViewBridgeManager? get bridgeManager => _bridgeManager;

  /// 处理特殊协议（tel:, mailto:, sms:, market: 等）
  Future<void> _handleSpecialScheme(String url, Uri uri) async {
    try {
      final scheme = uri.scheme;
      
      // 【防止快速点击】检查该协议是否正在处理中
      if (_processingSchemes.contains(scheme)) {
        debugPrint('协议 $scheme 正在处理中，忽略重复请求');
        return;
      }
      
      // 标记为正在处理
      _processingSchemes.add(scheme);
      
      try {
        // 根据不同的协议类型处理
        switch (uri.scheme) {
          case 'tel':
            // 电话协议
            debugPrint('尝试拨打电话: ${uri.path}');
            await UrlLauncherUtil.makePhoneCall(uri.path);
            break;
            
          case 'mailto':
            // 邮件协议
            debugPrint('尝试发送邮件: ${uri.path}');
            await UrlLauncherUtil.sendEmail(
              to: uri.path,
            );
            break;
            
          case 'sms':
            // 短信协议
            debugPrint('尝试发送短信: ${uri.path}');
            await UrlLauncherUtil.sendSms(uri.path);
            break;
            
          case 'market':
            // 应用市场协议
            debugPrint('尝试打开应用市场: $url');
            await UrlLauncherUtil.openUrl(url);
            break;
            
          default:
            // 其他协议（如 baiduboxapp:, intent: 等）
            // 这些通常是应用特定协议，可以尝试打开
            debugPrint('尝试打开特殊协议: $url');
            final result = await UrlLauncherUtil.canOpenUrl(url);
            if (result) {
              await UrlLauncherUtil.openUrl(url);
              debugPrint('成功打开协议: $scheme');
            } else {
              debugPrint('无法打开协议: $url (系统不支持或未安装相应应用)');
            }
        }
      } finally {
        // 处理完成后，延迟移除标记（防止快速重复点击）
        Future.delayed(const Duration(milliseconds: 500), () {
          _processingSchemes.remove(scheme);
        });
      }
    } catch (e) {
      debugPrint('处理特殊协议失败: $e');
    }
  }

  /// 格式化错误消息，使其更友好
  String _formatErrorMessage(WebResourceError error) {
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
        // 简化错误描述
        String desc = error.description;
        
        // 特殊处理超时错误
        if (desc.contains('TIMED_OUT') || desc.contains('TIMEOUT')) {
          return '连接超时\n网络响应时间过长\n请检查网络后重试';
        }
        
        if (desc.contains('ERR_')) {
          // 提取错误类型
          final match = RegExp(r'ERR_[A-Z_]+').firstMatch(desc);
          if (match != null) {
            final errorType = match.group(0)!;
            // 根据错误类型提供友好提示
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

  void _initializeWebView() {
    // 为 Android 平台启用混合内容模式
    if (Platform.isAndroid) {
      AndroidWebViewController.enableDebugging(true);
    }
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // 使用更现代的 UserAgent
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36');
    
    // 添加 JavaScript 通道（用于 H5 调用 Flutter）
    if (widget.enableBridge) {
      _controller.addJavaScriptChannel(
        'FlutterJavaScriptChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // 处理来自 H5 的消息
          _bridgeManager?.handleMessage(message.message);
        },
      );
    }
    
    _controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0.0;
              _error = null;
            });
          },
          onPageFinished: (url) async {
            setState(() {
              _isLoading = false;
              _loadingProgress = 1.0;
              _error = null;
            });
            
            // 页面加载完成后初始化桥接
            if (widget.enableBridge&& _bridgeManager == null) {
              _bridgeManager = WebViewBridgeManager(_controller);
              await _bridgeManager!.initializeBridge();
              
              // 通知外部桥接已就绪
              widget.onBridgeReady?.call(_bridgeManager!);
              
              debugPrint('WebView 桥接已启用');
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView Error - Code: ${error.errorCode}, Type: ${error.errorType}, Description: ${error.description}, isForMainFrame: ${error.isForMainFrame}');
            
            // 【关键】只处理主frame的错误，忽略子资源（图片、JS、CSS等）的加载失败
            if (error.isForMainFrame != true) {
              debugPrint('忽略子资源错误: ${error.description}');
              return;
            }
            
            // 1. 忽略跨域资源阻止错误（不影响主页面显示）
            if (error.description.contains('ERR_BLOCKED_BY_ORB')) {
              return;
            }
            
            // 2. 忽略缓存相关错误（正常现象）
            if (error.description.contains('ERR_CACHE_MISS') || 
                error.description.contains('ERR_CACHE_')) {
              return;
            }
            
            // 3. 忽略访问被拒绝的资源（通常是第三方资源）
            if (error.description.contains('ERR_ACCESS_DENIED')) {
              return;
            }
            
            // 4. 忽略 JavaScript 控制台错误（不是加载错误）
            if (error.description.contains('Uncaught') || 
                error.description.contains('ReferenceError') ||
                error.description.contains('TypeError') ||
                error.description.contains('SyntaxError')) {
              return;
            }
            
            // 5. 特殊处理：未知 URL 协议（如 tel:, mailto:, intent: 等）
            if (error.errorCode == -10 || 
                error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
              // 不显示错误，这些是系统调用，不是真正的错误
              debugPrint('检测到系统协议调用: ${error.description}');
              return;
            }
            
            // 6. 真正的主页面网络错误才显示
            // 这些错误代码表示主页面加载失败的严重问题：
            // -2: 名称解析失败（DNS错误）
            // -7: 连接超时
            // -8: 连接失败
            // 注意：ERR_CONNECTION_REFUSED (-6) 经常是子资源问题，已在上面通过 isForMainFrame 过滤
            final errorCode = error.errorCode;
            if (errorCode < 0 && errorCode >= -20) {
              setState(() {
                _isLoading = false;
                _error = _formatErrorMessage(error);
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // 处理特殊协议（tel:, mailto:, sms:, market:, intent: 等）
            final uri = Uri.parse(request.url);
            
            // 非 http/https 协议，阻止 WebView 加载并尝试外部处理
            if (uri.scheme != 'http' && 
                uri.scheme != 'https' && 
                uri.scheme != 'about' && 
                uri.scheme != 'data') {
              debugPrint('拦截特殊协议: ${uri.scheme}://${uri.host}${uri.path}');
              
              // 尝试使用 url_launcher 打开系统协议
              _handleSpecialScheme(request.url, uri);
              
              // 阻止 WebView 加载这些链接
              return NavigationDecision.prevent;
            }
            
            // 允许正常的 http/https 导航
            return NavigationDecision.navigate;
          },
        ),
      );

    // Android 平台特定配置
    if (Platform.isAndroid) {
      final androidController = _controller.platform as AndroidWebViewController;
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

    // 延迟加载
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        try {
          _controller.loadRequest(
            Uri.parse(widget.url),
            // 添加请求头
            headers: {
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
              'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            },
          );
        } catch (e) {
          setState(() {
            _isLoading = false;
            _error = 'URL 格式错误: $e';
          });
        }
      }
    });
  }

  /// 处理返回键逻辑
  Future<bool> _handleBackPressed() async {
    // 如果有错误，直接退出
    if (_error != null) {
      return true;
    }
    
    // 检查 WebView 是否可以返回上一页
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false; // 不退出页面
    }
    
    // 无法返回上一页，退出页面
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁用默认返回行为
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        
        final shouldPop = await _handleBackPressed();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _handleBackPressed();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                _controller.reload();
              },
              icon: Icon(Icons.refresh, size: 20.sp),
              tooltip: '刷新',
            ),
          ],
        ),
        body: Stack(
          children: [
            // WebView 或错误界面
            _error != null
                ? _buildErrorWidget()
                : WebViewWidget(controller: _controller),
            
            // 顶部加载进度条
            if (_isLoading && _loadingProgress < 1.0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                  minHeight: 3.h,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              '网页加载失败',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _error ?? '未知错误',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _controller.reload();
                  },
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text('重新加载', style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
                SizedBox(width: 16.w),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 18.sp),
                  label: Text('关闭', style: TextStyle(fontSize: 14.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

