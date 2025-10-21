import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/cached_image_widgets.dart';
import '../utils/getx_snackbar_util.dart';

/// 缓存图片Widget演示页面
class CachedImageDemoPage extends StatefulWidget {
  const CachedImageDemoPage({super.key});

  @override
  State<CachedImageDemoPage> createState() => _CachedImageDemoPageState();
}

class _CachedImageDemoPageState extends State<CachedImageDemoPage> {
  // 测试图片URL列表
  final List<String> testImageUrls = [
    'https://picsum.photos/600/400?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/500/400?random=3',
    'https://picsum.photos/600/500?random=4',
    'https://picsum.photos/700/600?random=5',
    'https://picsum.photos/800/700?random=6',
  ];

  // 错误图片URL（用于测试错误处理）
  final String errorImageUrl = 'https://invalid-url.com/image.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '缓存图片Widget演示',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade700,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像类型演示
            _buildSectionCard(
              '头像类型图片',
              Colors.purple,
              [
                _buildAvatarSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 圆角类型演示
            _buildSectionCard(
              '圆角类型图片',
              Colors.green,
              [
                _buildRoundedSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 毛玻璃效果演示
            _buildSectionCard(
              '毛玻璃效果图片',
              Colors.orange,
              [
                _buildGlassSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 占位图演示
            _buildSectionCard(
              '占位图类型图片',
              Colors.teal,
              [
                _buildPlaceholderSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 自定义占位图和错误处理演示
            _buildSectionCard(
              '自定义占位图和错误处理',
              Colors.red,
              [
                _buildCustomSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 测试按钮
            _buildSectionCard(
              '测试功能',
              Colors.blue,
              [
                _buildTestButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头像类型演示
  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '不同尺寸的头像图片：',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            AvatarImageWidget(
              imageUrl: testImageUrls[0],
              size: 50,
              onTap: () => _showImageInfo('小头像', testImageUrls[0]),
            ),
            AvatarImageWidget(
              imageUrl: testImageUrls[1],
              size: 60,
              onTap: () => _showImageInfo('中头像', testImageUrls[1]),
            ),
            AvatarImageWidget(
              imageUrl: testImageUrls[2],
              size: 70,
              onTap: () => _showImageInfo('大头像', testImageUrls[2]),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          '自定义占位图的头像：',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            AvatarImageWidget(
              imageUrl: testImageUrls[3],
              size: 60,
              placeholder: CustomPlaceholderWidget(
                icon: Icons.person,
                title: '加载中...',
                backgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue.shade400,
              ),
              onTap: () => _showImageInfo('自定义占位图头像', testImageUrls[3]),
            ),
            AvatarImageWidget(
              imageUrl: errorImageUrl,
              size: 60,
              errorWidget: CustomErrorWidget(
                icon: Icons.person_off,
                message: '头像加载失败',
                backgroundColor: Colors.red.shade50,
                iconColor: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建圆角类型演示
  Widget _buildRoundedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '不同尺寸的圆角图片：',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            RoundedImageWidget(
              imageUrl: testImageUrls[0],
              width: 90.w,
              height: 90.w,
              onTap: () => _showImageInfo('小圆角图片', testImageUrls[0]),
            ),
            RoundedImageWidget(
              imageUrl: testImageUrls[1],
              width: 120.w,
              height: 80.w,
              onTap: () => _showImageInfo('矩形圆角图片', testImageUrls[1]),
            ),
            RoundedImageWidget(
              imageUrl: testImageUrls[2],
              width: 100.w,
              height: 100.w,
              borderRadius: 20,
              onTap: () => _showImageInfo('大圆角图片', testImageUrls[2]),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          '长宽比不同的圆角图片：',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12.h),
        RoundedImageWidget(
          imageUrl: testImageUrls[3],
          width: double.infinity,
          height: 140.h,
          fit: BoxFit.cover,
          onTap: () => _showImageInfo('全宽圆角图片', testImageUrls[3]),
        ),
      ],
    );
  }

  /// 构建毛玻璃效果演示
  Widget _buildGlassSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '毛玻璃效果图片：',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            GlassImageWidget(
              imageUrl: testImageUrls[0],
              width: 110.w,
              height: 110.w,
              onTap: () => _showImageInfo('毛玻璃效果图片1', testImageUrls[0]),
            ),
            GlassImageWidget(
              imageUrl: testImageUrls[1],
              width: 110.w,
              height: 110.w,
              onTap: () => _showImageInfo('毛玻璃效果图片2', testImageUrls[1]),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GlassImageWidget(
          imageUrl: testImageUrls[2],
          width: double.infinity,
          height: 160.h,
          fit: BoxFit.cover,
          onTap: () => _showImageInfo('全宽毛玻璃效果图片', testImageUrls[2]),
        ),
      ],
    );
  }

  /// 构建占位图演示
  Widget _buildPlaceholderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '占位图类型图片：',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            PlaceholderImageWidget(
              imageUrl: testImageUrls[0],
              width: 90.w,
              height: 90.w,
              onTap: () => _showImageInfo('占位图图片1', testImageUrls[0]),
            ),
            PlaceholderImageWidget(
              imageUrl: testImageUrls[1],
              width: 90.w,
              height: 90.w,
              onTap: () => _showImageInfo('占位图图片2', testImageUrls[1]),
            ),
            PlaceholderImageWidget(
              imageUrl: testImageUrls[2],
              width: 90.w,
              height: 90.w,
              onTap: () => _showImageInfo('占位图图片3', testImageUrls[2]),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        PlaceholderImageWidget(
          imageUrl: testImageUrls[3],
          width: double.infinity,
          height: 120.h,
          fit: BoxFit.cover,
          onTap: () => _showImageInfo('全宽占位图图片', testImageUrls[3]),
        ),
      ],
    );
  }

  /// 构建自定义演示
  Widget _buildCustomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义占位图：',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            CachedImageWidget(
              imageUrl: testImageUrls[0],
              width: 90.w,
              height: 90.w,
              imageType: ImageType.custom,
              placeholder: CustomPlaceholderWidget(
                icon: Icons.image,
                title: '加载中',
                backgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue.shade400,
              ),
              onTap: () => _showImageInfo('自定义占位图', testImageUrls[0]),
            ),
            CachedImageWidget(
              imageUrl: testImageUrls[1],
              width: 90.w,
              height: 90.w,
              imageType: ImageType.custom,
              placeholder: CustomPlaceholderWidget(
                icon: Icons.photo_camera,
                title: '拍照中',
                backgroundColor: Colors.green.shade50,
                iconColor: Colors.green.shade400,
              ),
              onTap: () => _showImageInfo('拍照占位图', testImageUrls[1]),
            ),
            CachedImageWidget(
              imageUrl: errorImageUrl,
              width: 90.w,
              height: 90.w,
              imageType: ImageType.custom,
              errorWidget: CustomErrorWidget(
                icon: Icons.error_outline,
                message: '加载失败',
                backgroundColor: Colors.red.shade50,
                iconColor: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建测试按钮
  Widget _buildTestButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTestButton(
                '测试图片加载',
                Colors.blue.shade600,
                _testImageLoading,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildTestButton(
                '测试错误处理',
                Colors.red.shade600,
                _testImageError,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildTestButton(
                '清除图片缓存',
                Colors.orange.shade600,
                _clearImageCache,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildTestButton(
                '刷新图片',
                Colors.green.shade600,
                _refreshImages,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建测试按钮
  Widget _buildTestButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 44.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 构建区域卡片
  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            ...children,
          ],
        ),
      ),
    );
  }

  /// 显示图片信息
  void _showImageInfo(String title, String url) {
    GetXSnackBarUtil.info(
      message: '$title\nURL: $url',
      title: '图片信息',
    );
  }

  /// 测试图片加载
  void _testImageLoading() {
    GetXSnackBarUtil.success(
      message: '图片加载测试完成！',
      title: '测试成功',
    );
  }

  /// 测试错误处理
  void _testImageError() {
    GetXSnackBarUtil.warning(
      message: '错误处理测试完成！',
      title: '测试完成',
    );
  }

  /// 清除图片缓存
  void _clearImageCache() {
    // 这里可以添加清除缓存的逻辑
    GetXSnackBarUtil.info(
      message: '图片缓存已清除！',
      title: '缓存清除',
    );
  }

  /// 刷新图片
  void _refreshImages() {
    setState(() {
      // 触发重新构建，重新加载图片
    });
    GetXSnackBarUtil.success(
      message: '图片已刷新！',
      title: '刷新完成',
    );
  }
}
