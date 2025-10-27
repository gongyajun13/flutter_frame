import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../utils/image_util.dart';

/// 图片压缩信息
class ImageCompressInfo {
  final String originalSize;
  final String compressedSize;
  final bool isCompressed;
  
  ImageCompressInfo({
    required this.originalSize,
    required this.compressedSize,
    this.isCompressed = false,
  });
}

/// 图片处理演示控制器
class ImageUtilDemoController extends GetxController {
  // 选中的图片列表
  final selectedImages = <File>[].obs;
  
  // 当前正在处理的图片
  final currentImage = Rxn<File>();
  
  // 当前图片索引
  final currentImageIndex = 0.obs;
  
  // PageView控制器
  late PageController pageController;
  
  // 每张图片的压缩信息
  final Map<String, ImageCompressInfo> imageCompressInfo = <String, ImageCompressInfo>{};
  
  // 压缩前的图片大小
  final originalSize = ''.obs;
  
  // 压缩后的图片大小
  final compressedSize = ''.obs;
  
  // 上传进度
  final uploadProgress = 0.0.obs;
  
  // 是否正在上传
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// 切换到指定图片
  void switchToImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      currentImageIndex.value = index;
      currentImage.value = selectedImages[index];
      
      // 获取当前图片的压缩信息
      final currentFile = selectedImages[index];
      final filePath = currentFile.path;
      
