import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/log_interceptor.dart' as custom;

/// 网络配置管理类
class NetworkConfig {
  static Dio? _dio;

  /// 获取Dio实例
  static Dio get dio {
    if (_dio == null) {
      _initializeDio();
    }
    return _dio!;
  }

  /// 初始化Dio配置
  static void _initializeDio() {
    _dio = Dio();

    // 基础配置
    _dio!.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
      validateStatus: (status) {
        // 接受所有状态码，在拦截器中处理
        return true;
      },
    );

    // 添加拦截器
    _addInterceptors();

  }

  /// 添加拦截器
  static void _addInterceptors() {
    // 认证拦截器
    _dio!.interceptors.add(AuthInterceptor());

    // 日志拦截器（仅在调试模式下启用）
    if (kDebugMode) {
      _dio!.interceptors.add(custom.LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    // 重试拦截器
    _dio!.interceptors.add(RetryInterceptor());

    // 错误处理拦截器
    _dio!.interceptors.add(ErrorHandlerInterceptor());
  }

  /// 更新基础URL
  static void updateBaseUrl(String baseUrl) {
    if (_dio != null) {
      _dio!.options.baseUrl = baseUrl;
    }
  }

  /// 更新请求头
  static void updateHeaders(Map<String, dynamic> headers) {
    if (_dio != null) {
      _dio!.options.headers.addAll(headers);
    }
  }

  /// 设置代理（用于调试）
  static void setProxy(String proxy) {
    if (_dio != null) {
      (_dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'PROXY $proxy';
        };
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }

  /// 清除代理
  static void clearProxy() {
    if (_dio != null) {
      (_dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = null;
    }
  }

  /// 重置Dio实例
  static void reset() {
    _dio = null;
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retryCount = options.extra['retryCount'] ?? 0;

    if (retryCount < ApiConfig.maxRetries && _shouldRetry(err)) {
      options.extra['retryCount'] = retryCount + 1;
      
      // 延迟重试
      await Future.delayed(Duration(milliseconds: (ApiConfig.retryDelay * (retryCount + 1)).toInt()));
      
      try {
        final response = await Dio().fetch(options);
        handler.resolve(response);
        return;
      } catch (e) {
        // 重试失败，继续处理错误
      }
    }
    
    handler.next(err);
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    // 网络错误或5xx服务器错误时重试
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// 错误处理拦截器
class ErrorHandlerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 统一错误处理
    _getErrorMessage(err);
    
    // 可以在这里添加全局错误处理逻辑
    // 比如显示错误提示、记录错误日志等
    
    handler.next(err);
  }

  /// 获取错误信息
  String _getErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络连接';
      case DioExceptionType.sendTimeout:
        return '发送超时，请重试';
      case DioExceptionType.receiveTimeout:
        return '接收超时，请重试';
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 400:
            return '请求参数错误';
          case 401:
            return '未授权，请重新登录';
          case 403:
            return '禁止访问';
          case 404:
            return '请求的资源不存在';
          case 500:
            return '服务器内部错误';
          case 502:
            return '网关错误';
          case 503:
            return '服务不可用';
          default:
            return '请求失败，状态码：$statusCode';
        }
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接错误，请检查网络设置';
      default:
        return err.message ?? '未知错误';
    }
  }
}
