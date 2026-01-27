import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io' show Platform;
import '../utils/webview_bridge_manager.dart';
import '../utils/webview_error_handler.dart';
import '../utils/webview_scheme_handler.dart';
import '../utils/webview_cache_manager.dart';
import '../utils/webview_config.dart';
import '../utils/webview_file_chooser.dart';
import '../utils/permission_util.dart';
import '../utils/url_launcher_util.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter/material.dart';

/// 基础 WebView Controller
/// 
/// 提供 WebView 的公共逻辑，包括：
/// - 状态管理
/// - 错误处理
/// - 协议处理
/// - 缓存管理
/// - 导航控制
abstract class BaseWebViewController extends GetxController {
  // WebView Controller
  late WebViewController webViewController;

  // 桥接管理器
  WebViewBridgeManager? bridgeManager;

  // 响应式状态
  final isLoading = true.obs;
  final loadingProgress = 0.0.obs;
  final errorMessage = Rx<String?>(null);
  final currentUrl = ''.obs;
  final pageTitle = ''.obs; // 页面标题
  final canGoBack = false.obs;
  final canGoForward = false.obs;

  // 配置参数
  final String initialUrl;
  final bool enableBridge;
  final void Function(WebViewBridgeManager)? onBridgeReady;
  final WebViewRetryStrategy? retryStrategy;

  // 重试相关
  int _retryCount = 0;

  BaseWebViewController({
    required this.initialUrl,
    this.enableBridge = true,
    this.onBridgeReady,
    this.retryStrategy,
  });

  @override
  void onInit() {
    super.onInit();
    initializeWebView();
  }


  @override
  void onClose() {
    // 清理资源
    bridgeManager?.dispose();
    bridgeManager = null;
    WebViewSchemeHandler.clearProcessingSchemes();
    
    // 清理 WebView 相关资源
    try {
      // 清除缓存（可选，根据需要决定）
      // clearCache(includeDiskFiles: false);
    } catch (e) {
      debugPrint('WebView: 清理资源时出错 - $e');
    }
    
    super.onClose();
  }

