import 'package:flutter/material.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../utils/getx_snackbar_util.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'getx_utils_demo_controller.dart';

/// GetX工具类演示页面
class GetXUtilsDemoPage extends BaseScrollPage<GetXUtilsDemoController> {
  const GetXUtilsDemoPage({super.key});

  @override
  String? get pageTitle => 'GetX工具类演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      backgroundColor: AppDesignTokens.secondaryColor,
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
        // SnackBar演示区域
        _buildSectionCard(
          'SnackBar演示',
          AppDesignTokens.infoColor,
          [
            AppButton(
              text: '成功提示',
              onPressed: () => GetXSnackBarUtil.success(
                message: '操作成功完成！',
                title: '成功',
              ),
              type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.successColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '错误提示',
              onPressed: () => GetXSnackBarUtil.error(
                message: '操作失败，请重试！',
                title: '错误',
              ),
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.errorColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '警告提示',
              onPressed: () => GetXSnackBarUtil.warning(
                message: '请注意相关风险！',
                title: '警告',
              ),
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.warningColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '信息提示',
              onPressed: () => GetXSnackBarUtil.info(
                message: '这是一条信息提示！',
                title: '提示',
              ),
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.infoColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '自定义SnackBar',
              onPressed: () => GetXSnackBarUtil.custom(
                message: '自定义样式的提示！',
                title: '自定义',
                icon: Icons.star,
              ),
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.secondaryColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '多条消息队列',
              onPressed: controller.showMultipleSnackBars,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.primaryColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton.secondary(
              text: '清除所有SnackBar',
              onPressed: () => GetXSnackBarUtil.clearAll(),
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton.secondary(
              text: '测试SnackBar覆盖',
              onPressed: controller.testSnackBarOverride,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton.secondary(
              text: '测试立即显示SnackBar',
              onPressed: controller.testImmediateSnackBar,
              isFullWidth: true,
            ),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // Dialog演示区域
        _buildSectionCard(
          'Dialog演示',
          AppDesignTokens.successColor,
          [
            AppButton(
              text: 'Loading对话框',
              onPressed: controller.showLoadingDialog,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.infoColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '确认对话框',
              onPressed: controller.showConfirmDialog,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.warningColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '警告对话框',
              onPressed: controller.showAlertDialog,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.errorColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '输入对话框',
              onPressed: controller.showInputDialog,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.secondaryColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '选择对话框',
              onPressed: controller.showSelectDialog,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.primaryColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '底部弹窗',
              onPressed: controller.showBottomSheet,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.infoColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '自定义对话框',
              onPressed: controller.navigateToCustomDialogDemo,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.secondaryColor,
              isFullWidth: true,
            ),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 组合使用演示
        _buildSectionCard(
          '组合使用演示',
          AppDesignTokens.warningColor,
          [
            AppButton(
              text: '网络请求模拟',
              onPressed: controller.simulateNetworkRequest,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.infoColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '检查更新（演示）',
              onPressed: controller.showUpdateDemo,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.secondaryColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '表单验证模拟',
              onPressed: controller.simulateFormValidation,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.successColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '批量操作模拟',
              onPressed: controller.simulateBatchOperation,
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.warningColor,
              isFullWidth: true,
            ),
          ],
        ),
      ],
    );
  }

  /// 构建区域卡片
  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: color,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          ...children,
        ],
      ),
    );
  }
}