import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_mvvm_controller.dart';

/// WebView MVVM Page (View 层)
class WebViewMvvmPage extends GetView<WebViewMvvmController> {
  const WebViewMvvmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        
        final shouldPop = await controller.handleBackPressed();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  /// 构建 AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(() => Text(
            controller.currentUrl.value.isEmpty 
                ? 'WebView MVVM' 
                : 'WebView MVVM',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          )),
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          final shouldPop = await controller.handleBackPressed();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        // 后退按钮
        Obx(() => IconButton(
              onPressed: controller.canGoBack.value
                  ? () => controller.goBack()
                  : null,
              icon: Icon(Icons.arrow_back_ios, size: 18.sp),
              tooltip: '后退',
            )),
        
        // 前进按钮
        Obx(() => IconButton(
              onPressed: controller.canGoForward.value
                  ? () => controller.goForward()
                  : null,
              icon: Icon(Icons.arrow_forward_ios, size: 18.sp),
              tooltip: '前进',
            )),
        
        // 刷新按钮
        IconButton(
          onPressed: () => controller.reload(),
          icon: Icon(Icons.refresh, size: 20.sp),
          tooltip: '刷新',
        ),
        
        // 更多选项
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear_cache',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('清除缓存', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_cookies',
              child: Row(
                children: [
                  Icon(Icons.cookie, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('清除 Cookies', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'copy_url',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('复制链接', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
          ],
          icon: Icon(Icons.more_vert, size: 20.sp),
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    return Obx(() {
      // 有错误时显示错误界面
      if (controller.errorMessage.value != null) {
        return _buildErrorWidget();
      }
      
      // 正常显示 WebView
      return Stack(
        children: [
          WebViewWidget(controller: controller.webViewController),
          
          // 顶部加载进度条
          if (controller.isLoading.value && controller.loadingProgress.value < 1.0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: controller.loadingProgress.value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                minHeight: 3.h,
              ),
            ),
        ],
      );
    });
  }

  /// 构建错误界面
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              '网页加载失败',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(() => Text(
                  controller.errorMessage.value ?? '未知错误',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                )),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.reload(),
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text('重新加载', style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
                SizedBox(width: 16.w),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, size: 18.sp),
                  label: Text('关闭', style: TextStyle(fontSize: 14.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_cache':
        _clearCache();
        break;
      case 'clear_cookies':
        _clearCookies();
        break;
      case 'copy_url':
        _copyUrl();
        break;
    }
  }

  /// 清除缓存
  Future<void> _clearCache() async {
    try {
      await controller.clearCache();
      Get.snackbar(
        '成功',
        '缓存已清除',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '清除缓存失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  /// 清除 Cookies
  Future<void> _clearCookies() async {
    try {
      await controller.clearCookies();
      Get.snackbar(
        '成功',
        'Cookies 已清除',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '清除 Cookies 失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  /// 复制 URL
  void _copyUrl() {
    // TODO: 实现复制到剪贴板功能
    Get.snackbar(
      '提示',
      '当前链接: ${controller.currentUrl.value}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
