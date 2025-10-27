import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_image/extended_image.dart';
import 'advanced_crop_controller.dart';

/// 高级图片裁剪页面
class AdvancedCropView extends GetView<AdvancedCropController> {
  const AdvancedCropView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('图片裁剪'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
            iconSize: 20.sp,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.isProcessing.value) {
              return Container(
                margin: EdgeInsets.all(8.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            }
            return Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: IconButton(
                icon: const Icon(Icons.check),
                onPressed: controller.finishCrop,
                iconSize: 20.sp,
              ),
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          // 裁剪区域
          _buildCropArea(),
          
          // 比例选择器
          _buildRatioSelector(),
          
          // 底部操作栏
          _buildBottomActions(),
        ],
      ),
    );
  }

  /// 裁剪区域
  Widget _buildCropArea() {
    return Container(
      color: Colors.black,
      child: Obx(() {
        if (controller.currentImageFile.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 16.h),
                Text(
                  '加载图片中...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return ExtendedImage.file(
          controller.currentImageFile.value!,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.editor,
          extendedImageEditorKey: controller.editorKey,
          cacheRawData: true, // 添加这个参数
          initEditorConfigHandler: (state) {
            return EditorConfig(
              maxScale: 8.0,
              cropRectPadding: EdgeInsets.all(20.w),
              hitTestSize: 20.w,
              cropAspectRatio: controller.currentRatio.value.ratioX == 0 
                  ? null 
                  : controller.currentRatio.value.ratioX / controller.currentRatio.value.ratioY,
              editorMaskColorHandler: (context, pointerDown) {
                return controller.isCircularCrop.value
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.3);
              },
            );
          },
        );
      }),
    );
  }

  /// 比例选择器
  Widget _buildRatioSelector() {
    return Positioned(
      top: 100.h,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 圆形裁剪按钮
            Obx(() {
              return GestureDetector(
                onTap: controller.toggleCircularCrop,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: controller.isCircularCrop.value 
                        ? Colors.blue 
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.isCircularCrop.value 
                          ? Colors.blue 
                          : Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.crop_din,
                    color: controller.isCircularCrop.value 
                        ? Colors.white 
                        : Colors.white,
                    size: 20.sp,
                  ),
                ),
              );
            }),
            
            SizedBox(width: 16.w),
            
            // 比例按钮
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // 自由比例
                    Obx(() {
                      final isSelected = controller.currentRatio.value.ratioX == 0;
                      return GestureDetector(
                        onTap: controller.setFreeRatio,
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '自由',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    // 比例按钮
                    ...List.generate(controller.aspectRatios.length, (index) {
                      final ratio = controller.aspectRatios[index];
                      final name = controller.ratioNames[index];
                      
                      return Obx(() {
                        final isSelected = controller.currentRatio.value == ratio;
                        return GestureDetector(
                          onTap: () => controller.setAspectRatio(ratio),
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      });
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 底部操作栏
  Widget _buildBottomActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isProcessing.value) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: controller.uploadProgress.value,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '处理中... ${(controller.uploadProgress.value * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Row(
              children: [
                // 裁剪按钮
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: controller.getCroppedImage,
                      icon: const Icon(Icons.crop, color: Colors.white),
                      label: const Text(
                        '裁剪',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // 保存按钮
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: controller.saveCroppedImage,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        '保存',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // 上传按钮
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: TextButton.icon(
                      onPressed: controller.uploadCroppedImage,
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: const Text(
                        '上传',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
