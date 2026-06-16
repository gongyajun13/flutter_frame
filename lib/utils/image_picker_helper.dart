import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../overlay/overlay.dart';

/// 图片选择辅助工具类
/// 统一处理图片选择后的逻辑，减少代码重复
class ImagePickerHelper {
  /// 检查是否是权限相关的错误
  static bool isPermissionError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('permission') ||
        errorStr.contains('权限') ||
        errorStr.contains('denied') ||
        errorStr.contains('拒绝') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('forbidden');
  }

  /// 检查相册权限状态并显示提示
  /// 
  /// 返回 true 表示可以继续操作，false 表示权限被拒绝
  static Future<bool> checkPhotoPermission({
    bool showSnackbar = true,
  }) async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      debugPrint('ImagePickerHelper: 当前权限状态: $ps');

      // 如果权限被拒绝，提示用户
      if (ps == PermissionState.denied) {
        if (showSnackbar) {
          AppOverlay.snack.warning(
            message: '需要相册权限才能选择图片，请在设置中开启',
            title: '权限提示',
          );
        }
        return false;
      }

      // 如果权限受限，也提示用户
      if (ps == PermissionState.restricted) {
        if (showSnackbar) {
          AppOverlay.snack.warning(
            message: '相册权限受限，无法选择图片',
            title: '权限提示',
          );
        }
        return false;
      }

      // 权限已授权或有限权限，可以继续
      return true;
    } catch (e) {
      debugPrint('ImagePickerHelper: 权限检查失败: $e');
      return false;
    }
  }

  /// 处理图片选择错误
  /// 
  /// 根据错误类型显示相应的提示信息
  static void handleImagePickerError(
    dynamic error, {
    String? defaultMessage,
    String? permissionMessage,
  }) {
    final isPermission = isPermissionError(error);
    
    if (isPermission) {
      AppOverlay.snack.warning(
        message: permissionMessage ?? '需要相册权限才能选择图片，请在设置中开启',
        title: '权限提示',
      );
    } else {
      AppOverlay.snack.error(
        message: defaultMessage ?? '选择图片失败，请重试',
      );
    }
  }

  /// 处理相机权限错误
  static void handleCameraPermissionError() {
    AppOverlay.snack.warning(
      message: '需要相机权限才能拍照，请在设置中开启',
      title: '权限提示',
    );
  }

  /// 将 AssetEntity 列表转换为 File 列表
  static Future<List<File>> convertAssetsToFiles(
    List<AssetEntity> assets,
  ) async {
    final List<File> files = [];
    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) {
        files.add(file);
      }
    }
    return files;
  }

  /// 显示成功提示
  static void showSuccessMessage(String message) {
    AppOverlay.toast.success(message);
  }
}

/// 图片选择结果处理回调
typedef ImagePickerResultCallback = void Function(List<File> files);

/// 图片选择配置
class ImagePickerConfig {
  /// 最大选择数量
  final int maxAssets;
  
  /// 是否显示预览
  final bool showPreview;
  
  /// 请求类型（图片/视频）
  final RequestType requestType;

  const ImagePickerConfig({
    this.maxAssets = 9,
    this.showPreview = false,
    this.requestType = RequestType.image,
  });
}

/// 微信相册选择器辅助类
class WechatAssetPickerHelper {
  /// 使用微信相册选择器选择图片
  /// 
  /// 自动处理权限检查和错误处理
  static Future<List<File>?> pickImages({
    required ImagePickerConfig config,
    bool checkPermission = true,
  }) async {
    try {
      // 检查权限
      if (checkPermission) {
        final hasPermission = await ImagePickerHelper.checkPhotoPermission();
        if (!hasPermission) {
          return null;
        }
      }

      // 选择图片
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(
          maxAssets: config.maxAssets,
          selectedAssets: [],
          requestType: config.requestType,
          specialPickerType: config.showPreview
              ? null
              : SpecialPickerType.noPreview,
          textDelegate: const AssetPickerTextDelegate(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        // 转换 AssetEntity 为 File
        final files = await ImagePickerHelper.convertAssetsToFiles(result);
        return files;
      }

      return null;
    } catch (e) {
      debugPrint('WechatAssetPickerHelper: 选择图片失败: $e');
      ImagePickerHelper.handleImagePickerError(e);
      return null;
    }
  }
}
