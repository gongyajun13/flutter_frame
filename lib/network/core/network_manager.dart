import '../../utils/getx_utils.dart';
import '../models/api_response.dart';
import '../services/network_service.dart';

/// 网络请求回调
typedef NetworkCallback<T> = void Function(T data);
typedef NetworkErrorCallback = void Function(String message, int code);
typedef NetworkExceptionCallback = void Function(dynamic error);

/// 网络请求管理器
/// 提供简洁的网络请求接口，通过回调返回结果
class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  final NetworkService _networkService = NetworkService();

  /// GET请求
  Future<void> get<T>({
    required String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    required NetworkCallback<T> onSuccess,
    NetworkErrorCallback? onError,
    NetworkExceptionCallback? onException,
    bool showLoading = true,
    bool showError = true,
    String? loadingText,
    String? successText,
  }) async {
    await _executeRequest<T>(
      () => _networkService.get<T>(
        url,
        queryParameters: params,
        headers: headers,
        fromJson: fromJson,
      ),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: loadingText ?? '加载中...',
      successText: successText,
    );
  }

  /// POST请求
  Future<void> post<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    required NetworkCallback<T> onSuccess,
    NetworkErrorCallback? onError,
    NetworkExceptionCallback? onException,
    bool showLoading = true,
    bool showError = true,
    String? loadingText,
    String? successText,
  }) async {
    await _executeRequest<T>(
      () => _networkService.post<T>(
        url,
        data: data,
        queryParameters: params,
        headers: headers,
        fromJson: fromJson,
      ),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: loadingText ?? '提交中...',
      successText: successText,
    );
  }

  /// PUT请求
  Future<void> put<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    required NetworkCallback<T> onSuccess,
    NetworkErrorCallback? onError,
    NetworkExceptionCallback? onException,
    bool showLoading = true,
    bool showError = true,
    String? loadingText,
    String? successText,
  }) async {
    await _executeRequest<T>(
      () => _networkService.put<T>(
        url,
        data: data,
        queryParameters: params,
        headers: headers,
        fromJson: fromJson,
      ),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: loadingText ?? '更新中...',
      successText: successText,
    );
  }

  /// DELETE请求
  Future<void> delete<T>({
    required String url,
    dynamic data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    required NetworkCallback<T> onSuccess,
    NetworkErrorCallback? onError,
    NetworkExceptionCallback? onException,
    bool showLoading = true,
    bool showError = true,
    String? loadingText,
    String? successText,
  }) async {
    await _executeRequest<T>(
      () => _networkService.delete<T>(
        url,
        data: data,
        queryParameters: params,
        headers: headers,
        fromJson: fromJson,
      ),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: loadingText ?? '删除中...',
      successText: successText,
    );
  }

  /// 文件上传
  Future<void> upload<T>({
    required String url,
    required String filePath,
    String? fileName,
    dynamic data,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
    required NetworkCallback<T> onSuccess,
    NetworkErrorCallback? onError,
    NetworkExceptionCallback? onException,
    void Function(int sent, int total)? onProgress,
    bool showLoading = true,
    bool showError = true,
    String? loadingText,
    String? successText,
  }) async {
    await _executeRequest<T>(
      () => _networkService.upload<T>(
        url,
        filePath: filePath,
        fileName: fileName,
        data: data,
        headers: headers,
        onSendProgress: onProgress,
        fromJson: fromJson,
      ),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: loadingText ?? '上传中...',
      successText: successText,
    );
  }

  /// 分页请求
  Future<void> getPaginated<T>({
    required String url,
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? headers,
    required T Function(dynamic) itemFromJson,
    required NetworkCallback<PaginatedResponse<T>> onSuccess,
    NetworkErrorCallback? onError,
    NetworkExceptionCallback? onException,
    bool showLoading = true,
    bool showError = true,
    String? loadingText,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      ...?filters,
    };

    await _executeRequest<PaginatedResponse<T>>(
      () => _networkService.get<PaginatedResponse<T>>(
        url,
        queryParameters: params,
        headers: headers,
        fromJson: (data) => PaginatedResponse.fromJson(
          data,
          itemFromJson,
        ),
      ),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: loadingText ?? '加载中...',
      successText: null, // 分页请求通常不显示成功提示
    );
  }

  /// 执行网络请求的通用方法
  Future<void> _executeRequest<T>(
    Future<ApiResponse<T>> Function() request,
    {
    required NetworkCallback<T> onSuccess,
    NetworkErrorCallback? onError,
    NetworkExceptionCallback? onException,
    required bool showLoading,
    required bool showError,
    required String loadingText,
    String? successText,
  }) async {
    try {
      // 显示loading
      if (showLoading) {
        _showLoading(loadingText);
      }

      // 执行请求
      final response = await request();

      // 处理响应
      if (response.success) {
        // 先隐藏loading
        if (showLoading) {
          _hideLoading();
          // 等待一小段时间确保 dialog 关闭后再显示提示
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // 显示成功提示
        if (successText != null && successText.isNotEmpty) {
          _showSuccess(successText);
        }
        // 调用成功回调
        onSuccess(response.data as T);
      } else {
        // 先隐藏loading
        if (showLoading) {
          _hideLoading();
          // 等待一小段时间确保 dialog 关闭后再显示提示
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // 显示错误提示
        if (showError) {
          _showError(response.message);
        }
        // 调用失败回调
        onError?.call(response.message, response.code);
      }

    } catch (e) {
      // 隐藏loading
      if (showLoading) {
        _hideLoading();
        // 等待一小段时间确保 dialog 关闭后再显示提示
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // 显示异常提示
      if (showError) {
        _showError('网络请求异常: $e');
      }

      // 调用异常回调
      onException?.call(e);
    }
  }

  /// 显示loading
  void _showLoading(String text) {
    GetXDialogUtil.showLoading(message: text);
  }

  /// 隐藏loading
  void _hideLoading() {
    GetXDialogUtil.hideLoading();
  }

  /// 显示成功提示
  void _showSuccess(String message) {
    GetXSnackBarUtil.success(message: message);
  }

  /// 显示错误提示
  void _showError(String message) {
    GetXSnackBarUtil.error(message: message);
  }
}
