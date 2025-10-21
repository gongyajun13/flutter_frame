import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dialog类型枚举
enum DialogType {
  loading,
  confirm,
  alert,
  custom,
}

/// 全局Dialog工具类
/// 基于GetX实现，支持Loading、确认弹窗、自定义视图等
class GetXDialogUtil {
  // 私有构造函数，防止实例化
  GetXDialogUtil._();


  /// 显示Loading对话框
  static void showLoading({
    String? message,
    bool barrierDismissible = false,
    Color? barrierColor,
    Widget? customLoading,
  }) {
    Get.dialog(
      customLoading ?? _buildLoadingDialog(message),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.6),
    );
  }

  /// 隐藏Loading对话框
  static void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// 强制关闭所有Dialog
  /// 完全独立于SnackBar的处理，确保Dialog能正常关闭
  static void closeAllDialogs() {
    // 使用Navigator直接关闭Dialog，绕过GetX的路由管理
    if (Get.context != null) {
      Navigator.of(Get.context!).pop();
    }
  }

  /// 关闭所有SnackBar和Dialog
  /// 用于需要清理所有弹窗的场景
  static void closeAllOverlays() {
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
  static bool get isDialogActive => Get.isDialogOpen == true;

  /// 检查SnackBar状态
  static bool get isSnackBarActive => Get.isSnackbarOpen == true;

  /// 获取当前弹窗状态信息
  static Map<String, dynamic> getOverlayStatus() {
    return {
      'dialog': Get.isDialogOpen == true,
      'snackbar': Get.isSnackbarOpen == true,
      'bottomSheet': Get.isBottomSheetOpen == true,
    };
  }

  /// 显示确认对话框
  static void showConfirm({
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
  static void showAlert({
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
  static void showCustom({
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
    return Center(
      child: Container(
        // 优化：根据屏幕宽度动态调整边距
        margin: margin ?? EdgeInsets.symmetric(horizontal: Get.width * 0.08),
        // 优化：设置最小和最大宽度
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.85,
          maxHeight: Get.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
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
              // 头部
              if (header != null || title != null || showCloseButton) ...[
                _buildCustomDialogHeader(
                  title: title,
                  showCloseButton: showCloseButton,
                  onClose: onClose,
                  centerTitle: centerTitle,
                  header: header,
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
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
      child: SizedBox(
        height: 36.h,  // 固定高度，避免 Stack 布局问题
        child: Stack(
          children: [
            // 标题（居中布局）
            if (title != null) ...[
              Center(
                child: Padding(
                  padding: showCloseButton 
                    ? EdgeInsets.symmetric(horizontal: 48.w) // 为关闭按钮留出空间
                    : EdgeInsets.zero,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
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
  static void showCustomWithTitle({
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
  static void showCustomWithButtons({
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
  static void showCustomFullScreen({
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? Colors.white,
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
  static Widget buildConfirmButton({
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
  static Widget buildCancelButton({
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
  static Widget buildPrimaryButton({
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
  static Widget buildSecondaryButton({
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
  static void showBottomSheet({
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
  static void showInput({
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
  static void showSelect({
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

  /// 构建Loading对话框
  static Widget _buildLoadingDialog(String? message) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // 优化：根据屏幕宽度动态调整边距
        margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
        // 优化：根据内容动态调整内边距
        padding: EdgeInsets.all(24.w),
        // 优化：设置最小和最大宽度
        constraints: BoxConstraints(
          minWidth: 200.w,
          maxWidth: Get.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // 加载动画 - 优化尺寸
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
                  color: Colors.grey.shade700,
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // 优化：根据屏幕宽度动态调整边距
        // margin: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
        // 优化：设置最小和最大宽度
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标 - 优化尺寸
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 28.sp,
                  color: Colors.orange.shade600,
                ),
              ),
              SizedBox(height: 16.h),
              // 标题 - 优化字体大小
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              // 内容 - 优化字体大小和行高
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 24.h),
              // 按钮 - 优化高度
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // 优化：根据屏幕宽度动态调整边距
        // margin: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
        // 优化：设置最小和最大宽度
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标 - 优化尺寸
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 28.sp,
                  color: Colors.orange.shade600,
                ),
              ),
              SizedBox(height: 16.h),
              // 标题 - 优化字体大小
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              // 内容 - 优化字体大小和行高
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 24.h),
              // 按钮 - 优化高度
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // 优化：根据屏幕宽度动态调整边距
        // margin: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
        // 优化：设置最小和最大宽度
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标 - 优化尺寸
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 28.sp,
                  color: Colors.purple.shade600,
                ),
              ),
              SizedBox(height: 16.h),
              // 标题 - 优化字体大小
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20.h),
              // 输入框 - 优化样式
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade200, width: 1.w),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines ?? 1,
                  maxLength: maxLength,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade800,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
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
              // 按钮 - 优化间距
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // 优化：根据屏幕宽度动态调整边距
        // margin: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
        // 优化：设置最小和最大宽度，限制最大高度
        constraints: BoxConstraints(
          minWidth: 280.w,
          maxWidth: Get.width * 0.8,
          maxHeight: Get.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // 标题 - 优化布局
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(
                      Icons.list_rounded,
                      size: 18.sp,
                      color: Colors.teal.shade600,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 选项列表 - 优化样式
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
                              color: Colors.grey.shade50,
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
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12.sp,
                                  color: Colors.grey.shade400,
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