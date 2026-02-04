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
import '../../pages/custom_dialog_demo/custom_dialog_demo_page.dart';
import '../../pages/custom_dialog_demo/custom_dialog_demo_binding.dart';
import '../../pages/selector_demo/selector_demo_page.dart';
import '../../pages/selector_demo/selector_demo_binding.dart';
import '../../pages/image_util_demo/image_util_demo_view.dart';
import '../../pages/image_util_demo/image_util_demo_binding.dart';
import '../../pages/video_player_demo/video_player_demo_page.dart';
import '../../pages/video_player_demo/video_player_demo_binding.dart';
import '../../pages/deepseek_demo/deepseek_demo_view.dart';
import '../../pages/deepseek_demo/deepseek_demo_binding.dart';
import '../../pages/permission_demo/permission_demo_page.dart';
import '../../pages/permission_demo/permission_demo_binding.dart';
import '../../pages/webview_demo/webview_demo_page.dart';
import '../../pages/webview_demo/webview_demo_binding.dart';
import '../../pages/list_demo/list_demo_page.dart';
import '../../pages/list_demo/list_demo_binding.dart';
import '../../pages/database_demo/database_demo_page.dart';
import '../../pages/database_demo/database_demo_binding.dart';
import '../../pages/error_monitor_demo/error_monitor_demo_page.dart';
import '../../pages/error_monitor_demo/error_monitor_demo_binding.dart';
import '../../pages/file_download_demo/file_download_demo_page.dart';
import '../../pages/file_download_demo/file_download_demo_binding.dart';
import '../../app/widgets/theme_selector_widget.dart';

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
    
    // 选择器 UI 组件演示
    GetPage(
      name: _Paths.SELECTOR_DEMO,
      page: () => const SelectorDemoPage(),
      binding: SelectorDemoBinding(),
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
    
    // 自定义对话框演示
    GetPage(
      name: _Paths.CUSTOM_DIALOG_DEMO,
      page: () => const CustomDialogDemoPage(),
      binding: CustomDialogDemoBinding(),
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
      binding: VideoPlayerDemoBinding(),
    ),

    // DeepSeek API 演示
    GetPage(
      name: _Paths.DEEPSEEK_DEMO,
      page: () => const DeepSeekDemoView(),
      binding: DeepSeekDemoBinding(),
    ),

    // 主题选择器
    GetPage(
      name: _Paths.THEME_SELECTOR,
      page: () => const ThemeSelectorPage(),
    ),

    // 权限请求工具演示
    GetPage(
      name: _Paths.PERMISSION_DEMO,
      page: () => const PermissionDemoPage(),
      binding: PermissionDemoBinding(),
    ),

    // WebView 功能演示（整合版）
    GetPage(
      name: _Paths.WEBVIEW_DEMO,
      page: () => const WebViewDemoPage(),
      binding: WebViewDemoBinding(),
    ),

    // 数据列表演示
    GetPage(
      name: _Paths.LIST_DEMO,
      page: () => const ListDemoPage(),
      binding: ListDemoBinding(),
    ),

    // 数据库演示
    GetPage(
      name: _Paths.DATABASE_DEMO,
      page: () => const DatabaseDemoPage(),
      binding: DatabaseDemoBinding(),
    ),

    // 错误监控演示
    GetPage(
      name: _Paths.ERROR_MONITOR_DEMO,
      page: () => const ErrorMonitorDemoPage(),
      binding: ErrorMonitorDemoBinding(),
    ),

    // 文件下载演示
    GetPage(
      name: _Paths.FILE_DOWNLOAD_DEMO,
      page: () => const FileDownloadDemoPage(),
      binding: FileDownloadDemoBinding(),
    ),


  ];
}

