import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../overlay/overlay.dart';

/// 图片预览控制器
class ImagePreviewController extends GetxController {
  // 当前预览的图片
  late AssetEntity currentAsset;
  
  // 所有选中的图片
  late List<AssetEntity> selectedAssets;
  
  // 当前图片索引
  final currentIndex = 0.obs;
  
  // 当前图片文件
  final currentImageFile = Rxn<File>();
  
  // 是否正在加载
  final isLoading = true.obs;
  
  // 缩放比例
  final scale = 1.0.obs;
  
  // 是否显示工具栏
  final showToolbar = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    currentAsset = args['asset'] as AssetEntity;
    selectedAssets = args['selectedAssets'] as List<AssetEntity>;
    
    // 找到当前图片在列表中的索引
    currentIndex.value = selectedAssets.indexOf(currentAsset);
    if (currentIndex.value == -1) {
      currentIndex.value = 0;
    }
    
    loadCurrentImage();
  }

  /// 加载当前图片
  Future<void> loadCurrentImage() async {
    try {
      isLoading.value = true;
      final file = await selectedAssets[currentIndex.value].file;
      if (file != null) {
        currentImageFile.value = file;
      }
    } catch (e) {
      debugPrint('加载图片失败: $e');
      AppOverlay.snack.error(message: '加载图片失败');
    } finally {
      isLoading.value = false;
    }
  }

  /// 切换到上一张图片
  void previousImage() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      loadCurrentImage();
    }
  }

  /// 切换到下一张图片
  void nextImage() {
    if (currentIndex.value < selectedAssets.length - 1) {
      currentIndex.value++;
      loadCurrentImage();
    }
  }

  /// 进入裁剪页面
  void goToCrop() {
    Get.toNamed('/advanced-crop', arguments: {
      'asset': selectedAssets[currentIndex.value],
      'selectedAssets': selectedAssets,
    });
  }

  /// 删除当前图片
  void deleteCurrentImage() {
    if (selectedAssets.length > 1) {
      selectedAssets.removeAt(currentIndex.value);
      if (currentIndex.value >= selectedAssets.length) {
        currentIndex.value = selectedAssets.length - 1;
      }
      loadCurrentImage();
      AppOverlay.toast.success('已删除图片');
    } else {
      Get.back();
    }
  }

  /// 切换工具栏显示
  void toggleToolbar() {
    showToolbar.value = !showToolbar.value;
  }

  /// 重置缩放
  void resetScale() {
    scale.value = 1.0;
  }

  /// 放大
  void zoomIn() {
    if (scale.value < 5.0) {
      scale.value = (scale.value + 0.5).clamp(1.0, 5.0);
    }
  }

  /// 缩小
  void zoomOut() {
    if (scale.value > 1.0) {
      scale.value = (scale.value - 0.5).clamp(1.0, 5.0);
    }
  }
}
