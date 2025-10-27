import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'advanced_picker_controller.dart';

/// 高级图片选择页面
class AdvancedPickerView extends GetView<AdvancedPickerController> {
  const AdvancedPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高级图片选择'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            if (controller.selectedAssets.isNotEmpty) {
              return TextButton(
                onPressed: controller.clearAllAssets,
                child: Text(
                  '清除(${controller.selectedAssets.length})',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // 调试按钮（仅在调试模式下显示）
          if (kDebugMode)
            IconButton(
              onPressed: controller.debugPermissionStatus,
              icon: const Icon(Icons.bug_report),
              tooltip: '调试权限状态',
            ),
        ],
      ),
      body: Column(
        children: [
          // 预览区域
          _buildPreviewArea(),
          
          // 选择按钮区域
          _buildActionButtons(),
          
          // 选中的图片列表
          Expanded(
            child: _buildSelectedAssetsList(),
          ),
          
          // 底部操作栏
          _buildBottomActions(),
        ],
      ),
    );
  }

  /// 预览区域
  Widget _buildPreviewArea() {
    return Container(
      height: 300.h,
      width: double.infinity,
      color: Colors.grey[100],
      child: Obx(() {
        if (controller.currentAsset.value == null) {
          return Center(
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
                  '暂无预览图片',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return FutureBuilder<File?>(
          future: controller.currentAsset.value!.file,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              );
            }
            
            if (snapshot.hasError || snapshot.data == null) {
              return Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.error_outline,
                  color: Colors.grey[600],
                  size: 48.sp,
                ),
              );
            }
            
            return Image.file(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.grey[600],
                    size: 48.sp,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  /// 选择按钮区域
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.pickAssets,
              icon: const Icon(Icons.photo_library),
              label: const Text('选择图片'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 选中的图片列表
  Widget _buildSelectedAssetsList() {
    return Obx(() {
      if (controller.selectedAssets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 64.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                '请选择图片',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '支持多选，最多 ${controller.maxAssets} 张',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 1,
        ),
        itemCount: controller.selectedAssets.length,
        itemBuilder: (context, index) {
          final asset = controller.selectedAssets[index];
          final isSelected = controller.currentAsset.value == asset;
          
          return GestureDetector(
            onTap: () => controller.previewAsset(asset),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Stack(
                children: [
                  // 图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: FutureBuilder<File?>(
                      future: asset.file,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                            ),
                          );
                        }
                        
                        if (snapshot.hasError || snapshot.data == null) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey[600],
                              size: 24.sp,
                            ),
                          );
                        }
                        
                        return Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.grey[600],
                                size: 24.sp,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  // 序号
                  Positioned(
                    top: 4.h,
                    right: 4.w,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 删除按钮
                  Positioned(
                    top: 4.h,
                    left: 4.w,
                    child: GestureDetector(
                      onTap: () => controller.removeAsset(asset),
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  
                  // 预览按钮
                  Positioned(
                    bottom: 4.h,
                    left: 4.w,
                    child: GestureDetector(
                      onTap: () => controller.previewImage(asset),
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.preview,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  
                  // 裁剪按钮
                  Positioned(
                    bottom: 4.h,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => controller.goToCrop(asset),
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.crop,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// 底部操作栏
  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isUploading.value) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: controller.uploadProgress.value,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 8.h),
              Text(
                '处理中... ${(controller.uploadProgress.value * 100).toInt()}%',
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.selectedAssets.isNotEmpty
                    ? controller.processSelectedAssets
                    : null,
                icon: const Icon(Icons.auto_fix_high),
                label: Text('批量处理(${controller.selectedAssets.length})'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.selectedAssets.isNotEmpty
                    ? () => Get.snackbar('提示', '上传功能需要配置真实API地址')
                    : null,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('上传'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
