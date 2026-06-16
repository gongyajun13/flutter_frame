import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';

import 'package:flutter_frame/overlay/overlay.dart';

/// 设置网格粗细弹窗（底部弹出）
class GridThicknessSheet extends StatefulWidget {
  /// 当前选中的值
  final double selectedValue;

  /// 值变更回调
  final ValueChanged<double>? onValueChanged;

  const GridThicknessSheet({super.key, this.selectedValue = 3.0, this.onValueChanged});

  /// 弹出底部弹窗
  static void show(
    BuildContext context, {
    double selectedValue = 3.0,
    ValueChanged<double>? onValueChanged,
  }) {
    AppOverlay.sheet.show(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      child: GridThicknessSheet(
        selectedValue: selectedValue,
        onValueChanged: onValueChanged,
      ),
    );
  }

  @override
  State<GridThicknessSheet> createState() => _GridThicknessSheetState();
}

class _GridThicknessSheetState extends State<GridThicknessSheet> {
  late double _selected;
  late FixedExtentScrollController _scrollController;

  // 可选范围 0.5 ~ 10.0，步长 0.1
  static const double _min = 0.5;
  static const double _max = 10.0;
  static const double _step = 0.1;

  List<double> get _values => List.generate(
        ((_max - _min) / _step).round() + 1,
        (i) => _min + i * _step,
      );

  int _indexForValue(double value) =>
      ((value - _min) / _step).round().clamp(0, _values.length - 1);

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedValue.clamp(_min, _max);
    _scrollController =
        FixedExtentScrollController(initialItem: _indexForValue(_selected));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                      '设置参考线粗细（0.5-10）',
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

              SizedBox(height: 12.w),

              // 滚动选择器（固定高度）
              SizedBox(
                height: 220.h,
                child: CupertinoPicker(
                  scrollController: _scrollController,
                  itemExtent: 40.h,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.textColorHighlight.withOpacity(0.3), width: 1),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() => _selected = _values[index]);
                    widget.onValueChanged?.call(_selected);
                  },
                  children: _values.map((value) {
                    final isSelected = value == _selected;
                    return Center(
                      child: Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

              SizedBox(height: 12.w),
            ],
          ),
        ),
      ),
    );
  }
}
