import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_frame/widgets/pixelize/bc_gradient_text_button.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import 'package:get/get.dart';

/// 粗线网格颜色选择弹窗
class BoldGridColorDialog extends StatefulWidget {
  /// 初始颜色
  final Color initialColor;

  /// 弹窗标题
  final String title;

  const BoldGridColorDialog({
    super.key,
    required this.initialColor,
    this.title = '粗线网格颜色',
  });

  static Future<Color?> show(BuildContext context, {required Color initialColor}) {
    return AppOverlay.dialog.customAsync<Color>(
      child: BoldGridColorDialog(initialColor: initialColor),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  State<BoldGridColorDialog> createState() => _BoldGridColorDialogState();
}

class _BoldGridColorDialogState extends State<BoldGridColorDialog> {
  late Color _selectedColor;

  // HSV 颜色轮状态
  double _hue = 0;        // 色相 0-360
  double _saturation = 0; // 饱和度 0-1
  double _brightness = 1; // 明度 0-1

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;

    // 从初始颜色解析 HSV
    final hsv = _colorToHsv(widget.initialColor);
    _hue = hsv[0];
    _saturation = hsv[1];
    _brightness = hsv[2];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 0.82.sh),
          margin: EdgeInsets.symmetric(horizontal: 30.w),
          padding: EdgeInsets.fromLTRB(20.w, 24.w, 20.w, 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
            gradient: const LinearGradient(
              colors: AppColors.gradientBgColors2,
              stops: [0.0, 0.3],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: kPFFont,
                    color: AppColors.textColorPrimary,
                  ),
                ),
                SizedBox(height: 16.w),

                // 当前颜色预览条 + HEX 值
                _buildColorPreviewBar(),
                SizedBox(height: 20.w),

                // HSV 颜色轮
                _buildColorWheel(),
                SizedBox(height: 12.w),

                // 亮度滑块
                _buildBrightnessSlider(),
                SizedBox(height: 16.w),

                // 预设灰度色板
                _buildPresetPalette(),
                SizedBox(height: 24.w),

                // 底部按钮
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 颜色预览条（显示当前选中颜色的 HEX 值）
  Widget _buildColorPreviewBar() {
    return Container(
      height: 48.w,
      decoration: BoxDecoration(
        color: _selectedColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        '#${(_selectedColor.a * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(_selectedColor.r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(_selectedColor.g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(_selectedColor.b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          fontFamily: kPFFont,
          color: _getContrastTextColor(_selectedColor),
        ),
      ),
    );
  }

  /// 圆形选择器尺寸常量（与 Painter、取色逻辑共用）
  double get _wheelSize => 180.w;

