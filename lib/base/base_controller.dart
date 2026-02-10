import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../app/controllers/theme_controller.dart';
import '../utils/error_monitor_service.dart';

/// Controller 基类
/// 提供通用的状态管理、资源清理、错误处理等功能
abstract class BaseController extends GetxController {
  // ==================== 通用状态 ====================

  /// 加载状态
  final isLoading = false.obs;

  /// 错误消息
  final errorMessage = Rx<String?>(null);

  /// 是否发生错误
  bool get hasError => errorMessage.value != null;

  // ==================== 资源管理 ====================

  /// TextEditingController 列表（自动清理）
  final List<TextEditingController> _textControllers = [];

  /// PageController 列表（自动清理）
  final List<PageController> _pageControllers = [];

  /// Timer 列表（自动清理）
  final List<Timer> _timers = [];

  /// StreamSubscription 列表（自动清理）
  final List<StreamSubscription> _subscriptions = [];

  /// AnimationController 列表（自动清理）
  final List<AnimationController> _animationControllers = [];

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    _onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _onReady();
  }

  @override
  void onClose() {
    _disposeResources();
    _onClose();
    super.onClose();
  }

  /// 初始化（子类重写）
  void _onInit() {}

  /// 准备完成（子类重写）
  void _onReady() {}

  /// 关闭（子类重写）
  void _onClose() {}

  // ==================== 资源管理方法 ====================

  /// 注册 TextEditingController（自动清理）
  void registerTextController(TextEditingController controller) {
    _textControllers.add(controller);
  }

  /// 注册 PageController（自动清理）
  void registerPageController(PageController controller) {
    _pageControllers.add(controller);
  }

  /// 注册 Timer（自动清理）
  void registerTimer(Timer timer) {
    _timers.add(timer);
  }

  /// 注册 StreamSubscription（自动清理）
  void registerSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// 注册 AnimationController（自动清理）
  void registerAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
  }

  /// 清理所有资源
  void _disposeResources() {
    // 清理 TextEditingController
    for (final controller in _textControllers) {
      controller.dispose();
    }
    _textControllers.clear();

    // 清理 PageController
    for (final controller in _pageControllers) {
      controller.dispose();
    }
    _pageControllers.clear();

    // 清理 Timer
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    // 清理 StreamSubscription
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 清理 AnimationController
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear();
  }

  // ==================== 状态管理方法 ====================

  /// 设置加载状态
  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  /// 设置错误消息
  void setError(String? message) {
    errorMessage.value = message;
  }

  /// 清除错误
  void clearError() {
    errorMessage.value = null;
  }

  /// 执行异步操作（自动管理加载状态和错误处理）
  Future<T?> executeAsync<T>({
    required Future<T> Function() action,
    bool showLoading = true,
    bool showError = true,
    String? loadingMessage,
    String? errorMessage,
    Function(T)? onSuccess,
    Function(dynamic)? onError,
  }) async {
    try {
      // 设置加载状态
      if (showLoading) {
        setLoading(true);
      }

      // 清除之前的错误
      clearError();

      // 执行操作
      final result = await action();

      // 成功回调
      onSuccess?.call(result);

      return result;
    } catch (e, stackTrace) {
      // 设置错误消息
      final errorMsg = errorMessage ?? e.toString();
      if (showError) {
        setError(errorMsg);
      }

      // 上报错误到错误监控系统
      try {
        final errorMonitor = Get.find<ErrorMonitorService>();
        errorMonitor.reportError(
          e,
          stackTrace: stackTrace,
          context: 'BaseController.executeAsync',
          tags: {'source': 'BaseController.executeAsync'},
        );
      } catch (_) {
        // 错误监控服务可能未初始化，忽略
      }

      // 错误回调
      onError?.call(e);

      return null;
    } finally {
      // 清除加载状态
      if (showLoading) {
        setLoading(false);
      }
    }
  }

  // ==================== 工具方法 ====================

  /// 获取 SnackBar 随主题的背景色和文字色
  static (Color bg, Color text) _snackBarThemeColors() {
    try {
      final themeController = Get.find<ThemeController>();
      final isDark = themeController.isDarkTheme;
      return isDark
          ? (Colors.grey.shade800, Colors.white)
          : (Colors.grey.shade200, Colors.black87);
    } catch (_) {
      return (Colors.grey.shade200, Colors.black87);
    }
  }

  /// 显示成功提示
  void showSuccess(String message) {
    final (bg, text) = _snackBarThemeColors();
    Get.snackbar('成功', message, backgroundColor: bg, colorText: text);
  }

  /// 显示错误提示
  void showError(String message, {Object? error, StackTrace? stackTrace}) {
    final (bg, text) = _snackBarThemeColors();
    Get.snackbar('错误', message, backgroundColor: bg, colorText: text);
    
    // 上报错误到错误监控系统
    if (error != null) {
      try {
        final errorMonitor = Get.find<ErrorMonitorService>();
        errorMonitor.reportError(
          error,
          stackTrace: stackTrace,
          context: message,
          tags: {'source': 'BaseController.showError'},
        );
      } catch (e) {
        // 错误监控服务可能未初始化，忽略
      }
    }
  }

  /// 显示警告提示
  void showWarning(String message) {
    final (bg, text) = _snackBarThemeColors();
    Get.snackbar('警告', message, backgroundColor: bg, colorText: text);
  }

  /// 显示信息提示
  void showInfo(String message) {
    final (bg, text) = _snackBarThemeColors();
    Get.snackbar('提示', message, backgroundColor: bg, colorText: text);
  }

  /// 导航到指定路由
  void navigateTo(String route, {dynamic arguments, Map<String, String>? parameters}) {
    Get.toNamed(route, arguments: arguments, parameters: parameters);
  }

  /// 返回上一页
  void goBack({dynamic result}) {
    Get.back(result: result);
  }

  /// 替换当前页面
  void replaceTo(String route, {dynamic arguments}) {
    Get.offNamed(route, arguments: arguments);
  }

  /// 清空路由栈并跳转
  void clearAndNavigateTo(String route, {dynamic arguments}) {
    Get.offAllNamed(route, arguments: arguments);
  }
}

/// 带加载状态的 Controller 基类
/// 适用于需要显示加载状态的场景
abstract class BaseLoadingController extends BaseController {
  /// 加载提示文本
  String get loadingMessage => '加载中...';

  /// 显示加载对话框
  void showLoadingDialog({String? message}) {
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
              Text(message ?? loadingMessage),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  @override
  Future<T?> executeAsync<T>({
    required Future<T> Function() action,
    bool showLoading = true,
    bool showError = true,
    String? loadingMessage,
    String? errorMessage,
    Function(T)? onSuccess,
    Function(dynamic)? onError,
  }) async {
    if (showLoading) {
      showLoadingDialog(message: loadingMessage);
    }

    try {
      final result = await super.executeAsync<T>(
        action: action,
        showLoading: false, // 已经在上面处理了
        showError: showError,
        errorMessage: errorMessage,
        onSuccess: onSuccess,
        onError: onError,
      );

      if (showLoading) {
        hideLoadingDialog();
      }

      return result;
    } catch (e) {
      if (showLoading) {
        hideLoadingDialog();
      }
      rethrow;
    }
  }
}
