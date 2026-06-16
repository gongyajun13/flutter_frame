import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:flutter_frame/base/base_view.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/utils/pixelize_util.dart';
import 'color_picker_dialog.dart';
import 'pixel_canvas.dart';
import 'pixelize_result_controller.dart';
import 'data/tool_item.dart';
import 'widget/input_text_dialog.dart';

/// 画布页面
class PixelizeResultPage extends BaseView<PixelizeResultController> {
  PixelizeResultPage({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return null;
  }

  @override
  Widget body(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) return;
        controller.confirmExit();
      },
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color(0xFFFFEEC5),
            Color(0xFFF7F7F7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Column(
          children: [
            _buildTitle(),
            // 像素化图片卡片（固定在顶部，不滚动）
            _buildPixelizedImageCard(),
            SizedBox(height: 10.w),
            // 其他内容区域（可滚动，为后续功能预留）
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.w),
                child: Column(
                  children: [
                    _buildColorUsageStats(),
                    SizedBox(height: 10.w),
                    _buildQuickAccessColors(context),
                    _buildEditTools(),
                    SizedBox(height: 10.w),
                    _buildOtherTools(),
                    SizedBox(height: 10.w),
                    if (!controller.isBlankCanvasMode) _buildReduceColor(),
                    SizedBox(height: 10.w),
                    _buildBrandColor(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 标题
  Widget _buildTitle() {
    return Container(
      height: 44.h,
      margin: EdgeInsets.only(top: 44.w, left: 15.w, right: 15.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  controller.confirmExit();
                },
                child: Image.asset(
                  "assets/icons/icon_common_back.png",
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 上一步
                  InkWell(
                    onTap: () => controller.undo(),
                    child: Obx(() {
                      final hasPre = controller.hasPreStep.value;
                      return SvgPicture.asset(
                        'assets/icons/icon_step_pre.svg',
                        colorFilter: ColorFilter.mode(
                          hasPre ? Colors.black : const Color(0xFFECDEBE),
                          BlendMode.srcIn,
                        ),
                        width: 24.w,
                        height: 24.w,
                      );
                    }),
                  ),
                  SizedBox(width: 16.w),

                  /// 下一步
                  InkWell(
                    onTap: () => controller.redo(),
                    child: Obx(() {
                      final hasNext = controller.hasNextStep.value;
                      return SvgPicture.asset(
                        'assets/icons/icon_step_next.svg',
                        colorFilter: ColorFilter.mode(
                          hasNext ? Colors.black : const Color(0xFFECDEBE),
                          BlendMode.srcIn,
                        ),
                        width: 24.w,
                        height: 24.w,
                      );
                    }),
                  ),
                  SizedBox(width: 12.w),
                  _buildTitleSaveAction(),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  /// 标题栏：导出
  Widget _buildTitleSaveAction() {
    return InkWell(
      onTap: controller.exportImage,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          '导出',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// 像素化图片卡片
  Widget _buildPixelizedImageCard() {
    return Obx(() {
      // 使用 isDataLoaded 判断数据是否就绪（服务端加载时 originalImage 可能为 null）
      if (!controller.isDataLoaded.value) {
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            height: 345.h,
            margin: EdgeInsets.only(left: 15.w, right: 15.w, top: 5.w),

            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16.w)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/icon_diaosepan.png",
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    '拼豆画布区域',
                    style: TextStyle(
                      color: AppColors.textColorSecond,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Container(
        height: 375.h,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16.w)),
        margin: EdgeInsets.only(top: 5.w),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.w),
            child: RepaintBoundary(
              key: controller.pixelCanvasKey,
              child: PixelCanvas(
                imageFile: controller.originalImage.value,
                onPixelTapped: (x, y, color) {
                  controller.updatePixelColor(x, y);
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 使用的颜色统计
  Widget _buildColorUsageStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '使用的颜色',
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        SizedBox(height: 5.w),
        Obx(() {
          if (controller.isLoadingColors.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.colorUsageStats.isEmpty) {
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

          return SizedBox(
            height: 50.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.colorUsageStats.length,
              itemBuilder: (context, index) {
                final colorData = controller.colorUsageStats[index];
                final color = colorData['color'] as Color;
                final code = colorData['code'] as String;
                final count = colorData['count'] as int;

                return _buildColorItem(color, code, count);
              },
            ),
          );
        }),
      ],
    );
  }

  /// 快速访问色
  Widget _buildQuickAccessColors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速访问色',
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        SizedBox(height: 5.w),
        Obx(() {
          if (controller.isLoadingColors.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final quickAccessColors = controller.quickAccessColors;
          final selectedColors = controller.selectedColors;

          if (quickAccessColors.isEmpty &&
              controller.allColors.isEmpty &&
              selectedColors.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  '颜色库已用完',
                  style: TextStyle(
                    color: AppColors.textColorSecond,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }

          // 计算总item数量：quickAccessColors + 分割线 + selectedColors + 更多按钮
          final totalItems = quickAccessColors.length +
              (selectedColors.isNotEmpty ? 1 : 0) +
              selectedColors.length +
              1;

          return SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: totalItems,
              itemBuilder: (context, index) {
                // quickAccessColors 部分
                if (index < quickAccessColors.length) {
                  final colorData = quickAccessColors[index];
                  final color = colorData['color'] as Color;
                  final code = colorData['code'] as String;
                  return _buildQuickAccessColorItem(color, code);
                }

                // 分割线（只在有 selectedColors 时显示）
                if (selectedColors.isNotEmpty &&
                    index == quickAccessColors.length) {
                  return Container(
                    width: 1.w,
                    height: 5.h,
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: AppColors.sepLine,
                    ),
                  );
                }

                // selectedColors 部分
                final selectedIndex = index -
                    quickAccessColors.length -
                    (selectedColors.isNotEmpty ? 1 : 0);
                if (selectedIndex < selectedColors.length) {
                  final colorData = selectedColors[selectedIndex];
                  final color = colorData['color'] as Color;
                  final code = colorData['code'] as String;
                  return _buildQuickAccessColorItem(color, code);
                }

                // 最后一个item是"更多色"按钮
                return _buildMoreColorsButtonItem(context);
              },
            ),
          );
        }),
      ],
    );
  }

  /// 更多色按钮item
  Widget _buildMoreColorsButtonItem(BuildContext context) {
    return GestureDetector(
        onTap: () {
          ColorPickerDialog.show(context, controller);
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.5.w, horizontal: 1.5.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.w),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFEE904),
                    Color(0xFF0DEBFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.w),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 5.w),
                child: Center(
                  child: Text(
                    'More',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  /// 编辑工具
  Widget _buildEditTools() {
    return Obx(() {
      final locked = controller.pendingText.value.isNotEmpty;
      return Stack(
        children: [
          _buildEditToolsContent(),
          if (locked)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  /// 编辑工具内容（实际构建逻辑）
  Widget _buildEditToolsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '编辑工具',
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        SizedBox(height: 5.w),
        SizedBox(
          height: 50.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: controller.editTools.length,
            itemBuilder: (context, index) {
              final tool = controller.editTools[index];
              // 弹窗类型工具
              if (tool.type == ToolType.popupAction) {
                return Container(
                  width: 32.w,
                  margin: EdgeInsets.only(right: 8.w),
                  child: _buildPopupToolItem(tool),
                );
              }
              // 即时动作工具
              if (tool.type == ToolType.immediateAction) {
                return Container(
                  width: tool.toolMode== ToolMode.rotate||tool.toolMode== ToolMode.flip?42.w:32.w,
                  margin: EdgeInsets.only(right: 8.w),
                  child: _buildToolGridItem(
                    iconAsset: tool.iconAsset,
                    label: tool.label,
                    isSelected: false,
                    onTap: tool.getOnTap(controller),
                  ),
                );
              }
              return Obx(() {
                final isSelected = tool.getIsSelected(controller);
                return Container(
                  width: 32.w,
                  margin: EdgeInsets.only(right: 8.w),
                  child: _buildToolGridItem(
                    iconAsset: tool.iconAsset,
                    label: tool.label,
                    isSelected: isSelected,
                    onTap: tool.getOnTap(controller),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  /// 构建弹窗类型工具项（旋转、翻转、喷枪）
  Widget _buildPopupToolItem(ToolItem tool) {
    // if (tool.toolMode == ToolMode.rotate) {
    //   return CustomPopup(
    //     showArrow: false,
    //     barrierColor: Colors.black.withValues(alpha: 0.1),
    //     position: PopupPosition.top,
    //     content: _buildRotatePopupContent(),
    //     child: Obx(() => _buildToolGridItemNoTap(
    //           iconAsset: _getRotateIcon(),
    //           label: tool.label,
    //         )),
    //   );
    // }
    // if (tool.toolMode == ToolMode.flip) {
    //   return CustomPopup(
    //     showArrow: false,
    //     barrierColor: Colors.black.withValues(alpha: 0.1),
    //     position: PopupPosition.top,
    //     content: _buildFlipPopupContent(),
    //     child: Obx(() => _buildToolGridItemNoTap(
    //           iconAsset: _getFlipIcon(),
    //           label: tool.label,
    //         )),
    //   );
    // }
    if (tool.toolMode == ToolMode.shape) {
      return CustomPopup(
        showArrow: false,
        barrierColor: Colors.black.withValues(alpha: 0.1),
        position: PopupPosition.top,
        content: _buildShapePopupContent(),
        child: Obx(() => _buildToolGridItemNoTap(
              iconAsset: _getShapeIcon(),
              label: _getShapeLabel(),
              isSelected: controller.currentToolMode.value == ToolMode.shape,
            )),
      );
    }
    if (tool.toolMode == ToolMode.sprayGun) {
      return CustomPopup(
        showArrow: false,
        barrierColor: Colors.black.withValues(alpha: 0.1),
        position: PopupPosition.top,
        content: _buildSprayGunPopupContent(),
        child: Obx(() => _buildToolGridItemNoTap(
              iconAsset: _getSprayGunIcon(),
              label: _getSprayGunLabel(),
              isSelected: controller.currentToolMode.value == ToolMode.sprayGun,
            )),
      );
    }
    if (tool.toolMode == ToolMode.text) {
      return Obx(() => _buildToolGridItem(
            iconAsset: tool.iconAsset,
            label: tool.label,
            isSelected: controller.currentToolMode.value == ToolMode.text,
            onTap: () async {
              final text = await showInputTextDialog();
              if (text != null && text.isNotEmpty) {
                controller.setPendingText(text);
              }
            },
          ));
    }
    return _buildToolGridItem(
      iconAsset: tool.iconAsset,
      label: tool.label,
      isSelected: false,
      onTap: () {},
    );
  }

  /// 获取形状显示图标
  String _getShapeIcon() {
    if (controller.currentToolMode.value != ToolMode.shape)
      return 'assets/icons/icon_tools_shape.svg';
    const icons = {
      'rect': 'assets/icons/icon_shape_rect.svg',
      'rect_fill': 'assets/icons/icon_shape_rect_fill.svg',
      'circle': 'assets/icons/icon_shape_circle.svg',
      'circle_fill': 'assets/icons/icon_shape_circle_fill.svg',
      'line': 'assets/icons/icon_shape_line.svg',
      'triangle': 'assets/icons/icon_shape_triangle.svg',
      'triangle_fill': 'assets/icons/icon_shape_triangle_fill.svg',
      'diamond': 'assets/icons/icon_shape_diamond.svg',
      'diamond_fill': 'assets/icons/icon_shape_diamond_fill.svg',
    };
    return icons[controller.selectedShapeType.value] ??
        'assets/icons/icon_tools_shape.svg';
  }

  /// 获取形状显示标签
  String _getShapeLabel() {
    if (controller.currentToolMode.value != ToolMode.shape) return '形状';
    const labels = {
      'rect': '矩形',
      'rect_fill': '实心矩形',
      'circle': '圆形',
      'circle_fill': '实心圆形',
      'line': '直线',
      'triangle': '三角形',
      'triangle_fill': '实心三角形',
      'diamond': '菱形',
      'diamond_fill': '实心菱形',
    };
    return labels[controller.selectedShapeType.value] ?? '形状';
  }

  /// 获取旋转工具显示图标（根据上次选中的操作）
  String _getRotateIcon() {
    const icons = {
      'left90': 'assets/icons/icon_rotate_left90.svg',
      'right90': 'assets/icons/icon_rotate_right90.svg',
      '180': 'assets/icons/icon_rotate_180.svg',
    };
    return icons[controller.lastRotateOption.value] ??
        'assets/icons/icon_tools_rotate.svg';
  }

  /// 获取翻转工具显示图标（根据上次选中的操作）
  String _getFlipIcon() {
    const icons = {
      'horizontal': 'assets/icons/icon_flip_horizontal.svg',
      'vertical': 'assets/icons/icon_flip_vertical.svg',
    };
    return icons[controller.lastFlipOption.value] ??
        'assets/icons/icon_tools_flip.svg';
  }

  /// 构建形状弹窗内容
  Widget _buildShapePopupContent() {
    final options = [
      ('rect', 'assets/icons/icon_shape_rect.svg', '矩形'),
      ('rect_fill', 'assets/icons/icon_shape_rect_fill.svg', '实心矩形'),
      ('circle', 'assets/icons/icon_shape_circle.svg', '圆形'),
      ('circle_fill', 'assets/icons/icon_shape_circle_fill.svg', '实心圆形'),
      ('line', 'assets/icons/icon_shape_line.svg', '直线'),
      ('triangle', 'assets/icons/icon_shape_triangle.svg', '三角形'),
      ('triangle_fill', 'assets/icons/icon_shape_triangle_fill.svg', '实心三角形'),
      ('diamond', 'assets/icons/icon_shape_diamond.svg', '菱形'),
      ('diamond_fill', 'assets/icons/icon_shape_diamond_fill.svg', '实心菱形'),
    ];
    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cFAC331, width: 1.w),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: options
              .map((e) =>
                  _buildShapeOption(type: e.$1, iconAsset: e.$2, label: e.$3))
              .toList(),
        ),
      ),
    );
  }

  /// 构建形状选项（单行）
  Widget _buildShapeOption({
    required String type,
    required String iconAsset,
    required String label,
  }) {
    return Obx(() {
      final isSelected = controller.currentToolMode.value == ToolMode.shape &&
          controller.selectedShapeType.value == type;
      return InkWell(
        onTap: () => controller.setShapeType(type),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFFFFF8E4),
                  borderRadius: BorderRadius.circular(8.w),
                )
              : BoxDecoration(
                  color: Colors.white,
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.cFAC331 : AppColors.textColorPrimary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected
                      ? AppColors.cFAC331
                      : AppColors.textColorPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 获取喷枪显示标签
  String _getSprayGunLabel() {
    if (controller.currentToolMode.value != ToolMode.sprayGun) {
      return '喷枪';
    }
    switch (controller.sprayGunSize.value) {
      case 1:
        return '小喷枪';
      case 2:
        return '中喷枪';
      case 3:
        return '大喷枪';
      default:
        return '喷枪';
    }
  }

  /// 获取喷枪显示图标
  String _getSprayGunIcon() {
    if (controller.currentToolMode.value != ToolMode.sprayGun) {
      return 'assets/icons/icon_tools_spray_gun.svg';
    }
    switch (controller.sprayGunSize.value) {
      case 1:
        return 'assets/icons/icon_spray_gun_small.svg';
      case 2:
        return 'assets/icons/icon_spray_gun_middle.svg';
      case 3:
        return 'assets/icons/icon_spray_gun_big.svg';
      default:
        return 'assets/icons/icon_tools_spray_gun.svg';
    }
  }

  /// 构建喷枪弹窗内容
  Widget _buildSprayGunPopupContent() {
    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.cFAC331,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSprayGunOption(
              iconAsset: 'assets/icons/icon_spray_gun_small.svg',
              label: '小喷枪',
              size: 1,
            ),
            _buildSprayGunOption(
              iconAsset: 'assets/icons/icon_spray_gun_middle.svg',
              label: '中喷枪',
              size: 2,
            ),
            _buildSprayGunOption(
              iconAsset: 'assets/icons/icon_spray_gun_big.svg',
              label: '大喷枪',
              size: 3,
            ),
          ],
        ),
      ),

    );
  }

  /// 构建喷枪选项
  Widget _buildSprayGunOption({
    required String iconAsset,
    required String label,
    required int size,
  }) {
    return Obx(() {
      final isSelected =
          controller.currentToolMode.value == ToolMode.sprayGun &&
              controller.sprayGunSize.value == size;
      return InkWell(
        onTap: () {
          controller.setSprayGunSize(size);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFFFFF8E4),
                  borderRadius: BorderRadius.circular(8.w),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 16.w,
                height: 16.w,
                color:
                    isSelected ? AppColors.cFAC331 : AppColors.textColorPrimary,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected
                      ? AppColors.cFAC331
                      : AppColors.textColorPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 构建旋转弹窗内容
  Widget _buildRotatePopupContent() {
    return Obx(() => IntrinsicWidth(
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColors.cFAC331,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRotateOption(
                  iconAsset: 'assets/icons/icon_rotate_left90.svg',
                  label: '逆时针旋转90°',
                  optionValue: 'left90',
                  isSelected: controller.lastRotateOption.value == 'left90',
                  onTap: () => controller.rotateLeft90(),
                ),
                _buildRotateOption(
                  iconAsset: 'assets/icons/icon_rotate_right90.svg',
                  label: '顺时针旋转90°',
                  optionValue: 'right90',
                  isSelected: controller.lastRotateOption.value == 'right90',
                  onTap: () => controller.rotateRight90(),
                ),
                _buildRotateOption(
                  iconAsset: 'assets/icons/icon_rotate_180.svg',
                  label: '旋转180°',
                  optionValue: '180',
                  isSelected: controller.lastRotateOption.value == '180',
                  onTap: () => controller.rotate180(),
                ),
              ],
            ),
          ),
        ));
  }

  /// 构建旋转/翻转选项
  Widget _buildRotateOption({
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
    String optionValue = '',
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 16.w,
              height: 16.w,
              colorFilter: isSelected
                  ? const ColorFilter.mode(Color(0xFFF57C00), BlendMode.srcIn)
                  : null,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? const Color(0xFFF57C00) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建翻转弹窗内容
  Widget _buildFlipPopupContent() {
    return Obx(() => IntrinsicWidth(
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColors.cFAC331,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRotateOption(
                  iconAsset: 'assets/icons/icon_flip_horizontal.svg',
                  label: '水平翻转',
                  optionValue: 'horizontal',
                  isSelected: controller.lastFlipOption.value == 'horizontal',
                  onTap: () => controller.flipHorizontal(),
                ),
                _buildRotateOption(
                  iconAsset: 'assets/icons/icon_flip_vertical.svg',
                  label: '垂直翻转',
                  optionValue: 'vertical',
                  isSelected: controller.lastFlipOption.value == 'vertical',
                  onTap: () => controller.flipVertical(),
                ),
              ],
            ),
          ),
        ));
  }

  /// 其他工具项数据列表
  List<ToolItem> get _otherTools => controller.otherTools;

  /// 其他工具
  Widget _buildOtherTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '其他工具',
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        SizedBox(height: 5.w),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.w,
            childAspectRatio: 32 / 50,
          ),
          itemCount: _otherTools.length,
          itemBuilder: (context, index) {
            final tool = _otherTools[index];
            // 即时动作工具（放大、缩小）不需要响应式
            if (tool.type == ToolType.immediateAction) {
              return _buildToolGridItem(
                iconAsset: tool.iconAsset,
                label: tool.label,
                isSelected: false,
                onTap: tool.getOnTap(controller),
              );
            }
            // 其他工具需要响应式状态
            return Obx(() {
              final isSelected = tool.getIsSelected(controller);
              // 形状工具：动态切换图标和文字
              String icon = tool.iconAsset;
              String label = tool.label;
              if (tool.toolMode == ToolMode.square) {
                icon = controller.isCircleMode.value
                    ? 'assets/icons/icon_tools_item_shape_circle.svg'
                    : 'assets/icons/icon_tools_item_shape.svg';
                label = controller.isCircleMode.value ? '圆形' : '方形';
              }
              return _buildToolGridItem(
                iconAsset: icon,
                label: label,
                isSelected: isSelected,
                onTap: tool.getOnTap(controller),
              );
            });
          },
        ),
      ],
    );
  }

  /// 选择减色
  Widget _buildReduceColor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择减色',
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        SizedBox(height: 5.w),
        // 6种减色选项：全部，最多128色，最多64色，最多32色，最多16色，最多8色
        SizedBox(
          height: 33.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ColorLimit.values.length,
            itemBuilder: (context, index) {
              return _buildReduceColorItem(index);
            },
          ),
        ),
      ],
    );
  }

  /// 单个减色选项项
  Widget _buildReduceColorItem(int index) {
    final colorLimit = ColorLimit.values[index];

    return Obx(() {
      final isSelected = controller.selectedColorLimitIndex.value == index;
      final isDisabled = controller.isReprocessing.value;

      return GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                controller.changeColorLimit(index);
              },
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.w),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF8E4) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: isSelected
                  ? Border.all(
                      width: 1.w,
                      color: const Color(0xFFFAC331),
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              colorLimit.label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textColorPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 品牌颜色
  Widget _buildBrandColor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '品牌颜色',
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        SizedBox(height: 5.w),
        SizedBox(
          height: 33.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: BeadBrand.values.length,
            itemBuilder: (context, index) {
              return _buildBeadBrandItem(index);
            },
          ),
        ),
        SizedBox(height: 50.w),
      ],
    );
  }

  /// 单个品牌选项项
  Widget _buildBeadBrandItem(int index) {
    final beadBrand = BeadBrand.values[index];

    return Obx(() {
      final isSelected = controller.selectedBeadBrandIndex.value == index;
      final isDisabled = controller.isReprocessing.value;

      return GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                controller.changeBeadBrand(index);
              },
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.w),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF8E4) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: isSelected
                  ? Border.all(
                      width: 1.w,
                      color: const Color(0xFFFAC331),
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              beadBrand.displayName,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textColorPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 网格工具项（无GestureDetector，用于被CustomPopup包裹时避免点击事件被拦截）
  Widget _buildToolGridItemNoTap({
    required String iconAsset,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            height: 32.w,
            width: 32.w,
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF8E4) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: isSelected
                  ? Border.all(
                      width: 1.5.w,
                      color: const Color(0xFFFAC331),
                    )
                  : Border.all(
                      width: 1.5.w,
                      color: const Color(0xFFDDDDDD),
                    ),
            ),
            child: SvgPicture.asset(
              iconAsset,
              key: ValueKey(iconAsset),
            )),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.textColorPrimary,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 网格工具项
  Widget _buildToolGridItem({
    required String iconAsset,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: 32.w,
              width: 32.w,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF8E4) : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: isSelected
                    ? Border.all(
                        width: 1.5.w,
                        color: const Color(0xFFFAC331),
                      )
                    : Border.all(
                        width: 1.5.w,
                        color: const Color(0xFFDDDDDD),
                      ),
              ),
              child: SvgPicture.asset(
                iconAsset,
                key: ValueKey(iconAsset),
              )),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textColorPrimary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 单个颜色项
  Widget _buildColorItem(Color color, String code, int count) {
    return Obx(() {
      final isSelected = controller.brushColorCode.value == code;
      return GestureDetector(
        onTap: () {
          // 喷枪/形状/泛填充/文本模式保持当前模式；否则切换到绘画模式
          final mode = controller.currentToolMode.value;
          if(mode == ToolMode.view){
            controller.updatePixelColor(-1,-1,codeValue: code, countValue: count);
            return;
          }
          if(mode == ToolMode.locationLine){
            // controller.updatePixelColor(-1,-1,codeValue: code, countValue: count);
            return;
          }
          if (mode != ToolMode.sprayGun &&
              mode != ToolMode.shape &&
              mode != ToolMode.floodFill &&
              mode != ToolMode.text) {
            controller.switchToolMode(ToolMode.draw);
          }
          controller.setBrushColor(color, code);
        },
        child: Container(
          margin: EdgeInsets.only(right: 6.w),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 5.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: isSelected ? AppColors.cFAC331 : Colors.white,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.cFAC331.withValues(alpha: 0.3),
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(color),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.w),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isSelected
                      ? AppColors.cFAC331
                      : AppColors.textColorSecond,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 单个快速访问色项
  Widget _buildQuickAccessColorItem(Color color, String code) {
    return Obx(() {
      final isSelected = controller.brushColorCode.value == code;
      return GestureDetector(
        onTap: () {
          // 喷枪/形状/泛填充/文本模式保持当前模式；否则切换到绘画模式
          final mode = controller.currentToolMode.value;
          if (mode != ToolMode.sprayGun &&
              mode != ToolMode.view &&
              mode != ToolMode.locationLine &&
              mode != ToolMode.shape &&
              mode != ToolMode.floodFill &&
              mode != ToolMode.text) {
            controller.switchToolMode(ToolMode.draw);
          }
          controller.setBrushColor(color, code);
        },
        child: Container(
          margin: EdgeInsets.only(right: 4.w),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 5.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: isSelected ? AppColors.cFAC331 : Colors.white,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.cFAC331.withValues(alpha: 0.3),
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(color),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
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


