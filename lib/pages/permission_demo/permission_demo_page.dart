import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'permission_demo_controller.dart';

/// 权限请求工具演示页面
class PermissionDemoPage extends BaseScrollPage<PermissionDemoController> {
  const PermissionDemoPage({super.key});

  @override
  String? get pageTitle => '权限请求工具演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(
          fontSize: AppDesignTokens.fontSize18,
          fontWeight: AppDesignTokens.fontWeightBold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppDesignTokens.warningColor,
              AppDesignTokens.warningDark,
            ],
          ),
        ),
      ),
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing16,
        vertical: AppDesignTokens.spacing16,
      );

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 平台信息卡片
        _buildPlatformInfoCard(),
        SizedBox(height: AppDesignTokens.spacingV20),

        // 权限列表
        ...controller.permissionItems.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: AppDesignTokens.spacingV16),
            child: _buildPermissionCard(item),
          ),
        ),
      ],
    );
  }

  /// 构建平台信息卡片
  Widget _buildPlatformInfoCard() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDesignTokens.spacing24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppDesignTokens.warningLight.withOpacity(0.15),
              AppDesignTokens.warningColor.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDesignTokens.radius20),
          border: Border.all(
            color: AppDesignTokens.warningColor.withOpacity(0.3),
            width: 1.5.w,
          ),
          boxShadow: AppDesignTokens.shadowWithColor(
            AppDesignTokens.warningColor,
            opacity: 0.12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppDesignTokens.warningDark,
                  size: AppDesignTokens.iconSizeMedium,
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                Text(
                  '平台信息',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize18,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: AppDesignTokens.warningDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDesignTokens.spacingV16),
            Obx(() => _buildInfoRow('当前平台', controller.platformInfo.value)),
            _buildInfoRow('权限状态', '已初始化'),
          ],
        ),
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
              color: AppDesignTokens.warningColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              fontWeight: AppDesignTokens.fontWeightSemiBold,
              color: AppDesignTokens.warningDark,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建权限卡片
  Widget _buildPermissionCard(PermissionItem item) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppDesignTokens.spacing4,
                  height: AppDesignTokens.spacingV20,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius2),
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize16,
                      fontWeight: AppDesignTokens.fontWeightBold,
                      color: item.color,
                    ),
                  ),
                ),
                Obx(() => _buildStatusBadge(item.status.value)),
              ],
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            Text(
              item.description,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize13,
                color: AppDesignTokens.textSecondary,
                height: AppDesignTokens.lineHeightNormal,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingV16),
            Row(
              children: [
                Expanded(
                  child: _buildPrimaryButton(
                    '请求权限',
                    item.color,
                    Icons.lock_open,
                    () => controller.requestPermission(item),
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing12),
                Expanded(
                  child: _buildSecondaryButton(
                    '检查状态',
                    Icons.check_circle_outline,
                    () => controller.checkPermissionStatus(item),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态徽章
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData icon;
    
    switch (status) {
      case '已授予':
        badgeColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case '已拒绝':
        badgeColor = Colors.red;
        icon = Icons.cancel;
        break;
      case '永久拒绝':
        badgeColor = Colors.orange;
        icon = Icons.block;
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing8,
        vertical: AppDesignTokens.spacingV4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDesignTokens.iconSizeSmall, color: badgeColor),
          SizedBox(width: AppDesignTokens.spacing4),
          Text(
            status,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize12,
              color: badgeColor,
              fontWeight: AppDesignTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  /// 主按钮（请求权限）
  Widget _buildPrimaryButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.primary,
      size: AppButtonSize.medium,
      isFullWidth: true,
      icon: icon,
      backgroundColor: color,
    );
  }

  /// 次按钮（检查状态）
  Widget _buildSecondaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return AppButton.outline(
      text: text,
      onPressed: onPressed,
      size: AppButtonSize.medium,
      isFullWidth: true,
      icon: icon,
    );
  }
}
