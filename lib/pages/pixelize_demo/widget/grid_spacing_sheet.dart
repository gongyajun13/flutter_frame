import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';

import 'package:flutter_frame/overlay/overlay.dart';

/// 设置粗网格间隔弹窗（底部弹出）
class GridSpacingSheet extends StatefulWidget {
  /// 当前选中的值
  final int selectedValue;

  /// 值变更回调
  final ValueChanged<int>? onValueChanged;

  const GridSpacingSheet({super.key, this.selectedValue = 9, this.onValueChanged});

  /// 弹出底部弹窗
  static void show(
    BuildContext context, {
    int selectedValue = 9,
    ValueChanged<int>? onValueChanged,
  }) {
    AppOverlay.sheet.show(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      child: GridSpacingSheet(
        selectedValue: selectedValue,
        onValueChanged: onValueChanged,
      ),
    );
  }

  @override
  State<GridSpacingSheet> createState() => _GridSpacingSheetState();
}

class _GridSpacingSheetState extends State<GridSpacingSheet> {
  late int _selected;
  late FixedExtentScrollController _scrollController;

  // 可选范围 2 ~ 20
  static const int _min = 2;
  static const int _max = 20;

  List<int> get _values =>
      List.generate(_max - _min + 1, (i) => _min + i);

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedValue.clamp(_min, _max);
    _scrollController =
        FixedExtentScrollController(initialItem: _selected - _min);
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
                      '设置粗网格间隔（2-20）',
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
                  onSelectedItemChanged: (index) {
                    setState(() => _selected = _values[index]);
                    widget.onValueChanged?.call(_selected);
                  },
                  children: _values.map((value) {
                    final isSelected = value == _selected;
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

              SizedBox(height: 12.w),
            ],
          ),
        ),
      ),
    );
  }
}
