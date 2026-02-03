import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../utils/error_monitor_service.dart';

/// 错误监控演示控制器
class ErrorMonitorDemoController extends BaseController {
  /// 错误日志列表
  final RxList<String> errorLogs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadErrorLogs();
  }

  /// 加载错误日志
  void _loadErrorLogs() {
    // 这里可以加载本地存储的错误日志
    errorLogs.clear();
  }

  /// 添加错误日志
  void _addErrorLog(String message) {
    final timestamp = DateTime.now().toString().substring(0, 19);
    errorLogs.insert(0, '[$timestamp] $message');
    if (errorLogs.length > 50) {
      errorLogs.removeLast();
    }
  }

  /// 触发 Flutter 错误
  void triggerFlutterError() {
    try {
      _addErrorLog('触发 Flutter 错误');
      // 故意触发一个 Flutter 错误
      throw FlutterError('这是一个 Flutter 错误示例');
    } catch (e) {
      showError('Flutter 错误已触发', error: e);
    }
  }

  /// 触发异步错误
  void triggerAsyncError() {
    try {
      _addErrorLog('触发异步错误');
      Future.delayed(Duration.zero, () {
        throw Exception('这是一个异步错误示例');
      });
      showInfo('异步错误已触发（将在下一个事件循环中抛出）');
    } catch (e) {
      showError('触发异步错误失败', error: e);
    }
  }

  /// 触发 Zone 错误
  void triggerZoneError() {
    try {
      _addErrorLog('触发 Zone 错误');
      Future.delayed(const Duration(milliseconds: 100), () {
        throw Exception('这是一个 Zone 错误示例');
      });
      showInfo('Zone 错误已触发（将在 100ms 后抛出）');
    } catch (e) {
      showError('触发 Zone 错误失败', error: e);
    }
  }

  /// 手动上报错误
  void reportManualError() {
    try {
      _addErrorLog('手动上报错误');
      final errorMonitor = Get.find<ErrorMonitorService>();
      errorMonitor.reportError(
        Exception('这是一个手动上报的错误示例'),
        context: '错误监控演示页面',
        tags: {
          'type': 'manual',
          'page': 'error_monitor_demo',
        },
      );
      showSuccess('错误已手动上报');
    } catch (e) {
      showError('手动上报错误失败', error: e);
    }
  }

  /// 触发空指针错误
  void triggerNullPointerError() {
    try {
      _addErrorLog('触发空指针错误');
      String? nullString;
      // 故意访问 null 对象
      final length = nullString!.length;
      showInfo('长度: $length');
    } catch (e, stackTrace) {
      showError('空指针错误已触发', error: e, stackTrace: stackTrace);
    }
  }

  /// 触发类型转换错误
  void triggerTypeError() {
    try {
      _addErrorLog('触发类型转换错误');
      final dynamic value = 'not a number';
      final number = value as int;
      showInfo('数字: $number');
    } catch (e, stackTrace) {
      showError('类型转换错误已触发', error: e, stackTrace: stackTrace);
    }
  }

  /// 触发网络错误
  void triggerNetworkError() {
    try {
      _addErrorLog('触发网络错误');
      throw Exception('网络连接失败: 无法连接到服务器');
    } catch (e, stackTrace) {
      showError('网络错误已触发', error: e, stackTrace: stackTrace);
    }
  }

  /// 设置用户信息
  void setUserInfo() {
    try {
      final errorMonitor = Get.find<ErrorMonitorService>();
      errorMonitor.setUser(
        id: 'user_123',
        username: 'demo_user',
        email: 'demo@example.com',
      );
      showSuccess('用户信息已设置');
    } catch (e) {
      showError('设置用户信息失败', error: e);
    }
  }

  /// 添加面包屑
  void addBreadcrumb() {
    try {
      final errorMonitor = Get.find<ErrorMonitorService>();
      errorMonitor.addBreadcrumb(
        message: '用户点击了添加面包屑按钮',
        category: 'user_action',
        level: 'info',
        data: {'button': 'add_breadcrumb'},
      );
      showSuccess('面包屑已添加');
    } catch (e) {
      showError('添加面包屑失败', error: e);
    }
  }

  /// 设置标签
  void setTag() {
    try {
      final errorMonitor = Get.find<ErrorMonitorService>();
      errorMonitor.setTag('environment', 'demo');
      errorMonitor.setTag('version', '1.0.0');
      showSuccess('标签已设置');
    } catch (e) {
      showError('设置标签失败', error: e);
    }
  }

  /// 清空错误日志
  void clearLogs() {
    errorLogs.clear();
    showSuccess('错误日志已清空');
  }
}
