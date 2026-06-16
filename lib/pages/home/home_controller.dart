import 'package:get/get.dart';
import '../../app/routes/app_pages.dart';
import '../../base/base_controller.dart';
import '../../database/app_database.dart';
import '../../utils/app_logger.dart';

/// 首页控制器
class HomeController extends BaseController {
  // 计数器（响应式）
  final counter = 0.obs;

  // 当前选中的 Tab 索引（0: 视图, 1: 功能, 2: 工具）
  final currentTabIndex = 0.obs;

  /// 每个 Tab 的红点数量（>0 显示红点）
  /// 索引：0-视图，1-功能，2-工具
  final RxList<int> tabBadgeCounts = <int>[5, 100, 99].obs;

  /// 切换 Tab
  void switchTab(int index) {
    if (index >= 0 && index < 3) {
      currentTabIndex.value = index;
    }
  }

  /// 视图类演示项列表
  final List<DemoItem> viewItems = [
    DemoItem(
      title: '屏幕适配演示',
      route: Routes.SCREEN_ADAPTATION_DEMO,
      icon: '📱',
      description: '演示 ScreenUtil 屏幕适配',
    ),
    DemoItem(
      title: '缓存图片Widget演示',
      route: Routes.CACHED_IMAGE_DEMO,
      icon: '🖼️',
      description: '各种图片加载和缓存',
    ),
    DemoItem(
      title: '数据列表演示',
      route: Routes.LIST_DEMO,
      icon: '📋',
      description: '线性、网格、瀑布流三种布局样式动态切换',
    ),
    DemoItem(
      title: '多分类数据视图',
      route: Routes.MULTI_CATEGORY_VIEW,
      icon: '📑',
      description: '顶部主分类 Tab，每个 Tab 对应不同内容界面',
    ),
    DemoItem(
      title: '选择器 UI 组件',
      route: Routes.SELECTOR_DEMO,
      icon: '✅',
      description: '日期选择、时间选择、文件选择等通用选择器交互示例',
    ),
    DemoItem(
      title: '主题设置',
      route: Routes.THEME_SELECTOR,
      icon: '🎨',
      description: '应用主题切换和自定义',
    ),
  ];

  /// 功能类演示项列表
  final List<DemoItem> functionItems = [
    DemoItem(
      title: '简化网络请求演示',
      route: Routes.SIMPLE_NETWORK_DEMO,
      icon: '🌐',
      description: '演示网络请求、API 调用',
    ),
    DemoItem(
      title: 'WebView 功能演示',
      route: Routes.WEBVIEW_DEMO,
      icon: '🌐',
      description: 'WebView 浏览、桥接、MVVM 架构等完整功能',
    ),
    DemoItem(
      title: '图片处理工具演示',
      route: Routes.IMAGE_UTIL_DEMO,
      icon: '📸',
      description: '图片选择、裁剪、压缩、上传',
    ),
    DemoItem(
      title: '拼豆创作',
      route: Routes.PIXELIZE_DEMO,
      icon: '🎨',
      description: '空白画布自由创作，或图片生成像素图',
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
    DemoItem(
      title: '国际化演示',
      route: Routes.I18N_DEMO,
      icon: '🌍',
      description: '多语言支持、语言切换、国际化文本',
    ),
  ];

  /// 工具类演示项列表
  final List<DemoItem> toolItems = [
    DemoItem(
      title: '提示弹窗工具',
      route: Routes.GETX_UTILS_DEMO,
      icon: '🔔',
      description: 'Toast、SnackBar、Dialog 等提示弹窗工具',
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
      title: '权限请求工具演示',
      route: Routes.PERMISSION_DEMO,
      icon: '🔐',
      description: '各种权限请求和状态检查',
    ),
    DemoItem(
      title: '数据库演示',
      route: Routes.DATABASE_DEMO,
      icon: '💾',
      description: 'sqflite 数据库操作、Repository 模式',
    ),
    DemoItem(
      title: '错误监控演示',
      route: Routes.ERROR_MONITOR_DEMO,
      icon: '🚨',
      description: '全局错误捕获、错误上报、错误分析',
    ),
    DemoItem(
      title: '文件下载演示',
      route: Routes.FILE_DOWNLOAD_DEMO,
      icon: '⬇️',
      description: '文件下载、进度显示、下载管理',
    ),
  ];

  /// 获取当前 Tab 的演示项列表
  List<DemoItem> get currentTabItems {
    switch (currentTabIndex.value) {
      case 0:
        return viewItems;
      case 1:
        return functionItems;
      case 2:
        return toolItems;
      default:
        return viewItems;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // 延迟初始化数据库（提升启动速度）
    _initDatabaseAsync();
  }

  /// 异步初始化数据库（不阻塞 UI）
  Future<void> _initDatabaseAsync() async {
    try {
      await AppDatabase.instance.database;
      AppLogger.d('数据库初始化完成', tag: 'Startup');
    } catch (e, stackTrace) {
      AppLogger.e('数据库初始化失败', error: e, stackTrace: stackTrace, tag: 'Startup');
    }
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
    navigateTo(route);
  }

  /// 设置指定 Tab 的红点数量
  void setTabBadgeCount(int index, int count) {
    if (index < 0 || index >= tabBadgeCounts.length) return;
    tabBadgeCounts[index] = count < 0 ? 0 : count;
    tabBadgeCounts.refresh();
  }

  /// 清除指定 Tab 的红点
  void clearTabBadge(int index) {
    setTabBadgeCount(index, 0);
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

