import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'selector_demo_controller.dart';
import 'models/province_model.dart';

/// 选择器 UI 组件演示页面
class SelectorDemoPage extends BaseScrollPage<SelectorDemoController> {
  const SelectorDemoPage({super.key});

  @override
  String? get pageTitle => '选择器 UI 组件演示';

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
              AppDesignTokens.primaryColor,
              AppDesignTokens.secondaryColor,
            ],
          ),
        ),
      ),
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateSection(context),
        SizedBox(height: AppDesignTokens.spacingV20),
        _buildRegionSection(context),
        SizedBox(height: AppDesignTokens.spacingV20),
        _buildConstellationSection(context),
        SizedBox(height: AppDesignTokens.spacingV20),
        _buildColorSection(context),
        SizedBox(height: AppDesignTokens.spacingV20),
        _buildFileSection(context),
      ],
    );
  }

  /// 日期/时间选择区域
  Widget _buildDateSection(BuildContext context) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '日期 / 时间选择',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.primaryColor,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Text(
            '演示如何使用系统自带的日期/时间选择器，并通过统一的 UI 组件展示选择结果。',
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
                child: AppButton(
                  text: '选择日期',
                  onPressed: () => _showCupertinoDatePicker(context),
                  icon: Icons.event,
                  type: AppButtonType.primary,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              Expanded(
                child: AppButton.secondary(
                  text: '选择时间',
                  onPressed: () => _showCupertinoTimePicker(context),
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton.outline(
            text: '选择日期范围',
            onPressed: () => controller.pickDateRange(context),
            icon: Icons.date_range,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '选择日期和时间',
            onPressed: () => _showCupertinoDateTimePicker(context),
            icon: Icons.event_note,
            type: AppButtonType.primary,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          const Divider(),
          SizedBox(height: AppDesignTokens.spacingV12),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('选择的日期', controller.formatDateValue()),
                _buildInfoRow('选择的时间', controller.formatTimeValue()),
                _buildInfoRow(
                  '选择的日期和时间',
                  controller.formatDateTimeValue(),
                ),
                _buildInfoRow(
                  '选择的日期范围',
                  controller.formatDateRange(controller.selectedDateRange.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 省市区选择区域
  Widget _buildRegionSection(BuildContext context) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '省市区选择器',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoColor,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Text(
            '使用本地省市区数据创建三级联动选择器，支持省份、城市、区县的选择。',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize13,
              color: AppDesignTokens.textSecondary,
              height: AppDesignTokens.lineHeightNormal,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          AppButton(
            text: '选择省市区',
            onPressed: () => _showRegionPicker(context),
            icon: Icons.location_on,
            type: AppButtonType.primary,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          const Divider(),
          SizedBox(height: AppDesignTokens.spacingV12),
          Obx(
            () => _buildInfoRow(
              '选择的省市区',
              controller.formatRegionValue(),
            ),
          ),
        ],
      ),
    );
  }

  /// 星座选择区域
  Widget _buildConstellationSection(BuildContext context) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '星座选择器',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.warningColor,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Text(
            '选择你的星座，使用滚轮样式选择器，支持十二星座选择。',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize13,
              color: AppDesignTokens.textSecondary,
              height: AppDesignTokens.lineHeightNormal,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          AppButton(
            text: '选择星座',
            onPressed: () => _showConstellationPicker(context),
            icon: Icons.star,
            type: AppButtonType.primary,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          const Divider(),
          SizedBox(height: AppDesignTokens.spacingV12),
          Obx(
            () => _buildInfoRow(
              '选择的星座',
              controller.formatConstellationValue(),
            ),
          ),
        ],
      ),
    );
  }

  /// 颜色选择区域
  Widget _buildColorSection(BuildContext context) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '颜色选择器',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.errorColor,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Text(
            '使用圆形色盘选择色相与饱和度，配合亮度、透明度滑块实时预览。',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize13,
              color: AppDesignTokens.textSecondary,
              height: AppDesignTokens.lineHeightNormal,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          // 显示当前选中的颜色预览
          Obx(
            () => Container(
              padding: EdgeInsets.all(AppDesignTokens.spacing16),
              decoration: BoxDecoration(
                color: controller.selectedColor.value ?? Colors.transparent,
                borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                border: Border.all(
                  color: AppDesignTokens.textSecondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: controller.selectedColor.value != null
                            ? _getContrastColor(controller.selectedColor.value!)
                            : AppDesignTokens.textSecondary,
                      ),
                      SizedBox(width: AppDesignTokens.spacing8),
                      Text(
                        controller.formatColorValue(),
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize16,
                          fontWeight: AppDesignTokens.fontWeightBold,
                          color: controller.selectedColor.value != null
                              ? _getContrastColor(controller.selectedColor.value!)
                              : AppDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (controller.selectedColor.value != null)
                    TextButton(
                      onPressed: () {
                        controller.selectedColor.value = null;
                        controller.showInfo('已清空颜色选择');
                      },
                      child: Text(
                        '清空',
                        style: TextStyle(
                          color: _getContrastColor(controller.selectedColor.value!),
                          fontSize: AppDesignTokens.fontSize14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          AppButton(
            text: '选择颜色',
            onPressed: () => _showColorPicker(context),
            icon: Icons.colorize,
            type: AppButtonType.primary,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          const Divider(),
          SizedBox(height: AppDesignTokens.spacingV12),
          Obx(
            () => _buildInfoRow(
              '选择的颜色',
              controller.formatColorValue(),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取对比色（用于在颜色背景上显示文字）
  Color _getContrastColor(Color color) {
    // 计算颜色的亮度
    final luminance = color.computeLuminance();
    // 如果亮度大于 0.5，返回黑色，否则返回白色
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 颜色选择器滑块行
  Widget _buildColorSliderRow({
    required String label,
    required String trailing,
    required Widget child,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        ),
        Expanded(child: child),
        SizedBox(
          width: 44,
          child: Text(
            trailing,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// 文件选择区域
  Widget _buildFileSection(BuildContext context) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '文件选择器',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize18,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.secondaryColor,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Text(
            '使用 file_picker 插件选择单个或多个文件，并展示文件名、大小等信息。',
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
                child: AppButton(
                  text: '选择单个文件',
                  onPressed: controller.pickSingleFile,
                  icon: Icons.attach_file,
                  type: AppButtonType.primary,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              Expanded(
                child: AppButton.secondary(
                  text: '选择多个文件',
                  onPressed: controller.pickMultipleFiles,
                  icon: Icons.playlist_add,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton.text(
            text: '清空选择结果',
            onPressed: controller.clearSelections,
            icon: Icons.clear_all,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          const Divider(),
          SizedBox(height: AppDesignTokens.spacingV12),
          Obx(
            () {
              final files = controller.selectedFiles;
              if (files.isEmpty) {
                return Text(
                  '当前未选择任何文件。',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize13,
                    color: AppDesignTokens.textSecondary,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选择 ${files.length} 个文件：',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize14,
                      fontWeight: AppDesignTokens.fontWeightSemiBold,
                      color: AppDesignTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacingV12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: files.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppDesignTokens.spacingV8),
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return _buildFileItem(file);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.textPrimary,
                fontWeight: AppDesignTokens.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    final ext = file.extension?.toUpperCase() ?? '未知';
    final sizeText = controller.formatFileSize(file.size);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing12,
        vertical: AppDesignTokens.spacingV8,
      ),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        border: Border.all(
          color: AppDesignTokens.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppDesignTokens.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
            ),
            child: Center(
              child: Text(
                ext,
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                  fontWeight: AppDesignTokens.fontWeightBold,
                  color: AppDesignTokens.primaryDark,
                ),
              ),
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Text(
                  sizeText,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize12,
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 底部弹出的日期选择器（滚轮样式）
  Future<void> _showCupertinoDatePicker(BuildContext context) async {
    final now = DateTime.now();
    DateTime temp = controller.selectedDate.value ?? now;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppDesignTokens.surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDesignTokens.radius20),
              topRight: Radius.circular(AppDesignTokens.radius20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing16,
                    vertical: AppDesignTokens.spacingV8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: AppDesignTokens.textSecondary,
                            fontSize: AppDesignTokens.fontSize14,
                          ),
                        ),
                      ),
                      Text(
                        '选择日期',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize16,
                          fontWeight: AppDesignTokens.fontWeightBold,
                          color: AppDesignTokens.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.selectedDate.value = temp;
                          controller
                              .showSuccess('已选择日期：${controller.formatDateValue()}');
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          '完成',
                          style: TextStyle(
                            color: AppDesignTokens.primaryColor,
                            fontSize: AppDesignTokens.fontSize14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: temp,
                    minimumDate: DateTime(now.year - 5),
                    maximumDate: DateTime(now.year + 5),
                    onDateTimeChanged: (value) {
                      temp = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 底部弹出的时间选择器（滚轮样式）
  Future<void> _showCupertinoTimePicker(BuildContext context) async {
    final now = TimeOfDay.now();
    final current = controller.selectedTime.value ?? now;
    DateTime temp = DateTime(
      0,
      1,
      1,
      current.hour,
      current.minute,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppDesignTokens.surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDesignTokens.radius20),
              topRight: Radius.circular(AppDesignTokens.radius20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing16,
                    vertical: AppDesignTokens.spacingV8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: AppDesignTokens.textSecondary,
                            fontSize: AppDesignTokens.fontSize14,
                          ),
                        ),
                      ),
                      Text(
                        '选择时间',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize16,
                          fontWeight: AppDesignTokens.fontWeightBold,
                          color: AppDesignTokens.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final picked = TimeOfDay(
                            hour: temp.hour,
                            minute: temp.minute,
                          );
                          controller.selectedTime.value = picked;
                          controller
                              .showSuccess('已选择时间：${controller.formatTimeValue()}');
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          '完成',
                          style: TextStyle(
                            color: AppDesignTokens.primaryColor,
                            fontSize: AppDesignTokens.fontSize14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: temp,
                    onDateTimeChanged: (value) {
                      temp = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 底部弹出的日期时间选择器（滚轮样式）
  Future<void> _showCupertinoDateTimePicker(BuildContext context) async {
    final now = DateTime.now();
    DateTime temp = controller.selectedDateTime.value ?? now;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: AppDesignTokens.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDesignTokens.radius20),
                  topRight: Radius.circular(AppDesignTokens.radius20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: AppDesignTokens.textSecondary,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                          Text(
                            '选择日期和时间',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize16,
                              fontWeight: AppDesignTokens.fontWeightBold,
                              color: AppDesignTokens.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.selectedDateTime.value = temp;
                              controller.showSuccess(
                                '已选择日期和时间：${controller.formatDateTimeValue()}',
                              );
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: AppDesignTokens.primaryColor,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 格式化日期时间预览
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      padding: EdgeInsets.all(AppDesignTokens.spacing16),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                        border: Border.all(
                          color: AppDesignTokens.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            color: AppDesignTokens.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: AppDesignTokens.spacing8),
                          Text(
                            _formatDateTimePreview(temp),
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize18,
                              fontWeight: AppDesignTokens.fontWeightBold,
                              color: AppDesignTokens.primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        use24hFormat: true,
                        initialDateTime: temp,
                        minimumDate: DateTime(now.year - 5),
                        maximumDate: DateTime(now.year + 5),
                        onDateTimeChanged: (value) {
                          setState(() {
                            temp = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 底部弹出的省市区选择器（滚轮样式）
  Future<void> _showRegionPicker(BuildContext context) async {
    if (controller.provinces.isEmpty) {
      controller.showWarning('省市区数据加载中，请稍候...');
      return;
    }

    // 初始化选择
    int provinceIndex = 0;
    int cityIndex = 0;
    int areaIndex = 0;

    // 如果有已选择的值，找到对应的索引
    if (controller.selectedRegion.value != null) {
      final selected = controller.selectedRegion.value!;
      final provinceIdx = controller.provinces.indexWhere(
        (p) => p.name == selected.province,
      );
      if (provinceIdx >= 0) {
        provinceIndex = provinceIdx;
        final cityIdx = controller.provinces[provinceIndex].city.indexWhere(
          (c) => c.name == selected.city,
        );
        if (cityIdx >= 0) {
          cityIndex = cityIdx;
          final areaIdx = controller.provinces[provinceIndex]
              .city[cityIndex]
              .area
              .indexWhere((a) => a == selected.area);
          if (areaIdx >= 0) {
            areaIndex = areaIdx;
          }
        }
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentProvince = controller.provinces[provinceIndex];
            final currentCity = currentProvince.city[cityIndex];
            final currentAreas = currentCity.area;

            // 确保 areaIndex 不越界
            if (areaIndex >= currentAreas.length) {
              areaIndex = 0;
            }

            return Container(
              decoration: BoxDecoration(
                color: AppDesignTokens.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDesignTokens.radius20),
                  topRight: Radius.circular(AppDesignTokens.radius20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: AppDesignTokens.textSecondary,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                          Text(
                            '选择省市区',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize16,
                              fontWeight: AppDesignTokens.fontWeightBold,
                              color: AppDesignTokens.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final selected = SelectedRegion(
                                province: currentProvince.name,
                                city: currentCity.name,
                                area: currentAreas[areaIndex],
                              );
                              controller.selectedRegion.value = selected;
                              controller.showSuccess(
                                '已选择：${selected.fullAddress}',
                              );
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: AppDesignTokens.primaryColor,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 格式化地址预览
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      padding: EdgeInsets.all(AppDesignTokens.spacing16),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                        border: Border.all(
                          color: AppDesignTokens.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppDesignTokens.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: AppDesignTokens.spacing8),
                          Flexible(
                            child: Text(
                              '${currentProvince.name} ${currentCity.name} ${currentAreas[areaIndex]}',
                              style: TextStyle(
                                fontSize: AppDesignTokens.fontSize16,
                                fontWeight: AppDesignTokens.fontWeightBold,
                                color: AppDesignTokens.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 三个滚轮选择器
                    SizedBox(
                      height: 220,
                      child: Row(
                        children: [
                          // 省份选择器
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: provinceIndex,
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  provinceIndex = index;
                                  cityIndex = 0;
                                  areaIndex = 0;
                                });
                              },
                              children: controller.provinces
                                  .map((province) => Center(
                                        child: Text(
                                          province.name,
                                          style: TextStyle(
                                            fontSize: AppDesignTokens.fontSize16,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          // 城市选择器
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: cityIndex,
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  cityIndex = index;
                                  areaIndex = 0;
                                });
                              },
                              children: currentProvince.city
                                  .map((city) => Center(
                                        child: Text(
                                          city.name,
                                          style: TextStyle(
                                            fontSize: AppDesignTokens.fontSize16,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          // 区县选择器
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: areaIndex,
                              ),
                              itemExtent: 40,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  areaIndex = index;
                                });
                              },
                              children: currentAreas
                                  .map((area) => Center(
                                        child: Text(
                                          area,
                                          style: TextStyle(
                                            fontSize: AppDesignTokens.fontSize16,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 格式化日期时间预览（YYYY-MM-DD HH:mm）
  String _formatDateTimePreview(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  /// 底部弹出的星座选择器（滚轮样式）
  Future<void> _showConstellationPicker(BuildContext context) async {
    int selectedIndex = 0;

    // 如果有已选择的值，找到对应的索引
    if (controller.selectedConstellation.value != null) {
      final index = SelectorDemoController.constellations.indexWhere(
        (c) => c == controller.selectedConstellation.value,
      );
      if (index >= 0) {
        selectedIndex = index;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: AppDesignTokens.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDesignTokens.radius20),
                  topRight: Radius.circular(AppDesignTokens.radius20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: AppDesignTokens.textSecondary,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                          Text(
                            '选择星座',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize16,
                              fontWeight: AppDesignTokens.fontWeightBold,
                              color: AppDesignTokens.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final selected = SelectorDemoController
                                  .constellations[selectedIndex];
                              controller.selectedConstellation.value = selected;
                              controller.showSuccess('已选择：$selected');
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: AppDesignTokens.primaryColor,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 格式化星座预览
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      padding: EdgeInsets.all(AppDesignTokens.spacing16),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                        border: Border.all(
                          color: AppDesignTokens.warningColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppDesignTokens.warningColor,
                            size: 24,
                          ),
                          SizedBox(width: AppDesignTokens.spacing8),
                          Text(
                            SelectorDemoController.constellations[selectedIndex],
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize18,
                              fontWeight: AppDesignTokens.fontWeightBold,
                              color: AppDesignTokens.warningColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 星座滚轮选择器
                    SizedBox(
                      height: 220,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        children: SelectorDemoController.constellations
                            .map((constellation) => Center(
                                  child: Text(
                                    constellation,
                                    style: TextStyle(
                                      fontSize: AppDesignTokens.fontSize16,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 底部弹出的颜色选择器
  Future<void> _showColorPicker(BuildContext context) async {
    // 初始化颜色，如果有已选择的颜色则使用，否则使用红色
    HSVColor hsvColor = controller.selectedColor.value != null
        ? HSVColor.fromColor(controller.selectedColor.value!)
        : const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0); // 红色，完全不透明

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentColor = hsvColor.toColor();

            return Container(
              decoration: BoxDecoration(
                color: AppDesignTokens.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDesignTokens.radius20),
                  topRight: Radius.circular(AppDesignTokens.radius20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: AppDesignTokens.textSecondary,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                          Text(
                            '选择颜色',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize16,
                              fontWeight: AppDesignTokens.fontWeightBold,
                              color: AppDesignTokens.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.selectedColor.value = currentColor;
                              controller.showSuccess(
                                '已选择颜色：${controller.formatColorValue()}',
                              );
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: AppDesignTokens.primaryColor,
                                fontSize: AppDesignTokens.fontSize14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 颜色预览
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                        vertical: AppDesignTokens.spacingV8,
                      ),
                      padding: EdgeInsets.all(AppDesignTokens.spacing16),
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                        border: Border.all(
                          color: AppDesignTokens.textSecondary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.palette,
                            color: _getContrastColor(currentColor),
                            size: 24,
                          ),
                          SizedBox(width: AppDesignTokens.spacing8),
                          Text(
                            '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize18,
                              fontWeight: AppDesignTokens.fontWeightBold,
                              color: _getContrastColor(currentColor),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 圆形色盘 + 亮度 / 透明度
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '拖动色盘选色：环上为不同色相，越靠外颜色越鲜艳',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize12,
                              color: AppDesignTokens.textSecondary,
                              height: AppDesignTokens.lineHeightNormal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppDesignTokens.spacingV12),
                          Center(
                            child: _SelectorColorWheel(
                              hsvColor: hsvColor,
                              onChanged: (value) {
                                setState(() {
                                  hsvColor = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: AppDesignTokens.spacingV20),
                          _buildColorSliderRow(
                            label: '亮度',
                            trailing: '${(hsvColor.value * 100).round()}%',
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: hsvColor.value,
                                min: 0.0,
                                max: 1.0,
                                activeColor: currentColor,
                                onChanged: (value) {
                                  setState(() {
                                    hsvColor = HSVColor.fromAHSV(
                                      hsvColor.alpha,
                                      hsvColor.hue,
                                      hsvColor.saturation,
                                      value,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: AppDesignTokens.spacingV12),
                          _buildColorSliderRow(
                            label: '透明度',
                            trailing: '${(hsvColor.alpha * 100).round()}%',
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: hsvColor.alpha,
                                min: 0.0,
                                max: 1.0,
                                activeColor: currentColor,
                                onChanged: (value) {
                                  setState(() {
                                    hsvColor = HSVColor.fromAHSV(
                                      value,
                                      hsvColor.hue,
                                      hsvColor.saturation,
                                      hsvColor.value,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDesignTokens.spacingV16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 圆形色相-饱和度色盘
class _SelectorColorWheel extends StatelessWidget {
  static const double wheelSize = 240;
  static const double indicatorSize = 22;
  static const double edgeInset = 6;

  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onChanged;

  const _SelectorColorWheel({
    required this.hsvColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final maxRadius = wheelSize / 2 - edgeInset;
    final indicatorRadius = maxRadius * hsvColor.saturation;
    final angleRad = (hsvColor.hue / 180.0) * math.pi - math.pi / 2;
    final center = wheelSize / 2;
    final indicatorLeft = center + indicatorRadius * math.cos(angleRad) - indicatorSize / 2;
    final indicatorTop = center + indicatorRadius * math.sin(angleRad) - indicatorSize / 2;
    final selectedColor = hsvColor.toColor();

    return Container(
      width: wheelSize + 16,
      height: wheelSize + 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) => _updateFromPosition(details.localPosition),
          onPanUpdate: (details) => _updateFromPosition(details.localPosition),
          onTapDown: (details) => _updateFromPosition(details.localPosition),
          child: SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  painter: _HueSaturationWheelPainter(),
                  size: const Size(wheelSize, wheelSize),
                ),
                Positioned(
                  left: indicatorLeft,
                  top: indicatorTop,
                  child: Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedColor,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateFromPosition(Offset localPos) {
    final center = Offset(wheelSize / 2, wheelSize / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final maxRadius = wheelSize / 2 - edgeInset;

    if (distance > maxRadius) return;

    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    final hue = (angle * 180.0 / math.pi) % 360.0;
    final saturation = (distance / maxRadius).clamp(0.0, 1.0);

    onChanged(
      HSVColor.fromAHSV(
        hsvColor.alpha,
        hue,
        saturation,
        hsvColor.value,
      ),
    );
  }
}

/// HSV 圆形色盘绘制器：中心白 → 边缘纯色，环向为色相
class _HueSaturationWheelPainter extends CustomPainter {
  static const int _segmentCount = 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < _segmentCount; i++) {
      final startAngle = (i / _segmentCount) * 2 * math.pi - math.pi / 2;
      final sweepAngle = 2 * math.pi / _segmentCount;
      final hue = (i / _segmentCount) * 360.0;
      final edgeColor = _selectorHsvToColor(hue, 1.0, 1.0);

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startAngle, sweepAngle, false)
        ..close();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFFFFF), edgeColor],
        ).createShader(rect);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Color _selectorHsvToColor(double h, double s, double v) {
  return HSVColor.fromAHSV(1.0, h, s, v).toColor();
}

