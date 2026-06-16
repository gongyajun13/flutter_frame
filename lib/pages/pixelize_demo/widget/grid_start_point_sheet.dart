import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';

import 'package:flutter_frame/overlay/overlay.dart';

/// 设置参考线起始位置弹窗（底部弹出）
class GridStartPointSheet extends StatefulWidget {
  /// 当前选中的横向偏移
  final int offsetX;

  /// 当前选中的纵向偏移
  final int offsetY;

  /// 值变更回调
  final ValueChanged<Offset>? onValueChanged;

  const GridStartPointSheet({
    super.key,
    this.offsetX = 1,
    this.offsetY = 1,
    this.onValueChanged,
  });

  /// 弹出底部弹窗
  static void show(
    BuildContext context, {
    int offsetX = 1,
    int offsetY = 1,
    ValueChanged<Offset>? onValueChanged,
  }) {
    AppOverlay.sheet.show(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      child: GridStartPointSheet(
        offsetX: offsetX,
        offsetY: offsetY,
        onValueChanged: onValueChanged,
      ),
    );
  }

  @override
  State<GridStartPointSheet> createState() => _GridStartPointSheetState();
}

class _GridStartPointSheetState extends State<GridStartPointSheet> {
  late int _offsetX;
  late int _offsetY;
  late FixedExtentScrollController _scrollControllerX;
  late FixedExtentScrollController _scrollControllerY;

  // 可选范围 0 ~ 10
  static const int _min = 0;
  static const int _max = 10;

  List<int> get _values =>
      List.generate(_max - _min + 1, (i) => _min + i);

  @override
  void initState() {
    super.initState();
    _offsetX = widget.offsetX.clamp(_min, _max);
    _offsetY = widget.offsetY.clamp(_min, _max);
    _scrollControllerX =
        FixedExtentScrollController(initialItem: _offsetX - _min);
    _scrollControllerY =
        FixedExtentScrollController(initialItem: _offsetY - _min);
  }

  @override
  void dispose() {
    _scrollControllerX.dispose();
    _scrollControllerY.dispose();
    super.dispose();
  }

  void _onOffsetXChanged(int index) {
    setState(() => _offsetX = _values[index]);
    widget.onValueChanged?.call(Offset(_offsetX.toDouble(), _offsetY.toDouble()));
  }

  void _onOffsetYChanged(int index) {
    setState(() => _offsetY = _values[index]);
    widget.onValueChanged?.call(Offset(_offsetX.toDouble(), _offsetY.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.75.sh),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientBgColors2,
          stops: [0.0, 0.3],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.w, 24.w, 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题行 + 关闭按钮
              Stack(
                children: [
                  Center(
                    child: Text(
                      '设置参考线起始位置',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: kPFFont,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0.w,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        "assets/icons/icon_dialog_close.svg",
                        width: 15.w,
                        height: 15.w,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.w),

              // 列标题
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          '横向偏移',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textColorPrimary.withOpacity(0.5),
                            fontFamily: kPFFont,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '纵向偏移',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textColorPrimary.withOpacity(0.5),
                            fontFamily: kPFFont,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.w),

              // 双列滚动选择器
              SizedBox(
                height: 220.h,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _scrollControllerX,
                        itemExtent: 48.h,
                        selectionOverlay: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color:
                                    AppColors.textColorHighlight.withOpacity(0.3),
                                width: 1),
                          ),
                        ),
                        onSelectedItemChanged: _onOffsetXChanged,
                        children: _values.map((value) {
                          final isSelected = value == _offsetX;
                          return Center(
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.textColorPrimary
                                    : AppColors.textColorPrimary.withOpacity(0.3),
                                fontFamily: kPFFont,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _scrollControllerY,
                        itemExtent: 48.h,
                        selectionOverlay: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color:
                                    AppColors.textColorHighlight.withOpacity(0.3),
                                width: 1),
                          ),
                        ),
                        onSelectedItemChanged: _onOffsetYChanged,
                        children: _values.map((value) {
                          final isSelected = value == _offsetY;
                          return Center(
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.textColorPrimary
                                    : AppColors.textColorPrimary.withOpacity(0.3),
                                fontFamily: kPFFont,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.w),
            ],
          ),
        ),
      ),
    );
  }
}
