import '../overlay/overlay.dart';

export '../overlay/overlay.dart';

/// 像素模块兼容入口
void showToast(String message) => AppOverlay.toast.show(message);
