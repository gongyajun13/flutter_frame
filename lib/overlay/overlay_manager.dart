import 'package:get/get.dart';
import 'overlay_style.dart';

/// 浮层类型
enum OverlayLayer {
  toast,
  snack,
  dialog,
  sheet,
}

/// 所有浮层管理器基类：统一生命周期与样式扩展入口
abstract class OverlayManager {
  OverlayLayer get layer;

  /// 当前层是否处于展示状态
  bool get isActive;

  /// 关闭当前层
  void close();

  /// 全局默认样式（可在 App 启动时替换以实现主题定制）
  OverlayStyle style = OverlayStyle.defaults();

  /// 关闭所有 GetX 管理的浮层
  static void closeAll() {
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  /// 当前各层状态快照
  static Map<OverlayLayer, bool> status() {
    return {
      OverlayLayer.snack: Get.isSnackbarOpen == true,
      OverlayLayer.toast: Get.isSnackbarOpen == true,
      OverlayLayer.dialog: Get.isDialogOpen == true,
      OverlayLayer.sheet: Get.isBottomSheetOpen == true,
    };
  }
}
