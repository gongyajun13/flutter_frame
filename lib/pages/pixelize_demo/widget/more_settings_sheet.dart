import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import 'package:flutter_frame/pages/pixelize_demo/widget/bold_grid_color_dialog.dart';
import 'package:flutter_frame/pages/pixelize_demo/widget/baseplate_size_sheet.dart';
import 'package:flutter_frame/pages/pixelize_demo/widget/grid_thickness_sheet.dart';
import 'package:flutter_frame/pages/pixelize_demo/widget/grid_start_point_sheet.dart';
import 'package:flutter_frame/pages/pixelize_demo/widget/grid_spacing_sheet.dart';

/// 更多设置弹窗（底部弹出）
class MoreSettingsSheet extends StatefulWidget {
  /// 各项初始值
  final int gridSpacing;
  final bool centerDashShow;
  final bool gridShow;
  final int baseplateStitch;
  final double gridThickness;
  final Color gridColor;
  final double gridStartPoint;

  /// 网格颜色变更回调（选择确认后触发）
  final ValueChanged<Color>? onGridColorChanged;

  /// 底板拼接尺寸变更回调
  final ValueChanged<int?>? onBaseplateStitchChanged;

  /// 网格粗细变更回调
  final ValueChanged<double>? onGridThicknessChanged;

  /// 网格起始点变更回调
  final ValueChanged<Offset>? onGridStartPointChanged;

  /// 网格间隔变更回调
  final ValueChanged<int>? onGridSpacingChanged;

  /// 中虚线显示状态变更回调
  final ValueChanged<bool>? onCenterDashChanged;

  /// 网格展示状态变更回调
  final ValueChanged<bool>? onGridShowChanged;

  const MoreSettingsSheet({
    super.key,
    this.gridSpacing = 9,
    this.centerDashShow = false,
    this.gridShow = false,
    this.baseplateStitch = 52,
    this.gridThickness = 3.0,
    this.gridColor = const Color(0xFFFF4444),
    this.gridStartPoint = 1.0,
    this.onGridColorChanged,
    this.onBaseplateStitchChanged,
    this.onGridThicknessChanged,
    this.onGridStartPointChanged,
    this.onGridSpacingChanged,
    this.onCenterDashChanged,
    this.onGridShowChanged,
  });

  /// 弹出底部弹窗
  static void show(
    BuildContext context, {
    int gridSpacing = 9,
    bool centerDashShow = false,
    bool gridShow = false,
    int baseplateStitch = 52,
    double gridThickness = 3.0,
    Color gridColor = const Color(0xFFFF4444),
    double gridStartPoint = 1.0,
    ValueChanged<Color>? onGridColorChanged,
    ValueChanged<int?>? onBaseplateStitchChanged,
    ValueChanged<double>? onGridThicknessChanged,
    ValueChanged<Offset>? onGridStartPointChanged,
    ValueChanged<int>? onGridSpacingChanged,
    ValueChanged<bool>? onCenterDashChanged,
    ValueChanged<bool>? onGridShowChanged,}
  ) {
    AppOverlay.sheet.show(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      child: MoreSettingsSheet(
        gridSpacing: gridSpacing,
        centerDashShow: centerDashShow,
        gridShow: gridShow,
        baseplateStitch: baseplateStitch,
        gridThickness: gridThickness,
        gridColor: gridColor,
        gridStartPoint: gridStartPoint,
        onGridColorChanged: onGridColorChanged,
        onBaseplateStitchChanged: onBaseplateStitchChanged,
        onGridThicknessChanged: onGridThicknessChanged,
        onGridStartPointChanged: onGridStartPointChanged,
        onGridSpacingChanged: onGridSpacingChanged,
        onCenterDashChanged: onCenterDashChanged,
        onGridShowChanged: onGridShowChanged,
      ),
    );
  }

  @override
  State<MoreSettingsSheet> createState() => _MoreSettingsSheetState();
}

class _MoreSettingsSheetState extends State<MoreSettingsSheet> {
  late Color _gridColor;
  int? _baseplateStitch;
  late double _gridThickness;
  late Offset _gridStartPoint;
  late int _gridSpacing;
  late bool _centerDashShow;
  late bool _gridShow;

