import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// WebView 文件选择器工具类
/// 
/// 用于处理 WebView 中的文件选择请求（<input type="file">）
class WebViewFileChooser {
  WebViewFileChooser._();

  static final ImagePicker _picker = ImagePicker();

  /// 显示文件选择对话框
  /// 
  /// [context] 上下文
  /// [acceptTypes] 接受的文件类型（例如：image/*, video/*, .pdf）
  /// [allowMultiple] 是否允许多选
  /// 
  /// 返回选中的文件列表
  static Future<List<File>> showFileChooser({
    required BuildContext context,
    List<String>? acceptTypes,
    bool allowMultiple = false,
  }) async {
    // 解析接受的文件类型
    final fileType = _parseAcceptTypes(acceptTypes);

    // 显示选择对话框
    final source = await _showSourceDialog(context, fileType);
    if (source == null) {
      return [];
    }

    // 根据文件类型和来源选择文件
    switch (fileType) {
      case FileType.image:
        return await _pickImages(
          context: context,
          source: source,
          allowMultiple: allowMultiple,
        );
      case FileType.video:
        return await _pickVideos(
          context: context,
          source: source,
          allowMultiple: allowMultiple,
        );
      case FileType.any:
        // 对于任意文件类型，优先使用图片选择器
        // 实际项目中可以集成 file_picker 插件来支持更多文件类型
        return await _pickImages(
          context: context,
          source: source,
          allowMultiple: allowMultiple,
        );
    }
  }

  /// 解析接受的文件类型
  static FileType _parseAcceptTypes(List<String>? acceptTypes) {
    if (acceptTypes == null || acceptTypes.isEmpty) {
      return FileType.any;
    }

    // 检查是否包含图片类型
    final hasImage = acceptTypes.any((type) =>
        type.contains('image') || type.contains('.jpg') || type.contains('.png'));

    // 检查是否包含视频类型
    final hasVideo = acceptTypes.any((type) =>
        type.contains('video') || type.contains('.mp4') || type.contains('.mov'));

    if (hasImage && !hasVideo) {
      return FileType.image;
    } else if (hasVideo && !hasImage) {
      return FileType.video;
    } else {
      return FileType.any;
    }
  }

  /// 显示来源选择对话框（相机/相册）
  static Future<ImageSource?> _showSourceDialog(
    BuildContext context,
    FileType fileType,
  ) async {
    final index = await AppOverlay.dialog.selectAsync(
      title: fileType == FileType.video ? '选择视频来源' : '选择图片来源',
      options: const ['从相册选择', '拍照'],
    );
    if (index == null) return null;
    return index == 0 ? ImageSource.gallery : ImageSource.camera;
  }

  /// 选择图片
  static Future<List<File>> _pickImages({
    required BuildContext context,
    required ImageSource source,
    bool allowMultiple = false,
  }) async {
    try {
      // 请求权限
      final permission = source == ImageSource.camera
          ? ph.Permission.camera
          : ph.Permission.photos;

      final status = await permission.status;
      if (!status.isGranted) {
        final result = await permission.request();
        if (!result.isGranted) {
          debugPrint('权限被拒绝');
          return [];
        }
      }

      if (allowMultiple) {
        // 多选
        final List<XFile> images = await _picker.pickMultiImage();
        return images.map((xFile) => File(xFile.path)).toList();
      } else {
        // 单选
        final XFile? image = source == ImageSource.camera
            ? await _picker.pickImage(source: ImageSource.camera)
            : await _picker.pickImage(source: ImageSource.gallery);

        if (image == null) return [];
        return [File(image.path)];
      }
    } catch (e) {
      debugPrint('选择图片失败: $e');
      return [];
    }
  }

  /// 选择视频
  static Future<List<File>> _pickVideos({
    required BuildContext context,
    required ImageSource source,
    bool allowMultiple = false,
  }) async {
    try {
      // 请求权限
      final permission = source == ImageSource.camera
          ? ph.Permission.camera
          : ph.Permission.photos;

      final status = await permission.status;
      if (!status.isGranted) {
        final result = await permission.request();
        if (!result.isGranted) {
          debugPrint('权限被拒绝');
          return [];
        }
      }

      if (allowMultiple) {
        // 多选（image_picker 不支持多选视频，这里只返回单个）
        final XFile? video = source == ImageSource.camera
            ? await _picker.pickVideo(source: ImageSource.camera)
            : await _picker.pickVideo(source: ImageSource.gallery);

        if (video == null) return [];
        return [File(video.path)];
      } else {
        // 单选
        final XFile? video = source == ImageSource.camera
            ? await _picker.pickVideo(source: ImageSource.camera)
            : await _picker.pickVideo(source: ImageSource.gallery);

        if (video == null) return [];
        return [File(video.path)];
      }
    } catch (e) {
      debugPrint('选择视频失败: $e');
      return [];
    }
  }
}

/// 文件类型枚举
enum FileType {
  image,
  video,
  any,
}
