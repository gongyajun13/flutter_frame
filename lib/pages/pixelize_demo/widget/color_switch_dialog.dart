import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_frame/widgets/pixelize/bc_gradient_text_button.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:get/get.dart';
import 'package:flutter_frame/overlay/overlay.dart';

import '../color_picker_dialog.dart';
import '../data/tool_item.dart';
import '../pixelize_result_controller.dart';

/// 颜色切换弹窗
class ColorSwitchDialog extends StatelessWidget {
  final PixelizeResultController controller;

  const ColorSwitchDialog({super.key, required this.controller});

  /// 根据背景颜色获取合适的文本颜色
  Color _getTextColor(Color backgroundColor) {
    final luminance = 0.299 * backgroundColor.r +
        0.587 * backgroundColor.g +
        0.114 * backgroundColor.b;
    return luminance <= 0.5 ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 0.7.sh),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
           gradient: LinearGradient(colors: AppColors.gradientBgColors2,stops: [0.0, 0.3],begin: Alignment.topCenter,end: Alignment.bottomCenter)
          ),
          margin: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  '颜色切换',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: kPFFont,
                    color: AppColors.textColorPrimary,
                  ),
                ),
                SizedBox(height: 16.w),
                // 当前使用的颜色
                Obx(() {
                  if (controller.isLoadingColors.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (controller.allUsedColors.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Text(
                          '暂无颜色数据',
                          style: TextStyle(
                            color: AppColors.textColorSecond,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '选择要替换的颜色：',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorSecond,
                              ),
                            ),
                          ),
                          // 全选/取消操作
                          Row(children: [
                            InkWell(
                              onTap: () {
                                controller.multiSelectedColorCodes.assignAll(
                                  controller.allUsedColors
                                      .map((e) => e['code'] as String),
                                );
                              },
                              child: Text(
                                '全部',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4A90E2),
                                ),
                              ),
                            ),
                            15.horizontalSpace,
                            InkWell(
                              onTap: () {
                                controller.multiSelectedColorCodes.clear();
                              },
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColorSecond,
                                ),
                              ),
                            ),
                          ],)
                        ],
                      ),
                      SizedBox(height: 10.w),
                      // 已选择要替换的颜色数量
                      Obx(() => Text(
                        '已选${controller.multiSelectedColorCodes.length}个',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColorSecond,
                        ),
                      )),
                      SizedBox(height: 10.w),
                      SizedBox(
                        height: 190.w,
                        child: GridView.builder(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8.w,
                            crossAxisSpacing: 8.w,
                            childAspectRatio: 42 / 56,
                          ),
                          itemCount: controller.allUsedColors.length,
                          itemBuilder: (context, index) {
                            final colorData = controller.allUsedColors[index];
                            final color = colorData['color'] as Color;
                            final code = colorData['code'] as String;
                            final count = colorData['count'] as int;
                            return _buildMultiSelectColorItem(
                                color, code, count);
                          },
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 16.w),
                // 分割线
                Container(
                  height: 1.w,
                  color: AppColors.sepLine.withValues(alpha: 0.3),
                ),
                SizedBox(height: 16.w),
                // 快速访问色
                Obx(() {
                  if (controller.isLoadingColors.value) {
                    return const SizedBox.shrink();
                  }

                  // 使用弹窗专用的快速访问色
                  final quickColors = controller.dialogQuickAccessColors.toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '替换成：',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColorSecond,
                        ),
                      ),
                      SizedBox(height: 10.w),
                      SizedBox(
                        height: 120.w,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8.w,
                            crossAxisSpacing: 8.w,
                            childAspectRatio: 42 / 56,
                          ),
                          itemCount: quickColors.length + 2,
                          itemBuilder: (context, index) {
                            // 头部：清空按钮
                            if (index == 0) {
                              return _buildClearItem();
                            }
                            // 尾部：更多按钮
                            if (index == quickColors.length + 1) {
                              return _buildMoreItem();
                            }
                            // 中间：颜色item
                            final colorData = quickColors[index - 1];
                            final color = colorData['color'] as Color;
                            final code = colorData['code'] as String;
                            final count = colorData['count'] as int? ?? 0;
                            return _buildColorItem(color, code, count);
                          },
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 20.w),
                Row(
                  spacing: 15.w,
                  children: [
                    Expanded(
                      child: BCGradientTextButton(
                          isDisable: true,
                          onPressed: () {
                            // 重置选中状态
                            controller.multiSelectedColorCodes.clear();
                            controller.quickAccessSelectedCode.value = null;
                            Get.back();
                          },
                          padding: EdgeInsets.symmetric(vertical: 11.w),
                          child: Text(
                            "取消",
                          )),
                    ),
                    Expanded(
                      child: BCGradientTextButton(
                          onPressed: () async {
                            final selectedCodes = controller.multiSelectedColorCodes.toList();
                            final targetCode = controller.quickAccessSelectedCode.value;

                            if (selectedCodes.isEmpty) {
                              AppOverlay.toast.info('请先选择要替换的颜色');
                              return;
                            }

                            if (targetCode == null) {
                              AppOverlay.toast.info('请选择目标操作');
                              return;
                            }

                            Get.back();

                            if (targetCode == 'clear') {
                              // 清空选中的颜色像素
                              await controller.clearColors(selectedCodes);
                            } else {
                              // 替换颜色
                              await controller.replaceColors(selectedCodes, targetCode);
                            }

                            // 重置选中状态
                            controller.multiSelectedColorCodes.clear();
                            controller.quickAccessSelectedCode.value = null;
                          },
                          padding: EdgeInsets.symmetric(vertical: 12.w),
                          child: Text(
                            "确认",
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 多选颜色项（当前使用的颜色区域）
  Widget _buildMultiSelectColorItem(Color color, String code, int count) {
    return Obx(() {
      final isSelected = controller.multiSelectedColorCodes.contains(code);
      return GestureDetector(
        onTap: () {
          if (isSelected) {
            controller.multiSelectedColorCodes.remove(code);
          } else {
            controller.multiSelectedColorCodes.add(code);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // 颜色代码
                    Center(
                      child: Text(
                        code,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(color),
                        ),
                      ),
                    ),
                    // 黑色蒙层（选中时显示）
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                        ),
                      ),
                    // 选中图标
                    if (isSelected)
                      Positioned.fill(
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/icon_selected.svg',
                            width: 20.w,
                            height: 20.w,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.w),
            Text(
              'x$count',
              style: TextStyle(
                fontSize: 9.sp,
                color: isSelected
                    ? const Color(0xFF4A90E2)
                    : AppColors.textColorSecond,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 单个颜色项（快速访问色区域 - 点击选中）
  Widget _buildColorItem(Color color, String code, int count) {
    return Obx(() {
      final isSelected = controller.quickAccessSelectedCode.value == code;
      return GestureDetector(
        onTap: () {
          controller.quickAccessSelectedCode.value = code;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(color),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.w),
            Text(
              'x$count',
              style: TextStyle(
                fontSize: 9.sp,
                color: isSelected ? const Color(0xFF4A90E2) : AppColors.textColorSecond,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 清空按钮
  Widget _buildClearItem() {
    return Obx(() {
      final isSelected = controller.quickAccessSelectedCode.value == 'clear';
      return GestureDetector(
        onTap: () {
          controller.quickAccessSelectedCode.value = 'clear';
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.appCardBgColor,
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4A90E2) : AppColors.sepLine,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/icon_color_clear.svg',
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.w),
            Text(
              '清空',
              style: TextStyle(
                fontSize: 9.sp,
                color: isSelected ? const Color(0xFF4A90E2) : AppColors.textColorSecond,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 更多按钮
  Widget _buildMoreItem() {
    return GestureDetector(
      onTap: () async {
        // 弹出颜色选择弹窗，不关闭当前弹窗
        final result = await AppOverlay.dialog.customAsync<Map<String, dynamic>>(
          child: ColorPickerDialog(controller: controller, returnSelectedColor: true),
          barrierColor: Colors.black.withValues(alpha: 0.5),
        );
        if (result != null) {
          final color = result['color'] as Color;
          final code = result['code'] as String;
          // 检查是否已存在于弹窗快速访问色中
          final existingIndex = controller.dialogQuickAccessColors.indexWhere((item) => item['code'] == code);
          if (existingIndex >= 0) {
            // 已存在，直接选中
            controller.quickAccessSelectedCode.value = code;
          } else {
            // 不存在：追加到末尾（更多按钮前面），同时移除头部最旧的一个
            final newColor = {'color': color, 'code': code};
            controller.dialogQuickAccessColors.add(newColor);
            // FIFO：保持队列长度稳定，从头部淘汰最早加入的颜色
            if (controller.dialogQuickAccessColors.length > 4) {
              final removed = controller.dialogQuickAccessColors.removeAt(0);
              // 如果被淘汰的颜色正好是当前选中的，清除选中状态
              if (controller.quickAccessSelectedCode.value == removed['code']) {
                controller.quickAccessSelectedCode.value = null;
              }
            }
            // 选中该颜色
            controller.quickAccessSelectedCode.value = code;
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.appCardBgColor,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: AppColors.sepLine, width: 1),
              ),
              child: Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorSecond,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            '更多',
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.textColorSecond,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
