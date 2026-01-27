import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/simple_fullscreen_webview.dart';
import 'webview_demo_controller.dart';

/// WebView 功能演示页面
/// 
/// 整合了所有 WebView 相关功能的演示
class WebViewDemoPage extends BaseScrollPage<WebViewDemoController> {
  const WebViewDemoPage({super.key});

  @override
  String? get pageTitle => 'WebView 功能演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      backgroundColor: AppDesignTokens.infoColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 介绍卡片
        _buildIntroCard(),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 基础浏览功能
        _buildSectionCard(
          title: '🌍 基础浏览功能',
          icon: Icons.web,
          color: AppDesignTokens.infoColor,
          children: [
            _buildDemoSites(),
            SizedBox(height: AppDesignTokens.spacingV16),
            _buildCustomUrlSection(),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 桥接功能演示
        _buildSectionCard(
          title: '🌉 桥接功能演示',
          icon: Icons.swap_horiz,
          color: AppDesignTokens.primaryColor,
          children: [
            _buildBridgeDemoSection(),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // MVVM 架构演示
        _buildSectionCard(
          title: '🎯 MVVM 架构演示',
          icon: Icons.architecture,
          color: AppDesignTokens.secondaryColor,
          children: [
            _buildMvvmDemoSection(),
          ],
        ),
      ],
    );
  }

  /// 构建介绍卡片
  Widget _buildIntroCard() {
    return AppCard(
      size: AppCardSize.large,
      backgroundColor: AppDesignTokens.infoColor.withOpacity(0.1),
      showBorder: true,
      borderColor: AppDesignTokens.infoColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.web,
                color: AppDesignTokens.infoColor,
                size: AppDesignTokens.iconSizeMedium,
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              Text(
                'WebView 功能演示',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize18,
                  fontWeight: AppDesignTokens.fontWeightBold,
                  color: AppDesignTokens.infoDark,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Text(
            '整合了所有 WebView 相关功能的演示，包括基础浏览、桥接通信、MVVM 架构等。',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.infoColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建章节卡片
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      showBorder: true,
      borderColor: color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize18,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          ...children,
        ],
      ),
    );
  }

  /// 构建演示网站列表
  Widget _buildDemoSites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '热门网站',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize16,
            fontWeight: AppDesignTokens.fontWeightSemiBold,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDesignTokens.spacing12,
            mainAxisSpacing: AppDesignTokens.spacingV12,
            childAspectRatio: 1.2,
          ),
          itemCount: controller.demoUrls.length,
          itemBuilder: (context, index) {
            final site = controller.demoUrls[index];
            return _buildSiteCard(site);
          },
        ),
      ],
    );
  }

  /// 构建网站卡片
  Widget _buildSiteCard(Map<String, dynamic> site) {
    return GestureDetector(
      onTap: () => controller.openWebView(
        site['url'] as String,
        site['title'] as String,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius16),
          border: Border.all(
            color: (site['color'] as Color).withOpacity(0.2),
            width: 1.5.w,
          ),
          boxShadow: AppDesignTokens.shadowSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: (site['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
              ),
              child: Icon(
                site['icon'] as IconData,
                size: AppDesignTokens.iconSizeMedium,
                color: site['color'] as Color,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            Text(
              site['title'] as String,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                fontWeight: AppDesignTokens.fontWeightSemiBold,
                color: AppDesignTokens.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDesignTokens.spacingV4),
            Text(
              '点击浏览',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize12,
                color: AppDesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建自定义 URL 输入部分
  Widget _buildCustomUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义网址',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize16,
            fontWeight: AppDesignTokens.fontWeightSemiBold,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        TextField(
          controller: controller.urlController,
          decoration: InputDecoration(
            hintText: '请输入要浏览的网址',
            hintStyle: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textHint,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
              borderSide: BorderSide(
                color: AppDesignTokens.grey300,
                width: 1.5.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
              borderSide: BorderSide(
                color: AppDesignTokens.grey300,
                width: 1.5.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
              borderSide: BorderSide(
                color: AppDesignTokens.infoColor,
                width: 2.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDesignTokens.spacing16,
              vertical: AppDesignTokens.spacingV16,
            ),
            filled: true,
            fillColor: AppDesignTokens.grey50,
            prefixIcon: Icon(
              Icons.language,
              size: AppDesignTokens.iconSizeMedium,
              color: AppDesignTokens.textSecondary,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, size: AppDesignTokens.iconSizeMedium),
              onPressed: () {
                controller.urlController.clear();
              },
            ),
          ),
          style: TextStyle(fontSize: AppDesignTokens.fontSize14),
          onSubmitted: (url) => controller.openCustomUrl(url),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '浏览网址',
          onPressed: () => controller.openCustomUrl(controller.urlController.text),
          icon: Icons.open_in_browser,
          isFullWidth: true,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.infoColor,
        ),
      ],
    );
  }

  /// 构建桥接功能演示部分
  Widget _buildBridgeDemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'H5 ↔ Flutter 双向通信演示',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize16,
            fontWeight: AppDesignTokens.fontWeightSemiBold,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Text(
          '演示 H5 和 Flutter 之间的双向通信功能，包括方法调用、数据传递等。',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV16),
        AppButton(
          text: '打开桥接演示',
          onPressed: () => _openBridgeDemo(),
          icon: Icons.swap_horiz,
          isFullWidth: true,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.primaryColor,
        ),
      ],
    );
  }

  /// 打开桥接演示（全屏）
  void _openBridgeDemo() {
    Get.to(
      () => Scaffold(
        appBar: AppBar(
          title: const Text('WebView 桥接演示'),
          backgroundColor: AppDesignTokens.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              tooltip: '清除缓存',
              onPressed: controller.clearBridgeCache,
            ),
          ],
        ),
        body: Column(
          children: [
            // 操作按钮区域
            _buildBridgeControlButtons(),
            // WebView 区域
            Expanded(
              child: SimpleFullScreenWebView(
                url: controller.getBridgeDemoHtmlUrl(),
                title: '桥接测试',
                enableBridge: true,
                onBridgeReady: (bridgeManager) {
                  controller.onBridgeReady(bridgeManager);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建桥接控制按钮
  Widget _buildBridgeControlButtons() {
    return Obx(() => Container(
          padding: EdgeInsets.all(AppDesignTokens.spacing12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: AppDesignTokens.shadowSmall,
          ),
          child: Wrap(
            spacing: AppDesignTokens.spacing8,
            runSpacing: AppDesignTokens.spacingV8,
            children: [
              AppButton(
                text: 'Flutter调H5',
                onPressed: controller.bridgeManager.value != null ? controller.callH5Method : null,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.infoColor,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '发送数据',
                onPressed: controller.bridgeManager.value != null ? controller.sendDataToH5 : null,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.successColor,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '更新标题',
                onPressed: controller.bridgeManager.value != null ? controller.updateH5Title : null,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.warningColor,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '获取H5数据',
                onPressed: controller.bridgeManager.value != null ? controller.getH5Data : null,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.secondaryColor,
                size: AppButtonSize.small,
              ),
            ],
          ),
        ));
  }

  /// 构建 MVVM 架构演示部分
  Widget _buildMvvmDemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MVVM 架构演示',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize16,
            fontWeight: AppDesignTokens.fontWeightSemiBold,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Text(
          '演示使用 GetX Controller 管理 WebView 逻辑的 MVVM 架构实现。',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        _buildFeatureItem('✅ MVVM 架构，逻辑与 UI 分离'),
        _buildFeatureItem('✅ GetX 状态管理，响应式更新'),
        _buildFeatureItem('✅ 完整的错误处理和重试'),
        _buildFeatureItem('✅ 支持前进/后退导航'),
        _buildFeatureItem('✅ 顶部进度条显示'),
        _buildFeatureItem('✅ 特殊协议处理'),
        _buildFeatureItem('✅ 缓存管理功能'),
        _buildFeatureItem('✅ H5 ↔ Flutter 桥接（可选）'),
        SizedBox(height: AppDesignTokens.spacingV16),
        Wrap(
          spacing: AppDesignTokens.spacing12,
          runSpacing: AppDesignTokens.spacingV12,
          children: [
            AppButton(
              text: 'Flutter 官网',
              onPressed: () => controller.openMvvmDemo('https://flutter.dev'),
              icon: Icons.web,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.secondaryColor,
              size: AppButtonSize.small,
            ),
            AppButton(
              text: 'GitHub',
              onPressed: () => controller.openMvvmDemo('https://github.com'),
              icon: Icons.code,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.secondaryColor,
              size: AppButtonSize.small,
            ),
            AppButton(
              text: '百度',
              onPressed: () => controller.openMvvmDemo('https://www.baidu.com'),
              icon: Icons.search,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.secondaryColor,
              size: AppButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDesignTokens.spacingV8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
