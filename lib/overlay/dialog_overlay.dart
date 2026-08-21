import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'overlay_manager.dart';

/// Dialog类型枚举
enum DialogType {
  loading,
  confirm,
  alert,
  custom,
}

/// 居中 Dialog 浮层
class DialogOverlay extends OverlayManager {
  DialogOverlay._();
  static final DialogOverlay instance = DialogOverlay._();

  @override
  OverlayLayer get layer => OverlayLayer.dialog;

  @override
  bool get isActive => Get.isDialogOpen == true;

  @override
  void close() => hideLoading();

  bool _loadingShowing = false;

  static const String _loadingRouteName = 'app_overlay_loading';

  /// 显示Loading对话框
  void showLoading({
    String? message,
    bool barrierDismissible = false,
    Color? barrierColor,
    Widget? customLoading,
  }) {
    if (_loadingShowing) return;
    _loadingShowing = true;
    Get.dialog(
      customLoading ?? _buildLoadingDialog(message),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.6),
      routeSettings: const RouteSettings(name: _loadingRouteName),
    ).whenComplete(() => _loadingShowing = false);
  }

  /// 隐藏Loading对话框（仅关闭 loading 路由，避免误关导出预览等弹窗）
  void hideLoading() {
    if (!_loadingShowing) return;
    _loadingShowing = false;
    if (Get.isDialogOpen != true) return;
    if (Get.rawRoute?.settings.name == _loadingRouteName) {
      Get.back();
    }
  }
  /// 尝试关闭顶层 dialog
  static void _tryCloseDialog() {
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      debugPrint('DialogOverlay: 关闭 dialog 失败: $e');
    }
  }

  /// 随主题的对话框背景色与文字色（深色主题用浅字，浅色主题用深字）
  static (Color bg, Color title, Color body, Color surface) _dialogThemeColors() {
    if (Get.context == null) {
      return (Colors.white, Colors.grey.shade800, Colors.grey.shade600, Colors.grey.shade50);
    }
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? (
            theme.scaffoldBackgroundColor,
            theme.textTheme.titleLarge?.color ?? Colors.white,
            theme.textTheme.bodyMedium?.color ?? Colors.white70,
            theme.colorScheme.surfaceContainerHighest,
          )
        : (
            theme.scaffoldBackgroundColor,
            theme.textTheme.titleLarge?.color ?? Colors.grey.shade800,
            theme.textTheme.bodyMedium?.color ?? Colors.grey.shade600,
            theme.colorScheme.surfaceContainerLowest,
          );
  }

  /// 强制关闭所有Dialog
  /// 完全独立于SnackBar的处理，确保Dialog能正常关闭
  void closeAllDialogs() {
    // 使用Navigator直接关闭Dialog，绕过GetX的路由管理
    if (Get.context != null) {
      Navigator.of(Get.context!).pop();
    }
  }

  /// 关闭所有SnackBar和Dialog
  /// 用于需要清理所有弹窗的场景
  void closeAllOverlays() {
    // 关闭SnackBar
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    
    // 关闭Dialog
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }



  /// 终极关闭Dialog方法
  /// 使用多种方式确保Dialog能关闭
  static void _ultimateCloseDialog() {
    print('开始终极关闭Dialog');
    
    // 方法1：直接使用Navigator（最可靠）
    if (Get.context != null) {
      try {
        Navigator.of(Get.context!).pop();
        print('Navigator关闭成功');
        return;
      } catch (e) {
        print('Navigator关闭失败: $e');
      }
    }
    
    // 方法2：使用Get.back()
    try {
      Get.back();
      print('Get.back()关闭成功');
      return;
    } catch (e) {
      print('Get.back()关闭失败: $e');
    }
    
    // 方法3：延迟重试
    Future.delayed(Duration(milliseconds: 100), () {
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
        print('延迟Navigator关闭成功');
      }
    });
  }

  /// 智能关闭Dialog
  /// 根据当前状态选择最合适的关闭方式
  static void _smartCloseDialog() {
    print('Get.isDialogOpen: ${Get.isDialogOpen}');
    print('Get.isSnackbarOpen: ${Get.isSnackbarOpen}');
    
    // 使用终极关闭方法
    _ultimateCloseDialog();
  }

  /// 检查Dialog状态
  bool get isDialogActive => Get.isDialogOpen == true;

  /// 检查SnackBar状态
  bool get isSnackBarActive => Get.isSnackbarOpen == true;

  /// 获取当前弹窗状态信息
  Map<String, dynamic> getOverlayStatus() {
    return {
      'dialog': Get.isDialogOpen == true,
      'snackbar': Get.isSnackbarOpen == true,
      'bottomSheet': Get.isBottomSheetOpen == true,
    };
  }

  /// 显示确认对话框
  void showConfirm({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? cancelColor,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      _buildConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  /// 显示警告对话框
  void showAlert({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    Color? buttonColor,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      _buildAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        buttonColor: buttonColor,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  /// 显示自定义对话框
  void showCustom({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? title,
    bool showCloseButton = true,
    VoidCallback? onClose,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    bool centerTitle = true,
    Widget? header,
    Widget? footer,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: _buildCustomDialog(
          child: child,
          title: title,
          showCloseButton: showCloseButton,
          onClose: onClose,
          margin: margin,
          padding: padding,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
          centerTitle: centerTitle,
          header: header,
          footer: footer,
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.6),
      useSafeArea: useSafeArea,
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
      transitionCurve: transitionCurve ?? Curves.easeInOut,
    );
  }

  /// 显示自定义 Widget 对话框并等待结果
  Future<T?> customAsync<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
  }) {
    return Get.dialog<T>(
      child,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.6),
      useSafeArea: useSafeArea,
    );
  }

  /// 构建自定义对话框
  static Widget _buildCustomDialog({
    required Widget child,
    String? title,
    bool showCloseButton = true,
    VoidCallback? onClose,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    bool centerTitle = true,
    Widget? header,
    Widget? footer,
  }) {
    final (bg, titleColor, _, _) = _dialogThemeColors();
    return Center(
      child: Container(
        margin: margin ?? EdgeInsets.symmetric(horizontal: Get.width * 0.08),
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.85,
          maxHeight: Get.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? bg,
          borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null || title != null || showCloseButton) ...[
                _buildCustomDialogHeader(
                  title: title,
                  showCloseButton: showCloseButton,
                  onClose: onClose,
                  centerTitle: centerTitle,
                  header: header,
                  titleColor: titleColor,
                ),
              ],
              
              // 内容
              Flexible(
                child: SingleChildScrollView(
                  padding: padding ?? EdgeInsets.all(20.w),
                  child: child,
                ),
              ),
              
              // 底部
              if (footer != null) ...[
                _buildCustomDialogFooter(footer: footer),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建自定义对话框头部
  static Widget _buildCustomDialogHeader({
    String? title,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool centerTitle = true,
    Widget? header,
    Color? titleColor,
  }) {
    final (_, titleC, _, _) = _dialogThemeColors();
    final color = titleColor ?? titleC;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
      child: SizedBox(
        height: 36.h,
        child: Stack(
          children: [
            if (title != null) ...[
              Center(
                child: Padding(
                  padding: showCloseButton 
                    ? EdgeInsets.symmetric(horizontal: 48.w)
                    : EdgeInsets.zero,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ] else if (header != null) ...[
              Center(
                child: Padding(
                  padding: showCloseButton 
                    ? EdgeInsets.only(right: 48.w) 
                    : EdgeInsets.zero,
                  child: header,
                ),
              ),
            ],
            
            // 关闭按钮（绝对定位在右侧）
            if (showCloseButton) ...[
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    onClose?.call();
                    _smartCloseDialog();
                  },
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建自定义对话框底部
  static Widget _buildCustomDialogFooter({required Widget footer}) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: footer,
    );
  }

  /// 显示带标题的自定义对话框
  void showCustomWithTitle({
    required String title,
    required Widget child,
    bool showCloseButton = true,
    VoidCallback? onClose,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    bool centerTitle = true,
    Widget? header,
    Widget? footer,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    showCustom(
      child: child,
      title: title,
      showCloseButton: showCloseButton,
      onClose: onClose,
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      centerTitle: centerTitle,
      header: header,
      footer: footer,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      transitionDuration: transitionDuration,
      transitionCurve: transitionCurve,
    );
  }

  /// 显示带按钮的自定义对话框
  void showCustomWithButtons({
    required String title,
    required Widget child,
    List<Widget>? buttons,
    bool showCloseButton = true,
    VoidCallback? onClose,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    bool centerTitle = true,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    Widget footer;
    if (buttons != null && buttons.isNotEmpty) {
      footer = Row(
        children: buttons,  // ✅ 按钮已经是 Expanded，不需要再包装
      );
    } else {
      footer = SizedBox.shrink();
    }

    showCustom(
      child: child,
      title: title,
      showCloseButton: showCloseButton,
      onClose: onClose,
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      centerTitle: centerTitle,
      footer: footer,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      transitionDuration: transitionDuration,
      transitionCurve: transitionCurve,
    );
  }

  /// 显示全屏自定义对话框
  void showCustomFullScreen({
    required Widget child,
    String? title,
    bool showCloseButton = true,
    VoidCallback? onClose,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: _buildFullScreenDialog(
          child: child,
          title: title,
          showCloseButton: showCloseButton,
          onClose: onClose,
          backgroundColor: backgroundColor,
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.6),
      useSafeArea: useSafeArea,
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
      transitionCurve: transitionCurve ?? Curves.easeInOut,
    );
  }

  /// 构建全屏自定义对话框
  static Widget _buildFullScreenDialog({
    required Widget child,
    String? title,
    bool showCloseButton = true,
    VoidCallback? onClose,
    Color? backgroundColor,
  }) {
    final (bg, _, _, _) = _dialogThemeColors();
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? bg,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // 头部
            if (title != null || showCloseButton) ...[
              _buildCustomDialogHeader(
                title: title,
                showCloseButton: showCloseButton,
                onClose: onClose,
                centerTitle: true,
                header: null,
              ),
            ],
            
            // 内容（全屏，不使用 SingleChildScrollView）
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建确认按钮
  Widget buildConfirmButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    EdgeInsets? padding,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        height: 44.h,
        child: ElevatedButton(
          onPressed: () {
            onPressed();
            _smartCloseDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.blue,
            foregroundColor: textColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            elevation: 2,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 14.sp,
              fontWeight: fontWeight ?? FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建取消按钮
  Widget buildCancelButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    EdgeInsets? padding,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 4.w),
        height: 44.h,
        child: ElevatedButton(
          onPressed: () {
            onPressed();
            _smartCloseDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.grey.shade200,
            foregroundColor: textColor ?? Colors.grey.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            elevation: 1,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 14.sp,
              fontWeight: fontWeight ?? FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建主要按钮
  Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    EdgeInsets? padding,
    double? fontSize,
    FontWeight? fontWeight,
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        height: 44.h,
        child: ElevatedButton(
          onPressed: () {
            onPressed();
            _smartCloseDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.blue,
            foregroundColor: textColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp),
                SizedBox(width: 6.w),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 14.sp,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建次要按钮
  Widget buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
    EdgeInsets? padding,
    double? fontSize,
    FontWeight? fontWeight,
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        height: 44.h,
        child: OutlinedButton(
          onPressed: () {
            onPressed();
            _smartCloseDialog();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? Colors.blue,
            side: BorderSide(color: backgroundColor ?? Colors.blue, width: 1.5.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp),
                SizedBox(width: 6.w),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 14.sp,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示底部弹窗
  void showBottomSheet({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    Get.bottomSheet(
      Container(
        // 优化：添加最大高度限制
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.8,
        ),
        child: child,
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 6, // 优化：减小阴影
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)), // 优化：减小圆角
      ),
    );
  }

  /// 显示输入对话框
  void showInput({
    required String title,
    String? hintText,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    Function(String)? onConfirm,
    VoidCallback? onCancel,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    bool barrierDismissible = true,
  }) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    
    Get.dialog(
      _buildInputDialog(
        title: title,
        controller: controller,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  /// 显示选择对话框
  void showSelect({
    required String title,
    required List<String> options,
    Function(int index, String option)? onSelected,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      _buildSelectDialog(
        title: title,
        options: options,
        onSelected: onSelected,
        onCancel: onCancel,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  /// 异步确认对话框，返回 true=确认 / false=取消
  Future<bool> confirmAsync({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    Color? cancelColor,
    bool barrierDismissible = true,
  }) {
    final completer = Completer<bool>();
    showConfirm(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
      cancelColor: cancelColor,
      barrierDismissible: barrierDismissible,
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    );
    return completer.future;
  }

  /// 异步输入对话框，取消返回 null
  Future<String?> inputAsync({
    required String title,
    String? hintText,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    bool barrierDismissible = true,
  }) {
    final completer = Completer<String?>();
    showInput(
      title: title,
      hintText: hintText,
      initialValue: initialValue,
      confirmText: confirmText,
      cancelText: cancelText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      barrierDismissible: barrierDismissible,
      onConfirm: (value) => completer.complete(value),
      onCancel: () => completer.complete(null),
    );
    return completer.future;
  }

  /// 异步选择对话框，取消返回 null
  Future<int?> selectAsync({
    required String title,
    required List<String> options,
    bool barrierDismissible = true,
  }) {
    final completer = Completer<int?>();
    showSelect(
      title: title,
      options: options,
      barrierDismissible: barrierDismissible,
      onSelected: (index, _) => completer.complete(index),
      onCancel: () => completer.complete(null),
    );
    return completer.future;
  }

  /// 构建Loading对话框
  static Widget _buildLoadingDialog(String? message) {
    final (bg, _, body, _) = _dialogThemeColors();
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
        padding: EdgeInsets.all(24.w),
        constraints: BoxConstraints(
          minWidth: 200.w,
          maxWidth: Get.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5.w,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 16.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: body,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建确认对话框
  static Widget _buildConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? cancelColor,
  }) {
    final (bg, titleColor, bodyColor, _) = _dialogThemeColors();
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: bodyColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 24.h),
              // 按钮
              Row(
                children: [
                  Expanded(
                    child: _buildModernButton(
                      text: cancelText ?? '取消',
                      color: cancelColor ?? Colors.grey.shade300,
                      textColor: Colors.grey.shade700,
                      onPressed: () {
                        onCancel?.call();
                        _smartCloseDialog();
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildModernButton(
                      text: confirmText ?? '确认',
                      color: confirmColor ?? Colors.blue.shade600,
                      textColor: Colors.white,
                      onPressed: () {
                        onConfirm?.call();
                        _smartCloseDialog();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建警告对话框
  static Widget _buildAlertDialog({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    Color? buttonColor,
  }) {
    final (bg, titleColor, bodyColor, _) = _dialogThemeColors();
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: bodyColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 24.h),
              _buildModernButton(
                text: buttonText ?? '确定',
                color: buttonColor ?? Colors.orange.shade600,
                textColor: Colors.white,
                onPressed: () {
                  onPressed?.call();
                  _smartCloseDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建输入对话框
  static Widget _buildInputDialog({
    required String title,
    required TextEditingController controller,
    String? hintText,
    String? confirmText,
    String? cancelText,
    Function(String)? onConfirm,
    VoidCallback? onCancel,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
  }) {
    final (bg, titleColor, bodyColor, surface) = _dialogThemeColors();
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: surface, width: 1.w),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines ?? 1,
                  maxLength: maxLength,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: bodyColor,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: bodyColor.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    counterText: '',
                  ),
                  autofocus: true,
                ),
              ),
              SizedBox(height: 20.h),
              // 按钮
              Row(
                children: [
                  Expanded(
                    child: _buildModernButton(
                      text: cancelText ?? '取消',
                      color: Colors.grey.shade300,
                      textColor: Colors.grey.shade700,
                      onPressed: () {
                        onCancel?.call();
                        _smartCloseDialog();
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildModernButton(
                      text: confirmText ?? '确认',
                      color: Colors.purple.shade600,
                      textColor: Colors.white,
                      onPressed: () {
                        onConfirm?.call(controller.text);
                        _smartCloseDialog();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建选择对话框
  static Widget _buildSelectDialog({
    required String title,
    required List<String> options,
    Function(int index, String option)? onSelected,
    VoidCallback? onCancel,
  }) {
    final (bg, titleColor, bodyColor, surface) = _dialogThemeColors();
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
          maxHeight: Get.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isLast = index == options.length - 1;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            onSelected?.call(index, option);
                            _smartCloseDialog();
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade400,
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: bodyColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12.sp,
                                  color: bodyColor.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast) SizedBox(height: 6.h),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            // 取消按钮 - 优化间距
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: _buildModernButton(
                text: '取消',
                color: Colors.grey.shade300,
                textColor: Colors.grey.shade700,
                onPressed: () {
                  onCancel?.call();
                  _smartCloseDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建现代化按钮
  static Widget _buildModernButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44.h, // 优化：稍微减小按钮高度
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r), // 优化：减小圆角
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2), // 优化：减小阴影强度
            blurRadius: 6.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.r),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp, // 优化：减小字体大小
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}