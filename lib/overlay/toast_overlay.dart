import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'overlay_manager.dart';
import 'overlay_style.dart';

/// Toast 显示位置
enum ToastPosition {
  top,
  center,
  bottom,
}

/// 轻量 Toast 浮层
class ToastOverlay extends OverlayManager {
  ToastOverlay._();
  static final ToastOverlay instance = ToastOverlay._();

  @override
  OverlayLayer get layer => OverlayLayer.toast;

  @override
  bool get isActive => Get.isSnackbarOpen == true;

  @override
  void close() {
    if (isActive) Get.closeCurrentSnackbar();
  }

  void show(
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    OverlayStyle? styleOverride,
  }) {
    if (message.isEmpty) return;
    close();

    final s = style.merge(styleOverride);
    final bg = backgroundColor ?? s.toastBackground;
    final fg = textColor ?? s.toastText;

    Get.rawSnackbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 18.sp),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: fg, fontSize: 13.sp, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: bg,
      borderRadius: s.toastRadius.r,
      margin: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      snackPosition: _position(position),
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      animationDuration: const Duration(milliseconds: 160),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  void success(String message, {ToastPosition position = ToastPosition.bottom}) {
    show(
      message,
      position: position,
      icon: Icons.check_circle_rounded,
      backgroundColor: style.success.withOpacity(0.92),
    );
  }

  void error(String message, {ToastPosition position = ToastPosition.bottom}) {
    show(
      message,
      position: position,
      icon: Icons.error_rounded,
      backgroundColor: style.error.withOpacity(0.92),
    );
  }

  void info(String message, {ToastPosition position = ToastPosition.bottom}) {
    show(
      message,
      position: position,
      icon: Icons.info_rounded,
      backgroundColor: style.info.withOpacity(0.92),
    );
  }

  SnackPosition _position(ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
      case ToastPosition.center:
        return SnackPosition.TOP;
      case ToastPosition.bottom:
        return SnackPosition.BOTTOM;
    }
  }
}
