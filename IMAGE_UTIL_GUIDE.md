# 图片处理工具使用指南

## 概述

`ImageUtil` 是一个功能强大的图片处理工具类，提供了图片选择、裁剪、压缩和上传的完整功能。

## 功能特性

- ✅ 图片选择（相机/相册）
- ✅ 多图选择
- ✅ 图片裁剪（多种比例）
- ✅ 图片压缩（质量/大小）
- ✅ 图片上传（单张/多张）
- ✅ 完整流程（选择→裁剪→压缩→上传）
- ✅ 权限自动处理
- ✅ 进度回调支持

## 依赖包

```yaml
dependencies:
  # 图片选择
  image_picker: ^1.0.7
  # 图片裁剪
  image_cropper: ^5.0.1
  # 图片压缩
  flutter_image_compress: ^2.1.0
  # 权限处理
  permission_handler: ^11.2.0
  # 路径操作
  path_provider: ^2.1.2
  path: ^1.9.0
```

## Android 配置

### 1. 权限配置

在 `android/app/src/main/AndroidManifest.xml` 中添加权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 相机权限 -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- 存储权限 (Android 12 及以下) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- 照片权限 (Android 13+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <application>
        <!-- ... -->
        
        <!-- 文件提供者配置 (用于相机拍照) -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
    </application>
</manifest>
```

### 2. 创建文件路径配置

创建 `android/app/src/main/res/xml/file_paths.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-files-path name="my_images" path="Pictures" />
    <cache-path name="my_cache" path="." />
    <external-path name="external_files" path="." />
</paths>
```

### 3. ProGuard 配置（如果使用混淆）

在 `android/app/proguard-rules.pro` 中添加：

```proguard
# Image Cropper
-keep class androidx.appcompat.widget.** { *; }
-keep class androidx.appcompat.app.AppCompatDelegate { *; }
```

## iOS 配置

### 1. 权限配置

在 `ios/Runner/Info.plist` 中添加权限描述：

```xml
<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择图片</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存图片到相册</string>
```

### 2. 最低部署版本

确保 `ios/Podfile` 中的最低版本为 iOS 11.0：

```ruby
platform :ios, '11.0'
```

## 基础用法

### 1. 从相册选择图片

```dart
import 'package:flutter_frame/utils/image_util.dart';

// 选择单张图片
final file = await ImageUtil.pickFromGallery();
if (file != null) {
  print('图片路径: ${file.path}');
}

// 选择多张图片
final files = await ImageUtil.pickMultipleImages(limit: 9);
print('选择了 ${files.length} 张图片');
```

### 2. 从相机拍照

```dart
final file = await ImageUtil.pickFromCamera();
if (file != null) {
  print('拍摄成功: ${file.path}');
}
```

### 3. 显示选择来源对话框

```dart
final source = await ImageUtil.showImageSourceDialog(context);
if (source != null) {
  if (source == ImageSource.camera) {
    final file = await ImageUtil.pickFromCamera();
  } else {
    final file = await ImageUtil.pickFromGallery();
  }
}
```

## 图片裁剪

### 1. 自由裁剪

```dart
final croppedFile = await ImageUtil.cropImage(originalFile);
```

### 2. 按比例裁剪

```dart
// 1:1 正方形
final croppedFile = await ImageUtil.cropImage(
  originalFile,
  aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
);

// 16:9
final croppedFile = await ImageUtil.cropImage(
  originalFile,
  aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
);

// 4:3
final croppedFile = await ImageUtil.cropImage(
  originalFile,
  aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3),
);
```

### 3. 圆形裁剪

```dart
final croppedFile = await ImageUtil.cropImage(
  originalFile,
  cropStyle: CropStyle.circle,
  aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
);
```

## 图片压缩

### 1. 按质量压缩

```dart
// 标准压缩（质量85%）
final compressedFile = await ImageUtil.compressImage(
  originalFile,
  quality: 85,
);

// 高度压缩（质量60%）
final compressedFile = await ImageUtil.compressImage(
  originalFile,
  quality: 60,
);
```

### 2. 按大小压缩

```dart
// 压缩到 500KB 以下
final compressedFile = await ImageUtil.compressToSize(
  originalFile,
  maxSizeKB: 500,
);

// 压缩到 200KB 以下
final compressedFile = await ImageUtil.compressToSize(
  originalFile,
  maxSizeKB: 200,
  minQuality: 20, // 最低质量阈值
);
```

### 3. 自定义压缩参数

```dart
final compressedFile = await ImageUtil.compressImage(
  originalFile,
  quality: 85,
  minWidth: 1080,
  minHeight: 1920,
  format: CompressFormat.jpeg,
  keepExif: false, // 是否保留 EXIF 信息
);
```

## 图片上传

### 1. 上传单张图片

```dart
final response = await ImageUtil.uploadImage(
  imageFile,
  'https://your-api.com/upload',
  fileKey: 'file',
  data: {
    'userId': '123',
    'category': 'avatar',
  },
  headers: {
    'Authorization': 'Bearer token',
  },
  onProgress: (sent, total) {
    final progress = sent / total * 100;
    print('上传进度: ${progress.toStringAsFixed(1)}%');
  },
);

