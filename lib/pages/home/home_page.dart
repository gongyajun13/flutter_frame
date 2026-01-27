import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'home_controller.dart';

/// 首页
class HomePage extends BaseScrollPage<HomeController> {
  const HomePage({super.key});

  @override
  String? get pageTitle => '功能演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppDesignTokens.primaryColor,
              AppDesignTokens.secondaryColor,
            ],
          ),
        ),
      ),
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing20,
        vertical: AppDesignTokens.spacing16,
      );

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 计数器区域
        _buildCounterSection(),
        
        SizedBox(height: AppDesignTokens.spacingV24),
        
        // 演示列表
        _buildDemoList(),
        
        SizedBox(height: AppDesignTokens.spacingV24),
      ],
    );
  }

  /// 构建浮动操作按钮（可选）
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: controller.incrementCounter,
      tooltip: '增加',
      child: Icon(Icons.add, size: AppDesignTokens.iconSizeMedium),
    );
  }

  // 移除重写的 build 方法，使用 BasePage 的默认实现
  // BasePage 已经使用 GetBuilder<ThemeController> 包裹，会自动响应主题变化

  /// 构建计数器区域
  Widget _buildCounterSection() {
    return AppCard(
      size: AppCardSize.large,
      backgroundColor: Colors.transparent,
      showShadow: true,
      shadow: AppDesignTokens.shadowWithColor(
        AppDesignTokens.primaryColor,
        opacity: 0.1,
      ),
      padding: EdgeInsets.all(AppDesignTokens.spacing24),
      borderRadius: AppDesignTokens.radius20,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppDesignTokens.primaryColor.withOpacity(0.1),
              AppDesignTokens.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDesignTokens.radius20),
        ),
        child: Column(
          children: [
            Text(
              '你已经点击了这么多次：',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize16,
                color: AppDesignTokens.textSecondary,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            Obx(() => Text(
                  '${controller.counter}',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize48,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: AppDesignTokens.primaryColor,
                  ),
                )),
            SizedBox(height: AppDesignTokens.spacingV16),
            AppButton.danger(
              text: '重置',
              onPressed: controller.resetCounter,
              icon: Icons.refresh,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建演示列表
  Widget _buildDemoList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '功能演示',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize20,
            fontWeight: AppDesignTokens.fontWeightBold,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV16),
        ...controller.demoItems.map((item) => Padding(
              padding: EdgeInsets.only(bottom: AppDesignTokens.spacingV12),
              child: _buildDemoCard(item),
            )),
      ],
    );
  }

  /// 构建演示卡片
  Widget _buildDemoCard(DemoItem item) {
    return AppCard(
      onTap: () => controller.navigateToDemo(item.route),
      child: Row(
        children: [
          // 图标
          Container(
            width: AppDesignTokens.spacing48,
            height: AppDesignTokens.spacing48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppDesignTokens.primaryLight,
                  AppDesignTokens.secondaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
            ),
            child: Center(
              child: Text(
                item.icon,
                style: TextStyle(fontSize: AppDesignTokens.fontSize24),
              ),
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing16),
          // 文字信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize15,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize12,
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 箭头
          Icon(
            Icons.arrow_forward_ios,
            size: AppDesignTokens.iconSizeSmall,
            color: AppDesignTokens.textDisabled,
          ),
        ],
      ),
    );
  }
}

