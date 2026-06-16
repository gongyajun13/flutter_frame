import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import '../pixelize_result_controller.dart';

/// 色号操作弹窗（底部弹出）
class ColorActionSheet extends StatefulWidget {
  /// 色号代码
  final String code;

  /// 色号颜色
  final Color codeColor;

  /// 色号数量
  final int count;

  /// 点击的像素位置（用于判断区域已拼状态）
  final int tapX;
  final int tapY;

  /// 已设置的高亮色号集合（用于判断是否已高亮）
  final Set<String> highlightedCodes;

  /// 各项操作回调（参数为当前色号，替换后可能变化）
  final void Function(String currentCode)? onHighlight;
  final void Function(String currentCode)? onOverlayHighlight;
  final VoidCallback? onAreaPinned;
  final void Function(String currentCode)? onSameColorPinned;
  final void Function(String currentCode)? onMergeToOther;
  /// 自动替换成相似色号（替换后通过回调通知新色号以更新UI）
  final void Function(void Function(String newCode))? onAutoReplaceSimilar;
  final VoidCallback? onMergeBelowThreshold;
  final void Function(String currentCode)? onDelete;

  const ColorActionSheet({
    super.key,
    required this.code,
    required this.codeColor,
    required this.count,
    this.tapX = -1,
    this.tapY = -1,
    this.highlightedCodes = const {},
    this.onHighlight,
    this.onOverlayHighlight,
    this.onAreaPinned,
    this.onSameColorPinned,
    this.onMergeToOther,
    this.onAutoReplaceSimilar,
    this.onMergeBelowThreshold,
    this.onDelete,
  });

