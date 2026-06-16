import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';

import 'package:flutter_frame/overlay/overlay.dart';

/// 色号显示模式枚举
enum ColorDisplayMode {
  /// 行压缩模式（数量模式 水平）
  compressRow,
  /// 列压缩模式（数量模式 垂直）
  compressColumn,
  /// 色号显示
  normal,
  /// 缩放显示
  scale,
  /// 隐藏色号文字
  hidden,
}

/// 色号显示模式选择弹窗（底部弹出）
class ColorDisplayModeSheet extends StatefulWidget {
  /// 当前选中的模式
  final ColorDisplayMode initialMode;

  /// 模式变更回调（选中即触发，不关闭弹窗）
  final ValueChanged<ColorDisplayMode>? onModeChanged;

  const ColorDisplayModeSheet({super.key, this.initialMode = ColorDisplayMode.normal, this.onModeChanged});

  /// 弹出底部弹窗
  static void show(
    BuildContext context, {
    ColorDisplayMode initialMode = ColorDisplayMode.normal,
    ValueChanged<ColorDisplayMode>? onModeChanged,
  }) {
    AppOverlay.sheet.show(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      child: ColorDisplayModeSheet(initialMode: initialMode, onModeChanged: onModeChanged),
    );
  }

  @override
  State<ColorDisplayModeSheet> createState() => _ColorDisplayModeSheetState();
}

class _ColorDisplayModeSheetState extends State<ColorDisplayModeSheet> {
  late ColorDisplayMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  // ── 各模式的标题和描述 ──
  static const List<_ModeItem> _allModes = [
    _ModeItem(
      value: ColorDisplayMode.compressRow,
      label: '数量模式（水平）',
      desc: null,
    ),
    _ModeItem(
      value: ColorDisplayMode.compressColumn,
      label: '数量模式（垂直）',
      desc: null,
    ),
    _ModeItem(
      value: ColorDisplayMode.normal,
      label: '色号常显',
      desc: null,
    ),
    // _ModeItem(
    //   value: ColorDisplayMode.scale,
    //   label: '色号缩放显示',
    //   desc: null,
    // ),
    _ModeItem(
      value: ColorDisplayMode.hidden,
      label: '色号隐藏',
      desc: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.7.sh),
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
          padding: EdgeInsets.fromLTRB(24.w, 16.w, 10.w, 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示条 + 关闭按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding:  EdgeInsets.all(12.w),
                      child: SvgPicture.asset("assets/icons/icon_dialog_close.svg",width: 15.w,height: 15.w,),
                    ),
                  ),
                ],
              ),

              // 选项列表
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allModes.length,
                  separatorBuilder: (_, __) => SizedBox(height: 4.w),
                  itemBuilder: (context, index) =>
                      _buildRadioItem(_allModes[index]),
                ),
              ), 

              // 底部安全间距
              SizedBox(height: 12.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioItem(_ModeItem item) {
    final isSelected = _selectedMode == item.value;
    return _RadioItem(
      label: item.label,
      isSelected: isSelected,
      onTap: () {
        setState(() => _selectedMode = item.value);
        widget.onModeChanged?.call(_selectedMode);
      },
    );
  }
}

// ── 单个选项（独立 StatefulWidget，零延迟响应）──

class _RadioItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RadioItem> createState() => _RadioItemState();
}

class _RadioItemState extends State<_RadioItem> {
  bool? _localSelected;

  bool get selected => _localSelected ?? widget.isSelected;

  @override
  void didUpdateWidget(_RadioItem old) {
    super.didUpdateWidget(old);
    if (_localSelected != null && widget.isSelected != old.isSelected) {
      _localSelected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (!widget.isSelected) {
          setState(() => _localSelected = true);
          widget.onTap(); // 立即选中 + 回调
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.w, horizontal: 8.w),
        child: Row(
          children: [
            SizedBox(
              width: 22.w, height: 22.w,
              child: selected
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFC107),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.check, size: 14.w, color: Colors.black87),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.textColorSecond, width: 1.5.w),
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: kPFFont,
                  color: AppColors.textColorPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 内部数据模型 ──
class _ModeItem {
  final ColorDisplayMode value;
  final String label;
  final String? desc;
  const _ModeItem({required this.value, required this.label, this.desc});
}
