import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/simple_fullscreen_webview.dart';

/// 全屏 WebView 演示页面
class FullScreenWebViewDemoPage extends StatefulWidget {
  const FullScreenWebViewDemoPage({super.key});

  @override
  State<FullScreenWebViewDemoPage> createState() => _FullScreenWebViewDemoPageState();
}

class _FullScreenWebViewDemoPageState extends State<FullScreenWebViewDemoPage> {
  String? _errorMessage;
  
  final List<Map<String, dynamic>> _demoUrls = [
    {
      'title': '百度',
      'url': 'https://www.baidu.com',
      'icon': Icons.search,
      'color': Colors.blue,
    },
    {
      'title': 'Google',
      'url': 'https://www.google.com',
      'icon': Icons.search,
      'color': Colors.red,
    },
    {
      'title': 'GitHub',
      'url': 'https://github.com',
      'icon': Icons.code,
      'color': Colors.black,
    },
    {
      'title': 'Stack Overflow',
      'url': 'https://stackoverflow.com',
      'icon': Icons.help,
      'color': Colors.orange,
    },
    {
      'title': 'Flutter 官网',
      'url': 'https://flutter.dev',
      'icon': Icons.phone_android,
      'color': Colors.blue,
    },
    {
      'title': 'Dart 官网',
      'url': 'https://dart.dev',
      'icon': Icons.language,
      'color': Colors.cyan,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '全屏 WebView 演示',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade600,
                Colors.purple.shade700,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 介绍卡片
            _buildIntroCard(),
            
            SizedBox(height: 20.h),
            
            // 演示网站列表
            _buildDemoSites(),
            
            SizedBox(height: 20.h),
            
            // 自定义 URL 输入
            _buildCustomUrlSection(),
          ],
        ),
      ),
    );
  }

  /// 构建介绍卡片
  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.purple.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.purple.shade200,
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.web,
                color: Colors.purple.shade600,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '全屏 WebView 演示',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '体验全屏 WebView 浏览功能，支持自定义标题、工具栏和导航控制。点击下方网站卡片即可在全屏模式下浏览网页。',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.purple.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建演示网站列表
  Widget _buildDemoSites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '热门网站',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.2,
          ),
          itemCount: _demoUrls.length,
          itemBuilder: (context, index) {
            final site = _demoUrls[index];
            return _buildSiteCard(site);
          },
        ),
      ],
    );
  }

  /// 构建网站卡片
  Widget _buildSiteCard(Map<String, dynamic> site) {
    return GestureDetector(
      onTap: () => _openFullScreenWebView(site['url'], site['title']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: (site['color'] as Color).withOpacity(0.2),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: (site['color'] as Color).withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: (site['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                site['icon'] as IconData,
                size: 24.sp,
                color: site['color'] as Color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              site['title'] as String,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              '点击浏览',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建自定义 URL 输入部分
  Widget _buildCustomUrlSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                size: 20.sp,
                color: Colors.blue.shade600,
              ),
              SizedBox(width: 8.w),
              Text(
                '自定义网址',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            decoration: InputDecoration(
              hintText: '请输入要浏览的网址',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.blue.shade400,
                  width: 2.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Icon(
                Icons.language,
                size: 20.sp,
                color: Colors.grey.shade600,
              ),
            ),
            style: TextStyle(fontSize: 14.sp),
            onSubmitted: (url) => _openCustomUrl(url),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showUrlInputDialog(),
              icon: Icon(Icons.open_in_browser, size: 18.sp),
              label: Text('输入网址浏览', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
          // 显示错误消息
          if (_errorMessage != null) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16.sp,
                    color: Colors.red.shade600,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 打开全屏 WebView
  void _openFullScreenWebView(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleFullScreenWebView(
          url: url,
          title: title,
        ),
      ),
    );
  }

  /// 打开自定义 URL
  void _openCustomUrl(String url) {
    if (url.trim().isEmpty) {
      // 显示错误提示在界面上
      setState(() {
        _errorMessage = '请输入网址';
      });
      return;
    }

    // 清除之前的错误消息
    setState(() {
      _errorMessage = null;
    });

    String finalUrl = url.trim();
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    _openFullScreenWebView(finalUrl, '自定义网页');
  }

  /// 显示 URL 输入对话框
  void _showUrlInputDialog() {
    final TextEditingController urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '输入网址',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            hintText: '请输入完整的网址',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openCustomUrl(urlController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              '浏览',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
