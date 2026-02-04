import 'package:flutter/foundation.dart';

/// 调试日志条目
class DebugLogEntry {
  final DateTime timestamp;
  final String level; // D, I, W, E
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  DebugLogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  String get formattedTime => 
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}.'
      '${timestamp.millisecond.toString().padLeft(3, '0')}';

  String get fullMessage {
    final buffer = StringBuffer(message);
    if (error != null) {
      buffer.write(' | error: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }
}

/// 调试日志收集器
/// 用于收集和存储应用日志，供调试面板显示
class DebugLogger {
  DebugLogger._();
  static final DebugLogger instance = DebugLogger._();

  /// 最大日志条数（避免内存溢出）
  static const int maxLogs = 1000;

  /// 日志列表
  final List<DebugLogEntry> _logs = [];

  /// 日志监听器
  final List<Function()> _listeners = [];

  /// 获取所有日志
  List<DebugLogEntry> get logs => List.unmodifiable(_logs);

  /// 获取指定级别的日志
  List<DebugLogEntry> getLogsByLevel(String level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// 获取指定标签的日志
  List<DebugLogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// 添加日志
  void addLog({
    required String level,
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final entry = DebugLogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(entry);

    // 限制日志数量
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }

    // 通知监听器
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 添加监听器
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  /// 移除监听器
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  /// 清空日志
  void clear() {
    _logs.clear();
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 导出日志为文本
  String exportLogs() {
    final buffer = StringBuffer();
    for (final log in _logs) {
      buffer.writeln(
        '[${log.formattedTime}][${log.tag}][${log.level}] ${log.fullMessage}',
      );
    }
    return buffer.toString();
  }
}
