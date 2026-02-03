import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import 'error_monitor_demo_controller.dart';

/// 错误监控演示页面
class ErrorMonitorDemoPage extends BasePage<ErrorMonitorDemoController> {
  const ErrorMonitorDemoPage({super.key});

  @override
  String? get pageTitle => '错误监控演示';

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // 操作按钮区域
        _buildActionButtons(),
        // 错误日志区域
        Expanded(
          child: _buildErrorLogs(),
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.all(AppDesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '错误类型测试',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.textPrimary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Wrap(
            spacing: AppDesignTokens.spacing8,
            runSpacing: AppDesignTokens.spacingV8,
            children: [
              AppButton(
                text: 'Flutter 错误',
                icon: Icons.error_outline,
                onPressed: controller.triggerFlutterError,
                type: AppButtonType.danger,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '异步错误',
                icon: Icons.sync_problem,
                onPressed: controller.triggerAsyncError,
                type: AppButtonType.danger,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: 'Zone 错误',
                icon: Icons.warning_amber,
                onPressed: controller.triggerZoneError,
                type: AppButtonType.danger,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '空指针错误',
                icon: Icons.bug_report,
                onPressed: controller.triggerNullPointerError,
                type: AppButtonType.danger,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '类型错误',
                icon: Icons.type_specimen,
                onPressed: controller.triggerTypeError,
                type: AppButtonType.danger,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '网络错误',
                icon: Icons.wifi_off,
                onPressed: controller.triggerNetworkError,
                type: AppButtonType.danger,
                size: AppButtonSize.small,
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          Text(
            '错误监控功能',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.textPrimary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Wrap(
            spacing: AppDesignTokens.spacing8,
            runSpacing: AppDesignTokens.spacingV8,
            children: [
              AppButton(
                text: '手动上报',
                icon: Icons.report,
                onPressed: controller.reportManualError,
                type: AppButtonType.primary,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '设置用户',
                icon: Icons.person,
                onPressed: controller.setUserInfo,
                type: AppButtonType.secondary,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '添加面包屑',
                icon: Icons.timeline,
                onPressed: controller.addBreadcrumb,
                type: AppButtonType.secondary,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '设置标签',
                icon: Icons.label,
                onPressed: controller.setTag,
                type: AppButtonType.secondary,
                size: AppButtonSize.small,
              ),
              AppButton(
                text: '清空日志',
                icon: Icons.clear_all,
                onPressed: controller.clearLogs,
                type: AppButtonType.outline,
                size: AppButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建错误日志
  Widget _buildErrorLogs() {
    return Obx(() {
      if (controller.errorLogs.isEmpty) {
        return Center(
          child: Text(
            '暂无错误日志',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.all(AppDesignTokens.spacing16),
        itemCount: controller.errorLogs.length,
        itemBuilder: (context, index) {
          final log = controller.errorLogs[index];
          return AppCard(
            margin: EdgeInsets.only(bottom: AppDesignTokens.spacingV8),
            padding: EdgeInsets.all(AppDesignTokens.spacing12),
            child: Text(
              log,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize12,
                color: AppDesignTokens.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          );
        },
      );
    });
  }
}