  /// 初始化 WebView
  /// 
  /// 子类可以重写此方法以自定义初始化逻辑
  void initializeWebView() {
    // Android 平台启用调试
    if (Platform.isAndroid && WebViewConfig.shouldEnableDebugging()) {
      AndroidWebViewController.enableDebugging(true);
    }

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_getDefaultUserAgent());

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
          // 只有在加载中时才更新进度
          if (isLoading.value) {
            loadingProgress.value = progress / 100.0;
          }
        },
        onPageStarted: (url) {
          // 立即重置状态，确保新页面加载时进度从0开始
          isLoading.value = true;
          loadingProgress.value = 0.0;
          errorMessage.value = null;
          currentUrl.value = url;
          _updateNavigationState();
          debugPrint('WebView: 开始加载 $url');
        },
        onPageFinished: (url) async {
          // 页面加载完成
          isLoading.value = false;
          loadingProgress.value = 1.0;
          errorMessage.value = null;
          currentUrl.value = url;
          _updateNavigationState();
          debugPrint('WebView: 加载完成 $url');

          // 获取页面标题
          try {
            final title = await webViewController.getTitle();
            if (title != null && title.isNotEmpty) {
              pageTitle.value = title;
              debugPrint('WebView: 页面标题 - $title');
            }
          } catch (e) {
            debugPrint('WebView: 获取页面标题失败 - $e');
          }

          // 延迟一小段时间后隐藏进度条（让用户看到100%）
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!isLoading.value) {
              loadingProgress.value = 0.0; // 重置进度，隐藏进度条
            }
          });

          // 初始化桥接
          if (enableBridge && bridgeManager == null) {
            bridgeManager = WebViewBridgeManager(webViewController);
            await bridgeManager!.initializeBridge();
            onBridgeReady?.call(bridgeManager!);
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
      
      // 配置文件选择器（Android）
      androidController.setOnShowFileSelector((fileSelectorParams) async {
        return await _handleFileSelectorAndroid(fileSelectorParams);
      });
      
      // 配置平台权限请求（Android）
      androidController.setOnPlatformPermissionRequest((request) async {
        return await _handlePlatformPermissionRequest(request);
      });
    }

    // iOS 特定配置
    if (Platform.isIOS) {
      try {
        // iOS 端的权限请求可能需要通过其他方式处理
        // 尝试通过动态方式配置
        final iosController = webViewController.platform as dynamic;
        
        // 尝试设置权限请求回调（如果 API 支持）
        if (iosController != null) {
          try {
            // 尝试调用 setOnPlatformPermissionRequest（如果存在）
            if (iosController.setOnPlatformPermissionRequest != null) {
              iosController.setOnPlatformPermissionRequest((request) async {
                return await _handlePlatformPermissionRequestIOS(request);
              });
              debugPrint('WebView: iOS 平台权限请求已配置');
            } else {
              debugPrint('WebView: iOS 平台不支持 setOnPlatformPermissionRequest');
            }
          } catch (e) {
            debugPrint('WebView: iOS 平台权限请求配置失败 - $e');
          }
        }
      } catch (e) {
        debugPrint('WebView: iOS 平台配置失败 - $e');
      }
    }

    // 延迟加载 URL（可配置）
    Future.delayed(WebViewConfig.getInitializationDelay(), () {
      loadUrl(initialUrl);
    });
  }

  /// 获取默认 UserAgent
  String _getDefaultUserAgent() {
    return WebViewConfig.defaultUserAgent;
  }

  /// 加载 URL
  void loadUrl(String url) {
    try {
      // 加载新URL前，立即重置状态
      isLoading.value = true;
      loadingProgress.value = 0.0;
      errorMessage.value = null;
      
      webViewController.loadRequest(
        Uri.parse(url),
        headers: _getDefaultHeaders(),
      );
    } catch (e) {
      isLoading.value = false;
      loadingProgress.value = 0.0;
      errorMessage.value = 'URL 格式错误: $e';
    }
  }

  /// 获取默认请求头
  Map<String, String> _getDefaultHeaders() {
    return WebViewConfig.getDefaultHeaders();
  }

  /// 刷新页面
  void reload() {
    // 重置重试计数
    _retryCount = 0;
    errorMessage.value = null;
    // 立即重置进度
    isLoading.value = true;
    loadingProgress.value = 0.0;
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

    // 使用工具类判断是否应该忽略该错误
    if (WebViewErrorHandler.shouldIgnoreError(error)) {
      return;
    }

    // 显示错误
    final errorCode = error.errorCode;
    if (errorCode < 0 && errorCode >= -20) {
      isLoading.value = false;
      errorMessage.value = WebViewErrorHandler.formatErrorMessage(error);

      // 尝试自动重试
      _tryAutoRetry(error);
    }
  }

  /// 尝试自动重试
  void _tryAutoRetry(WebResourceError error) {
    // 如果没有配置重试策略，不自动重试
    if (retryStrategy == null) {
      return;
    }

    // 判断是否应该重试
    if (!WebViewErrorHandler.shouldRetry(error)) {
      return;
    }

    // 检查重试次数
    if (_retryCount >= retryStrategy!.maxRetries) {
      debugPrint('WebView: 已达到最大重试次数 ${retryStrategy!.maxRetries}');
      return;
    }

    // 增加重试次数
    _retryCount++;

    // 延迟重试
    final delay = retryStrategy!.getRetryDelay(_retryCount);
    debugPrint('WebView: 将在 ${delay.inSeconds} 秒后自动重试（第 $_retryCount 次）');

    Future.delayed(delay, () {
      if (isLoading.value == false && errorMessage.value != null) {
        debugPrint('WebView: 开始自动重试...');
        reload();
      }
    });
  }

  /// 处理导航请求
  NavigationDecision handleNavigationRequest(NavigationRequest request) {
    // 1. 检查 URL 白名单/黑名单
    if (!WebViewConfig.isUrlAllowed(request.url)) {
      debugPrint('WebView: URL 被禁止访问 - ${request.url}');
      errorMessage.value = '该网站不在允许访问列表中';
      return NavigationDecision.prevent;
    }

    // 2. 使用工具类判断是否为特殊协议
    if (WebViewSchemeHandler.isSpecialScheme(request.url)) {
      final uri = Uri.parse(request.url);
      debugPrint('拦截特殊协议: ${uri.scheme}://${uri.host}${uri.path}');
      handleSpecialScheme(request.url, uri);
      return NavigationDecision.prevent;
    }

    // 3. 检查是否为下载链接（如果启用下载功能）
    if (WebViewConfig.enableFileDownload && _isDownloadLink(request.url)) {
      debugPrint('WebView: 检测到下载链接 - ${request.url}');
      _handleDownload(request.url);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  /// 判断是否为下载链接
  bool _isDownloadLink(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      
      // 常见的下载文件扩展名
      final downloadExtensions = [
        '.apk', '.ipa', '.exe', '.dmg', '.zip', '.rar', '.7z',
        '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
        '.mp4', '.avi', '.mov', '.mkv',
        '.mp3', '.wav', '.flac',
      ];

      return downloadExtensions.any((ext) => path.endsWith(ext));
    } catch (e) {
      return false;
    }
  }

  /// 处理文件下载
  Future<void> _handleDownload(String url) async {
    try {
      final context = Get.context;
      if (context == null) {
        debugPrint('WebView: 无法获取上下文，无法处理下载');
        return;
      }

      // TODO: 实现文件下载功能
      // 可以使用 url_launcher 打开下载链接，或者使用 dio 下载文件
      debugPrint('WebView: 开始下载文件 - $url');
      
      // 临时方案：使用 url_launcher 打开下载链接
      // 实际项目中可以集成文件下载管理器
      await UrlLauncherUtil.launchWebUrl(url);
    } catch (e) {
      debugPrint('WebView: 处理下载失败 - $e');
    }
  }

  /// 处理特殊协议
  Future<void> handleSpecialScheme(String url, Uri uri) async {
    await WebViewSchemeHandler.handleSpecialScheme(url, uri);
  }

  /// 清除缓存
  Future<void> clearCache({bool includeDiskFiles = true}) async {
    await WebViewCacheManager.clearCache(webViewController, includeDiskFiles: includeDiskFiles);
  }

  /// 清除 Cookies
  Future<void> clearCookies() async {
    await WebViewCacheManager.clearCookies();
  }

  /// 清除 LocalStorage
  Future<void> clearLocalStorage() async {
    await WebViewCacheManager.clearLocalStorage(webViewController);
  }

  /// 处理文件选择器（iOS）
  /// 
  /// 注意：此方法已实现，但 iOS 端的配置暂时注释，等待确认正确的 API
  /// 当 iOS 端 API 确认后，取消注释 iOS 配置代码即可使用
  // ignore: unused_element
  Future<List<String>> _handleFileSelectorIOS(dynamic fileSelectorParams) async {
    try {
      // 获取上下文
      final context = Get.context;
      if (context == null) {
        debugPrint('WebView FileSelector (iOS): 无法获取上下文');
        return [];
      }

      // 解析接受的文件类型和选择模式
      List<String> acceptTypes = [];
      bool allowMultiple = false;

      // 尝试从参数中获取信息
      try {
        if (fileSelectorParams is Map) {
          acceptTypes = (fileSelectorParams['acceptTypes'] as List?)?.cast<String>() ?? [];
          allowMultiple = fileSelectorParams['allowMultiple'] as bool? ?? 
                         fileSelectorParams['allowsMultipleSelection'] as bool? ?? false;
        } else {
          final paramsMap = fileSelectorParams as dynamic;
          try {
            acceptTypes = (paramsMap.acceptTypes as List?)?.cast<String>() ?? [];
            allowMultiple = paramsMap.allowMultiple as bool? ?? 
                           paramsMap.allowsMultipleSelection as bool? ?? false;
          } catch (e) {
            debugPrint('解析文件选择器参数失败，使用默认值: $e');
          }
        }
      } catch (e) {
        debugPrint('解析文件选择器参数失败: $e');
      }

      // 显示文件选择器
      final files = await WebViewFileChooser.showFileChooser(
        context: context,
        acceptTypes: acceptTypes.isEmpty ? null : acceptTypes,
        allowMultiple: allowMultiple,
      );

      if (files.isEmpty) {
        return [];
      }

      // 返回文件路径列表
      return files.map((file) => file.path).toList();
    } catch (e) {
      debugPrint('WebView FileSelector (iOS) 错误: $e');
      return [];
    }
  }

  /// 处理文件选择器（Android）
  Future<List<String>> _handleFileSelectorAndroid(dynamic fileSelectorParams) async {
    try {
      // 获取上下文
      final context = Get.context;
      if (context == null) {
        debugPrint('WebView FileSelector: 无法获取上下文');
        return [];
      }

      // 解析接受的文件类型和选择模式
      List<String> acceptTypes = [];
      bool allowMultiple = false;

      // 尝试从参数中获取信息
      // 注意：根据实际的 FileSelectorParams 结构来解析
      try {
        // 如果参数有 acceptTypes 属性
        if (fileSelectorParams is Map) {
          acceptTypes = (fileSelectorParams['acceptTypes'] as List?)?.cast<String>() ?? [];
          allowMultiple = fileSelectorParams['allowMultiple'] as bool? ?? false;
        } else {
          // 尝试通过反射或类型检查获取属性
          // 这里使用 try-catch 来处理不同的参数类型
          final paramsMap = fileSelectorParams as dynamic;
          try {
            acceptTypes = (paramsMap.acceptTypes as List?)?.cast<String>() ?? [];
            allowMultiple = paramsMap.allowMultiple as bool? ?? 
                           paramsMap.mode?.toString().contains('multiple') ?? false;
          } catch (e) {
            debugPrint('解析文件选择器参数失败，使用默认值: $e');
          }
        }
      } catch (e) {
        debugPrint('解析文件选择器参数失败: $e');
      }

      // 显示文件选择器
      final files = await WebViewFileChooser.showFileChooser(
        context: context,
        acceptTypes: acceptTypes.isEmpty ? null : acceptTypes,
        allowMultiple: allowMultiple,
      );

      if (files.isEmpty) {
        return [];
      }

      // 返回文件路径列表
      return files.map((file) => file.path).toList();
    } catch (e) {
      debugPrint('WebView FileSelector 错误: $e');
      return [];
    }
  }

  /// 处理平台权限请求（iOS）
  Future<dynamic> _handlePlatformPermissionRequestIOS(dynamic request) async {
    try {
      final context = Get.context;
      if (context == null) {
        debugPrint('WebView PlatformPermissionRequest (iOS): 无法获取上下文，拒绝权限');
        return _createPermissionResponse(request, false);
      }

      // 解析请求的权限资源
      List<dynamic> resources = [];
      try {
        if (request is Map) {
          resources = request['resources'] as List? ?? [];
        } else {
          final requestMap = request as dynamic;
          try {
            resources = (requestMap.resources as List?) ?? [];
          } catch (e) {
            debugPrint('解析权限请求资源失败: $e');
          }
        }
      } catch (e) {
        debugPrint('解析权限请求参数失败: $e');
      }

      debugPrint('WebView 请求平台权限 (iOS): $resources');

      // 根据资源类型映射到 Permission 对象
      final permissions = <ph.Permission>[];
      final permissionTypes = <String>[];

      for (final resource in resources) {
        final resourceStr = resource.toString().toLowerCase();
        if (resourceStr.contains('camera')) {
          permissions.add(ph.Permission.camera);
          permissionTypes.add('camera');
        } else if (resourceStr.contains('microphone') || resourceStr.contains('audio')) {
          permissions.add(ph.Permission.microphone);
          permissionTypes.add('microphone');
        } else if (resourceStr.contains('location')) {
          permissions.add(ph.Permission.locationWhenInUse);
          permissionTypes.add('location');
        } else {
          debugPrint('未知的平台权限资源类型: $resource');
        }
      }

      if (permissions.isEmpty) {
        debugPrint('无法识别的平台权限资源，拒绝权限');
        return _createPermissionResponse(request, false);
      }

      // 请求权限（iOS 不需要显示权限说明弹窗）
      bool allGranted = true;
      for (int i = 0; i < permissions.length; i++) {
        final permission = permissions[i];
        final permissionType = permissionTypes[i];

        // iOS 不显示权限说明弹窗，直接请求系统权限
        final granted = await PermissionUtil.request(
          permission,
          context: context,
          permissionType: permissionType,
          showExplanation: false, // iOS 不显示权限说明弹窗
        );

        if (!granted) {
          allGranted = false;
          debugPrint('平台权限请求被拒绝 (iOS): $permissionType');
        }
      }

      return _createPermissionResponse(request, allGranted);
    } catch (e) {
      debugPrint('WebView PlatformPermissionRequest (iOS) 错误: $e');
      return _createPermissionResponse(request, false);
    }
  }

  /// 处理平台权限请求（Android 的 setOnPlatformPermissionRequest）
  Future<dynamic> _handlePlatformPermissionRequest(dynamic request) async {
    try {
      final context = Get.context;
      if (context == null) {
        debugPrint('WebView PlatformPermissionRequest: 无法获取上下文，拒绝权限');
        return _createPermissionResponse(request, false);
      }

      // 解析请求的权限资源
      List<dynamic> resources = [];
      try {
        if (request is Map) {
          resources = request['resources'] as List? ?? [];
        } else {
          final requestMap = request as dynamic;
          try {
            resources = (requestMap.resources as List?) ?? [];
          } catch (e) {
            debugPrint('解析权限请求资源失败: $e');
          }
        }
      } catch (e) {
        debugPrint('解析权限请求参数失败: $e');
      }

      debugPrint('WebView 请求平台权限: $resources');

      // 根据资源类型映射到 Permission 对象
      final permissions = <ph.Permission>[];
      final permissionTypes = <String>[];

      for (final resource in resources) {
        final resourceStr = resource.toString().toLowerCase();
        if (resourceStr.contains('camera')) {
          permissions.add(ph.Permission.camera);
          permissionTypes.add('camera');
        } else if (resourceStr.contains('microphone') || resourceStr.contains('audio')) {
          permissions.add(ph.Permission.microphone);
          permissionTypes.add('microphone');
        } else if (resourceStr.contains('location')) {
          permissions.add(ph.Permission.locationWhenInUse);
          permissionTypes.add('location');
        } else {
          debugPrint('未知的平台权限资源类型: $resource');
        }
      }

      if (permissions.isEmpty) {
        debugPrint('无法识别的平台权限资源，拒绝权限');
        return _createPermissionResponse(request, false);
      }

      // 请求权限（Android 需要显示权限说明弹窗）
      bool allGranted = true;
      for (int i = 0; i < permissions.length; i++) {
        final permission = permissions[i];
        final permissionType = permissionTypes[i];

        // Android 需要显示权限说明弹窗
        final granted = await PermissionUtil.request(
          permission,
          context: context,
          permissionType: permissionType,
          showExplanation: true, // Android 显示权限说明（符合应用市场审核要求）
        );

        if (!granted) {
          allGranted = false;
          debugPrint('平台权限请求被拒绝: $permissionType');
        }
      }

      return _createPermissionResponse(request, allGranted);
    } catch (e) {
      debugPrint('WebView PlatformPermissionRequest 错误: $e');
      return _createPermissionResponse(request, false);
    }
  }

  /// 创建权限响应（根据实际 API 调整）
  dynamic _createPermissionResponse(dynamic request, bool granted) {
    try {
      // 尝试创建响应对象
      // 注意：这里需要根据实际的 API 来创建响应
      // 可能需要使用 PlatformPermissionResponse 或类似类型
      
      // 如果 request 有 resources 属性，尝试创建响应
      if (request is Map) {
        return {
          'resources': request['resources'],
          'action': granted ? 'grant' : 'deny',
        };
      } else {
        // 尝试通过动态属性创建
        final requestMap = request as dynamic;
        try {
          // 这里需要根据实际的 API 来创建响应对象
          // 暂时返回一个 Map，实际使用时可能需要返回特定类型
          return {
            'resources': requestMap.resources,
            'action': granted ? 'grant' : 'deny',
          };
        } catch (e) {
          debugPrint('创建权限响应失败: $e');
          // 返回一个简单的响应
          return granted;
        }
      }
    } catch (e) {
      debugPrint('创建权限响应错误: $e');
      return granted;
    }
  }
}