  /// 弹出底部弹窗
  static void show(
    BuildContext context, {
    required String code,
    required Color codeColor,
    required int count,
    int tapX = 0,
    int tapY = 0,
    Set<String> highlightedCodes = const {},
    void Function(String)? onHighlight,
    void Function(String)? onOverlayHighlight,
    VoidCallback? onAreaPinned,
    void Function(String)? onSameColorPinned,
    void Function(String)? onMergeToOther,
    void Function(void Function(String))? onAutoReplaceSimilar,
    VoidCallback? onMergeBelowThreshold,
    void Function(String)? onDelete,
  }) {
    AppOverlay.sheet.show(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      child: ColorActionSheet(
        code: code,
        codeColor: codeColor,
        count: count,
        tapX: tapX,
        tapY: tapY,
        highlightedCodes: highlightedCodes,
        onHighlight: onHighlight,
        onOverlayHighlight: onOverlayHighlight,
        onAreaPinned: onAreaPinned,
        onSameColorPinned: onSameColorPinned,
        onMergeToOther: onMergeToOther,
        onAutoReplaceSimilar: onAutoReplaceSimilar,
        onMergeBelowThreshold: onMergeBelowThreshold,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<ColorActionSheet> createState() => _ColorActionSheetState();
}

class _ColorActionSheetState extends State<ColorActionSheet> {
  final PixelizeResultController _controller = Get.find<PixelizeResultController>();

  late String _currentCode;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentCode = widget.code;
    _currentColor = widget.codeColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.8.sh),
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
          padding: EdgeInsets.fromLTRB(24.w, 0.w, 12.w, 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Divider(height: 2.w, color: Colors.white),
              SizedBox(height: 16.w),
              _buildGridItems(),
              SizedBox(height: 4.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.w),
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 左侧色号芯片
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.w),
                  decoration: BoxDecoration(
                    color: _currentColor,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.w,
                    ),
                  ),
                  child: Text(
                    _currentCode,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: kPFFont,
                      color: _currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: kPFFont,
                    color: AppColors.textColorPrimary,
                  ),
                ),

              ],
            ),
          ),

          Positioned(
            right: 0,
            top: 0,
            child:  // 关闭按钮
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                "assets/icons/icon_dialog_close.svg",
                width: 15.w,
                height: 15.w,
              ),
            ),
          ),)
        ],
      ),
    );
  }

  Widget _buildGridItems() {
    return Obx(() {
      // 实时从控制器获取所有最新状态
      final currentHighlighted = _controller.highlightedCodes;
      final isNowHighlighted = currentHighlighted.contains(_currentCode);

      // 区域已拼状态：检查点击位置是否在已标记的连通区域内
      // final areaRegions = _controller.areaPinnedRegions;
      final tapRegionKey = '${widget.tapX},${widget.tapY}';
      // 需要进一步判断：该位置是否真的被标记（因为 regionKey 是中心点，需要更精确匹配）
      // 简化处理：如果该色号有任意区域被标记，且点击位置附近有标记，则视为已拼
      // 更精确的方式：通过 checkedGridKeys 判断
      final checkedKeys = _controller.checkedGridKeys;
      final isAreaPinned = checkedKeys.contains(tapRegionKey);

      // 同一色号已拼好状态：直接检查色号是否在集合中
      final sameColorPinned = _controller.sameColorPinnedCodes;
      final isSameColorPinned = sameColorPinned.contains(_currentCode);

      // 叠加高亮状态：检查当前色号是否在叠加高亮集合中
      final overlayHighlighted = _controller.overlayHighlightedCodes;
      final isOverlayHighlighted = overlayHighlighted.contains(_currentCode);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 第一行：两列
          Row(
            children: [
              Expanded(child: _buildActionItem(
                icon: "assets/icons/icon_high_light.svg",
                label: isNowHighlighted ? '取消高亮' : '高亮',
                onTap: () => widget.onHighlight?.call(_currentCode),
              )),
              SizedBox(width: 1.w),
              Expanded(child: _buildActionItem(
                icon: "assets/icons/icon_add_high_light.svg",
                label: isOverlayHighlighted ? '取消叠加高亮' : '叠加高亮',
                onTap: () => widget.onOverlayHighlight?.call(_currentCode),
              )),
            ],
          ),
          SizedBox(height: 1.w),

          // 第二行：两列（动态文本）
          Row(
            children: [
              Expanded(child: _buildActionItem(
                icon: "assets/icons/icon_same_area_done.svg",
                label: isAreaPinned ? '取消区域已拼' : '区域已拼',
                onTap: widget.onAreaPinned,
              )),
              SizedBox(width: 1.w),
              Expanded(child: _buildActionItem(
                icon: "assets/icons/icon_same_color_done.svg",
                label: isSameColorPinned ? '取消同色已拼好' : '同一色号已拼好',
                onTap: () => widget.onSameColorPinned?.call(_currentCode),
              )),
            ],
          ),
          SizedBox(height: 1.w),

          // 第三行起：单列
          _buildActionItem(icon: "assets/icons/icon_replace_same.svg", label: '自动替换成相似色号', onTap: () {
            widget.onAutoReplaceSimilar?.call((newCode) {
              setState(() {
                _currentCode = newCode;
                _currentColor = _controller.beadColorMap[newCode] ?? Colors.grey;
              });
            });
          }),
          SizedBox(height: 1.w),

          _buildActionItem(icon: "assets/icons/icon_merge_num.svg", label: '合并小于指定数量的色号', onTap: () {
            Navigator.of(context).pop();
            widget.onMergeBelowThreshold?.call();
          }),
          SizedBox(height: 1.w),

          _buildActionItem(icon: "assets/icons/icon_color_delete.svg", label: '删除', onTap: () => widget.onDelete?.call(_currentCode)),
        ],
      );
    });
  }

  Widget _buildActionItem({
    required String icon,
    required String label,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (!isDisabled) {
          onTap?.call();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.w, horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(icon, width: 18.w, height: 18.w, colorFilter: isDisabled ? const ColorFilter.mode(Colors.grey, BlendMode.srcIn) : null,),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: kPFFont,
                  color: isDisabled ? Colors.grey : AppColors.textColorPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
