import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../overlay/overlay.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'getx_utils_demo_controller.dart';

/// GetX工具类演示页面
class GetXUtilsDemoPage extends BaseScrollPage<GetXUtilsDemoController> {
  const GetXUtilsDemoPage({super.key});

  @override
  String? get pageTitle => '提示弹窗工具';

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
    // 用于演示代码触发 Popup 的 GlobalKey
    final GlobalKey<CustomPopupState> popupKey = GlobalKey<CustomPopupState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toast 演示区域
        _buildSectionCard(
          'Toast 演示',
          AppDesignTokens.primaryColor,
          [
            AppButton(
              text: '底部成功 Toast',
              onPressed: () => AppOverlay.toast.success('操作成功完成！'),
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.successColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '底部错误 Toast',
              onPressed: () => AppOverlay.toast.error('操作失败，请稍后重试'),
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.errorColor,
              isFullWidth: true,
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            AppButton(
              text: '信息 Toast（顶部）',
              onPressed: () =>
                  AppOverlay.toast.info('这是一条轻量级信息提示', position: ToastPosition.top),
              type: AppButtonType.primary,
              backgroundColor: AppDesignTokens.infoColor,
              isFullWidth: true,
            ),
          ],
        ),

        SizedBox(height: AppDesignTokens.spacingV20),

        // Popup 演示区域（基于 flutter_popup）
        _buildPopupSection(context, popupKey),

        SizedBox(height: AppDesignTokens.spacingV20),

        // SnackBar演示区域
        _buildSectionCard(
          'SnackBar演示',
          AppDesignTokens.infoColor,
          [
            AppButton(
              text: '成功提示',
              onPressed: () => AppOverlay.snack.success(
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
              onPressed: () => AppOverlay.snack.error(
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
              onPressed: () => AppOverlay.snack.warning(
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
              onPressed: () => AppOverlay.snack.info(
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
              onPressed: () => AppOverlay.snack.custom(
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
              onPressed: () => AppOverlay.snack.clearAll(),
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

  /// Popup 演示区域
  Widget _buildPopupSection(BuildContext context, GlobalKey<CustomPopupState> popupKey) {
    return _buildSectionCard(
      'Popup 演示（flutter_popup）',
      AppDesignTokens.secondaryColor,
      [
        // 最简单用法
        Row(
          children: [
            const Expanded(
              child: Text(
                '基础用法：点击右侧图标弹出提示气泡',
                style: TextStyle(fontSize: 13),
              ),
            ),
            CustomPopup(
              content: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('George says everything looks fine'),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.help_outline, color: Colors.blue),
              ),
            ),
          ],
        ),

        SizedBox(height: AppDesignTokens.spacingV16),

        // 自定义箭头 / 背景 / 遮罩
        CustomPopup(
          arrowColor: Colors.orange,
          barrierColor: Colors.green.withOpacity(0.05),
          backgroundColor: Colors.white,
          content: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('自定义箭头 / 遮罩 / 背景颜色'),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lightbulb_outline, color: Colors.orange),
              SizedBox(width: 4),
              Text('自定义样式 Popup'),
            ],
          ),
        ),

        SizedBox(height: AppDesignTokens.spacingV16),

        // 顶部位置 + 可交互内容（Slider）
        CustomPopup(
          position: PopupPosition.top,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _PopupSlider(),
          ),
          child: const Text('顶部 Slider Popup'),
        ),

        SizedBox(height: AppDesignTokens.spacingV16),

        // 简单菜单列表
        CustomPopup(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('menu$index'),
              ),
            ),
          ),
          child: const Icon(Icons.add_circle_outline, color: Colors.teal),
        ),

        SizedBox(height: AppDesignTokens.spacingV16),

        // 顶部筛选条 + 宽度铺满的内容 Popup
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
            boxShadow: AppDesignTokens.shadowWithColor(
              Colors.black,
              opacity: 0.04,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomPopup(
                showArrow: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                barrierColor: Colors.transparent,
                contentDecoration: const BoxDecoration(color: Colors.white),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      4,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('item$index'),
                      ),
                    ),
                  ),
                ),
                child: const Text('筛选1'),
              ),
              const Text('筛选2'),
              const Text('筛选3'),
            ],
          ),
        ),

        SizedBox(height: AppDesignTokens.spacingV16),

        // 代码触发 show 的示例
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                text: '代码触发 Popup 显示',
                onPressed: () {
                  popupKey.currentState?.show();
                },
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 12),
            CustomPopup(
              key: popupKey,
              content: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('这是通过代码调用 show() 显示的 Popup'),
              ),
              child: const Icon(Icons.help, color: Colors.blueGrey),
            ),
          ],
        ),
      ],
    );
  }
}

/// Popup 内部使用的简单 Slider 示例
class _PopupSlider extends StatefulWidget {
  const _PopupSlider();

  @override
  State<_PopupSlider> createState() => _PopupSliderState();
}

class _PopupSliderState extends State<_PopupSlider> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('调整数值'),
        Slider(
          value: _value,
          onChanged: (v) {
            setState(() {
              _value = v;
            });
          },
        ),
        Text('当前值：${_value.toStringAsFixed(2)}'),
      ],
    );
  }
}
