import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_frame/constants/app_colors.dart';

class BCGradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  const BCGradientContainer(
      {super.key, required this.child, this.padding, this.margin, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius ??
            BorderRadius.vertical(
              top: Radius.circular(24.r),
            ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFEEFC8),
            AppColors.appSheetBgColor,
            AppColors.appSheetBgColor,
          ],
          stops: [0.0, 0.35, 1.0], // 👈 30% 渐变
        ),
      ),
      child: child,
    );
  }
}
