import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

/// 错误监控工具类
/// 提供全局错误捕获、错误上报、错误分析等功能
class ErrorMonitor {
  ErrorMonitor._();

  static ErrorMonitor? _instance;
  static ErrorMonitor get instance {
    _instance ??= ErrorMonitor._();
    return _instance!;
  }

  /// 是否已初始化
  bool _initialized = false;

  /// 错误上报回调列表
  final List<ErrorReportCallback> _reportCallbacks = [];

  /// 错误过滤器列表
  final List<ErrorFilter> _errorFilters = [];

  /// 初始化错误监控
  /// 
  /// [enableConsoleLog] 是否在控制台输出错误日志（默认 true）
  /// [enableErrorReporting] 是否启用错误上报（默认 false，需要配置上报服务）
  Future<void> init({
    bool enableConsoleLog = true,
    bool enableErrorReporting = false,
  }) async {
    if (_initialized) {
      AppLogger.w('错误监控已初始化，跳过重复初始化');
      return;
    }

    _initialized = true;

    // 捕获 Flutter 框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details, enableConsoleLog);
    };

    // 捕获异步错误（Zone 外的错误）
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleAsyncError(error, stack, enableConsoleLog);
      return true; // 返回 true 表示错误已处理
    };

    // 捕获 Dart 异常
    runZonedGuarded(() {
      // 应用运行在 Zone 中
    }, (error, stack) {
      _handleZoneError(error, stack, enableConsoleLog);
    });

    AppLogger.d('错误监控已初始化');
  }

  /// 处理 Flutter 框架错误
  void _handleFlutterError(
    FlutterErrorDetails details,
    bool enableConsoleLog,
  ) {
    if (enableConsoleLog) {
      FlutterError.presentError(details);
    }

    // 应用错误过滤器
    if (_shouldFilterError(details.exception, details.stack)) {
      return;
    }

    // 构建错误信息
    final errorInfo = ErrorInfo(
      type: ErrorType.flutterError,
      error: details.exception,
      stackTrace: details.stack,
      context: details.context?.toString(),
      library: details.library,
      information: details.informationCollector != null
          ? details.informationCollector!().toList()
          : null,
    );

    // 记录日志
    AppLogger.e(
      'Flutter 错误: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );

    // 上报错误
    _reportError(errorInfo);
  }

  /// 处理异步错误
  void _handleAsyncError(
    Object error,
    StackTrace stack,
    bool enableConsoleLog,
  ) {
    if (enableConsoleLog) {
      AppLogger.e(
        '异步错误: $error',
        error: error,
        stackTrace: stack,
      );
    }

    // 应用错误过滤器
    if (_shouldFilterError(error, stack)) {
      return;
    }

    // 构建错误信息
    final errorInfo = ErrorInfo(
      type: ErrorType.asyncError,
      error: error,
      stackTrace: stack,
    );

    // 上报错误
    _reportError(errorInfo);
  }

  /// 处理 Zone 错误
  void _handleZoneError(
    Object error,
    StackTrace stack,
    bool enableConsoleLog,
  ) {
    if (enableConsoleLog) {
      AppLogger.e(
        'Zone 错误: $error',
        error: error,
        stackTrace: stack,
      );
    }

    // 应用错误过滤器
    if (_shouldFilterError(error, stack)) {
      return;
    }

    // 构建错误信息
    final errorInfo = ErrorInfo(
      type: ErrorType.zoneError,
      error: error,
      stackTrace: stack,
    );

    // 上报错误
    _reportError(errorInfo);
  }

  /// 检查是否应该过滤错误
  bool _shouldFilterError(Object error, StackTrace? stack) {
    for (final filter in _errorFilters) {
      if (filter(error, stack)) {
        return true;
      }
    }
    return false;
  }

  /// 上报错误
  void _reportError(ErrorInfo errorInfo) {
    for (final callback in _reportCallbacks) {
      try {
        callback(errorInfo);
      } catch (e) {
        AppLogger.e('错误上报回调执行失败', error: e);
      }
    }
  }

  /// 手动上报错误
  /// 
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  /// [context] 上下文信息
  /// [tags] 标签（用于分类和过滤）
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, String>? tags,
  }) {
    final errorInfo = ErrorInfo(
      type: ErrorType.manual,
      error: error,
      stackTrace: stackTrace,
      context: context,
      tags: tags,
    );

    AppLogger.e(
      '手动上报错误: $error',
      error: error,
      stackTrace: stackTrace,
    );

    _reportError(errorInfo);
  }

  /// 添加错误上报回调
  /// 
  /// 可以添加多个回调，例如：Sentry、Firebase Crashlytics 等
  void addReportCallback(ErrorReportCallback callback) {
    _reportCallbacks.add(callback);
  }

  /// 移除错误上报回调
  void removeReportCallback(ErrorReportCallback callback) {
    _reportCallbacks.remove(callback);
  }

  /// 添加错误过滤器
  /// 
  /// 用于过滤不需要上报的错误（例如：某些已知的、不影响功能的错误）
  void addErrorFilter(ErrorFilter filter) {
    _errorFilters.add(filter);
  }

  /// 移除错误过滤器
  void removeErrorFilter(ErrorFilter filter) {
    _errorFilters.remove(filter);
  }

  /// 设置用户信息（用于错误上报时的用户标识）
  void setUser({
    String? id,
    String? username,
    String? email,
    Map<String, dynamic>? extra,
  }) {
    // 子类可以重写此方法来实现用户信息设置
    AppLogger.d('设置用户信息: id=$id, username=$username, email=$email');
  }

  /// 添加面包屑（用于错误上下文追踪）
  void addBreadcrumb({
    required String message,
    String? category,
    String? level,
    Map<String, dynamic>? data,
  }) {
    // 子类可以重写此方法来实现面包屑记录
    AppLogger.d('添加面包屑: $message');
  }

  /// 设置标签（用于错误分类）
  void setTag(String key, String value) {
    // 子类可以重写此方法来实现标签设置
    AppLogger.d('设置标签: $key=$value');
  }

  /// 设置上下文（用于错误上下文信息）
  void setContext(String key, Map<String, dynamic> context) {
    // 子类可以重写此方法来实现上下文设置
    AppLogger.d('设置上下文: $key');
  }
}

/// 错误类型
enum ErrorType {
  flutterError, // Flutter 框架错误
  asyncError, // 异步错误
  zoneError, // Zone 错误
  manual, // 手动上报
}

/// 错误信息
class ErrorInfo {
  final ErrorType type;
  final Object error;
  final StackTrace? stackTrace;
  final String? context;
  final String? library;
  final List<DiagnosticsNode>? information;
  final Map<String, String>? tags;
  final DateTime timestamp;

  ErrorInfo({
    required this.type,
    required this.error,
    this.stackTrace,
    this.context,
    this.library,
    this.information,
    this.tags,
  }) : timestamp = DateTime.now();

  /// 获取错误消息
  String get message {
    if (error is Exception) {
      return error.toString();
    }
    return error.toString();
  }

  /// 转换为 Map（用于序列化）
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'library': library,
      'tags': tags,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 错误上报回调
typedef ErrorReportCallback = void Function(ErrorInfo errorInfo);

/// 错误过滤器
/// 返回 true 表示过滤该错误（不上报）
typedef ErrorFilter = bool Function(Object error, StackTrace? stack);
