import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'overlay_manager.dart';

/// 底部 Sheet 浮层
class SheetOverlay extends OverlayManager {
  SheetOverlay._();
  static final SheetOverlay instance = SheetOverlay._();

  @override
  OverlayLayer get layer => OverlayLayer.sheet;

  @override
  bool get isActive => Get.isBottomSheetOpen == true;

  @override
  void close() {
    if (isActive) Get.back();
  }

  void show({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        child: child,
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 6,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
    );
  }
}
