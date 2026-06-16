import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import 'package:get/get.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'data/tool_item.dart';
import 'pixelize_result_controller.dart';

/// 颜色选择弹窗
class ColorPickerDialog extends StatelessWidget {
  final PixelizeResultController controller;
  final bool returnSelectedColor; // 是否返回选中的颜色而不是直接设置

  const ColorPickerDialog({
    super.key,
    required this.controller,
    this.returnSelectedColor = false,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    PixelizeResultController controller, {
    bool returnSelectedColor = false,
  }) {
    return AppOverlay.dialog.customAsync<Map<String, dynamic>>(
      child: ColorPickerDialog(
        controller: controller,
        returnSelectedColor: returnSelectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(
            '选择颜色',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      // contentPadding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 8.w),
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 64.w,
        height: 500.h,
        child: Obx(() {
          if (controller.allColors.isEmpty) {
            return Center(
              child: Text(
                '暂无颜色数据',
                style: TextStyle(
                  color: AppColors.textColorSecond,
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          // 按代码首字母分组
          final groupedColors = <String, List<Map<String, dynamic>>>{};
          for (final colorData in controller.allColors) {
            final code = colorData['code'] as String;
            if (code.isNotEmpty) {
              final group = code[0].toUpperCase();
              if (!groupedColors.containsKey(group)) {
                groupedColors[group] = [];
              }
              groupedColors[group]!.add(colorData);
            }
          }

          // 按组名排序
          final sortedGroups = groupedColors.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedGroups.length,
            itemBuilder: (context, groupIndex) {
              final group = sortedGroups[groupIndex];
              final colorsInGroup = groupedColors[group]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分组标题
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 16.w, 0, 8.w),
                    child: Text(
                      group,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorSecond,
                      ),
                    ),
                  ),
                  // 分组内的颜色网格
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 20.w,
                      mainAxisSpacing: 10.w,
                      childAspectRatio: 1,
                    ),
                    itemCount: colorsInGroup.length,
                    itemBuilder: (context, index) {
                      final colorData = colorsInGroup[index];
                      final color = colorData['color'] as Color;
                      final code = colorData['code'] as String;

                      final isSelected = controller.brushColorCode.value == code;

                      return GestureDetector(
                        onTap: () {
                          if (returnSelectedColor) {
                            // 返回选中的颜色数据
                            Get.back(result: {
                              'color': color,
                              'code': code,
                            });
                          } else {
                            // 直接设置颜色并关闭
                            // 查看模式下选颜色，自动切回绘画模式；其他模式保持不变
                            // if (controller.currentToolMode.value == ToolMode.view) {
                            //   controller.switchToolMode(ToolMode.draw);
                            // }
                            controller.selectColorFromPicker(color, code);
                            Get.back();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.c7D70E1 : Colors.transparent,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.c7D70E1.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              code,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: _getTextColor(color),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  /// 根据背景颜色获取合适的文本颜色
  Color _getTextColor(Color backgroundColor) {
    // 计算亮度（使用相对亮度公式）
    final luminance = 0.299 * backgroundColor.r +
        0.587 * backgroundColor.g +
        0.114 * backgroundColor.b;
    return luminance <= 0.5 ? Colors.white : Colors.black;
  }
}
