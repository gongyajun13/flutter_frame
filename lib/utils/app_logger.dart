import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 全局日志工具
///
/// - Debug 环境输出详细日志（含 curl、响应体等）
/// - Release 环境仅输出必要的错误日志
class AppLogger {
  AppLogger._();

  static const String _defaultTag = 'App';

  static void d(String message, {String tag = _defaultTag}) {
    if (kDebugMode) {
      debugPrint('[$tag][D] $message');
    }
  }

  static void i(String message, {String tag = _defaultTag}) {
    if (kDebugMode) {
      debugPrint('[$tag][I] $message');
    }
  }

  static void w(String message, {String tag = _defaultTag}) {
    if (kDebugMode) {
      debugPrint('[$tag][W] $message');
    }
  }

  /// 错误日志在 debug / release 都会输出（便于排查线上问题）
  static void e(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer('[$tag][E] $message');
    if (error != null) {
      buffer.write(' | error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      // 仅在 debug 下输出完整堆栈，避免日志过大
      buffer.write('\n$stackTrace');
    }
    debugPrint(buffer.toString());
  }
}

