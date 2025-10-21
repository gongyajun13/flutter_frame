import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/api_response.dart';
import '../services/network_service.dart';

/// 网络请求基类
/// 提供统一的网络请求处理、loading显示、错误提示等功能
abstract class BaseNetworkRequest<T> {
  final NetworkService _networkService = NetworkService();
  
  /// 请求URL
  String get url;
  
  /// 请求方法
  HttpMethod get method;
  
  /// 请求参数
  Map<String, dynamic>? get params => null;
  
  /// 请求体数据
  dynamic get data => null;
  
  /// 请求头
  Map<String, dynamic>? get headers => null;
  
  /// 是否显示loading
  bool get showLoading => true;
  
  /// 是否显示错误提示
  bool get showError => true;
  
  /// Loading提示文本
  String get loadingText => '加载中...';
  
  /// 成功提示文本（为空则不显示）
  String? get successText;
  
  /// 从JSON解析数据模型
  T Function(dynamic)? get fromJson;
  
  /// 请求成功回调
  void onSuccess(T data) {}
  
  /// 请求失败回调
  void onError(String message, int code) {}
  
  /// 请求异常回调
  void onException(dynamic error) {}
  
  /// 执行网络请求
  Future<void> execute() async {
    try {
      // 显示loading
      if (showLoading) {
        _showLoading();
      }
      
      // 执行请求
      ApiResponse<T> response;
      switch (method) {
        case HttpMethod.get:
          response = await _networkService.get<T>(
            url,
            queryParameters: params,
            headers: headers,
            fromJson: fromJson,
          );
          break;
        case HttpMethod.post:
          response = await _networkService.post<T>(
            url,
            data: data,
            queryParameters: params,
            headers: headers,
            fromJson: fromJson,
          );
          break;
        case HttpMethod.put:
          response = await _networkService.put<T>(
            url,
            data: data,
            queryParameters: params,
            headers: headers,
            fromJson: fromJson,
          );
          break;
        case HttpMethod.delete:
          response = await _networkService.delete<T>(
            url,
            data: data,
            queryParameters: params,
            headers: headers,
            fromJson: fromJson,
          );
          break;
        case HttpMethod.patch:
          response = await _networkService.patch<T>(
            url,
            data: data,
            queryParameters: params,
            headers: headers,
            fromJson: fromJson,
          );
          break;
      }
      
      // 隐藏loading
      if (showLoading) {
        _hideLoading();
      }
      
      // 处理响应
      if (response.success) {
        // 显示成功提示
        _showSuccess(successText ?? '操作成功');
        // 调用成功回调
        onSuccess(response.data as T);
      } else {
        // 显示错误提示
        _showError(response.message);
        // 调用失败回调
        onError(response.message, response.code);
      }
      
    } catch (e) {
      // 隐藏loading
      _hideLoading();
      
      // 显示异常提示
      _showError('网络请求异常: $e');
      
      // 调用异常回调
      onException(e);
    }
  }
  
  /// 显示loading
  void _showLoading() {
    if (showLoading) {
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(loadingText),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
  
  /// 隐藏loading
  void _hideLoading() {
    if (showLoading && Get.isDialogOpen == true) {
      Get.back();
    }
  }
  
  /// 显示成功提示
  void _showSuccess(String message) {
    if (successText != null && successText!.isNotEmpty) {
      Get.snackbar(
        '成功',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  /// 显示错误提示
  void _showError(String message) {
    if (showError) {
      Get.snackbar(
        '错误',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

/// HTTP请求方法枚举
enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
}

/// 文件上传基类
abstract class BaseFileUploadRequest<T> extends BaseNetworkRequest<T> {
  /// 文件路径
  String get filePath;
  
  /// 文件名
  String? get fileName;
  
  /// 上传进度回调
  void onProgress(int sent, int total) {}
  
  @override
  Future<void> execute() async {
    try {
      // 显示loading
      if (showLoading) {
        _showLoading();
      }
      
      // 执行文件上传
      final response = await _networkService.upload<T>(
        url,
        filePath: filePath,
        fileName: fileName,
        data: data,
        headers: headers,
        onSendProgress: onProgress,
        fromJson: fromJson,
      );
      
      // 隐藏loading
      if (showLoading) {
        _hideLoading();
      }
      
      // 处理响应
      if (response.success) {
        // 显示成功提示
        _showSuccess(successText ?? '文件上传成功');
        // 调用成功回调
        onSuccess(response.data as T);
      } else {
        // 显示错误提示
        _showError(response.message);
        // 调用失败回调
        onError(response.message, response.code);
      }
      
    } catch (e) {
      // 隐藏loading
      _hideLoading();
      
      // 显示异常提示
      _showError('文件上传异常: $e');
      
      // 调用异常回调
      onException(e);
    }
  }
}

/// 分页请求基类
abstract class BasePaginatedRequest<T> extends BaseNetworkRequest<PaginatedResponse<T>> {
  /// 页码
  int get page => 1;
  
  /// 每页大小
  int get pageSize => 10;
  
  /// 过滤参数
  Map<String, dynamic>? get filters;
  
  @override
  Map<String, dynamic>? get params {
    final baseParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    
    if (filters != null) {
      baseParams.addAll(filters!);
    }
    
    return baseParams;
  }
  
  @override
  PaginatedResponse<T> Function(dynamic)? get fromJson => (data) {
    return PaginatedResponse.fromJson(
      data,
      (item) => itemFromJson(item),
    );
  };
  
  /// 从JSON解析单个数据项
  T Function(dynamic) get itemFromJson;
}