  /// HSV 圆形颜色选择器（含可拖动指示器）
  Widget _buildColorWheel() {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) => _updateColorFromPosition(details.localPosition),
        onPanUpdate: (details) => _updateColorFromPosition(details.localPosition),
        onTapDown: (details) => _updateColorFromPosition(details.localPosition),
        child: SizedBox(
          width: _wheelSize,
          height: _wheelSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                painter: _HueSaturationWheelPainter(),
                size: Size(_wheelSize, _wheelSize),
              ),
              // 可拖动指示器 — 位置跟随当前 hue/sat
              _buildColorIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// 圆形色值指示器（根据当前 hue/sat 计算位置）
  Widget _buildColorIndicator() {
    final radius = (_wheelSize / 2) * _saturation;
    // 与 Painter 对齐：startAngle=-π/2 → hue=0° 在正上方(0,-1)
    final angleRad = (_hue / 180.0) * math.pi - math.pi / 2;
    final cx = _wheelSize / 2 + radius * math.cos(angleRad);
    final cy = _wheelSize / 2 + radius * math.sin(angleRad);

    const indicatorSize = 20.0;

    return Positioned(
      left: cx - indicatorSize / 2,
      top: cy - indicatorSize / 2,
      child: Container(
        width: indicatorSize.w,
        height: indicatorSize.w,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:Colors.white,
            width: 1.w,
          ),
          color: Colors.transparent,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha: 0.25),
          //     blurRadius: 4,
          //     offset: const Offset(0, 1),
          //   ),
          // ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.5.w,
            ),
          ),

        ),
      ),
    );
  }

  /// 根据触摸/拖动位置更新颜色（HSV 模型，与 Painter 渲染对齐）
  void _updateColorFromPosition(Offset localPos) {
    final size = _wheelSize;
    final center = Offset(size / 2, size / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final maxRadius = size / 2 - 4;

    if (distance > maxRadius) return;

    // atan2: 右=0, 下=π/2, 左=π, 上=-π/2(或3π/2)
    // Painter startAngle = -π/2 (上=0° hue/红色)
    // 需要把 atan2 角度 + π/2 对齐到 Painter 的 hue 零点
    double angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    if (angle >= 2 * math.pi) angle -= 2 * math.pi;

    _hue = (angle * 180.0 / math.pi) % 360.0;

    // 饱和度 = 距离比例
    _saturation = (distance / maxRadius).clamp(0.0, 1.0);

    setState(() {
      _selectedColor = _hsvToRgb(_hue, _saturation, _brightness);
    });
  }

  /// 亮度滑块值变化时刷新颜色
  void _onBrightnessChanged(double v) {
    setState(() {
      _brightness = v;
      _selectedColor = _hsvToRgb(_hue, _saturation, _brightness);
    });
  }

  /// 亮度滑块
  Widget _buildBrightnessSlider() {
    return Column(
      children: [

        Row(
          children: [
            SvgPicture.asset("assets/icons/icon_light.svg",width: 16.w,height: 16.w,),
            SizedBox(width: 4.w),
            Text(
              '${(_brightness * 100).round()}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(0xFF6D6D6D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        8.w.verticalSpace,
        SizedBox(
          height: 10.w,
          width: 240.w,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.w,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.w),
              activeTrackColor: Color(0xFFFFD10C),
              inactiveTrackColor: AppColors.getEEE,
              overlayShape: RoundSliderOverlayShape(overlayRadius: 10.w),
              overlayColor: Color(0xFFFFD10C),
            ),
            child: Slider(
              activeColor: Color(0xFFFFD10C),
              value: _brightness,
              onChanged: _onBrightnessChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// 预设灰度色板（5列 × 4行，共 20 个灰阶）
  Widget _buildPresetPalette() {
    // 固定颜色预设：每行 5 个，共 25 色 + 1 补充色（含灰度 + 彩色）
    final presetColors = <String>[
      // 第1行：灰度浅色系
      'FFE0E0E0', 'FFEEEEEE', 'FF757575', 'FF616161', 'FF212121',
      // 第2行：白 + 红/橙/黄色系
      'FFFFFFFF', 'FFFF0060', 'FFFF0200', 'FFFF4400', 'FFFF9200',
      // 第3行：黄/绿/青色系
      'FFFFBE00', 'FFFFE900', 'FFCADC00', 'FF7AC532', 'FF00B141',
      // 第4行：青/蓝/紫色系
      'FF009988', 'FF00BED7', 'FF00ACFA', 'FF009AF9', 'FF3853BA',
      // 第5行：紫/棕/黑灰系
      'FFA915B7', 'FF6E37BE', 'FF587E8D', 'FF7D5346', 'FF2A2A2A',
      // 第6行补充：浅白
      'FFF5F5F5',
    ];

    final presets = presetColors
        .map((hex) => {'color': Color(int.parse(hex, radix: 16)), 'label': ''})
        .toList();

    return SizedBox(
      height: 200.h,
      child: GridView.builder(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8.w,
          crossAxisSpacing: 8.w,
          childAspectRatio: 42 / 40,
        ),
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final preset = presets[index]['color'] as Color;
          final isSelected = _isSameColor(_selectedColor, preset);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = preset;
                // 同步更新 HSV 状态
                final hsv = _colorToHsv(preset);
                _hue = hsv[0];
                _saturation = hsv[1];

                // 预设颜色直接设为目标色，brightness 同步为该颜色的 V 值
                _brightness = hsv[2].clamp(0.0, 1.0);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: preset,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.white,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Icon(Icons.check, size: 16.w, color: Colors.white))
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// 底部按钮
  Widget _buildButtons() {
    return Row(
      spacing: 15.w,
      children: [
        Expanded(
          child: BCGradientTextButton(
            isDisable: true,
            onPressed: () => Get.back(),
            padding: EdgeInsets.symmetric(vertical: 11.w),
            child: const Text('取消'),
          ),
        ),
        Expanded(
          child: BCGradientTextButton(
            onPressed: () => Get.back(result: _selectedColor),
            padding: EdgeInsets.symmetric(vertical: 12.w),
            child: const Text('确认'),
          ),
        ),
      ],
    );
  }

  // ========== 工具方法 ==========

  /// Color → HSV（标准算法，返回 [h: 0~360, s: 0~1, v: 0~1]）
  List<double> _colorToHsv(Color c) {
    final r = c.r;
    final g = c.g;
    final b = c.b;
    final maxVal = math.max(r, math.max(g, b));
    final minVal = math.min(r, math.min(g, b));
    final delta = maxVal - minVal;

    double h = 0.0;
    if (delta > 1e-10) {
      if (maxVal == r) {
        h = 60.0 * (((g - b) / delta) % 6.0);
      } else if (maxVal == g) {
        h = 60.0 * ((b - r) / delta + 2.0);
      } else {
        h = 60.0 * ((r - g) / delta + 4.0);
      }
    }
    if (h < 0) h += 360.0;

    final s = maxVal < 1e-10 ? 0.0 : (delta / maxVal);
    return <double>[h, s, maxVal];
  }

  bool _isSameColor(Color a, Color b) {
    return (a.r == b.r && a.g == b.g && a.b == b.b);
  }

  Color _getContrastTextColor(Color bg) {
    // final luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
    // return luminance <= 0.5 ? Colors.white : Colors.black;
    return Colors.white;
  }
}

// ============================================================
// HSV → RGB 转换工具（State 和 Painter 共用）
// ============================================================

/// HSV → Color（标准算法：h=0~360, s=0~1, v=0~1）
Color _hsvToRgb(double h, double s, double v) {
  final c = v * s; // chroma
  final hPrime = h / 60.0;
  final x = c * (1.0 - ((hPrime % 2.0) - 1.0).abs());
  final m = v - c;

  double r1 = 0.0, g1 = 0.0, b1 = 0.0;
  if (hPrime < 1.0)       { r1 = c; g1 = x; b1 = 0.0; }
  else if (hPrime < 2.0)  { r1 = x; g1 = c; b1 = 0.0; }
  else if (hPrime < 3.0)  { r1 = 0.0; g1 = c; b1 = x; }
  else if (hPrime < 4.0)  { r1 = 0.0; g1 = x; b1 = c; }
  else if (hPrime < 5.0)  { r1 = x; g1 = 0.0; b1 = c; }
  else                    { r1 = c; g1 = 0.0; b1 = x; }

  return Color.fromRGBO(
    ((r1 + m) * 255.0).round(),
    ((g1 + m) * 255.0).round(),
    ((b1 + m) * 255.0).round(),
    1.0,
  );
}

// ============================================================
// HSV 圆形色相-饱和度选择器绘制器
// ============================================================

class _HueSaturationWheelPainter extends CustomPainter {
  /// 扇区数量（越大越平滑，180 = 每 2° 一个）
  static const int _segmentCount = 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 预建径向渐变 shader：中心白 → 边缘某纯色
    // 每个扇区复用同一 shader 结构，只改终点色
    for (int i = 0; i < _segmentCount; i++) {
      final startAngle = (i / _segmentCount) * 2 * math.pi - math.pi / 2;
      final sweepAngle = (2 * math.pi / _segmentCount);
      final hue = (i.toDouble() / _segmentCount) * 360.0;

      // 该色相在 S=1, V=1 下的最鲜艳纯色
      final edgeColor = _hsvToRgb(hue, 1.0, 1.0);

      // 构建扇形路径
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startAngle, sweepAngle, false)
        ..close();

      // 径向渐变：白色(中心) → 该色相纯色(边缘)
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFFFFF), edgeColor],
        ).createShader(rect);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