if (response != null && response.statusCode == 200) {
  print('上传成功: ${response.data}');
}
```

### 2. 批量上传图片

```dart
final response = await ImageUtil.uploadMultipleImages(
  imageFiles,
  'https://your-api.com/upload-batch',
  fileKey: 'files',
  data: {
    'albumId': '456',
  },
  onProgress: (sent, total) {
    print('上传进度: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

## 完整流程

### 一键完成选择→裁剪→压缩

```dart
// 从相册选择，自动裁剪和压缩
final processedFile = await ImageUtil.pickAndProcessImage(
  source: ImageSource.gallery,
  needCrop: true,
  needCompress: true,
  aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
  maxSizeKB: 500,
);

if (processedFile != null) {
  // 处理完成的图片
  print('处理完成: ${processedFile.path}');
  
  // 上传
  final response = await ImageUtil.uploadImage(
    processedFile,
    'https://your-api.com/upload',
  );
}
```

## 高级用法

### 1. 带进度的完整流程

```dart
class ImageUploadController extends GetxController {
  final isProcessing = false.obs;
  final progress = 0.0.obs;
  final currentStep = ''.obs;
  
  Future<void> uploadAvatar() async {
    isProcessing.value = true;
    
    try {
      // 1. 选择图片
      currentStep.value = '选择图片...';
      final file = await ImageUtil.pickFromGallery();
      if (file == null) return;
      
      // 2. 裁剪图片
      currentStep.value = '裁剪图片...';
      progress.value = 0.3;
      final croppedFile = await ImageUtil.cropImage(
        file,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.circle,
      );
      if (croppedFile == null) return;
      
      // 3. 压缩图片
      currentStep.value = '压缩图片...';
      progress.value = 0.6;
      final compressedFile = await ImageUtil.compressToSize(
        croppedFile,
        maxSizeKB: 500,
      );
      if (compressedFile == null) return;
      
      // 4. 上传图片
      currentStep.value = '上传中...';
      final response = await ImageUtil.uploadImage(
        compressedFile,
        'https://your-api.com/avatar',
        onProgress: (sent, total) {
          progress.value = 0.6 + (sent / total * 0.4);
        },
      );
      
      if (response?.statusCode == 200) {
        Get.snackbar('成功', '头像上传成功');
      }
    } finally {
      isProcessing.value = false;
      progress.value = 0.0;
      currentStep.value = '';
    }
  }
}
```

### 2. 批量图片处理

```dart
Future<List<File>> processBatchImages(List<File> files) async {
  final processedFiles = <File>[];
  
  for (var i = 0; i < files.length; i++) {
    final file = files[i];
    
    // 压缩每张图片
    final compressed = await ImageUtil.compressToSize(
      file,
      maxSizeKB: 500,
    );
    
    if (compressed != null) {
      processedFiles.add(compressed);
    }
    
    // 更新进度
    final progress = (i + 1) / files.length * 100;
    print('处理进度: ${progress.toStringAsFixed(1)}%');
  }
  
  return processedFiles;
}
```

### 3. 自定义裁剪UI

```dart
final croppedFile = await ImageUtil.cropImage(
  originalFile,
  aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
  maxWidth: 1920,
  maxHeight: 1080,
  compressQuality: 90,
  cropStyle: CropStyle.rectangle,
);
```

## 实用示例

### 示例1: 用户头像上传

```dart
Future<void> uploadUserAvatar() async {
  // 完整流程：选择 -> 圆形裁剪 -> 压缩 -> 上传
  final file = await ImageUtil.pickAndProcessImage(
    source: ImageSource.gallery,
    needCrop: true,
    needCompress: true,
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    maxSizeKB: 200,
  );
  
  if (file != null) {
    final response = await ImageUtil.uploadImage(
      file,
      'https://api.example.com/user/avatar',
      data: {'userId': getUserId()},
    );
    
    if (response?.statusCode == 200) {
      print('头像上传成功');
    }
  }
}
```

### 示例2: 商品图片上传（多图）

```dart
Future<void> uploadProductImages() async {
  // 选择多张图片
  final files = await ImageUtil.pickMultipleImages(limit: 9);
  
  if (files.isEmpty) return;
  
  // 压缩所有图片
  final compressedFiles = <File>[];
  for (final file in files) {
    final compressed = await ImageUtil.compressToSize(file, maxSizeKB: 500);
    if (compressed != null) {
      compressedFiles.add(compressed);
    }
  }
  
  // 批量上传
  final response = await ImageUtil.uploadMultipleImages(
    compressedFiles,
    'https://api.example.com/product/images',
    data: {'productId': getProductId()},
  );
  
  if (response?.statusCode == 200) {
    print('商品图片上传成功');
  }
}
```

### 示例3: 相机拍照并上传

```dart
Future<void> takePhotoAndUpload() async {
  // 拍照
  final photo = await ImageUtil.pickFromCamera(
    imageQuality: 90,
    preferredCameraDevice: CameraDevice.rear,
  );
  
  if (photo == null) return;
  
  // 压缩
  final compressed = await ImageUtil.compressToSize(
    photo,
    maxSizeKB: 500,
  );
  
  if (compressed == null) return;
  
  // 上传
  final response = await ImageUtil.uploadImage(
    compressed,
    'https://api.example.com/photo',
  );
  
  if (response?.statusCode == 200) {
    print('照片上传成功');
  }
}
```

## 错误处理

### 1. 权限被拒绝

```dart
final file = await ImageUtil.pickFromGallery();
if (file == null) {
  // 用户取消或权限被拒绝
  Get.snackbar('提示', '无法访问相册，请检查权限设置');
}
```

### 2. 上传失败

```dart
try {
  final response = await ImageUtil.uploadImage(file, url);
  if (response == null) {
    Get.snackbar('错误', '上传失败');
  } else if (response.statusCode != 200) {
    Get.snackbar('错误', '服务器错误: ${response.statusCode}');
  }
} catch (e) {
  Get.snackbar('错误', '上传异常: $e');
}
```

### 3. 文件过大提示

```dart
final fileSize = await file.length();
if (fileSize > 10 * 1024 * 1024) { // 10MB
  Get.snackbar('提示', '文件过大，请选择小于10MB的图片');
  return;
}

// 自动压缩
final compressed = await ImageUtil.compressToSize(file, maxSizeKB: 500);
```

## 性能优化建议

1. **压缩优先级**: 先压缩再上传，减少网络传输时间
2. **批量处理**: 使用并发处理多张图片，但要控制并发数量
3. **缓存清理**: 定期清理临时文件，避免占用过多存储空间
4. **质量平衡**: 根据使用场景选择合适的压缩质量（头像200KB，商品图500KB）
5. **EXIF处理**: 上传前移除EXIF信息可减小文件大小

## 注意事项

1. ⚠️ 务必在AndroidManifest.xml和Info.plist中配置权限
2. ⚠️ Android 13+ 需要使用新的照片权限 READ_MEDIA_IMAGES
3. ⚠️ 相机拍照需要配置 FileProvider
4. ⚠️ 压缩会创建临时文件，建议定期清理
5. ⚠️ 上传大文件时注意设置合理的超时时间
6. ⚠️ 裁剪功能在模拟器上可能不稳定，建议真机测试

## 常见问题

### Q1: Android 相机拍照后无响应？

A: 确保已配置 FileProvider，并在 AndroidManifest.xml 中正确设置。

### Q2: iOS 相册选择崩溃？

A: 检查 Info.plist 中是否添加了 NSPhotoLibraryUsageDescription。

### Q3: 压缩后图片质量太差？

A: 适当提高 quality 参数或增大 maxSizeKB 限制。

### Q4: 裁剪功能不显示？

A: 确保已正确添加 image_cropper 依赖并配置了对应平台的权限。

### Q5: 上传进度回调不工作？

A: 检查网络请求是否正确，某些服务器可能不支持上传进度。

## 演示页面

运行项目后，在主页选择「图片处理工具演示」即可查看完整的功能演示。

演示页面包含：
- 图片选择（单张/多张/相机/相册）
- 图片裁剪（自由/正方形/4:3/16:9）
- 图片压缩（标准/高度/指定大小）
- 图片上传（模拟上传进度）
- 完整流程（一键完成所有步骤）

## 相关文档

- [image_picker 官方文档](https://pub.dev/packages/image_picker)
- [image_cropper 官方文档](https://pub.dev/packages/image_cropper)
- [flutter_image_compress 官方文档](https://pub.dev/packages/flutter_image_compress)
- [permission_handler 官方文档](https://pub.dev/packages/permission_handler)

## 更新日志

### v1.0.0 (2024-10-22)

- ✅ 初始版本发布
- ✅ 支持图片选择（相机/相册/多选）
- ✅ 支持图片裁剪（多种比例）
- ✅ 支持图片压缩（质量/大小）
- ✅ 支持图片上传（单张/批量）
- ✅ 支持完整流程处理
- ✅ 自动处理权限请求

