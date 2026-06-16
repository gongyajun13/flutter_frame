import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';

import 'package:flutter_frame/overlay/overlay.dart';

/// 设置拼接板尺寸弹窗（底部弹出）
class BaseplateSizeSheet extends StatefulWidget {
  /// 当前选中的值（null 表示无拼接）
  final int? selectedValue;

  /// 尺寸变更回调
  final ValueChanged<int?>? onValueChanged;

  const BaseplateSizeSheet({super.key, this.selectedValue, this.onValueChanged});

  /// 弹出底部弹窗
  static void show(
    BuildContext context, {
    int? selectedValue,
    ValueChanged<int?>? onValueChanged,
  }) {
    AppOverlay.sheet.show(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      child: BaseplateSizeSheet(
        selectedValue: selectedValue,
        onValueChanged: onValueChanged,
      ),
    );
  }

  @override
  State<BaseplateSizeSheet> createState() => _BaseplateSizeSheetState();
}

class _BaseplateSizeSheetState extends State<BaseplateSizeSheet> {
  int? _selected;
  late FixedExtentScrollController _scrollController;

  // 可选尺寸范围 1 ~ 120
  static const int _min = 1;
  static const int _max = 120;

  List<int> get _values => List.generate(_max - _min + 1, (i) => _min + i);

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedValue ?? _min;
    final initialIndex = (_selected! - _min).clamp(0, _values.length - 1);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
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
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                16.w.verticalSpace,
                // 副标题
                Text(
                  '设置拼接板尺寸',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: kPFFont,
                    color: AppColors.textColorPrimary,
                  ),
                ),
                Text(
                  '设置拼接板子的尺寸',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textColorSecond,
                    fontFamily: kPFFont,
                  ),
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
                          '$value',
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

            Positioned(
              top: 12.w,
              right: 15.w,
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _toggleNoStitch(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 6.w),
                    child: Text(
                      '无拼接',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFCE8900),
                        fontWeight: FontWeight.w500,
                        fontFamily: kPFFont,
                      ),
                    ),
                  ),
                ),
                10.w.horizontalSpace,
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: SvgPicture.asset(
                    "assets/icons/icon_dialog_close.svg",
                    width: 15.w,
                    height: 15.w,
                  ),
                ),
              ],
            ),)
          ],
        ),
      ),
    );
  }

  void _toggleNoStitch() {
    if (_selected == null) return;
    setState(() => _selected = null);
    widget.onValueChanged?.call(null);
  }
}
