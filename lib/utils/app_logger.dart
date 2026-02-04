import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'debug_logger.dart';

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
      // 收集到调试日志
      DebugLogger.instance.addLog(
        level: 'D',
        tag: tag,
        message: message,
      );
    }
  }

  static void i(String message, {String tag = _defaultTag}) {
    if (kDebugMode) {
      debugPrint('[$tag][I] $message');
      // 收集到调试日志
      DebugLogger.instance.addLog(
        level: 'I',
        tag: tag,
        message: message,
      );
    }
  }

  static void w(String message, {String tag = _defaultTag}) {
    if (kDebugMode) {
      debugPrint('[$tag][W] $message');
      // 收集到调试日志
      DebugLogger.instance.addLog(
        level: 'W',
        tag: tag,
        message: message,
      );
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
    
    // 收集到调试日志（错误日志在所有环境都收集）
    DebugLogger.instance.addLog(
      level: 'E',
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

