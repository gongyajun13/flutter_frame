import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// SnackBar类型枚举
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// 全局SnackBar工具类
/// 基于GetX实现，支持队列管理和多种样式
class GetXSnackBarUtil {
  // 私有构造函数，防止实例化
  GetXSnackBarUtil._();

  // SnackBar队列管理
  static final List<SnackBarConfig> _snackBarQueue = [];
  static bool _isShowing = false;
  
  // 防抖机制相关
  static DateTime? _lastShowTime;
  static final Duration _debounceWindow = Duration(milliseconds: 500);

  /// 显示成功提示
  static void success({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
  }) {
    _showSnackBar(
      message: message,
      title: title ?? '成功',
      type: SnackBarType.success,
      duration: duration,
      position: position,
      showProgressIndicator: showProgressIndicator,
      onTap: onTap,
    );
  }

  /// 显示错误提示
  static void error({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.TOP,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
  }) {
    _showSnackBar(
      message: message,
      title: title ?? '错误',
      type: SnackBarType.error,
      duration: duration,
      position: position,
      showProgressIndicator: showProgressIndicator,
      onTap: onTap,
    );
  }

  /// 显示警告提示
  static void warning({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
  }) {
    _showSnackBar(
      message: message,
      title: title ?? '警告',
      type: SnackBarType.warning,
      duration: duration,
      position: position,
      showProgressIndicator: showProgressIndicator,
      onTap: onTap,
    );
  }

  /// 显示信息提示
  static void info({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
  }) {
    _showSnackBar(
      message: message,
      title: title ?? '提示',
      type: SnackBarType.info,
      duration: duration,
      position: position,
      showProgressIndicator: showProgressIndicator,
      onTap: onTap,
    );
  }

  /// 显示自定义SnackBar
  static void custom({
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    IconData? icon,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
  }) {
    _showSnackBar(
      message: message,
      title: title,
      type: type,
      duration: duration,
      position: position,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
      icon: icon,
      showProgressIndicator: showProgressIndicator,
      onTap: onTap,
    );
  }

  /// 显示多条消息（队列管理）
  static void showMultiple(List<SnackBarConfig> configs) {
    _snackBarQueue.addAll(configs);
    _processQueue();
  }

  /// 清除所有SnackBar
  static void clearAll() {
    _snackBarQueue.clear();
    if (_isShowing) {
      Get.closeCurrentSnackbar();
      _isShowing = false;
    }
  }

  /// 立即显示新的SnackBar（强制替换当前显示的）
  static void showImmediate({
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    IconData? icon,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
  }) {
    // 强制关闭当前显示的SnackBar
    if (_isShowing) {
      Get.closeCurrentSnackbar();
      _isShowing = false;
    }

    // 清空队列
    _snackBarQueue.clear();

    // 立即显示新的SnackBar
    _showSnackBarImmediately(SnackBarConfig(
      message: message,
      title: title,
      type: type,
      duration: duration,
      position: position,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
      icon: icon,
      showProgressIndicator: showProgressIndicator,
      onTap: onTap,
    ));
  }

  /// 内部显示SnackBar方法（带防抖机制）
  static void _showSnackBar({
    required String message,
    String? title,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    IconData? icon,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
  }) {
    final config = SnackBarConfig(
      message: message,
      title: title,
      type: type,
      duration: duration,
      position: position,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
      icon: icon,
      showProgressIndicator: showProgressIndicator,
      onTap: onTap,
    );

    final now = DateTime.now();
    
    // 防抖机制：500毫秒内的连续消息复用同一个 SnackBar 窗口
    if (_isShowing && 
        _lastShowTime != null && 
        now.difference(_lastShowTime!) < _debounceWindow) {
      // 在防抖窗口内，更新当前 SnackBar 的内容
      print('[SnackBar防抖] 复用窗口，更新内容：$message');
      _updateCurrentSnackBar(config);
      _lastShowTime = now;
      return;
    }

    // 不在防抖窗口内，需要显示新的 SnackBar
    _lastShowTime = now;

    // 如果有正在显示的SnackBar，先关闭它
    if (_isShowing) {
      print('[SnackBar] 关闭旧窗口，显示新窗口');
      Get.closeCurrentSnackbar();
      _isShowing = false;
      
      // 等待关闭动画完成后再显示新的
      Future.delayed(const Duration(milliseconds: 100), () {
        _showSnackBarImmediately(config);
      });
    } else {
      // 没有正在显示的SnackBar，直接显示
      print('[SnackBar] 显示新窗口');
      _showSnackBarImmediately(config);
    }
  }
  
