import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_design_tokens.dart';
import 'debug_panel_page.dart';

/// 调试悬浮球
/// 使用 Overlay 显示在应用最上层
class DebugBall extends StatefulWidget {
  const DebugBall({super.key});

  @override
  State<DebugBall> createState() => _DebugBallState();
}

class _DebugBallState extends State<DebugBall> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final GlobalKey _ballKey = GlobalKey();

  // 悬浮球当前位置（相对屏幕左上角）
  double _dx = 0;
  double _dy = 0;
  bool _positionInited = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    // 悬浮球作为“开发者入口”，点击后以弹窗形式打开调试面板
    Get.dialog(
      const DebugPanelDialog(),
      barrierDismissible: true,
    );
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 初始化默认位置：右下角（与之前的 right:16, bottom:100 对齐）
    if (!_positionInited) {
      const ballSize = 56.0;
      const marginRight = 16.0;
      const marginBottom = 100.0;
      _dx = size.width - marginRight - ballSize;
      _dy = size.height - marginBottom - ballSize;
      _positionInited = true;
    }

    return Positioned(
      left: _dx,
      top: _dy,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onPanUpdate: (details) {
          setState(() {
            const ballSize = 56.0;
            _dx += details.delta.dx;
            _dy += details.delta.dy;
            // 简单边界限制，避免完全拖出屏幕
            _dx = _dx.clamp(0.0, size.width - ballSize);
            _dy = _dy.clamp(0.0, size.height - ballSize);
          });
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            key: _ballKey,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppDesignTokens.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// 管理调试悬浮球的 OverlayEntry
class DebugBallOverlay {
  static OverlayEntry? _entry;

  /// 确保悬浮球已添加到全局 Overlay 中
  static void ensureAttached() {
    // 依赖 Get.overlayContext 获取全局 Overlay
    final overlayContext = Get.overlayContext;
    if (overlayContext == null) return;

    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (context) => const DebugBall(),
    );

    final overlayState = Overlay.of(overlayContext);
    overlayState.insert(_entry!);
  }

  /// 可选：移除悬浮球
  static void detach() {
    _entry?.remove();
    _entry = null;
  }
}

