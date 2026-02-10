import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../app/controllers/theme_controller.dart';
import 'home_controller.dart';

/// 首页
class HomePage extends BasePage<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 同时监听 ThemeController 的变化，确保主题切换时页面自动更新
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return Scaffold(
          // appBar: buildAppBar(context),
          body: SafeArea(
            child: _buildBody(context),
          ),
          bottomNavigationBar: _buildBottomTabBar(),
          floatingActionButton: buildFloatingActionButton(context),
        );
      },
    );
  }

  /// 构建页面主体（从 BasePage 复制，因为需要重写 build 方法）
  Widget _buildBody(BuildContext context) {
    return Obx(() {
      final controller = this.controller;

      // 显示错误状态
      if (controller.hasError) {
        return _buildErrorWidget(context, controller.errorMessage.value!);
      }

      // 显示加载状态
      if (controller.isLoading.value) {
        return _buildLoadingWidget(context);
      }

      // 显示正常内容
      return buildContent(context);
    });
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

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // Tab 内容区域
        Expanded(
          child: Obx(() => IndexedStack(
                index: controller.currentTabIndex.value,
                children: [
                  _buildTabContent(controller.viewItems, showCounter: true),
                  _buildTabContent(controller.functionItems),
                  _buildTabContent(controller.toolItems),
                ],
              )),
        ),
      ],
    );
  }

  /// 构建底部 TabBar
  Widget _buildBottomTabBar() {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final isDark = themeController.isDarkTheme;
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppDesignTokens.surfaceColor
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 8.h,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final tabWidth = screenWidth / 3;
                  
                  return Stack(
                    children: [
                      // 滑块背景
                      _buildSliderIndicator(tabWidth),
                      // Tab 按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBottomTabButton('视图', Icons.grid_view_rounded, 0),
                          _buildBottomTabButton('功能', Icons.account_balance_sharp, 1),
                          _buildBottomTabButton('工具', Icons.build_circle_rounded, 2),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建滑块指示器
  Widget _buildSliderIndicator(double tabWidth) {
    return Obx(() {
      final currentIndex = controller.currentTabIndex.value;
      
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        left: currentIndex * tabWidth + 4.w,
        // 调整上下间距，让滑块更高一些
        top: 4.h,
        bottom: 4.h,
        width: tabWidth - 8.w,
        child: Container(
          decoration: BoxDecoration(
            color: AppDesignTokens.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
          ),
        ),
      );
    });
  }

  /// 构建底部 Tab 按钮
  Widget _buildBottomTabButton(String text, IconData icon, int index) {
    return Obx(() {
      final isSelected = controller.currentTabIndex.value == index;
      final badgeCount = controller.tabBadgeCounts[index];
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => controller.switchTab(index),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 60,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 4.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 26.w,
                      color: isSelected
                          ? AppDesignTokens.primaryColor
                          : AppDesignTokens.textSecondary,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right:-12.w,
                        top: -8.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: badgeCount > 99 ? 4.w : 5.w,
                            vertical: 2.h,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected
                        ? AppDesignTokens.fontWeightSemiBold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppDesignTokens.primaryColor
                        : AppDesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 构建 Tab 内容
  Widget _buildTabContent(List<DemoItem> items, {bool showCounter = false}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 演示列表
          _buildDemoList(items),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }



  /// 构建演示列表
  Widget _buildDemoList(List<DemoItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12.h : 0),
            child: _buildDemoCard(item),
          );
        }),
      ],
    );
  }

  /// 构建演示卡片
  Widget _buildDemoCard(DemoItem item) {
    return AppCard(
      onTap: () => controller.navigateToDemo(item.route),
      showShadow: true,
      borderRadius: AppDesignTokens.radius16,
      padding: EdgeInsets.all(AppDesignTokens.spacing16),
      child: Row(
        children: [
          // 图标容器
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppDesignTokens.primaryColor.withOpacity(0.15),
                  AppDesignTokens.secondaryColor.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
            ),
            child: Center(
              child: Text(
                item.icon,
                style: TextStyle(fontSize: 28.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // 文字信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppDesignTokens.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // 箭头
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18.w,
            color: AppDesignTokens.textDisabled,
          ),
        ],
      ),
    );
  }
}

