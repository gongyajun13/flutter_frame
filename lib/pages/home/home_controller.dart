import 'package:get/get.dart';
import '../../app/routes/app_pages.dart';

/// 首页控制器
class HomeController extends GetxController {
  // 计数器（响应式）
  final counter = 0.obs;

  /// 演示项列表
  final List<DemoItem> demoItems = [
    DemoItem(
      title: '简化网络请求演示',
      route: Routes.SIMPLE_NETWORK_DEMO,
      icon: '🌐',
      description: '演示网络请求、API 调用',
    ),
    DemoItem(
      title: '屏幕适配演示',
      route: Routes.SCREEN_ADAPTATION_DEMO,
      icon: '📱',
      description: '演示 ScreenUtil 屏幕适配',
    ),
    DemoItem(
      title: 'GetX 工具演示',
      route: Routes.GETX_UTILS_DEMO,
      icon: '🛠️',
      description: 'SnackBar、Dialog 等工具',
    ),
    DemoItem(
      title: '缓存图片Widget演示',
      route: Routes.CACHED_IMAGE_DEMO,
      icon: '🖼️',
      description: '各种图片加载和缓存',
    ),
    DemoItem(
      title: '本地缓存工具演示',
      route: Routes.LOCAL_CACHE_DEMO,
      icon: '💾',
      description: 'SharedPreferences 封装',
    ),
    DemoItem(
      title: 'URL跳转工具演示',
      route: Routes.URL_LAUNCHER_DEMO,
      icon: '🔗',
      description: '各种 URL 跳转场景',
    ),
    DemoItem(
      title: '全屏 WebView 演示',
      route: Routes.FULLSCREEN_WEBVIEW_DEMO,
      icon: '🌍',
      description: 'WebView 加载和控制',
    ),
    DemoItem(
      title: 'WebView 桥接演示',
      route: Routes.WEBVIEW_BRIDGE_DEMO,
      icon: '🌉',
      description: 'H5 ↔ Flutter 双向通信',
    ),
    DemoItem(
      title: 'WebView MVVM 演示',
      route: Routes.WEBVIEW_MVVM_DEMO,
      icon: '🎯',
      description: 'MVVM 架构的 WebView',
    ),
    DemoItem(
      title: '图片处理工具演示',
      route: Routes.IMAGE_UTIL_DEMO,
      icon: '📸',
      description: '图片选择、裁剪、压缩、上传',
    ),
    DemoItem(
      title: '视频播放器演示',
      route: Routes.VIDEO_PLAYER_DEMO,
      icon: '🎬',
      description: '带缓存的视频播放器',
    ),
    DemoItem(
      title: 'DeepSeek AI 演示',
      route: Routes.DEEPSEEK_DEMO,
      icon: '🤖',
      description: 'AI聊天对话和代码生成',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // 初始化逻辑
  }

  @override
  void onReady() {
    super.onReady();
    // 页面准备完成后的逻辑
  }

  @override
  void onClose() {
    super.onClose();
    // 清理资源
  }

  /// 增加计数
  void incrementCounter() {
    counter.value++;
  }

  /// 重置计数
  void resetCounter() {
    counter.value = 0;
  }

  /// 导航到演示页面
  void navigateToDemo(String route) {
    Get.toNamed(route);
  }
}

/// 演示项数据模型
class DemoItem {
  final String title;
  final String route;
  final String icon;
  final String description;

  DemoItem({
    required this.title,
    required this.route,
    required this.icon,
    required this.description,
  });
}

