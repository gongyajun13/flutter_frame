import 'package:get/get.dart';
import '../../pages/home/home_page.dart';
import '../../pages/home/home_binding.dart';
import '../../pages/simple_network_demo/simple_network_demo_page.dart';
import '../../pages/simple_network_demo/simple_network_demo_binding.dart';
import '../../pages/screen_adaptation_demo/screen_adaptation_demo_page.dart';
import '../../pages/screen_adaptation_demo/screen_adaptation_demo_binding.dart';
import '../../pages/getx_utils_demo/getx_utils_demo_page.dart';
import '../../pages/getx_utils_demo/getx_utils_demo_binding.dart';
import '../../pages/cached_image_demo/cached_image_demo_page.dart';
import '../../pages/cached_image_demo/cached_image_demo_binding.dart';
import '../../pages/local_cache_demo/local_cache_demo_page.dart';
import '../../pages/local_cache_demo/local_cache_demo_binding.dart';
import '../../pages/url_launcher_demo/url_launcher_demo_page.dart';
import '../../pages/url_launcher_demo/url_launcher_demo_binding.dart';
import '../../pages/fullscreen_webview_demo/fullscreen_webview_demo_page.dart';
import '../../pages/fullscreen_webview_demo/fullscreen_webview_demo_binding.dart';
import '../../pages/webview_bridge_demo/webview_bridge_demo_page.dart';
import '../../pages/webview_bridge_demo/webview_bridge_demo_binding.dart';
import '../../pages/custom_dialog_demo/custom_dialog_demo_page.dart';
import '../../pages/custom_dialog_demo/custom_dialog_demo_binding.dart';
import '../../pages/webview_mvvm_demo/webview_mvvm_demo_page.dart';
import '../../pages/webview_mvvm_demo/webview_mvvm_demo_binding.dart';
import '../../pages/webview_mvvm_demo/webview_mvvm_page.dart';
import '../../pages/webview_mvvm_demo/webview_mvvm_binding.dart';
import '../../pages/image_util_demo/image_util_demo_view.dart';
import '../../pages/image_util_demo/image_util_demo_binding.dart';
import '../../pages/video_player_demo/video_player_demo_page.dart';
import '../../pages/deepseek_demo/deepseek_demo_view.dart';
import '../../pages/deepseek_demo/deepseek_demo_binding.dart';

part 'app_routes.dart';

/// 应用路由配置
class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    // 首页
    GetPage(
      name: _Paths.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    
    // 简单网络请求演示
    GetPage(
      name: _Paths.SIMPLE_NETWORK_DEMO,
      page: () => const SimpleNetworkDemoPage(),
      binding: SimpleNetworkDemoBinding(),
    ),
    
    // 屏幕适配演示
    GetPage(
      name: _Paths.SCREEN_ADAPTATION_DEMO,
      page: () => const ScreenAdaptationDemoPage(),
      binding: ScreenAdaptationDemoBinding(),
    ),
    
    // GetX 工具演示
    GetPage(
      name: _Paths.GETX_UTILS_DEMO,
      page: () => const GetXUtilsDemoPage(),
      binding: GetXUtilsDemoBinding(),
    ),
    
    // 缓存图片演示
    GetPage(
      name: _Paths.CACHED_IMAGE_DEMO,
      page: () => const CachedImageDemoPage(),
      binding: CachedImageDemoBinding(),
    ),
    
    // 本地缓存演示
    GetPage(
      name: _Paths.LOCAL_CACHE_DEMO,
      page: () => const LocalCacheDemoPage(),
      binding: LocalCacheDemoBinding(),
    ),
    
    // URL 跳转演示
    GetPage(
      name: _Paths.URL_LAUNCHER_DEMO,
      page: () => const UrlLauncherDemoPage(),
      binding: UrlLauncherDemoBinding(),
    ),
    
    // 全屏 WebView 演示
    GetPage(
      name: _Paths.FULLSCREEN_WEBVIEW_DEMO,
      page: () => const FullScreenWebViewDemoPage(),
      binding: FullScreenWebViewDemoBinding(),
    ),
    
    // WebView 桥接演示
    GetPage(
      name: _Paths.WEBVIEW_BRIDGE_DEMO,
      page: () => const WebViewBridgeDemoPage(),
      binding: WebViewBridgeDemoBinding(),
    ),
    
    // 自定义对话框演示
    GetPage(
      name: _Paths.CUSTOM_DIALOG_DEMO,
      page: () => const CustomDialogDemoPage(),
      binding: CustomDialogDemoBinding(),
    ),
    
    // WebView MVVM 演示入口
    GetPage(
      name: _Paths.WEBVIEW_MVVM_DEMO,
      page: () => const WebViewMvvmDemoPage(),
      binding: WebViewMvvmDemoBinding(),
    ),
    
    // WebView MVVM 页面
    GetPage(
      name: _Paths.WEBVIEW_MVVM,
      page: () => const WebViewMvvmPage(),
      binding: WebViewMvvmBinding(),
    ),
    
    // 图片处理工具演示
    GetPage(
      name: _Paths.IMAGE_UTIL_DEMO,
      page: () => const ImageUtilDemoView(),
      binding: ImageUtilDemoBinding(),
    ),

    // 视频播放器演示
    GetPage(
      name: _Paths.VIDEO_PLAYER_DEMO,
      page: () => const VideoPlayerDemoPage(),
    ),

    // DeepSeek API 演示
    GetPage(
      name: _Paths.DEEPSEEK_DEMO,
      page: () => const DeepSeekDemoView(),
      binding: DeepSeekDemoBinding(),
    ),

  ];
}

