/// 统一浮层入口：Toast / Snack / Dialog / Sheet
///
/// ```dart
/// AppOverlay.toast.success('保存成功');
/// AppOverlay.snack.error(message: '网络异常');
/// AppOverlay.dialog.showConfirm(title: '提示', message: '确认删除？', onConfirm: () {});
/// AppOverlay.sheet.show(child: MySheet());
/// AppOverlay.closeAll();
/// ```
library overlay;

export 'overlay_manager.dart';
export 'overlay_style.dart';
export 'toast_overlay.dart';
export 'snack_overlay.dart';
export 'dialog_overlay.dart';
export 'sheet_overlay.dart';
export 'overlay_init.dart';

import 'dialog_overlay.dart';
import 'overlay_manager.dart';
import 'overlay_style.dart';
import 'sheet_overlay.dart';
import 'snack_overlay.dart';
import 'toast_overlay.dart';

class AppOverlay {
  AppOverlay._();

  static final toast = ToastOverlay.instance;
  static final snack = SnackOverlay.instance;
  static final dialog = DialogOverlay.instance;
  static final sheet = SheetOverlay.instance;

  /// 全局默认样式（可在 main 中替换）
  static set globalStyle(OverlayStyle value) {
    toast.style = value;
    snack.style = value;
    dialog.style = value;
    sheet.style = value;
  }

  static OverlayStyle get globalStyle => toast.style;

  static void closeAll() => OverlayManager.closeAll();

  static Map<OverlayLayer, bool> status() => OverlayManager.status();
}
