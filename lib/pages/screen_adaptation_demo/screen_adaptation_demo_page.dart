import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../utils/screen_util_helper.dart';
import 'screen_adaptation_demo_controller.dart';

/// 屏幕适配演示页面
class ScreenAdaptationDemoPage extends BaseScrollPage<ScreenAdaptationDemoController> {
  const ScreenAdaptationDemoPage({super.key});

  @override
  String? get pageTitle => '屏幕适配演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      backgroundColor: AppDesignTokens.infoColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 屏幕信息卡片
        _buildScreenInfoCard(),
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 字体大小演示
        _buildFontSizeDemo(),
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 间距演示
        _buildSpacingDemo(),
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 按钮演示
        _buildButtonDemo(),
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 圆角演示
        _buildRadiusDemo(),
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 图标演示
        _buildIconDemo(),
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 响应式布局演示
        _buildResponsiveDemo(),
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 打印屏幕信息按钮
        _buildPrintInfoButton(),
        SizedBox(height: AppDesignTokens.spacingV20),
      ],
    );
  }

  /// 构建屏幕信息卡片
  Widget _buildScreenInfoCard() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '屏幕信息',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          _buildInfoRow('屏幕宽度', '${ScreenUtilHelper.screenWidth.toStringAsFixed(1)}px'),
          _buildInfoRow('屏幕高度', '${ScreenUtilHelper.screenHeight.toStringAsFixed(1)}px'),
          _buildInfoRow('状态栏高度', '${ScreenUtilHelper.statusBarHeight.toStringAsFixed(1)}px'),
          _buildInfoRow('底部安全区', '${ScreenUtilHelper.bottomBarHeight.toStringAsFixed(1)}px'),
          _buildInfoRow('像素密度', '${ScreenUtilHelper.pixelRatio.toStringAsFixed(2)}'),
          _buildInfoRow('宽度比例', '${ScreenUtilHelper.widthRatio.toStringAsFixed(3)}'),
          _buildInfoRow('高度比例', '${ScreenUtilHelper.heightRatio.toStringAsFixed(3)}'),
          _buildInfoRow('设备类型', _getDeviceType()),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingV4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              fontWeight: AppDesignTokens.fontWeightSemiBold,
              color: AppDesignTokens.infoColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取设备类型
  String _getDeviceType() {
    if (ScreenUtilHelper.isTablet) return '平板';
    if (ScreenUtilHelper.isLargeScreen) return '大屏手机';
    if (ScreenUtilHelper.isSmallScreen) return '小屏手机';
    return '标准手机';
  }

  /// 构建字体大小演示
  Widget _buildFontSizeDemo() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '字体大小演示',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Text('超小字体 (10sp)', style: TextStyle(fontSize: AppDesignTokens.fontSize10)),
          SizedBox(height: AppDesignTokens.spacingV8),
          Text('小字体 (12sp)', style: TextStyle(fontSize: AppDesignTokens.fontSize12)),
          SizedBox(height: AppDesignTokens.spacingV8),
          Text('基础字体 (14sp)', style: TextStyle(fontSize: AppDesignTokens.fontSize14)),
          SizedBox(height: AppDesignTokens.spacingV8),
          Text('大字体 (16sp)', style: TextStyle(fontSize: AppDesignTokens.fontSize16)),
          SizedBox(height: AppDesignTokens.spacingV8),
          Text('超大字体 (18sp)', style: TextStyle(fontSize: AppDesignTokens.fontSize18)),
          SizedBox(height: AppDesignTokens.spacingV8),
          Text('巨大字体 (24sp)', style: TextStyle(fontSize: AppDesignTokens.fontSize24)),
        ],
      ),
    );
  }

  /// 构建间距演示
  Widget _buildSpacingDemo() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '间距演示',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          _buildSpacingItem('超小间距 (4px)', AppDesignTokens.spacing4),
          _buildSpacingItem('小间距 (8px)', AppDesignTokens.spacing8),
          _buildSpacingItem('基础间距 (12px)', AppDesignTokens.spacing12),
          _buildSpacingItem('大间距 (16px)', AppDesignTokens.spacing16),
          _buildSpacingItem('超大间距 (20px)', AppDesignTokens.spacing20),
          _buildSpacingItem('巨大间距 (32px)', AppDesignTokens.spacing32),
        ],
      ),
    );
  }

  /// 构建间距项目
  Widget _buildSpacingItem(String label, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingV4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: AppDesignTokens.fontSize14),
          ),
          SizedBox(width: spacing),
          Container(
            width: spacing,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppDesignTokens.infoLight,
              borderRadius: BorderRadius.circular(AppDesignTokens.radius2),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建按钮演示
  Widget _buildButtonDemo() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '按钮演示',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '小按钮',
            onPressed: () {},
            isFullWidth: true,
            size: AppButtonSize.small,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '中等按钮',
            onPressed: () {},
            isFullWidth: true,
            type: AppButtonType.primary,
            backgroundColor: AppDesignTokens.successColor,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '大按钮',
            onPressed: () {},
            isFullWidth: true,
            type: AppButtonType.primary,
            backgroundColor: AppDesignTokens.warningColor,
            size: AppButtonSize.large,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '超大按钮',
            onPressed: () {},
            isFullWidth: true,
            type: AppButtonType.primary,
            backgroundColor: AppDesignTokens.secondaryColor,
            size: AppButtonSize.large,
          ),
        ],
      ),
    );
  }

  /// 构建圆角演示
  Widget _buildRadiusDemo() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '圆角演示',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Wrap(
            spacing: AppDesignTokens.spacing12,
            runSpacing: AppDesignTokens.spacing12,
            children: [
              _buildRadiusItem('4px', AppDesignTokens.radius4, AppDesignTokens.errorColor),
              _buildRadiusItem('8px', AppDesignTokens.radius8, AppDesignTokens.successColor),
              _buildRadiusItem('12px', AppDesignTokens.radius12, AppDesignTokens.infoColor),
              _buildRadiusItem('16px', AppDesignTokens.radius16, AppDesignTokens.warningColor),
              _buildRadiusItem('24px', AppDesignTokens.radius24, AppDesignTokens.secondaryColor),
              _buildRadiusItem('32px', AppDesignTokens.radius32, AppDesignTokens.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建圆角项目
  Widget _buildRadiusItem(String label, double radius, Color color) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize12,
            color: AppDesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 构建图标演示
  Widget _buildIconDemo() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '图标大小演示',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconItem(Icons.home, AppDesignTokens.iconSizeSmall, '16sp'),
              _buildIconItem(Icons.favorite, AppDesignTokens.iconSizeMedium, '20sp'),
              _buildIconItem(Icons.star, AppDesignTokens.iconSizeLarge, '24sp'),
              _buildIconItem(Icons.settings, 28.sp, '28sp'),
              _buildIconItem(Icons.notifications, AppDesignTokens.iconSizeExtraLarge, '32sp'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建图标项目
  Widget _buildIconItem(IconData icon, double size, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: size,
          color: AppDesignTokens.infoColor,
        ),
        SizedBox(height: AppDesignTokens.spacingV4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize12,
            color: AppDesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 构建响应式布局演示
  Widget _buildResponsiveDemo() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '响应式布局演示',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          // 根据屏幕大小显示不同的布局
          if (ScreenUtilHelper.isTablet) ...[
            // 平板布局
            Row(
              children: [
                Expanded(
                  child: _buildResponsiveCard('平板布局', AppDesignTokens.infoColor, '这是平板设备的布局'),
                ),
                SizedBox(width: AppDesignTokens.spacing12),
                Expanded(
                  child: _buildResponsiveCard('平板布局', AppDesignTokens.successColor, '两列显示'),
                ),
              ],
            ),
          ] else if (ScreenUtilHelper.isLargeScreen) ...[
            // 大屏手机布局
            _buildResponsiveCard('大屏手机布局', AppDesignTokens.warningColor, '这是大屏手机的布局，内容更宽'),
          ] else if (ScreenUtilHelper.isSmallScreen) ...[
            // 小屏手机布局
            _buildResponsiveCard('小屏手机布局', AppDesignTokens.errorColor, '这是小屏手机的布局，内容紧凑'),
          ] else ...[
            // 标准手机布局
            _buildResponsiveCard('标准手机布局', AppDesignTokens.secondaryColor, '这是标准手机的布局'),
          ],
        ],
      ),
    );
  }

  /// 构建响应式卡片
  Widget _buildResponsiveCard(String title, Color color, String content) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: color.withOpacity(0.8),
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV8),
          Text(
            content,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }  /// 构建打印信息按钮
  Widget _buildPrintInfoButton() {
    return AppButton(
            text: '打印屏幕信息到控制台',
      onPressed: controller.printScreenInfo,
      icon: Icons.print,
      isFullWidth: true,
            type: AppButtonType.primary,
            backgroundColor: AppDesignTokens.infoColor,
    );
  }
}
