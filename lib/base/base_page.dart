import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import '../theme/app_design_tokens.dart';
import '../app/controllers/theme_controller.dart';
import 'base_controller.dart';
import '../utils/performance_monitor.dart';

/// 页面基类
/// 提供通用的页面布局、错误处理、加载状态显示等功能
abstract class BasePage<T extends BaseController> extends GetView<T> {
  const BasePage({super.key});

  /// 页面标题
  String? get pageTitle => null;

  /// 是否显示 AppBar
  bool get showAppBar => true;

  /// AppBar 配置
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    if (!showAppBar || pageTitle == null) return null;

    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      centerTitle: true,
    );
  }

  /// 构建页面内容
  Widget buildContent(BuildContext context);

  /// 构建浮动操作按钮（可选，子类可重写）
  Widget? buildFloatingActionButton(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    // 同时监听 ThemeController 的变化，确保主题切换时页面自动更新
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return Scaffold(
          appBar: buildAppBar(context),
          body: SafeArea(
            child: _buildBody(context),
          ),
          floatingActionButton: buildFloatingActionButton(context),
        );
      },
    );
  }

  /// 构建页面主体
  Widget _buildBody(BuildContext context) {
    final pageName = pageTitle ?? Get.currentRoute;
    return _PageOpenPerfWrapper(
      pageName: pageName,
      childBuilder: (ctx) {
        return Obx(() {
          final controller = this.controller;

          // 显示错误状态
          if (controller.hasError) {
            return _buildErrorWidget(ctx, controller.errorMessage.value!);
          }

          // 显示加载状态
          if (controller.isLoading.value) {
            return _buildLoadingWidget(ctx);
          }

          // 显示正常内容
          return buildContent(ctx);
        });
      },
    );
  }

  /// 构建加载状态 Widget
  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppDesignTokens.spacingV16),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态 Widget
  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppDesignTokens.iconSizeXLarge,
              color: AppDesignTokens.errorColor,
            ),
            SizedBox(height: AppDesignTokens.spacingV16),
            Text(
              '出错了',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize18,
                fontWeight: AppDesignTokens.fontWeightBold,
                color: AppDesignTokens.textPrimary,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingV8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDesignTokens.spacingV24),
            ElevatedButton(
              onPressed: () {
                controller.clearError();
                controller.onReady();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 页面首帧耗时统计包装组件
class _PageOpenPerfWrapper extends StatefulWidget {
  final String pageName;
  final WidgetBuilder childBuilder;

  const _PageOpenPerfWrapper({
    required this.pageName,
    required this.childBuilder,
  });

  @override
  State<_PageOpenPerfWrapper> createState() => _PageOpenPerfWrapperState();
}

class _PageOpenPerfWrapperState extends State<_PageOpenPerfWrapper> {
  late final DateTime _startTime;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    // 新页面会话开始：后续 FPS/Jank 统计将代表该页面
    PerformanceMonitor.instance.startPageSession(widget.pageName);
  }

  @override
  Widget build(BuildContext context) {
    if (!_reported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_reported) return;
        _reported = true;
        final duration = DateTime.now().difference(_startTime);
        PerformanceMonitor.instance.recordPageOpen(widget.pageName, duration);
      });
    }
    return widget.childBuilder(context);
  }
}

/// 带滚动视图的页面基类
abstract class BaseScrollPage<T extends BaseController> extends BasePage<T> {
  const BaseScrollPage({super.key});

  /// 页面内边距
  EdgeInsets get pagePadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: pagePadding,
      child: buildScrollContent(context),
    );
  }

  /// 构建滚动内容
  Widget buildScrollContent(BuildContext context);
}

/// 带列表的页面基类
abstract class BaseListPage<T extends BaseController, I> extends BasePage<T> {
  const BaseListPage({super.key});

  /// 列表数据
  List<I> get items;

  /// 构建列表项
  Widget buildListItem(BuildContext context, I item, int index);

  /// 列表项间距
  double get itemSpacing => AppDesignTokens.spacingV12;

  /// 列表内边距
  EdgeInsets get listPadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildContent(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyWidget(context);
    }

    return ListView.separated(
      padding: listPadding,
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        return buildListItem(context, items[index], index);
      },
    );
  }

  /// 构建空状态 Widget
  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: AppDesignTokens.iconSizeXLarge,
            color: AppDesignTokens.textDisabled,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
