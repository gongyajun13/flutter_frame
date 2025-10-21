import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/screen_util_helper.dart';

/// 屏幕适配演示页面
class ScreenAdaptationDemoPage extends StatefulWidget {
  const ScreenAdaptationDemoPage({Key? key}) : super(key: key);

  @override
  State<ScreenAdaptationDemoPage> createState() => _ScreenAdaptationDemoPageState();
}

class _ScreenAdaptationDemoPageState extends State<ScreenAdaptationDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '屏幕适配演示',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 屏幕信息卡片
            _buildScreenInfoCard(),
            SizedBox(height: 20.h),
            
            // 字体大小演示
            _buildFontSizeDemo(),
            SizedBox(height: 20.h),
            
            // 间距演示
            _buildSpacingDemo(),
            SizedBox(height: 20.h),
            
            // 按钮演示
            _buildButtonDemo(),
            SizedBox(height: 20.h),
            
            // 圆角演示
            _buildRadiusDemo(),
            SizedBox(height: 20.h),
            
            // 图标演示
            _buildIconDemo(),
            SizedBox(height: 20.h),
            
            // 响应式布局演示
            _buildResponsiveDemo(),
            SizedBox(height: 20.h),
            
            // 打印屏幕信息按钮
            _buildPrintInfoButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// 构建屏幕信息卡片
  Widget _buildScreenInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '屏幕信息',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow('屏幕宽度', '${ScreenUtilHelper.screenWidth.toStringAsFixed(1)}px'),
            _buildInfoRow('屏幕高度', '${ScreenUtilHelper.screenHeight.toStringAsFixed(1)}px'),
            _buildInfoRow('状态栏高度', '${ScreenUtilHelper.statusBarHeight.toStringAsFixed(1)}px'),
            _buildInfoRow('底部安全区', '${ScreenUtilHelper.bottomBarHeight.toStringAsFixed(1)}px'),
            _buildInfoRow('像素密度', '${ScreenUtilHelper.pixelRatio.toStringAsFixed(2)}'),
            _buildInfoRow('宽度比例', '${ScreenUtilHelper.widthRatio.toStringAsFixed(3)}'),
            _buildInfoRow('高度比例', '${ScreenUtilHelper.heightRatio.toStringAsFixed(3)}'),
            _buildInfoRow('设备类型', _getDeviceType()),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.indigo.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取设备类型
  String _getDeviceType() {
    if (ScreenUtilHelper.isTablet) return '平板';
    if (ScreenUtilHelper.isLargeScreen) return '大屏手机';
    if (ScreenUtilHelper.isSmallScreen) return '小屏手机';
    return '标准手机';
  }

  /// 构建字体大小演示
  Widget _buildFontSizeDemo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '字体大小演示',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            Text('超小字体 (10sp)', style: TextStyle(fontSize: 10.sp)),
            SizedBox(height: 8.h),
            Text('小字体 (12sp)', style: TextStyle(fontSize: 12.sp)),
            SizedBox(height: 8.h),
            Text('基础字体 (14sp)', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            Text('大字体 (16sp)', style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 8.h),
            Text('超大字体 (18sp)', style: TextStyle(fontSize: 18.sp)),
            SizedBox(height: 8.h),
            Text('巨大字体 (24sp)', style: TextStyle(fontSize: 24.sp)),
          ],
        ),
      ),
    );
  }

  /// 构建间距演示
  Widget _buildSpacingDemo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '间距演示',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            _buildSpacingItem('超小间距 (4px)', 4.w),
            _buildSpacingItem('小间距 (8px)', 8.w),
            _buildSpacingItem('基础间距 (12px)', 12.w),
            _buildSpacingItem('大间距 (16px)', 16.w),
            _buildSpacingItem('超大间距 (20px)', 20.w),
            _buildSpacingItem('巨大间距 (32px)', 32.w),
          ],
        ),
      ),
    );
  }

  /// 构建间距项目
  Widget _buildSpacingItem(String label, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(width: spacing),
          Container(
            width: spacing,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.indigo.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建按钮演示
  Widget _buildButtonDemo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '按钮演示',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            _buildButton('小按钮', 32.h, Colors.blue),
            SizedBox(height: 12.h),
            _buildButton('中等按钮', 40.h, Colors.green),
            SizedBox(height: 12.h),
            _buildButton('大按钮', 48.h, Colors.orange),
            SizedBox(height: 12.h),
            _buildButton('超大按钮', 56.h, Colors.purple),
          ],
        ),
      ),
    );
  }

  /// 构建按钮
  Widget _buildButton(String text, double height, Color color) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
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

  /// 构建圆角演示
  Widget _buildRadiusDemo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '圆角演示',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _buildRadiusItem('4px', 4.r, Colors.red),
                _buildRadiusItem('8px', 8.r, Colors.green),
                _buildRadiusItem('12px', 12.r, Colors.blue),
                _buildRadiusItem('16px', 16.r, Colors.orange),
                _buildRadiusItem('24px', 24.r, Colors.purple),
                _buildRadiusItem('32px', 32.r, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建圆角项目
  Widget _buildRadiusItem(String label, double radius, Color color) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(radius),
            ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 构建图标演示
  Widget _buildIconDemo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '图标大小演示',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconItem(Icons.home, 16.sp, '16sp'),
                _buildIconItem(Icons.favorite, 20.sp, '20sp'),
                _buildIconItem(Icons.star, 24.sp, '24sp'),
                _buildIconItem(Icons.settings, 28.sp, '28sp'),
                _buildIconItem(Icons.notifications, 32.sp, '32sp'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图标项目
  Widget _buildIconItem(IconData icon, double size, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: size,
          color: Colors.indigo.shade600,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 构建响应式布局演示
  Widget _buildResponsiveDemo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '响应式布局演示',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            SizedBox(height: 12.h),
            // 根据屏幕大小显示不同的布局
            if (ScreenUtilHelper.isTablet) ...[
              // 平板布局
              Row(
                children: [
                  Expanded(
                    child: _buildResponsiveCard('平板布局', Colors.blue, '这是平板设备的布局'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildResponsiveCard('平板布局', Colors.green, '两列显示'),
                  ),
                ],
              ),
            ] else if (ScreenUtilHelper.isLargeScreen) ...[
              // 大屏手机布局
              _buildResponsiveCard('大屏手机布局', Colors.orange, '这是大屏手机的布局，内容更宽'),
            ] else if (ScreenUtilHelper.isSmallScreen) ...[
              // 小屏手机布局
              _buildResponsiveCard('小屏手机布局', Colors.red, '这是小屏手机的布局，内容紧凑'),
            ] else ...[
              // 标准手机布局
              _buildResponsiveCard('标准手机布局', Colors.purple, '这是标准手机的布局'),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建响应式卡片
  Widget _buildResponsiveCard(String title, Color color, String content) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建打印信息按钮
  Widget _buildPrintInfoButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton.icon(
        onPressed: () {
          ScreenUtilHelper.printScreenInfo();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '屏幕信息已打印到控制台',
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: Colors.indigo.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        },
        icon: Icon(
          Icons.print,
          size: 20.sp,
        ),
        label: Text(
          '打印屏幕信息到控制台',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}