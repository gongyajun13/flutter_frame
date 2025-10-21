import 'package:dio/dio.dart';
import '../config/network_config.dart';
import '../models/api_response.dart';

/// 网络请求服务类
/// 提供统一的网络请求接口，处理成功、失败、异常回调
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Dio _dio = NetworkConfig.dio;

  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PATCH请求
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 文件上传
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required String filePath,
    String? fileName,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 多文件上传
  Future<ApiResponse<T>> uploadMultiple<T>(
    String path, {
    required List<String> filePaths,
    List<String>? fileNames,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final files = <MultipartFile>[];
      for (int i = 0; i < filePaths.length; i++) {
        files.add(await MultipartFile.fromFile(
          filePaths[i],
          filename: fileNames?[i],
        ));
      }

      final formData = FormData.fromMap({
        'files': files,
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 文件下载
  Future<ApiResponse<String>> download(
    String path, {
    required String savePath,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return ApiResponse.successResponse(data: savePath, message: '下载成功');
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  /// 处理响应
  ApiResponse<T> _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    final statusCode = response.statusCode ?? 0;
    
    if (statusCode >= 200 && statusCode < 300) {
      // 成功响应
      if (response.data is Map<String, dynamic>) {
        // 如果响应是JSON格式，尝试解析为ApiResponse
        try {
          return ApiResponse.fromJson(response.data, fromJson);
        } catch (e) {
          // 如果解析失败，直接返回数据
        return ApiResponse.successResponse(
          data: fromJson != null ? fromJson(response.data) : response.data,
          code: statusCode,
        );
        }
      } else {
        // 非JSON响应
        return ApiResponse.successResponse(
          data: fromJson != null ? fromJson(response.data) : response.data,
          code: statusCode,
        );
      }
    } else {
      // 错误响应
      String message = '请求失败';
      if (response.data is Map<String, dynamic>) {
        message = response.data['message'] ?? message;
      }
      return ApiResponse.errorResponse(
        message: message,
        code: statusCode,
        error: response.data?.toString(),
      );
    }
  }

  /// 处理错误
  ApiResponse<T> _handleError<T>(dynamic error) {
    final networkError = NetworkError.fromDioException(error);
    return ApiResponse.errorResponse(
      message: networkError.message,
      code: networkError.statusCode ?? 0,
      error: networkError.data?.toString(),
    );
  }
}

/// 网络请求工具类
/// 提供便捷的API调用方法
class NetworkUtils {
  static final NetworkService _service = NetworkService();

  /// 用户登录
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    return _service.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  /// 用户注册
  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String password,
    required String email,
  }) async {
    return _service.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'username': username,
        'password': password,
        'email': email,
      },
    );
  }

  /// 获取用户信息
  static Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return _service.get<Map<String, dynamic>>('/user/profile');
  }

  /// 更新用户信息
  static Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
    required Map<String, dynamic> profile,
  }) async {
    return _service.put<Map<String, dynamic>>(
      '/user/profile',
      data: profile,
    );
  }

  /// 上传头像
  static Future<ApiResponse<Map<String, dynamic>>> uploadAvatar({
    required String filePath,
    ProgressCallback? onProgress,
  }) async {
    return _service.upload<Map<String, dynamic>>(
      '/user/avatar',
      filePath: filePath,
      onSendProgress: onProgress,
    );
  }

  /// 获取产品列表
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>> getProducts({
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
  }) async {
    return _service.get<PaginatedResponse<Map<String, dynamic>>>(
      '/products',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        ...?filters,
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  /// 获取产品详情
  static Future<ApiResponse<Map<String, dynamic>>> getProductDetail({
    required String productId,
  }) async {
    return _service.get<Map<String, dynamic>>('/products/$productId');
  }

  /// 创建产品
  static Future<ApiResponse<Map<String, dynamic>>> createProduct({
    required Map<String, dynamic> product,
  }) async {
    return _service.post<Map<String, dynamic>>(
      '/products',
      data: product,
    );
  }

  /// 更新产品
  static Future<ApiResponse<Map<String, dynamic>>> updateProduct({
    required String productId,
    required Map<String, dynamic> product,
  }) async {
    return _service.put<Map<String, dynamic>>(
      '/products/$productId',
      data: product,
    );
  }

  /// 删除产品
  static Future<ApiResponse<void>> deleteProduct({
    required String productId,
  }) async {
    return _service.delete<void>('/products/$productId');
  }
}
