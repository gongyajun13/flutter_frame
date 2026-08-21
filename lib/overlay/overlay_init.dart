import 'overlay.dart';

/// 在主题控制器就绪后初始化全局浮层样式
void initAppOverlay() {
  AppOverlay.globalStyle = OverlayStyle.defaults();
}
