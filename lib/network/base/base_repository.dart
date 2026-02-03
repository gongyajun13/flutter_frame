import 'package:dio/dio.dart';
import '../services/network_service.dart';
import '../models/api_response.dart';
import '../../utils/app_logger.dart';

/// 仓库层基础类
/// 统一封装 NetworkService 和 ApiResponse，向上抛出 NetworkError
abstract class BaseRepository {
  BaseRepository();

  final NetworkService _networkService = NetworkService();

  /// GET 请求并返回模型
  Future<T> getJson<T>({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final ApiResponse<T> resp = await _networkService.get<T>(
        path,
        queryParameters: query,
        headers: headers,
        fromJson: fromJson,
      );
      return _unwrapResponse(resp);
    } on DioException catch (e) {
      AppLogger.e('GET 请求异常: $path', error: e, stackTrace: e.stackTrace);
      throw NetworkError.fromDioException(e);
    } catch (e, stack) {
      AppLogger.e('GET 请求未知异常: $path', error: e, stackTrace: stack);
      throw NetworkError(
        type: NetworkErrorType.unknown,
        message: e.toString(),
      );
    }
  }

  /// GET 请求并返回分页模型
  Future<PaginatedResponse<T>> getPaginated<T>({
    required String path,
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? headers,
    required T Function(dynamic json) itemFromJson,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      ...?filters,
    };

    try {
      final ApiResponse<PaginatedResponse<T>> resp =
          await _networkService.get<PaginatedResponse<T>>(
        path,
        queryParameters: params,
        headers: headers,
        fromJson: (data) => PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          itemFromJson,
        ),
      );
      return _unwrapResponse(resp);
    } on DioException catch (e) {
      AppLogger.e('GET 分页请求异常: $path', error: e, stackTrace: e.stackTrace);
      throw NetworkError.fromDioException(e);
    } catch (e, stack) {
      AppLogger.e('GET 分页请求未知异常: $path', error: e, stackTrace: stack);
      throw NetworkError(
        type: NetworkErrorType.unknown,
        message: e.toString(),
      );
    }
  }

  /// POST 请求
  Future<T> postJson<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final ApiResponse<T> resp = await _networkService.post<T>(
        path,
        data: data,
        queryParameters: query,
        headers: headers,
        fromJson: fromJson,
      );
      return _unwrapResponse(resp);
    } on DioException catch (e) {
      AppLogger.e('POST 请求异常: $path', error: e, stackTrace: e.stackTrace);
      throw NetworkError.fromDioException(e);
    } catch (e, stack) {
      AppLogger.e('POST 请求未知异常: $path', error: e, stackTrace: stack);
      throw NetworkError(
        type: NetworkErrorType.unknown,
        message: e.toString(),
      );
    }
  }

  /// PUT 请求
  Future<T> putJson<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final ApiResponse<T> resp = await _networkService.put<T>(
        path,
        data: data,
        queryParameters: query,
        headers: headers,
        fromJson: fromJson,
      );
      return _unwrapResponse(resp);
    } on DioException catch (e) {
      AppLogger.e('PUT 请求异常: $path', error: e, stackTrace: e.stackTrace);
      throw NetworkError.fromDioException(e);
    } catch (e, stack) {
      AppLogger.e('PUT 请求未知异常: $path', error: e, stackTrace: stack);
      throw NetworkError(
        type: NetworkErrorType.unknown,
        message: e.toString(),
      );
    }
  }

  /// DELETE 请求
  Future<T> deleteJson<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final ApiResponse<T> resp = await _networkService.delete<T>(
        path,
        data: data,
        queryParameters: query,
        headers: headers,
        fromJson: fromJson,
      );
      return _unwrapResponse(resp);
    } on DioException catch (e) {
      AppLogger.e('DELETE 请求异常: $path', error: e, stackTrace: e.stackTrace);
      throw NetworkError.fromDioException(e);
    } catch (e, stack) {
      AppLogger.e('DELETE 请求未知异常: $path', error: e, stackTrace: stack);
      throw NetworkError(
        type: NetworkErrorType.unknown,
        message: e.toString(),
      );
    }
  }

  /// 统一解包 ApiResponse，失败时抛 NetworkError
  T _unwrapResponse<T>(ApiResponse<T> resp) {
    if (resp.success && resp.data != null) {
      return resp.data as T;
    }
    throw NetworkError(
      type: NetworkErrorType.badResponse,
      message: resp.message,
      statusCode: resp.code,
      data: resp.error ?? resp.extra,
    );
  }
}