      if (imageCompressInfo.containsKey(filePath)) {
        // 如果已有压缩信息，使用保存的信息
        final info = imageCompressInfo[filePath]!;
        originalSize.value = info.originalSize;
        compressedSize.value = info.compressedSize;
      } else {
        // 如果没有压缩信息，重新计算文件大小
        _updateFileSize(currentFile);
      }
    }
  }

  /// 切换到下一张图片
  void nextImage() {
    if (currentImageIndex.value < selectedImages.length - 1) {
      switchToImage(currentImageIndex.value + 1);
    }
  }

  /// 切换到上一张图片
  void previousImage() {
    if (currentImageIndex.value > 0) {
      switchToImage(currentImageIndex.value - 1);
    }
  }

  /// 从相册选择单张图片
  Future<void> pickFromGallery() async {
    final file = await ImageUtil.pickFromGallery();
    if (file != null) {
      currentImage.value = file;
      selectedImages.clear();
      selectedImages.add(file);
      currentImageIndex.value = 0;
      await _updateFileSize(file);
      Get.snackbar(
        '成功',
        '已选择图片',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 从相机拍照
  Future<void> pickFromCamera() async {
    final file = await ImageUtil.pickFromCamera();
    if (file != null) {
      currentImage.value = file;
      selectedImages.clear();
      selectedImages.add(file);
      currentImageIndex.value = 0;
      await _updateFileSize(file);
      Get.snackbar(
        '成功',
        '已拍摄图片',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 选择多张图片
  Future<void> pickMultipleImages() async {
    final files = await ImageUtil.pickMultipleImages(limit: 9);
    if (files.isNotEmpty) {
      selectedImages.value = files;
      currentImage.value = files.first;
      currentImageIndex.value = 0;
      await _updateFileSize(files.first);
      Get.snackbar(
        '成功',
        '已选择 ${files.length} 张图片',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 使用微信相册选择器选择图片
  Future<void> pickFromWechatAssets() async {
    try {
      // 检查权限状态
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      debugPrint('当前权限状态: $ps');
      
      // 如果权限被拒绝，提示用户
      if (ps == PermissionState.denied) {
        Get.snackbar(
          '权限提示', 
          '需要相册权限才能选择图片，请在设置中开启',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      // 如果权限受限，也提示用户
      if (ps == PermissionState.restricted) {
        Get.snackbar(
          '权限提示', 
          '相册权限受限，无法选择图片',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(
          maxAssets: 9,
          selectedAssets: [],
          requestType: RequestType.image,
          specialPickerType: SpecialPickerType.noPreview,
          textDelegate: const AssetPickerTextDelegate(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        // 转换 AssetEntity 为 File
        final List<File> files = [];
        for (final asset in result) {
          final file = await asset.file;
          if (file != null) {
            files.add(file);
          }
        }

        if (files.isNotEmpty) {
          selectedImages.value = files;
          currentImage.value = files.first;
          currentImageIndex.value = 0;
          await _updateFileSize(files.first);
          Get.snackbar(
            '成功',
            '已选择 ${files.length} 张图片',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint('选择图片失败: $e');
      // 检查是否是权限相关的错误
      if (e.toString().toLowerCase().contains('permission') ||
          e.toString().toLowerCase().contains('权限') ||
          e.toString().toLowerCase().contains('denied') ||
          e.toString().toLowerCase().contains('拒绝')) {
        Get.snackbar(
          '权限错误', 
          '相册权限被拒绝，请在设置中开启权限',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar('错误', '选择图片失败: $e');
      }
    }
  }

  /// 使用微信相机选择器拍照
  Future<void> takePhotoWithWechatCamera() async {
    try {
      final AssetEntity? result = await CameraPicker.pickFromCamera(
        Get.context!,
        pickerConfig: CameraPickerConfig(
          enableRecording: false,
          onlyEnableRecording: false,
        ),
      );

      if (result != null) {
        final file = await result.file;
        if (file != null) {
          currentImage.value = file;
          selectedImages.clear();
          selectedImages.add(file);
          currentImageIndex.value = 0;
          await _updateFileSize(file);
          Get.snackbar(
            '成功',
            '拍照完成',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint('拍照失败: $e');
      // 检查是否是权限相关的错误
      if (e.toString().toLowerCase().contains('permission') ||
          e.toString().toLowerCase().contains('权限') ||
          e.toString().toLowerCase().contains('denied') ||
          e.toString().toLowerCase().contains('拒绝') ||
          e.toString().toLowerCase().contains('camera')) {
        Get.snackbar(
          '权限错误', 
          '相机权限被拒绝，请在设置中开启相机权限',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar('错误', '拍照失败: $e');
      }
    }
  }

  /// 使用微信相机选择器录制视频
  Future<void> recordVideoWithWechatCamera() async {
    try {
      final AssetEntity? result = await CameraPicker.pickFromCamera(
        Get.context!,
        pickerConfig: CameraPickerConfig(
          enableRecording: true,
          onlyEnableRecording: true,
        ),
      );

      if (result != null) {
        final file = await result.file;
        if (file != null) {
          currentImage.value = file;
          selectedImages.clear();
          selectedImages.add(file);
          currentImageIndex.value = 0;
          await _updateFileSize(file);
          Get.snackbar(
            '成功',
            '视频录制完成',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint('录制视频失败: $e');
      // 检查是否是权限相关的错误
      if (e.toString().toLowerCase().contains('permission') ||
          e.toString().toLowerCase().contains('权限') ||
          e.toString().toLowerCase().contains('denied') ||
          e.toString().toLowerCase().contains('拒绝') ||
          e.toString().toLowerCase().contains('camera')) {
        Get.snackbar(
          '权限错误', 
          '相机权限被拒绝，请在设置中开启相机权限',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar('错误', '录制视频失败: $e');
      }
    }
  }

  /// 显示图片来源选择对话框
  Future<void> showSourceDialog() async {
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('选择图片来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('相机'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('相册'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      if (source == ImageSource.camera) {
        await pickFromCamera();
      } else {
        await pickFromGallery();
      }
    }
  }

  /// 显示高级图片来源选择对话框
  Future<void> showAdvancedSourceDialog() async {
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('选择图片来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('系统相机'),
              subtitle: const Text('使用系统相机拍照'),
              onTap: () => Get.back(result: 'system_camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('系统相册'),
              subtitle: const Text('使用系统相册选择'),
              onTap: () => Get.back(result: 'system_gallery'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('微信相机'),
              subtitle: const Text('使用微信风格相机'),
              onTap: () => Get.back(result: 'wechat_camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('微信相册'),
              subtitle: const Text('使用微信风格相册选择'),
              onTap: () => Get.back(result: 'wechat_assets'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('微信录像'),
              subtitle: const Text('使用微信风格录像'),
              onTap: () => Get.back(result: 'wechat_video'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      switch (result) {
        case 'system_camera':
          await pickFromCamera();
          break;
        case 'system_gallery':
          await pickFromGallery();
          break;
        case 'wechat_camera':
          await takePhotoWithWechatCamera();
          break;
        case 'wechat_assets':
          await pickFromWechatAssets();
          break;
        case 'wechat_video':
          await recordVideoWithWechatCamera();
          break;
      }
    }
  }

  /// 裁剪图片
  Future<void> cropImage({CropAspectRatio? aspectRatio}) async {
    if (currentImage.value == null) {
      Get.snackbar(
        '提示',
        '请先选择图片',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final croppedFile = await ImageUtil.cropImage(
      currentImage.value!,
      aspectRatio: aspectRatio,
    );

    if (croppedFile != null) {
      currentImage.value = croppedFile;
      // 更新列表中的图片
      final index = selectedImages.indexWhere(
        (file) => file.path == currentImage.value!.path,
      );
      if (index != -1) {
        selectedImages[index] = croppedFile;
      } else {
        selectedImages.add(croppedFile);
      }
      await _updateFileSize(croppedFile);
      Get.snackbar(
        '成功',
        '图片裁剪完成',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 裁剪为正方形
  Future<void> cropToSquare() async {
    await cropImage(
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );
  }

  /// 裁剪为 16:9
  Future<void> cropTo16x9() async {
    await cropImage(
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
    );
  }

  /// 裁剪为 4:3
  Future<void> cropTo4x3() async {
    await cropImage(
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
    );
  }

  /// 自由裁剪
  Future<void> cropFree() async {
    await cropImage();
  }

  /// 压缩图片
  Future<void> compressImage({int quality = 85}) async {
    if (currentImage.value == null) {
      Get.snackbar(
        '提示',
        '请先选择图片',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final compressedFile = await ImageUtil.compressImage(
      currentImage.value!,
      quality: quality,
    );

    if (compressedFile != null) {
      // 显示压缩前后的大小对比
      final originalBytes = await currentImage.value!.length();
      final compressedBytes = await compressedFile.length();
      
      final originalSizeStr = _formatBytes(originalBytes);
      final compressedSizeStr = _formatBytes(compressedBytes);
      
      originalSize.value = originalSizeStr;
      compressedSize.value = compressedSizeStr;
      
      final ratio = (compressedBytes / originalBytes * 100).toStringAsFixed(1);
      
      // 更新当前图片
      currentImage.value = compressedFile;
      
      // 更新选中图片列表中的对应图片
      final currentIndex = currentImageIndex.value;
      if (currentIndex < selectedImages.length) {
        selectedImages[currentIndex] = compressedFile;
      }
      
      // 保存压缩信息
      final filePath = compressedFile.path;
      imageCompressInfo[filePath] = ImageCompressInfo(
        originalSize: originalSizeStr,
        compressedSize: compressedSizeStr,
        isCompressed: true,
      );
      
      Get.snackbar(
        '压缩完成',
        '原始: ${originalSizeStr} → 压缩后: ${compressedSizeStr} (${ratio}%)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 压缩到指定大小
  Future<void> compressToSize({int maxSizeKB = 500}) async {
    if (currentImage.value == null) {
      Get.snackbar(
        '提示',
        '请先选择图片',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final originalBytes = await currentImage.value!.length();
    originalSize.value = _formatBytes(originalBytes);

    final compressedFile = await ImageUtil.compressToSize(
      currentImage.value!,
      maxSizeKB: maxSizeKB,
    );

    if (compressedFile != null) {
      final compressedBytes = await compressedFile.length();
      final compressedSizeStr = _formatBytes(compressedBytes);
      
      compressedSize.value = compressedSizeStr;
      
      final ratio = (compressedBytes / originalBytes * 100).toStringAsFixed(1);
      
      // 更新当前图片
      currentImage.value = compressedFile;
      
      // 更新选中图片列表中的对应图片
      final currentIndex = currentImageIndex.value;
      if (currentIndex < selectedImages.length) {
        selectedImages[currentIndex] = compressedFile;
      }
      
      // 保存压缩信息
      final filePath = compressedFile.path;
      imageCompressInfo[filePath] = ImageCompressInfo(
        originalSize: originalSize.value,
        compressedSize: compressedSizeStr,
        isCompressed: true,
      );
      
      Get.snackbar(
        '压缩完成',
        '原始: ${originalSize.value} → 压缩后: ${compressedSizeStr} (${ratio}%)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 模拟上传图片
  /// 
  /// 注意：这里是模拟上传，实际使用时请替换为真实的上传地址
  Future<void> uploadImage() async {
    if (currentImage.value == null) {
      Get.snackbar(
        '提示',
        '请先选择图片',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      // 模拟上传进度
      for (var i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        uploadProgress.value = i / 100;
      }

      // 实际上传示例（需要替换为真实的上传地址）
      // final response = await ImageUtil.uploadImage(
      //   currentImage.value!,
      //   'https://your-api.com/upload',
      //   onProgress: (sent, total) {
      //     uploadProgress.value = sent / total;
      //   },
      // );

      Get.snackbar(
        '成功',
        '图片上传完成',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '失败',
        '上传失败: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// 完整流程：选择 -> 裁剪 -> 压缩 -> 上传
  Future<void> completeFlow() async {
    // 1. 选择图片来源
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('选择图片来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('相机'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('相册'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // 2. 选择并处理图片
    final file = await ImageUtil.pickAndProcessImage(
      source: source,
      needCrop: true,
      needCompress: true,
      maxSizeKB: 500,
    );

    if (file != null) {
      currentImage.value = file;
      selectedImages.clear();
      selectedImages.add(file);
      await _updateFileSize(file);

      // 3. 显示是否上传的确认对话框
      final shouldUpload = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('确认'),
          content: const Text('是否上传此图片？'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('上传'),
            ),
          ],
        ),
      );

      if (shouldUpload == true) {
        await uploadImage();
      }
    }
  }

  /// 清除所有图片
  void clearImages() {
    selectedImages.clear();
    currentImage.value = null;
    currentImageIndex.value = 0;
    originalSize.value = '';
    compressedSize.value = '';
    imageCompressInfo.clear();
  }

  /// 更新文件大小显示
  Future<void> _updateFileSize(File file) async {
    final bytes = await file.length();
    final fileSizeStr = _formatBytes(bytes);
    originalSize.value = fileSizeStr;
    compressedSize.value = '';
    
    // 保存初始文件大小信息
    final filePath = file.path;
    if (!imageCompressInfo.containsKey(filePath)) {
      imageCompressInfo[filePath] = ImageCompressInfo(
        originalSize: fileSizeStr,
        compressedSize: '',
        isCompressed: false,
      );
    }
  }

  /// 格式化字节大小
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}

