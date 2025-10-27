import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'image_util_demo_controller.dart';

/// 图片处理演示页面
class ImageUtilDemoView extends GetView<ImageUtilDemoController> {
  const ImageUtilDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片处理工具'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearImages,
            tooltip: '清除所有',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 图片预览区域
            _buildImagePreview(),
            
            SizedBox(height: 20.h),
            
            // 图片信息
            _buildImageInfo(),
            
            SizedBox(height: 20.h),
            
            // 选择图片
            _buildPickSection(),
            
            SizedBox(height: 20.h),
            
            // 裁剪图片
            _buildCropSection(),
            
            SizedBox(height: 20.h),
            
            // 压缩图片
            _buildCompressSection(),
            
            SizedBox(height: 20.h),
            
            // 上传图片
            _buildUploadSection(),
            
            SizedBox(height: 20.h),
            
            // 完整流程
            _buildCompleteFlowSection(),
          ],
        ),
      ),
    );
  }

  /// 图片预览区域
  Widget _buildImagePreview() {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 64.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 8.h),
                Text(
                  '暂无图片',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              // PageView 图片预览
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.switchToImage(index);
                },
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    controller.selectedImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '图片加载失败',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              
              // 图片计数指示器
              if (controller.selectedImages.length > 1)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${controller.currentImageIndex.value + 1}/${controller.selectedImages.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              
              // 左右切换按钮
              if (controller.selectedImages.length > 1) ...[
                // 左箭头
                if (controller.currentImageIndex.value > 0)
                  Positioned(
                    left: 12.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: controller.previousImage,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // 右箭头
                if (controller.currentImageIndex.value < controller.selectedImages.length - 1)
                  Positioned(
                    right: 12.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: controller.nextImage,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// 图片信息
  Widget _buildImageInfo() {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '图片信息',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.selectedImages.length > 1) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '第 ${controller.currentImageIndex.value + 1} 张',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              if (controller.originalSize.value.isNotEmpty)
                _buildInfoRow('原始大小', controller.originalSize.value),
              if (controller.compressedSize.value.isNotEmpty)
                _buildInfoRow('压缩后', controller.compressedSize.value),
              if (controller.selectedImages.length > 1)
                _buildInfoRow('已选择', '${controller.selectedImages.length} 张图片'),
              if (controller.selectedImages.length > 1)
                _buildInfoRow('当前图片', '${controller.currentImageIndex.value + 1}/${controller.selectedImages.length}'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 选择图片区域
  Widget _buildPickSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. 选择图片',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.showSourceDialog,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('选择单张'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.pickMultipleImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('选择多张'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.showAdvancedSourceDialog,
                    icon: const Icon(Icons.wechat),
                    label: const Text('高级选择'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.pickFromWechatAssets,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('微信相册'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.takePhotoWithWechatCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('微信拍照'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.recordVideoWithWechatCamera,
                    icon: const Icon(Icons.videocam),
                    label: const Text('微信录像'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('相机拍照'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.pickFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text('从相册'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 裁剪图片区域
  Widget _buildCropSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. 裁剪图片',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                ElevatedButton(
                  onPressed: controller.cropFree,
                  child: const Text('自由裁剪'),
                ),
                ElevatedButton(
                  onPressed: controller.cropToSquare,
                  child: const Text('正方形 1:1'),
                ),
                ElevatedButton(
                  onPressed: controller.cropTo4x3,
                  child: const Text('4:3'),
                ),
                ElevatedButton(
                  onPressed: controller.cropTo16x9,
                  child: const Text('16:9'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 压缩图片区域
  Widget _buildCompressSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3. 压缩图片',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.compressImage(quality: 85),
                    child: const Text('标准压缩 (85%)'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.compressImage(quality: 60),
                    child: const Text('高度压缩 (60%)'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.compressToSize(maxSizeKB: 500),
                    child: const Text('压缩到 500KB'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.compressToSize(maxSizeKB: 200),
                    child: const Text('压缩到 200KB'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 上传图片区域
  Widget _buildUploadSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '4. 上传图片',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              if (controller.isUploading.value) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.uploadProgress.value,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '上传中... ${(controller.uploadProgress.value * 100).toInt()}%',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                );
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.uploadImage,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('上传图片（模拟）'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 完整流程区域
  Widget _buildCompleteFlowSection() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue[700]),
                SizedBox(width: 8.w),
                Text(
                  '完整流程',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '选择 → 裁剪 → 压缩 → 上传',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.completeFlow,
                icon: const Icon(Icons.play_arrow),
                label: const Text('一键完整流程'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

