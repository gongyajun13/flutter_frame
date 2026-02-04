/// 网络请求记录
class NetworkLogEntry {
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, dynamic>? headers;
  final dynamic requestData;
  final Map<String, dynamic>? queryParameters;
  final int? statusCode;
  final String? statusMessage;
  final dynamic responseData;
  final String? error;
  final Duration? duration;

  NetworkLogEntry({
    required this.timestamp,
    required this.method,
    required this.url,
    this.headers,
    this.requestData,
    this.queryParameters,
    this.statusCode,
    this.statusMessage,
    this.responseData,
    this.error,
    this.duration,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get isError => error != null || (statusCode != null && statusCode! >= 400);

  String get formattedTime => 
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}.'
      '${timestamp.millisecond.toString().padLeft(3, '0')}';

  String get shortUrl {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}${uri.path}';
    } catch (e) {
      return url;
    }
  }
}

/// 网络请求记录器
/// 用于记录网络请求和响应，供调试面板显示
class NetworkLogger {
  NetworkLogger._();
  static final NetworkLogger instance = NetworkLogger._();

  /// 最大记录数（避免内存溢出）
  static const int maxLogs = 500;

  /// 请求记录列表
  final List<NetworkLogEntry> _logs = [];

  /// 监听器
  final List<Function()> _listeners = [];

  /// 获取所有记录
  List<NetworkLogEntry> get logs => List.unmodifiable(_logs);

  /// 获取成功的请求
  List<NetworkLogEntry> get successLogs => 
      _logs.where((log) => log.isSuccess).toList();

  /// 获取失败的请求
  List<NetworkLogEntry> get errorLogs => 
      _logs.where((log) => log.isError).toList();

  // TODO: 记录请求开始（待实现）
  // DateTime? _recordRequest({
  //   required String method,
  //   required String url,
  //   Map<String, dynamic>? headers,
  //   dynamic requestData,
  //   Map<String, dynamic>? queryParameters,
  // }) {
  //   final timestamp = DateTime.now();
  //   final entry = NetworkLogEntry(
  //     timestamp: timestamp,
  //     method: method,
  //     url: url,
  //     headers: headers,
  //     requestData: requestData,
  //     queryParameters: queryParameters,
  //   );
  //
  //   _logs.add(entry);
  //
  //   // 限制记录数量
  //   if (_logs.length > maxLogs) {
  //     _logs.removeAt(0);
  //   }
  //
  //   return timestamp;
  // }

  /// 记录响应
  void recordResponse({
    required String method,
    required String url,
    required int statusCode,
    String? statusMessage,
    dynamic responseData,
    DateTime? requestTime,
    Map<String, dynamic>? headers,
    dynamic requestData,
    Map<String, dynamic>? queryParameters,
  }) {
    final timestamp = requestTime ?? DateTime.now();
    final duration = requestTime != null 
        ? DateTime.now().difference(requestTime)
        : null;

    // 只记录已完成的响应（不记录进行中请求）
    _logs.add(NetworkLogEntry(
      timestamp: timestamp,
      method: method,
      url: url,
      headers: headers,
      requestData: requestData,
      queryParameters: queryParameters,
      statusCode: statusCode,
      statusMessage: statusMessage,
      responseData: responseData,
      duration: duration,
    ));

    // 限制记录数量
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }

    // 通知监听器
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 记录错误
  void recordError({
    required String method,
    required String url,
    String? error,
    int? statusCode,
    DateTime? requestTime,
    Map<String, dynamic>? headers,
    dynamic requestData,
    Map<String, dynamic>? queryParameters,
  }) {
    final timestamp = requestTime ?? DateTime.now();
    final duration = requestTime != null 
        ? DateTime.now().difference(requestTime)
        : null;

    _logs.add(NetworkLogEntry(
      timestamp: timestamp,
      method: method,
      url: url,
      headers: headers,
      requestData: requestData,
      queryParameters: queryParameters,
      statusCode: statusCode,
      error: error,
      duration: duration,
    ));

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

  /// 清空记录
  void clear() {
    _logs.clear();
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 导出记录为文本
  String exportLogs() {
    final buffer = StringBuffer();
    for (final log in _logs) {
      buffer.writeln('[$log.formattedTime] ${log.method} ${log.url}');
      if (log.statusCode != null) {
        buffer.writeln('  Status: ${log.statusCode} ${log.statusMessage ?? ''}');
      }
      if (log.error != null) {
        buffer.writeln('  Error: ${log.error}');
      }
      if (log.duration != null) {
        buffer.writeln('  Duration: ${log.duration!.inMilliseconds}ms');
      }
      buffer.writeln('');
    }
    return buffer.toString();
  }
}
