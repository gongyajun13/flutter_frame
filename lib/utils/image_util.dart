import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import '../overlay/overlay.dart';

/// 图片处理工具类
/// 
/// 功能包括：
/// - 图片选择（相机/相册）
/// - 图片裁剪
/// - 图片压缩
/// - 图片上传
class ImageUtil {
  ImageUtil._();

  static final ImagePicker _picker = ImagePicker();

  /// 从相册选择图片
  /// 
  /// [maxWidth] 图片最大宽度
  /// [maxHeight] 图片最大高度
  /// [imageQuality] 图片质量 (0-100)
  /// [requestFullMetadata] 是否请求完整元数据
  /// 
  /// 返回选中的图片文件，如果用户取消则返回 null
  static Future<File?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 100,
    bool requestFullMetadata = true,
  }) async {
    try {
      // 请求相册权限
      final status = await _requestPhotosPermission();
      if (!status) {
        debugPrint('相册权限被拒绝');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        requestFullMetadata: requestFullMetadata,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('从相册选择图片失败: $e');
      return null;
    }
  }

  /// 从相机拍照
  /// 
  /// [maxWidth] 图片最大宽度
  /// [maxHeight] 图片最大高度
  /// [imageQuality] 图片质量 (0-100)
  /// [preferredCameraDevice] 优先使用的相机（前置/后置）
  /// 
  /// 返回拍摄的图片文件，如果用户取消则返回 null
  static Future<File?> pickFromCamera({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 100,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      // 请求相机权限
      final status = await _requestCameraPermission();
      if (!status) {
        debugPrint('相机权限被拒绝');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('从相机拍照失败: $e');
      return null;
    }
  }

  /// 选择多张图片
  /// 
  /// [maxWidth] 图片最大宽度
  /// [maxHeight] 图片最大高度
  /// [imageQuality] 图片质量 (0-100)
  /// [limit] 最多选择的图片数量
  /// 
  /// 返回选中的图片文件列表
  static Future<List<File>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 100,
    int? limit,
  }) async {
    try {
      // 请求相册权限
      final status = await _requestPhotosPermission();
      if (!status) {
        debugPrint('相册权限被拒绝');
        return [];
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        limit: limit,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('选择多张图片失败: $e');
      return [];
    }
  }

  /// 裁剪图片
  /// 
  /// [file] 要裁剪的图片文件
  /// [aspectRatio] 裁剪比例，默认自由比例
  /// [maxWidth] 裁剪后图片最大宽度
  /// [maxHeight] 裁剪后图片最大高度
  /// [compressQuality] 压缩质量 (0-100)
  /// 
  /// 返回裁剪后的图片文件，如果用户取消则返回 null
  static Future<File?> cropImage(
    File file, {
    CropAspectRatio? aspectRatio,
    int? maxWidth,
    int? maxHeight,
    int compressQuality = 90,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        compressQuality: compressQuality,
        aspectRatio: aspectRatio,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪图片',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: aspectRatio != null,
          ),
          IOSUiSettings(
            title: '裁剪图片',
            aspectRatioLockEnabled: aspectRatio != null,
            resetAspectRatioEnabled: aspectRatio == null,

          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      debugPrint('裁剪图片失败: $e');
      return null;
    }
  }

  /// 压缩图片
  /// 
  /// [file] 要压缩的图片文件
  /// [quality] 压缩质量 (0-100)，默认 85
  /// [minWidth] 压缩后最小宽度
  /// [minHeight] 压缩后最小高度
  /// [format] 压缩格式（jpeg/png/heic/webp）
  /// [keepExif] 是否保留 EXIF 信息
  /// 
  /// 返回压缩后的图片文件
  static Future<File?> compressImage(
    File file, {
    int quality = 85,
    int? minWidth,
    int? minHeight,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    try {
      // 生成压缩后的文件路径
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed${path.extension(file.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth ?? 800,
        minHeight: minHeight ?? 600,
        format: format,
        keepExif: keepExif,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('压缩图片失败: $e');
      return null;
    }
  }

  /// 压缩图片到指定大小以下
  /// 
  /// [file] 要压缩的图片文件
  /// [maxSizeKB] 目标文件大小（KB），默认 500KB
  /// [minQuality] 最低质量阈值，默认 20，防止过度压缩
  /// [format] 压缩格式
  /// 
  /// 返回压缩后的图片文件
  static Future<File?> compressToSize(
    File file, {
    int maxSizeKB = 500,
    int minQuality = 20,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    try {
      int quality = 90;
      File? compressedFile = file;
      int fileSizeKB = await file.length() ~/ 1024;

      // 如果文件已经小于目标大小，直接返回
      if (fileSizeKB <= maxSizeKB) {
        return file;
      }

      // 逐步降低质量直到达到目标大小
      while (quality >= minQuality && fileSizeKB > maxSizeKB) {
        compressedFile = await compressImage(
          file,
          quality: quality,
          format: format,
        );

        if (compressedFile == null) return null;

        fileSizeKB = await compressedFile.length() ~/ 1024;
        quality -= 10;
      }

      return compressedFile;
    } catch (e) {
      debugPrint('压缩图片到指定大小失败: $e');
      return null;
    }
  }

  /// 上传图片
  /// 
  /// [file] 要上传的图片文件
  /// [url] 上传地址
  /// [fileKey] 文件字段名，默认 "file"
  /// [data] 额外的表单数据
  /// [headers] 请求头
  /// [onProgress] 上传进度回调
  /// 
  /// 返回服务器响应数据
  static Future<Response?> uploadImage(
    File file,
    String url, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final fileName = path.basename(file.path);
      
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?data,
      });

      final dio = Dio();
      
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: headers,
        ),
        onSendProgress: onProgress,
      );

      return response;
    } catch (e) {
      debugPrint('上传图片失败: $e');
      return null;
    }
  }

  /// 批量上传图片
  /// 
  /// [files] 要上传的图片文件列表
  /// [url] 上传地址
  /// [fileKey] 文件字段名，默认 "files"
  /// [data] 额外的表单数据
  /// [headers] 请求头
  /// [onProgress] 上传进度回调
  /// 
  /// 返回服务器响应数据
  static Future<Response?> uploadMultipleImages(
    List<File> files,
    String url, {
    String fileKey = 'files',
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final List<MultipartFile> multipartFiles = [];
      
      for (final file in files) {
        final fileName = path.basename(file.path);
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        );
      }

      final formData = FormData.fromMap({
        fileKey: multipartFiles,
        ...?data,
      });

      final dio = Dio();
      
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: headers,
        ),
        onSendProgress: onProgress,
      );

      return response;
    } catch (e) {
      debugPrint('批量上传图片失败: $e');
      return null;
    }
  }

  /// 请求相册权限
  static Future<bool> _requestPhotosPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ 使用新的照片权限
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  /// 请求相机权限
  static Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 获取 Android 版本
  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // 这里简化处理，实际项目中可以使用 device_info_plus 包
      return 33; // 假设为 Android 13+
    }
    return 0;
  }

  /// 选择图片来源（相机或相册）
  /// 
  /// [context] 上下文
  /// 
  /// 返回选择的来源类型，如果用户取消则返回 null
  static Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    final index = await AppOverlay.dialog.selectAsync(
      title: '选择图片来源',
      options: const ['相机', '相册'],
    );
    if (index == 0) return ImageSource.camera;
    if (index == 1) return ImageSource.gallery;
    return null;
  }

  /// 完整的图片处理流程（选择 -> 裁剪 -> 压缩）
  /// 
  /// [source] 图片来源
  /// [needCrop] 是否需要裁剪
  /// [needCompress] 是否需要压缩
  /// [aspectRatio] 裁剪比例
  /// [maxSizeKB] 压缩后的最大文件大小（KB）
  /// 
  /// 返回处理后的图片文件
  static Future<File?> pickAndProcessImage({
    required ImageSource source,
    bool needCrop = true,
    bool needCompress = true,
    CropAspectRatio? aspectRatio,
    int maxSizeKB = 500,
  }) async {
    File? imageFile;

    // 1. 选择图片
    if (source == ImageSource.camera) {
      imageFile = await pickFromCamera();
    } else {
      imageFile = await pickFromGallery();
    }

    if (imageFile == null) return null;

    // 2. 裁剪图片
    if (needCrop) {
      final croppedFile = await cropImage(
        imageFile,
        aspectRatio: aspectRatio,
      );
      if (croppedFile != null) {
        imageFile = croppedFile;
      }
    }

    // 3. 压缩图片
    if (needCompress) {
      final compressedFile = await compressToSize(
        imageFile,
        maxSizeKB: maxSizeKB,
      );
      if (compressedFile != null) {
        imageFile = compressedFile;
      }
    }

    return imageFile;
  }
}

