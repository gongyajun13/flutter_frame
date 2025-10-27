import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../utils/image_util.dart';

/// 裁剪比例
class CropAspectRatio {
  final double ratioX;
  final double ratioY;
  
  const CropAspectRatio({
    required this.ratioX,
    required this.ratioY,
  });
}

/// 高级图片裁剪控制器
class AdvancedCropController extends GetxController {
  // 当前资源
  late AssetEntity asset;
  
  // 裁剪后的图片
  final croppedImage = Rxn<File>();
  
  // 当前裁剪比例
  final currentRatio = const CropAspectRatio(ratioX: 1, ratioY: 1).obs;
  
  // 是否圆形裁剪
  final isCircularCrop = false.obs;
  
  // 是否正在处理
  final isProcessing = false.obs;
  
  // 上传进度
  final uploadProgress = 0.0.obs;
  
  // 编辑器键
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();
  
  // 当前图片文件
  final currentImageFile = Rxn<File>();

  // 预设比例列表
  final List<CropAspectRatio> aspectRatios = const [
    CropAspectRatio(ratioX: 1, ratioY: 1),   // 1:1
    CropAspectRatio(ratioX: 3, ratioY: 4),   // 3:4
    CropAspectRatio(ratioX: 4, ratioY: 3),   // 4:3
    CropAspectRatio(ratioX: 3, ratioY: 2),   // 3:2
    CropAspectRatio(ratioX: 16, ratioY: 9),  // 16:9
  ];

  // 比例名称
  final List<String> ratioNames = [
    '1:1',
    '3:4',
    '4:3',
    '3:2',
    '16:9',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    asset = args['asset'] as AssetEntity;
    _loadImageFile();
  }

  /// 加载图片文件
  Future<void> _loadImageFile() async {
    try {
      final file = await asset.file;
      if (file != null) {
        currentImageFile.value = file;
      }
    } catch (e) {
      debugPrint('加载图片文件失败: $e');
      Get.snackbar('错误', '加载图片失败');
    }
  }

  /// 切换裁剪比例
  void setAspectRatio(CropAspectRatio ratio) {
    currentRatio.value = ratio;
    isCircularCrop.value = false;
    
    // 显示提示信息
    Get.snackbar(
      '比例选择',
      '已选择 ${ratio.ratioX}:${ratio.ratioY} 比例',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  /// 切换圆形裁剪
  void toggleCircularCrop() {
    isCircularCrop.value = !isCircularCrop.value;
    if (isCircularCrop.value) {
      currentRatio.value = const CropAspectRatio(ratioX: 1, ratioY: 1);
    }
    
    // 显示提示信息
    Get.snackbar(
      '裁剪模式',
      isCircularCrop.value ? '已切换到圆形裁剪' : '已切换到矩形裁剪',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  /// 自由比例
  void setFreeRatio() {
    currentRatio.value = const CropAspectRatio(ratioX: 0, ratioY: 0);
    isCircularCrop.value = false;
    
    // 显示提示信息
    Get.snackbar(
      '比例选择',
      '已选择自由比例',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  /// 获取裁剪后的图片
  Future<void> getCroppedImage() async {
    try {
      isProcessing.value = true;
      
      final state = editorKey.currentState;
      if (state == null) {
        Get.snackbar('错误', '编辑器未初始化');
        return;
      }

      // 获取裁剪后的数据
      final data = state.rawImageData;
      if (data.isEmpty) {
        Get.snackbar('错误', '无法获取图片数据');
        return;
      }

      // 保存裁剪后的图片
      final tempDir = await Directory.systemTemp.createTemp('crop_');
      final croppedFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await croppedFile.writeAsBytes(data);
      
      croppedImage.value = croppedFile;
      
      // 替换当前图片文件
      currentImageFile.value = croppedFile;
      
      Get.snackbar('成功', '裁剪完成，图片已更新');
    } catch (e) {
      debugPrint('裁剪失败: $e');
      Get.snackbar('错误', '裁剪失败: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  /// 保存裁剪后的图片
  Future<void> saveCroppedImage() async {
    if (croppedImage.value == null) {
      Get.snackbar('提示', '请先裁剪图片');
      return;
    }

    try {
      isProcessing.value = true;
      
      // 压缩图片
      final compressed = await ImageUtil.compressToSize(
        croppedImage.value!,
        maxSizeKB: 500,
      );

      if (compressed != null) {
        croppedImage.value = compressed;
        Get.snackbar('成功', '图片已保存并压缩');
      }
    } catch (e) {
      Get.snackbar('错误', '保存失败: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  /// 上传裁剪后的图片
  Future<void> uploadCroppedImage() async {
    if (croppedImage.value == null) {
      Get.snackbar('提示', '请先裁剪图片');
      return;
    }

    try {
      isProcessing.value = true;
      uploadProgress.value = 0.0;

      // 压缩图片
      final compressed = await ImageUtil.compressToSize(
        croppedImage.value!,
        maxSizeKB: 500,
      );

      if (compressed == null) {
        Get.snackbar('错误', '压缩失败');
        return;
      }

      // 上传图片
      final response = await ImageUtil.uploadImage(
        compressed,
        'https://api.example.com/upload',
        onProgress: (sent, total) {
          uploadProgress.value = sent / total;
        },
      );

      if (response?.statusCode == 200) {
        Get.snackbar('成功', '上传完成');
        Get.back(result: compressed);
      } else {
        Get.snackbar('错误', '上传失败');
      }
    } catch (e) {
      Get.snackbar('错误', '上传失败: $e');
    } finally {
      isProcessing.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// 完成裁剪并返回
  void finishCrop() {
    if (croppedImage.value != null) {
      Get.back(result: croppedImage.value);
    } else {
      // 如果没有裁剪过，返回原图
      Get.back(result: currentImageFile.value);
    }
  }
}
