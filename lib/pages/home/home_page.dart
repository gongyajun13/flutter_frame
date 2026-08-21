import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../app/controllers/theme_controller.dart';
import 'home_controller.dart';
import 'widgets/home_bottom_tab_bar.dart';
import 'widgets/home_tab_content.dart';

/// 首页
class HomePage extends BasePage<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 同时监听 ThemeController 的变化，确保主题切换时页面自动更新
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return Scaffold(
          backgroundColor: AppDesignTokens.backgroundColor,
          body: SafeArea(
            bottom: false,
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
                  HomeTabContent(
                    meta: HomeTabContent.metas[0],
                    items: controller.viewItems,
                    onItemTap: controller.navigateToDemo,
                  ),
                  HomeTabContent(
                    meta: HomeTabContent.metas[1],
                    items: controller.functionItems,
                    onItemTap: controller.navigateToDemo,
                  ),
                  HomeTabContent(
                    meta: HomeTabContent.metas[2],
                    items: controller.toolItems,
                    onItemTap: controller.navigateToDemo,
                  ),
                ],
              )),
        ),
      ],
    );
  }

  /// 构建底部 TabBar
  Widget _buildBottomTabBar() {
    return Obx(
      () => HomeBottomTabBar(
        currentIndex: controller.currentTabIndex.value,
        onTabSelected: controller.switchTab,
        badgeCounts: controller.tabBadgeCounts,
      ),
    );
  }

}