  /// 更新当前显示的 SnackBar 内容
  static void _updateCurrentSnackBar(SnackBarConfig config) {
    if (!_isShowing) return;
    
    // 延迟到下一帧执行，避免在 build 过程中调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isShowing) return;
      
      // 关闭当前的并立即显示新的（视觉上像是更新）
      try {
        Get.closeCurrentSnackbar();
      } catch (e) {
        print('[SnackBar] 关闭失败: $e');
      }
      
      Future.delayed(const Duration(milliseconds: 50), () {
        _snackBarQueue.clear();
        _snackBarQueue.add(config);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _processQueue();
        });
      });
    });
  }

  /// 立即显示SnackBar
  static void _showSnackBarImmediately(SnackBarConfig config) {
    // 清空队列，只显示最新的
    _snackBarQueue.clear();
    _snackBarQueue.add(config);
    
    // 延迟到下一帧执行，避免在 build 过程中调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processQueue();
    });
  }

  /// 处理SnackBar队列
  static void _processQueue() {
    if (_isShowing || _snackBarQueue.isEmpty) return;

    final config = _snackBarQueue.removeAt(0);
    _isShowing = true;

    // 获取样式配置
    final style = _getSnackBarStyle(config.type);

    Get.snackbar(
      config.title ?? style.title,
      config.message,
      backgroundColor: config.backgroundColor ?? style.backgroundColor,
      colorText: config.textColor ?? style.textColor,
      icon: config.icon != null
          ? Icon(
              config.icon,
              color: config.iconColor ?? style.iconColor,
              size: 24.sp,
            )
          : Icon(
              style.icon,
              color: config.iconColor ?? style.iconColor,
              size: 24.sp,
            ),
      snackPosition: config.position,
      duration: config.duration,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 200),
      showProgressIndicator: config.showProgressIndicator,
      progressIndicatorBackgroundColor: Colors.white.withOpacity(0.3),
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(
        config.textColor ?? style.textColor,
      ),
      onTap: config.onTap != null ? (snack) => config.onTap!() : null,
      shouldIconPulse: false,
      maxWidth: Get.width * 0.9,
      titleText: config.title != null
          ? Text(
              config.title!,
              style: TextStyle(
                color: config.textColor ?? style.textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      messageText: Text(
        config.message,
        style: TextStyle(
          color: config.textColor ?? style.textColor,
          fontSize: 14.sp,
          height: 1.4,
        ),
      ),
    );
    
    // 设置定时器，在SnackBar显示完成后重置状态
    Future.delayed(config.duration + const Duration(milliseconds: 200), () {
      _isShowing = false;
      // 处理队列中的下一个SnackBar（如果有的话）
      _processQueue();
    });
  }

  /// 获取SnackBar样式配置
  static SnackBarStyle _getSnackBarStyle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return SnackBarStyle(
          title: '成功',
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.check_circle,
        );
      case SnackBarType.error:
        return SnackBarStyle(
          title: '错误',
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.error,
        );
      case SnackBarType.warning:
        return SnackBarStyle(
          title: '警告',
          backgroundColor: Colors.orange.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.warning,
        );
      case SnackBarType.info:
        return SnackBarStyle(
          title: '提示',
          backgroundColor: Colors.blue.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: Icons.info,
        );
    }
  }
}

/// SnackBar配置类
class SnackBarConfig {
  final String message;
  final String? title;
  final SnackBarType type;
  final Duration duration;
  final SnackPosition position;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final IconData? icon;
  final bool showProgressIndicator;
  final VoidCallback? onTap;

  SnackBarConfig({
    required this.message,
    this.title,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.position = SnackPosition.TOP,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.icon,
    this.showProgressIndicator = false,
    this.onTap,
  });
}

/// SnackBar样式配置类
class SnackBarStyle {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  SnackBarStyle({
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}
