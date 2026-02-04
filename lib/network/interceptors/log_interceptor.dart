import 'package:dio/dio.dart';
import '../../../utils/network_logger.dart';

class _RequestSnapshot {
  final DateTime startTime;
  final Map<String, dynamic> headers;
  final dynamic data;
  final Map<String, dynamic> queryParameters;

  const _RequestSnapshot({
    required this.startTime,
    required this.headers,
    required this.data,
    required this.queryParameters,
  });
}

/// 日志拦截器
/// 负责记录网络请求和响应的详细信息
class LogInterceptor extends Interceptor {
  final bool requestHeader;
  final bool requestBody;
  final bool responseHeader;
  final bool responseBody;
  final bool error;
  final bool compact;
  final int maxWidth;

  LogInterceptor({
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.compact = true,
    this.maxWidth = 90,
  });

  // 存储请求快照（用于耗时计算 + 生成 curl）
  final Map<String, _RequestSnapshot> _requestSnapshots = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestKey = '${options.method}_${options.uri}';
    final startTime = DateTime.now();
    _requestSnapshots[requestKey] = _RequestSnapshot(
      startTime: startTime,
      headers: Map<String, dynamic>.from(options.headers),
      data: options.data,
      queryParameters: Map<String, dynamic>.from(options.queryParameters),
    );

    if (requestHeader) {
      _printRequestHeader(options);
    }
    if (requestBody) {
      _printRequestData(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 记录响应到 NetworkLogger
    // 始终记录，不依赖 kDebugMode，因为 NetworkLogger 本身会控制是否启用
    final requestKey = '${response.requestOptions.method}_${response.requestOptions.uri}';
    final snapshot = _requestSnapshots.remove(requestKey);
    
    NetworkLogger.instance.recordResponse(
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode ?? 0,
      statusMessage: response.statusMessage,
      responseData: responseBody ? response.data : null,
      requestTime: snapshot?.startTime,
      headers: snapshot?.headers,
      requestData: snapshot?.data,
      queryParameters: snapshot?.queryParameters,
    );

    if (responseHeader) {
      _printResponseHeader(response);
    }
    if (responseBody) {
      _printResponseData(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 记录错误到 NetworkLogger
    // 始终记录，不依赖 kDebugMode，因为 NetworkLogger 本身会控制是否启用
    final requestKey = '${err.requestOptions.method}_${err.requestOptions.uri}';
    final snapshot = _requestSnapshots.remove(requestKey);
    
    NetworkLogger.instance.recordError(
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      error: err.message,
      statusCode: err.response?.statusCode,
      requestTime: snapshot?.startTime,
      headers: snapshot?.headers,
      requestData: snapshot?.data,
      queryParameters: snapshot?.queryParameters,
    );

    if (error) {
      _printError(err);
    }
    handler.next(err);
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    print('┌─────────────────────────────────────────────────────────────');
    print('│ Request: $method $uri');
    print('├─────────────────────────────────────────────────────────────');
    print('│ Headers:');
    options.headers.forEach((key, value) {
      print('│   $key: $value');
    });
  }

  void _printRequestData(RequestOptions options) {
    if (options.data != null) {
      print('├─────────────────────────────────────────────────────────────');
      print('│ Request Data:');
      _printData(options.data);
    }
    if (options.queryParameters.isNotEmpty) {
      print('├─────────────────────────────────────────────────────────────');
      print('│ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        print('│   $key: $value');
      });
    }
    print('└─────────────────────────────────────────────────────────────');
  }

  void _printResponseHeader(Response response) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ Response: ${response.statusCode} ${response.statusMessage}');
    print('├─────────────────────────────────────────────────────────────');
    print('│ Headers:');
    response.headers.forEach((key, value) {
      print('│   $key: $value');
    });
  }

  void _printResponseData(Response response) {
    print('├─────────────────────────────────────────────────────────────');
    print('│ Response Data:');
    _printData(response.data);
    print('└─────────────────────────────────────────────────────────────');
  }

  void _printError(DioException err) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ Error: ${err.type}');
    print('├─────────────────────────────────────────────────────────────');
    print('│ Message: ${err.message}');
    if (err.response != null) {
      print('│ Status Code: ${err.response?.statusCode}');
      print('│ Response Data:');
      _printData(err.response?.data);
    }
    print('└─────────────────────────────────────────────────────────────');
  }

  void _printData(dynamic data) {
    if (data == null) {
      print('│   null');
      return;
    }

    String dataStr = data.toString();
    if (compact && dataStr.length > maxWidth) {
      dataStr = '${dataStr.substring(0, maxWidth)}...';
    }

    final lines = dataStr.split('\n');
    for (final line in lines) {
      print('│   $line');
    }
  }
}
