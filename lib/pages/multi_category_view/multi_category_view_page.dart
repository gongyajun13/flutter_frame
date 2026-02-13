import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import 'multi_category_view_controller.dart';

/// 多分类数据视图页面
/// 顶部主分类 Tab 可横向滑动，内容区可左右滑动并与 Tab 联动
/// 使用每个 Tab 自身的 RefreshIndicator，避免与多 Tab 手势冲突
class MultiCategoryViewPage extends BasePage<MultiCategoryViewController> {
  const MultiCategoryViewPage({super.key});

  @override
  String? get pageTitle => '多分类数据视图';

  /// 自定义 AppBar，右侧增加「管理 Tab」操作按钮
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    if (!showAppBar || pageTitle == null) return null;

    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(
          fontSize: AppDesignTokens.fontSize18,
          fontWeight: FontWeight.w600,
          color: AppDesignTokens.textPrimary,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppDesignTokens.surfaceColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 12.w),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppDesignTokens.surfaceVariantColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.tune_outlined,
                size: 20.w,
                color: AppDesignTokens.textSecondary,
              ),
            ),
            tooltip: '管理分类 Tab',
            onPressed: () => _showTabActionsSheet(context),
            splashRadius: 24.r,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      final tabs = controller.categoryTabs;
      return _ScrollableTabContent(
        categoryTabs: tabs.toList(growable: false),
        buildContentForIndex: _buildContentForIndex,
        onTabVisible: (index) => controller.onTabVisible(index),
      );
    });
  }

  /// 根据索引构建对应 Tab 的内容（可扩展为真实列表等）
  Widget _buildContentForIndex(BuildContext context, int index) {
    final tabs = controller.categoryTabs;
    if (index < 0 || index >= tabs.length) return const SizedBox.shrink();
    final tab = tabs[index];
    final color = _colorForIndex(index);
    // 使用 RefreshIndicator 包裹每个 Tab 的内部 ScrollView，
    // 这样当前 Tab 的任意垂直下拉都更容易触发刷新，
    // 同时不会影响左右滑动切换 Tab。
    return RefreshIndicator(
      onRefresh: () => controller.refreshTabData(tab.id),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Center(
                  child: _CategoryTabContent(
                    icon: tab.icon,
                    title: tab.name,
                    subtitle: '此处可展示「${tab.name}」分类下的数据，左右滑动可切换，'
                        '已加载后再次切换不会自动刷新，请下拉手动刷新',
                    color: color,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Color _colorForIndex(int index) {
    final colors = [
      AppDesignTokens.primaryColor,
      AppDesignTokens.warningColor,
      AppDesignTokens.errorColor,
      AppDesignTokens.infoColor,
      AppDesignTokens.successColor,
      AppDesignTokens.secondaryColor,
      AppDesignTokens.primaryColor,
    ];
    return colors[index % colors.length];
  }

  /// 标题栏右侧按钮：弹出操作面板，用于新增/删除 Tab
  void _showTabActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppDesignTokens.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部指示器
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppDesignTokens.surfaceVariantColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
              
                  SizedBox(height: 16.h),
                  // 标题和关闭按钮
                  Row(
                    children: [
                      Text(
                        '管理分类 Tab',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppDesignTokens.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: AppDesignTokens.surfaceVariantColor,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18.w,
                            color: AppDesignTokens.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Tab 列表
                  Obx(() {
                    final tabs = controller.categoryTabs;
                    return Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 320.h,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: tabs.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (ctx, index) {
                            final tab = tabs[index];
                            final canDelete = tabs.length > 1;
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: AppDesignTokens.surfaceVariantColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      color: AppDesignTokens.surfaceColor,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Center(
                                      child: Icon(tab.icon, color: AppDesignTokens.textSecondary),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tab.name,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppDesignTokens.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'ID: ${tab.id}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppDesignTokens.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: canDelete
                                          ? AppDesignTokens.errorColor
                                          : AppDesignTokens.textDisabled,
                                      size: 20.w,
                                    ),
                                    onPressed: canDelete
                                        ? () => controller.removeCategoryTabAt(index)
                                        : null,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48.h,
                          child: OutlinedButton.icon(
                            icon: Icon(
                              Icons.add,
                              size: 16.w,
                              color: AppDesignTokens.primaryColor,
                            ),
                            label: Text(
                              '新增 Tab',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppDesignTokens.primaryColor,
                              ),
                            ),
                            onPressed: _handleAddTab,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppDesignTokens.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(() {
                          final tabs = controller.categoryTabs;
                          final canDelete = tabs.length > 1;
                          return Container(
                            height: 48.h,
                            child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.remove,
                                size: 16.w,
                                color: canDelete
                                    ? AppDesignTokens.errorColor
                                    : AppDesignTokens.textDisabled,
                              ),
                              label: Text(
                                '删除最后一个',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: canDelete
                                      ? AppDesignTokens.errorColor
                                      : AppDesignTokens.textDisabled,
                                ),
                              ),
                              onPressed: canDelete
                                  ? () => controller.removeCategoryTabAt(tabs.length - 1)
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: canDelete
                                      ? AppDesignTokens.errorColor
                                      : AppDesignTokens.textDisabled,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 简单示例：按当前数量生成一个「自定义X」Tab
  void _handleAddTab() {
    final tabs = controller.categoryTabs;
    final index = tabs.length + 1;
    controller.addCategoryTab(
      CategoryTab(
        id: 'custom_$index',
        name: '自定义$index',
        icon: Icons.label_outline,
      ),
    );
  }
}

/// 可滑动 Tab + 可左右滑动内容区，由 TabController 联动
class _ScrollableTabContent extends StatefulWidget {
  final List<CategoryTab> categoryTabs;
  final Widget Function(BuildContext context, int index) buildContentForIndex;
  final ValueChanged<int> onTabVisible;

  const _ScrollableTabContent({
    required this.categoryTabs,
    required this.buildContentForIndex,
    required this.onTabVisible,
  });

  @override
  State<_ScrollableTabContent> createState() => _ScrollableTabContentState();
}

class _ScrollableTabContentState extends State<_ScrollableTabContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  // 添加ScrollController来控制TabBar的滚动
  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.categoryTabs.length,
      vsync: this,
    );
    _currentIndex = _tabController.index;
    // 添加监听，使用动画控制器的动画值变化来实时更新选中状态
    _tabController.animation?.addListener(_handleAnimationChange);
    _tabController.addListener(_handleTabChange);
    // 首次进入时，为默认选中的 Tab 触发一次懒加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTabVisible(_currentIndex);
    });
  }

  @override
  void dispose() {
    _tabController.animation?.removeListener(_handleAnimationChange);
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ScrollableTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryTabs.length != widget.categoryTabs.length &&
        widget.categoryTabs.isNotEmpty) {
      final previousIndex = _tabController.index;
      _tabController.animation?.removeListener(_handleAnimationChange);
      _tabController.removeListener(_handleTabChange);
      _tabController.dispose();
      _tabController = TabController(
        length: widget.categoryTabs.length,
        vsync: this,
      );
      final newIndex = previousIndex.clamp(0, widget.categoryTabs.length - 1);
      _tabController.index = newIndex;
      _currentIndex = newIndex;
      _tabController.animation?.addListener(_handleAnimationChange);
      _tabController.addListener(_handleTabChange);
      // 长度变化后，对当前可见 Tab 再触发一次可见回调（比如删除前面 Tab）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTabVisible(_currentIndex);
      });
    }
  }

  // 监听动画值变化，实时更新选中状态
  void _handleAnimationChange() {
    if (_tabController.animation == null) return;
    final animatedIndex = _tabController.animation!.value.round();
    if (animatedIndex != _currentIndex) {
      setState(() {
        _currentIndex = animatedIndex;
      });
      // 当滑动内容区域切换tab时，也要触发tab bar自动滚动
      _scrollToSelectedTab();
    }
  }

  void _handleTabChange() {
    if (_tabController.index == _currentIndex) return;
    setState(() {
      _currentIndex = _tabController.index;
    });
    // 触发TabBar自动滚动，确保当前选中的Tab可见
    _scrollToSelectedTab();
    widget.onTabVisible(_currentIndex);
  }

  // 滚动到选中的Tab，确保可见
  void _scrollToSelectedTab() {
    // 计算每个Tab的大致宽度（包含margin）
    const double tabWidth = 120; // 估计值，可根据实际情况调整
    final double scrollPosition = _currentIndex * tabWidth;
    
    // 滚动到选中的Tab，使其位于屏幕中间偏左位置
    _tabScrollController.animateTo(
      scrollPosition - 80, // 偏移量，可根据实际情况调整
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildScrollableTabBar(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            // 使用ClampingScrollPhysics，减少滑动惯性，使Tab切换更及时
            physics: const ClampingScrollPhysics(),
            children: List.generate(
              widget.categoryTabs.length,
              (index) => widget.buildContentForIndex(context, index),
            ),
          ),
        ),
      ],
    );
  }

  /// 顶部可横向滑动的 TabBar
  Widget _buildScrollableTabBar(BuildContext context) {
    return Container(
      color: AppDesignTokens.surfaceColor,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48.h,
          child: ListView.builder(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.categoryTabs.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (context, index) {
              final tab = widget.categoryTabs[index];
              final isSelected = _currentIndex == index;
              
              return GestureDetector(
                  onTap: () {
                    // 立即更新状态，给予即时视觉反馈
                    setState(() {
                      _currentIndex = index;
                    });
                    // 触发TabBar自动滚动，确保当前选中的Tab可见
                    _scrollToSelectedTab();
                    // 立即触发可见回调
                    widget.onTabVisible(index);
                    // 使用较短的动画时长，减少切换延迟
                    _tabController.animateTo(index, duration: Duration(milliseconds: 200));
                  },
                  // 添加按下效果，增强交互反馈
                  onTapDown: (_) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppDesignTokens.primaryColor,
                                AppDesignTokens.primaryDark,
                              ],
                            )
                          : null,
                      color: isSelected ? null : AppDesignTokens.surfaceVariantColor,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppDesignTokens.primaryColor.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 18.w,
                          color: isSelected ? Colors.white : AppDesignTokens.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          tab.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            letterSpacing: 0.3,
                            color: isSelected ? Colors.white : AppDesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      ),
    );
  }
}

/// 单个 Tab 的内容占位（可替换为真实列表/网格等）
class _CategoryTabContent extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _CategoryTabContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  State<_CategoryTabContent> createState() => _CategoryTabContentState();
}

class _CategoryTabContentState extends State<_CategoryTabContent> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    // 延迟启动动画，使效果更加自然
    Future.delayed(Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withOpacity(0.2),
                  widget.color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 48.w,
                color: widget.color,
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _opacityAnimation.value) * 20),
                child: child,
              ),
            );
          },
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppDesignTokens.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _opacityAnimation.value) * 20),
                child: child,
              ),
            );
          },
          child: Container(
            width: 280.w,
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppDesignTokens.textSecondary,
                height: 1.5,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppDesignTokens.surfaceVariantColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '下拉刷新查看最新内容',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppDesignTokens.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
