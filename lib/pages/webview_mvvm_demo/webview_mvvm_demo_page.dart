import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// WebView MVVM 演示页面
class WebViewMvvmDemoPage extends StatelessWidget {
  const WebViewMvvmDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WebView MVVM 演示',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            SizedBox(height: 16.h),
            _buildSectionCard(
              title: '基础示例',
              children: [
                _buildDemoButton(
                  '加载 Flutter 官网',
                  () => _openWebView('https://flutter.dev'),
                ),
                _buildDemoButton(
                  '加载 GitHub',
                  () => _openWebView('https://github.com'),
                ),
                _buildDemoButton(
                  '加载百度',
                  () => _openWebView('https://www.baidu.com'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildSectionCard(
              title: '桥接功能',
              children: [
                _buildDemoButton(
                  '启用桥接的 WebView',
                  () => _openWebView(
                    'https://flutter.dev',
                    enableBridge: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildSectionCard(
              title: '特性说明',
              children: [
                _buildFeatureItem('✅ MVVM 架构，逻辑与 UI 分离'),
                _buildFeatureItem('✅ GetX 状态管理，响应式更新'),
                _buildFeatureItem('✅ 完整的错误处理和重试'),
                _buildFeatureItem('✅ 支持前进/后退导航'),
                _buildFeatureItem('✅ 顶部进度条显示'),
                _buildFeatureItem('✅ 特殊协议处理'),
                _buildFeatureItem('✅ 缓存管理功能'),
                _buildFeatureItem('✅ H5 ↔ Flutter 桥接（可选）'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.web, color: Colors.white, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'MVVM 架构 WebView',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '使用 GetX Controller 管理 WebView 逻辑\n将业务逻辑与 UI 完全分离',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDemoButton(String text, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 打开 WebView
  void _openWebView(String url, {bool enableBridge = false}) {
    Get.toNamed(
      '/webview-mvvm',
      parameters: {
        'url': url,
        'enableBridge': enableBridge.toString(),
      },
    );
  }
}