  @override
  void initState() {
    super.initState();
    _gridColor = widget.gridColor;
    _baseplateStitch = widget.baseplateStitch;
    _gridThickness = widget.gridThickness;
    _gridStartPoint = Offset(widget.gridStartPoint, widget.gridStartPoint);
    _gridSpacing = widget.gridSpacing.toInt().clamp(2, 20);
    _centerDashShow = widget.centerDashShow;
    _gridShow = widget.gridShow;
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
          padding: EdgeInsets.fromLTRB(24.w, 0.w, 0.w, 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题 + 关闭按钮
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '更多设置',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: kPFFont,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: EdgeInsets.all(14.w),
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

              // 设置项列表
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(right: 12.w),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _settingsItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 2.w),
                  itemBuilder: (context, index) =>
                      _buildSettingItem(_settingsItems[index]),
                ),
              ),

              SizedBox(height: 12.w),
            ],
          ),
        ),
      ),
    );
  }

  static List<_SettingItem> get _settingsItems => [
        _SettingItem(label: '网格展示', valueType: _ValueType.text, valueText: '隐藏'),
        _SettingItem(label: '网格间距', valueType: _ValueType.number, valueText: ''),
        _SettingItem(label: '中虚线', valueType: _ValueType.text, valueText: '显示'),
        // _SettingItem(label: '底板拼接', valueType: _ValueType.number, valueText: ''),
        _SettingItem(label: '网格粗细', valueType: _ValueType.decimal, valueText: ''),
        _SettingItem(label: '网格颜色', valueType: _ValueType.color, valueText: ''),
        _SettingItem(label: '网格起始点', valueType: _ValueType.decimal, valueText: ''),
      ];

  Widget _buildSettingItem(_SettingItem item) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onItemTap(item),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.w, horizontal: 4.w),
        child: Row(
          children: [
            Text(
              item.label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                fontFamily: kPFFont,
                color: AppColors.textColorPrimary,
              ),
            ),
            const Spacer(),
            _buildValueWidget(item),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right,
              size: 18.w,
              color: AppColors.get999,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueWidget(_SettingItem item) {
    switch (item.valueType) {
      case _ValueType.number:
        final valMap = {'底板拼接': _baseplateStitch?.toString() ?? ''};
        if (item.label == '网格间距') {
          return Text(
            _gridSpacing.toString(),
            style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
          );
        }
        return Text(
          valMap[item.label] ?? '',
          style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
        );
      case _ValueType.decimal:
        final valMap = {'网格粗细': _gridThickness.toStringAsFixed(1)};
        if (valMap.containsKey(item.label)) {
          return Text(
            valMap[item.label]!,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
          );
        }
        // 网格起始点显示为 "x, y"
        if (item.label == '网格起始点') {
          return Text(
            '${_gridStartPoint.dx.toInt()}, ${_gridStartPoint.dy.toInt()}',
            style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
          );
        }
        return Text(
          '',
          style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
        );
      case _ValueType.text:
        // 中虚线显示实际切换状态
        if (item.label == '中虚线') {
          return Text(
            _centerDashShow ? '显示' : '隐藏',
            style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
          );
        }
        // 网格展示显示实际切换状态
        if (item.label == '网格展示') {
          return Text(
            _gridShow ? '显示' : '隐藏',
            style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
          );
        }
        return Text(
          item.valueText ?? '',
          style: TextStyle(fontSize: 15.sp, color: AppColors.textColorPrimary),
        );
      case _ValueType.color:
        return Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: _gridColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
    }
  }

  void _onItemTap(_SettingItem item) {
    if (item.label == '网格间距') {
      GridSpacingSheet.show(
         context,
        selectedValue: _gridSpacing,
        onValueChanged: (value) {
          setState(() => _gridSpacing = value);
          widget.onGridSpacingChanged?.call(value);
        },
      );
    } else if (item.label == '网格颜色') {
      BoldGridColorDialog.show(
         context,
        initialColor: _gridColor,
      ).then((selectedColor) {
        if (selectedColor != null && mounted) {
          setState(() => _gridColor = selectedColor);
          widget.onGridColorChanged?.call(selectedColor);
        }
      });
    } else if (item.label == '底板拼接') {
      BaseplateSizeSheet.show(
         context,
        selectedValue: _baseplateStitch,
        onValueChanged: (value) {
          setState(() => _baseplateStitch = value);
          widget.onBaseplateStitchChanged?.call(value);
        },
      );
    } else if (item.label == '网格粗细') {
      GridThicknessSheet.show(
         context,
        selectedValue: _gridThickness,
        onValueChanged: (value) {
          setState(() => _gridThickness = value);
          widget.onGridThicknessChanged?.call(value);
        },
      );
    } else if (item.label == '网格起始点') {
      GridStartPointSheet.show(
         context,
        offsetX: _gridStartPoint.dx.toInt(),
        offsetY: _gridStartPoint.dy.toInt(),
        onValueChanged: (value) {
          setState(() => _gridStartPoint = value);
          widget.onGridStartPointChanged?.call(value);
        },
      );
    } else if (item.label == '中虚线') {
      final newValue = !_centerDashShow;
      setState(() => _centerDashShow = newValue);
      widget.onCenterDashChanged?.call(newValue);
    } else if (item.label == '网格展示') {
      final newValue = !_gridShow;
      setState(() => _gridShow = newValue);
      widget.onGridShowChanged?.call(newValue);
    }
  }
}

// ── 数据模型 ─

enum _ValueType { number, decimal, text, color }

class _SettingItem {
  final String label;
  final _ValueType valueType;
  final String? valueText;

  const _SettingItem({
    required this.label,
    required this.valueType,
    this.valueText,
  });
}
