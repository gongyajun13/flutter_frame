import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';

/// 浮层统一视觉配置，支持全局默认 + 单次调用覆盖
class OverlayStyle {
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color toastBackground;
  final Color toastText;
  final Color dialogBarrier;
  final double dialogRadius;
  final double toastRadius;

  const OverlayStyle({
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.toastBackground,
    required this.toastText,
    required this.dialogBarrier,
    required this.dialogRadius,
    required this.toastRadius,
  });

  /// 从设计令牌构建默认样式
  factory OverlayStyle.defaults() {
    return OverlayStyle(
      success: AppDesignTokens.successColor,
      error: AppDesignTokens.errorColor,
      warning: AppDesignTokens.warningColor,
      info: AppDesignTokens.infoColor,
      toastBackground: Colors.black.withOpacity(0.82),
      toastText: Colors.white,
      dialogBarrier: Colors.black54,
      dialogRadius: 20,
      toastRadius: 20,
    );
  }

  /// 合并局部覆盖（未传字段保留原值）
  OverlayStyle merge(OverlayStyle? override) {
    if (override == null) return this;
    return OverlayStyle(
      success: override.success,
      error: override.error,
      warning: override.warning,
      info: override.info,
      toastBackground: override.toastBackground,
      toastText: override.toastText,
      dialogBarrier: override.dialogBarrier,
      dialogRadius: override.dialogRadius,
      toastRadius: override.toastRadius,
    );
  }

  Color tone(SnackTone tone) {
    switch (tone) {
      case SnackTone.success:
        return success;
      case SnackTone.error:
        return error;
      case SnackTone.warning:
        return warning;
      case SnackTone.info:
        return info;
    }
  }
}

/// Snack / Toast 语义色
enum SnackTone {
  success,
  error,
  warning,
  info,
}
