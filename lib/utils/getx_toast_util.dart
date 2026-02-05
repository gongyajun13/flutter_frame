import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Toast 显示位置
enum ToastPosition {
  top,
  center,
  bottom,
}

/// 简易 Toast 工具类（基于 GetX）
/// 适合轻量级提示，不抢占过多注意力
class Toast {
  Toast._();

  /// 通用 Toast
  static void show(
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    if (message.isEmpty) return;

    // 关闭当前 SnackBar，避免叠加
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }

    final Color bg = backgroundColor ?? Colors.black.withOpacity(0.82);
    final Color fg = textColor ?? Colors.white;

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
              style: TextStyle(
                color: fg,
                fontSize: 13.sp,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: bg,
      borderRadius: 20.r,
      margin: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      snackPosition: _convertPosition(position),
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      animationDuration: const Duration(milliseconds: 160),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  /// 成功 Toast
  static void success(
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      message,
      position: position,
      icon: Icons.check_circle_rounded,
      backgroundColor: Colors.green.shade600.withOpacity(0.9),
    );
  }

  /// 错误 Toast
  static void error(
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      message,
      position: position,
      icon: Icons.error_rounded,
      backgroundColor: Colors.red.shade600.withOpacity(0.9),
    );
  }

  /// 信息 Toast
  static void info(
    String message, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      message,
      position: position,
      icon: Icons.info_rounded,
      backgroundColor: Colors.blue.shade600.withOpacity(0.9),
    );
  }

  /// 将自定义位置转换为 GetX 的 SnackPosition
  static SnackPosition _convertPosition(ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
        return SnackPosition.TOP;
      case ToastPosition.center:
        return SnackPosition.TOP;
      case ToastPosition.bottom:
        return SnackPosition.BOTTOM;
    }
  }
}

