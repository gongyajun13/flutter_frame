import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_frame/constants/app_values.dart';

class BCGradientTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// 渐变色
  final List<Color> gradientColors;

  /// 圆角
  final double borderRadius;

  /// padding
  final EdgeInsetsGeometry? padding;

  /// margin
  final EdgeInsetsGeometry? margin;

  /// height
  final double? height;

  /// 是否禁用（但仍可点击）
  final bool isDisable;

  /// 字体大小
  final double fontSize;

  const BCGradientTextButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.gradientColors = const [Color(0xFFFFD967), Color(0xFFFFD000)],
      this.borderRadius = 40,
      this.padding,
      this.margin,
      this.height,
      this.isDisable = false,
      this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    final disable = (isDisable || onPressed == null);
    final List<Color> colors = (disable)
        ? [const Color(0xFFF2F2F2), const Color(0xFFF2F2F2)]
        : (gradientColors);

    final Color textColor =
        (disable) ? const Color(0xFF666666) : const Color(0xFF000000);

    final style = TextStyle(
        color: textColor,
        fontSize: fontSize.sp,
        fontFamily: kPFFont,
        fontWeight: disable ? FontWeight.w400 : FontWeight.w500,
        height: 1.4);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
        padding: height != null
            ? (EdgeInsets.zero)
            : (padding ?? EdgeInsets.symmetric(vertical: 15.w)),
        alignment: Alignment.center,
        child: DefaultTextStyle.merge(
          style: style,
          child: child,
        ),
      ),
    );
  }

// /// 确保 Text 颜色被统一控制
  Widget _wrapTextColor(Widget child, Color color) {
    if (child is Text) {
      return Text(
        child.data ?? '',
        style: child.style?.copyWith(color: color) ?? TextStyle(color: color),
      );
    }
    return child;
  }
}
