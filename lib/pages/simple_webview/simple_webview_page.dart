import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'simple_webview_controller.dart';
import '../../utils/webview_bridge_manager.dart';

/// Simple WebView 页面（MVVM 架构）
class SimpleWebViewPage extends StatefulWidget {
  final String title;
  final String url;
  final bool enableBridge;
  final void Function(WebViewBridgeManager)? onBridgeReady;

  const SimpleWebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.enableBridge = true,
    this.onBridgeReady,
  });

  @override
  State<SimpleWebViewPage> createState() => _SimpleWebViewPageState();
}

class _SimpleWebViewPageState extends State<SimpleWebViewPage> {
  late SimpleWebViewController controller;

  @override
  void initState() {
    super.initState();
    // 每次创建新页面时，都创建新的 Controller 实例
    // 先删除旧的 Controller（如果存在）
    if (Get.isRegistered<SimpleWebViewController>()) {
      Get.delete<SimpleWebViewController>();
    }
    
    // 创建并注册新的 Controller
    controller = Get.put<SimpleWebViewController>(
      SimpleWebViewController(
        initialUrl: widget.url,
        enableBridge: widget.enableBridge,
        onBridgeReady: widget.onBridgeReady,
      ),
      permanent: false, // 页面关闭时自动删除
    );
  }

  @override
  void dispose() {
    // 页面销毁时删除 Controller
    if (Get.isRegistered<SimpleWebViewController>()) {
      Get.delete<SimpleWebViewController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 GetView 来获取 Controller
    return GetBuilder<SimpleWebViewController>(
      builder: (controller) => _buildScaffold(context, controller),
    );
  }

  Widget _buildScaffold(BuildContext context, SimpleWebViewController controller) {
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
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
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
            IconButton(
              onPressed: () {
                controller.reload();
              },
              icon: Icon(Icons.refresh, size: 20.sp),
              tooltip: '刷新',
            ),
          ],
        ),
        body: Obx(() {
          // 有错误时显示错误界面
          if (controller.errorMessage.value != null) {
            return _buildErrorWidget(controller);
          }

          // 正常显示 WebView
          return Stack(
            children: [
              WebViewWidget(controller: controller.webViewController),

              // 顶部加载进度条
              Obx(() {
                // 只有在加载中且进度大于0时才显示进度条
                if (controller.isLoading.value && controller.loadingProgress.value > 0) {
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: controller.loadingProgress.value,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                      minHeight: 3.h,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          );
        }),
      ),
    );
  }

  /// 构建错误界面
  Widget _buildErrorWidget(SimpleWebViewController controller) {
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
            Obx(() => Column(
                  children: [
                    Text(
                      controller.errorMessage.value ?? '未知错误',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // 显示重试信息（如果有）
                    if (controller.retryStrategy != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '正在自动重试...',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                )),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    controller.reload();
                  },
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
}
