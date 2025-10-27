import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_image/extended_image.dart';
import 'image_preview_controller.dart';

/// 图片预览页面
class ImagePreviewView extends GetView<ImagePreviewController> {
  const ImagePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 图片显示区域
          _buildImageArea(),
          
          // 顶部工具栏
          _buildTopToolbar(),
          
          // 底部工具栏
          _buildBottomToolbar(),
          
          // 加载指示器
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// 图片显示区域
  Widget _buildImageArea() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      }

      return PageView.builder(
        controller: PageController(initialPage: controller.currentIndex.value),
        onPageChanged: (index) {
          controller.currentIndex.value = index;
          controller.loadCurrentImage();
        },
        itemCount: controller.selectedAssets.length,
        itemBuilder: (context, index) {
          return _buildSingleImage(index);
        },
      );
    });
  }

  /// 构建单张图片
  Widget _buildSingleImage(int index) {
    return FutureBuilder<File?>(
      future: controller.selectedAssets[index].file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Text(
              '图片加载失败',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return GestureDetector(
          onTap: controller.toggleToolbar,
          child: _buildImageWithAspectRatio(snapshot.data!),
        );
      },
    );
  }

  /// 根据图片比例构建图片
  Widget _buildImageWithAspectRatio(File imageFile) {
    return FutureBuilder<ui.Image>(
      future: _getImageSize(imageFile),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final image = snapshot.data!;
          final aspectRatio = image.width / image.height;
          final screenAspectRatio = MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
          
          // 判断图片是横屏还是竖屏
          if (aspectRatio > screenAspectRatio) {
            // 横屏图片，居中显示
            return Center(
              child: ExtendedImage.file(
                imageFile,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    minScale: 1.0,
                    maxScale: 5.0,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: true,
                    initialAlignment: InitialAlignment.center,
                  );
                },
                onDoubleTap: (ExtendedImageGestureState state) {
                  final pointerDownPosition = state.pointerDownPosition;
                  final begin = state.gestureDetails!.totalScale;
                  double end;

                  if (begin == 1.0) {
                    end = 2.0;
                  } else {
                    end = 1.0;
                  }

                  state.handleDoubleTap(
                    scale: end,
                    doubleTapPosition: pointerDownPosition,
                  );
                },
              ),
            );
          } else {
            // 竖屏图片，全屏显示
            return ExtendedImage.file(
              imageFile,
              fit: BoxFit.cover,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (state) {
                return GestureConfig(
                  minScale: 1.0,
                  maxScale: 5.0,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: true,
                  initialAlignment: InitialAlignment.center,
                );
              },
              onDoubleTap: (ExtendedImageGestureState state) {
                final pointerDownPosition = state.pointerDownPosition;
                final begin = state.gestureDetails!.totalScale;
                double end;

                if (begin == 1.0) {
                  end = 2.0;
                } else {
                  end = 1.0;
                }

                state.handleDoubleTap(
                  scale: end,
                  doubleTapPosition: pointerDownPosition,
                );
              },
            );
          }
        }
        
        // 默认显示
        return ExtendedImage.file(
          imageFile,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 1.0,
              maxScale: 5.0,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: true,
              initialAlignment: InitialAlignment.center,
            );
          },
        );
      },
    );
  }

  /// 获取图片尺寸
  Future<ui.Image> _getImageSize(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// 顶部工具栏
  Widget _buildTopToolbar() {
    return Obx(() {
      if (!controller.showToolbar.value) return const SizedBox.shrink();
      
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // 返回按钮
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // 图片计数
                  Expanded(
                    child: Obx(() => Text(
                      '${controller.currentIndex.value + 1} / ${controller.selectedAssets.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ),
                  SizedBox(width: 16.w),
                  // 删除按钮
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: IconButton(
                      onPressed: controller.deleteCurrentImage,
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      iconSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 底部工具栏
  Widget _buildBottomToolbar() {
    return Obx(() {
      if (!controller.showToolbar.value) return const SizedBox.shrink();
      
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 裁剪按钮
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: IconButton(
                      onPressed: controller.goToCrop,
                      icon: const Icon(Icons.crop, color: Colors.white),
                      iconSize: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 加载指示器
  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();
      
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    });
  }

}
