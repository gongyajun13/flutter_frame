import 'package:dio/dio.dart';

/// API统一响应模型
class ApiResponse<T> {
  final bool success;
  final int code;
  final String message;
  final T? data;
  final String? error;
  final Map<String, dynamic>? extra;

  ApiResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    this.error,
    this.extra,
  });

  /// 从JSON创建响应对象
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
      extra: json['extra'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'message': message,
      'data': data,
      'error': error,
      'extra': extra,
    };
  }

  /// 创建成功响应
  static ApiResponse<T> successResponse<T>({
    required T data,
    String message = '操作成功',
    int code = 200,
    Map<String, dynamic>? extra,
  }) {
    return ApiResponse<T>(
      success: true,
      code: code,
      message: message,
      data: data,
      extra: extra,
    );
  }

  /// 创建失败响应
  static ApiResponse<T> errorResponse<T>({
    required String message,
    int code = 400,
    String? error,
    Map<String, dynamic>? extra,
  }) {
    return ApiResponse<T>(
      success: false,
      code: code,
      message: message,
      error: error,
      extra: extra,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, code: $code, message: $message, data: $data, error: $error}';
  }
}

/// 分页响应模型
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// 从JSON创建分页响应对象
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => fromJsonT(item))
            .toList() ??
        [];

    return PaginatedResponse<T>(
      items: items,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      hasMore: json['hasMore'] ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse{items: ${items.length}, total: $total, page: $page, pageSize: $pageSize, hasMore: $hasMore}';
  }
}

/// 网络错误类型
enum NetworkErrorType {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badResponse,
  cancel,
  connectionError,
  unknown,
}

/// 网络错误模型
class NetworkError {
  final NetworkErrorType type;
  final String message;
  final int? statusCode;
  final dynamic data;

  NetworkError({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
  });

  /// 从DioException创建网络错误
  factory NetworkError.fromDioException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return NetworkError(
            type: NetworkErrorType.connectionTimeout,
            message: '连接超时',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.sendTimeout:
          return NetworkError(
            type: NetworkErrorType.sendTimeout,
            message: '发送超时',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.receiveTimeout:
          return NetworkError(
            type: NetworkErrorType.receiveTimeout,
            message: '接收超时',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.badResponse:
          return NetworkError(
            type: NetworkErrorType.badResponse,
            message: '服务器响应错误',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.cancel:
          return NetworkError(
            type: NetworkErrorType.cancel,
            message: '请求已取消',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.connectionError:
          return NetworkError(
            type: NetworkErrorType.connectionError,
            message: '网络连接错误',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
        default:
          return NetworkError(
            type: NetworkErrorType.unknown,
            message: error.message ?? '未知错误',
            statusCode: error.response?.statusCode,
            data: error.response?.data,
          );
      }
    }
    return NetworkError(
      type: NetworkErrorType.unknown,
      message: error.toString(),
    );
  }

  @override
  String toString() {
    return 'NetworkError{type: $type, message: $message, statusCode: $statusCode}';
  }
}
