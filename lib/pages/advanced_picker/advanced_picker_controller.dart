import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../utils/image_util.dart';

/// 高级图片选择控制器
class AdvancedPickerController extends GetxController {
  // 选中的资源列表
  final selectedAssets = <AssetEntity>[].obs;
  
  // 当前预览的资源
  final currentAsset = Rxn<AssetEntity>();
  
  // 是否正在上传
  final isUploading = false.obs;
  
  // 上传进度
  final uploadProgress = 0.0.obs;
  
  // 最大选择数量
  final int maxAssets = 9;
  
  // 当前相册
  final currentAlbum = Rxn<AssetPathEntity>();

  @override
  void onInit() {
    super.onInit();
    _requestPermission();
  }

  /// 请求权限
  Future<void> _requestPermission() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      debugPrint('权限状态: $ps');
      // 只在权限被明确拒绝时才提示，不干扰正常使用
      if (ps == PermissionState.denied) {
        debugPrint('相册权限被拒绝');
      } else if (ps == PermissionState.restricted) {
        debugPrint('相册权限受限');
      } else if (ps == PermissionState.authorized) {
        debugPrint('相册权限已授权');
      } else {
        debugPrint('相册权限状态: $ps');
      }
    } catch (e) {
      debugPrint('权限请求失败: $e');
      // 权限请求失败不一定是权限问题，可能是其他错误
    }
  }

  /// 调试权限状态（开发时使用）
  Future<void> debugPermissionStatus() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      debugPrint('=== 权限调试信息 ===');
      debugPrint('当前权限状态: $ps');
      debugPrint('权限类型: ${ps.runtimeType}');
      debugPrint('是否已授权: ${ps.isAuth}');
      debugPrint('是否被拒绝: ${ps == PermissionState.denied}');
      debugPrint('是否受限: ${ps == PermissionState.restricted}');
      debugPrint('==================');
    } catch (e) {
      debugPrint('权限调试失败: $e');
    }
  }

  /// 检查是否是权限相关的错误
  bool _isPermissionError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('permission') || 
           errorStr.contains('权限') ||
           errorStr.contains('denied') ||
           errorStr.contains('拒绝') ||
           errorStr.contains('unauthorized') ||
           errorStr.contains('forbidden');
  }

  /// 选择图片（相册目录）
  Future<void> pickAssets() async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(
          maxAssets: maxAssets,
          selectedAssets: selectedAssets,
          requestType: RequestType.image,
          specialPickerType: SpecialPickerType.noPreview,
          textDelegate: const AssetPickerTextDelegate(),
        ),
      );

      if (result != null) {
        selectedAssets.value = result;
        if (result.isNotEmpty) {
          currentAsset.value = result.first;
        }
        Get.snackbar('成功', '已选择 ${result.length} 张图片');
      }
    } catch (e) {
      debugPrint('选择图片失败: $e');
      // 使用工具方法检查是否是权限问题
      if (_isPermissionError(e)) {
        Get.snackbar('权限提示', '需要相册权限才能选择图片，请在设置中开启');
      } else {
        Get.snackbar('错误', '选择图片失败，请重试');
      }
    }
  }

  /// 拍照
  Future<void> takePhoto() async {
    try {
      final AssetEntity? result = await CameraPicker.pickFromCamera(
        Get.context!,
        pickerConfig: CameraPickerConfig(
          enableRecording: false,
          onlyEnableRecording: false,
        ),
      );

      if (result != null) {
        selectedAssets.value = [result];
        currentAsset.value = result;
        Get.snackbar('成功', '拍照完成');
      }
    } catch (e) {
      debugPrint('拍照失败: $e');
      // 使用工具方法检查是否是权限问题
      if (_isPermissionError(e) || e.toString().toLowerCase().contains('camera')) {
        Get.snackbar('权限提示', '需要相机权限才能拍照，请在设置中开启');
      } else {
        Get.snackbar('错误', '拍照失败，请重试');
      }
    }
  }

  /// 预览单张图片
  Future<void> previewAsset(AssetEntity asset) async {
    currentAsset.value = asset;
  }

  /// 删除选中的资源
  void removeAsset(AssetEntity asset) {
    selectedAssets.remove(asset);
    if (currentAsset.value == asset) {
      currentAsset.value = selectedAssets.isNotEmpty ? selectedAssets.first : null;
    }
  }

  /// 清除所有选中的资源
  void clearAllAssets() {
    selectedAssets.clear();
    currentAsset.value = null;
  }

  /// 进入裁剪页面
  Future<void> goToCrop(AssetEntity asset) async {
    if (asset.type == AssetType.image) {
      Get.toNamed('/advanced-crop', arguments: {
        'asset': asset,
        'selectedAssets': selectedAssets,
      });
    }
  }

  /// 预览图片
  Future<void> previewImage(AssetEntity asset) async {
    if (asset.type == AssetType.image) {
      Get.toNamed('/image-preview', arguments: {
        'asset': asset,
        'selectedAssets': selectedAssets,
      });
    }
  }

  /// 批量处理选中的图片
  Future<void> processSelectedAssets() async {
    if (selectedAssets.isEmpty) {
      Get.snackbar('提示', '请先选择图片');
      return;
    }

    isUploading.value = true;
    uploadProgress.value = 0.0;

    try {
      final List<File> files = [];
      
      // 获取所有图片文件
      for (int i = 0; i < selectedAssets.length; i++) {
        final asset = selectedAssets[i];
        final file = await asset.file;
        if (file != null) {
          files.add(file);
        }
        uploadProgress.value = (i + 1) / selectedAssets.length * 0.5;
      }

      // 压缩所有图片
      final List<File> compressedFiles = [];
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final compressed = await ImageUtil.compressToSize(
          file,
          maxSizeKB: 500,
        );
        if (compressed != null) {
          compressedFiles.add(compressed);
        }
        uploadProgress.value = 0.5 + (i + 1) / files.length * 0.3;
      }

      // 模拟上传（实际使用时替换为真实上传地址）
      uploadProgress.value = 0.8;
      await Future.delayed(const Duration(seconds: 1));
      
      uploadProgress.value = 1.0;
      Get.snackbar('成功', '已处理 ${compressedFiles.length} 张图片');
      
    } catch (e) {
      Get.snackbar('错误', '处理图片失败: $e');
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// 单张图片完整流程（选择→裁剪→压缩→上传）
  Future<void> completeFlowForAsset(AssetEntity asset) async {
    try {
      final file = await asset.file;
      if (file == null) return;

      // 压缩图片
      final compressed = await ImageUtil.compressToSize(
        file,
        maxSizeKB: 500,
      );

      if (compressed != null) {
        // 模拟上传
        final response = await ImageUtil.uploadImage(
          compressed,
          'https://api.example.com/upload',
          onProgress: (sent, total) {
            uploadProgress.value = sent / total;
          },
        );

        if (response?.statusCode == 200) {
          Get.snackbar('成功', '图片处理完成');
        }
      }
    } catch (e) {
      Get.snackbar('错误', '处理失败: $e');
    }
  }
}
