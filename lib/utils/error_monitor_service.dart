import 'package:get/get.dart';
import 'error_monitor.dart';

/// 错误监控服务
/// 使用 GetX Service 管理错误监控的生命周期
class ErrorMonitorService extends GetxService {
  /// 初始化错误监控服务
  Future<ErrorMonitorService> init({
    bool enableConsoleLog = true,
    bool enableErrorReporting = false,
  }) async {
    await ErrorMonitor.instance.init(
      enableConsoleLog: enableConsoleLog,
      enableErrorReporting: enableErrorReporting,
    );
    return this;
  }

  /// 手动上报错误
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, String>? tags,
  }) {
    ErrorMonitor.instance.reportError(
      error,
      stackTrace: stackTrace,
      context: context,
      tags: tags,
    );
  }

  /// 设置用户信息
  void setUser({
    String? id,
    String? username,
    String? email,
    Map<String, dynamic>? extra,
  }) {
    ErrorMonitor.instance.setUser(
      id: id,
      username: username,
      email: email,
      extra: extra,
    );
  }

  /// 添加面包屑
  void addBreadcrumb({
    required String message,
    String? category,
    String? level,
    Map<String, dynamic>? data,
  }) {
    ErrorMonitor.instance.addBreadcrumb(
      message: message,
      category: category,
      level: level,
      data: data,
    );
  }

  /// 设置标签
  void setTag(String key, String value) {
    ErrorMonitor.instance.setTag(key, value);
  }

  /// 设置上下文
  void setContext(String key, Map<String, dynamic> context) {
    ErrorMonitor.instance.setContext(key, context);
  }
}
