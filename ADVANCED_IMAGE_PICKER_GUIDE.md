# 高级图片选择与裁剪使用指南

## 概述

高级图片选择与裁剪功能基于 `wechat_assets_picker` + `extended_image` 实现，提供了完整的相册目录、多选、预览、高级裁剪体验，完美复刻了您图片中的交互效果。

## 功能特性

- ✅ **相册目录浏览**：原生相册目录，支持多相册切换
- ✅ **多选图片**：支持最多 9 张图片选择，带序号标识
- ✅ **实时预览**：选中图片实时预览，支持切换查看
- ✅ **拍照功能**：直接调用相机拍照
- ✅ **高级裁剪**：支持多种比例（1:1、3:4、4:3、3:2、16:9）
- ✅ **圆形裁剪**：支持圆形裁剪遮罩
- ✅ **自由裁剪**：无比例限制的自由裁剪
- ✅ **压缩上传**：集成现有 ImageUtil 压缩和上传功能
- ✅ **进度显示**：实时显示处理进度

## 依赖包

```yaml
dependencies:
  # 微信图片选择
  wechat_assets_picker: ^9.8.0
  # 微信相机选择
  wechat_camera_picker: ^4.4.0
  # 图片扩展（裁剪）
  extended_image: ^10.0.1
  # 相册管理
  photo_manager: ^3.7.1
  # 现有工具
  image_picker: ^1.2.0
  image_cropper: ^11.0.0
  flutter_image_compress: ^2.4.0
  permission_handler: ^12.0.1
```

## 页面结构

```
lib/pages/
├── advanced_picker/
│   ├── advanced_picker_view.dart      # 选择页面
│   ├── advanced_picker_controller.dart # 选择控制器
│   └── advanced_picker_binding.dart   # 选择绑定
├── advanced_crop/
│   ├── advanced_crop_view.dart        # 裁剪页面
│   ├── advanced_crop_controller.dart # 裁剪控制器
│   └── advanced_crop_binding.dart     # 裁剪绑定
├── advanced_picker_page.dart         # 导出文件
└── advanced_crop_page.dart           # 导出文件
```

## 快速开始

### 1. 进入高级图片选择页面

```dart
// 从主页点击「🎨 高级图片选择与裁剪」进入
Get.toNamed(Routes.ADVANCED_PICKER);
```

### 2. 选择图片

页面提供两种选择方式：
- **选择图片**：打开相册目录，支持多选
- **拍照**：直接调用相机拍照

### 3. 预览和管理

- 选中图片会显示在网格中，带序号标识
- 点击图片可预览大图
- 支持删除单张图片
- 支持进入裁剪页面

### 4. 高级裁剪

点击图片上的裁剪按钮进入裁剪页面：
- **比例选择**：1:1、3:4、4:3、3:2、16:9、自由
- **圆形裁剪**：切换圆形裁剪模式
- **手势操作**：缩放、旋转、拖拽
- **保存/上传**：完成裁剪后保存或直接上传

## 核心功能详解

### 1. 相册目录浏览

```dart
// 在 AdvancedPickerController 中
Future<void> pickAssets() async {
  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    Get.context!,
    pickerConfig: AssetPickerConfig(
      maxAssets: maxAssets,           // 最大选择数量
      selectedAssets: selectedAssets, // 已选中的资源
      requestType: RequestType.image, // 只选择图片
      specialPickerType: SpecialPickerType.noPreview,
      textDelegate: const AssetPickerTextDelegate(),
    ),
  );
}
```

### 2. 多选图片管理

```dart
// 添加图片到选择列表
selectedAssets.value = result;

// 预览单张图片
void previewAsset(AssetEntity asset) {
  currentAsset.value = asset;
}

// 删除选中的图片
void removeAsset(AssetEntity asset) {
  selectedAssets.remove(asset);
}
```

### 3. 拍照功能

```dart
Future<void> takePhoto() async {
  final AssetEntity? result = await CameraPicker.pickFromCamera(
    Get.context!,
    pickerConfig: CameraPickerConfig(
      enableRecording: false,
      onlyEnableRecording: false,
    ),
  );
}
```

### 4. 高级裁剪

```dart
// 裁剪比例定义
class CropAspectRatio {
  final double ratioX;
  final double ratioY;
  
  const CropAspectRatio({
    required this.ratioX,
    required this.ratioY,
  });
}

// 预设比例
final List<CropAspectRatio> aspectRatios = const [
  CropAspectRatio(ratioX: 1, ratioY: 1),   // 1:1
  CropAspectRatio(ratioX: 3, ratioY: 4),   // 3:4
  CropAspectRatio(ratioX: 4, ratioY: 3),   // 4:3
  CropAspectRatio(ratioX: 3, ratioY: 2),   // 3:2
  CropAspectRatio(ratioX: 16, ratioY: 9), // 16:9
];
```

### 5. 压缩和上传

```dart
// 批量处理选中的图片
Future<void> processSelectedAssets() async {
  final List<File> files = [];
  
  // 获取所有图片文件
  for (final asset in selectedAssets) {
    final file = await asset.file;
    if (file != null) files.add(file);
  }

  // 压缩所有图片
  final List<File> compressedFiles = [];
  for (final file in files) {
    final compressed = await ImageUtil.compressToSize(
      file,
      maxSizeKB: 500,
    );
    if (compressed != null) {
      compressedFiles.add(compressed);
    }
  }
}
```

## 权限配置

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

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
        <!-- FileProvider 配置 -->
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

### iOS 配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄照片</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择图片</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存图片到相册</string>
```

## 使用示例

### 示例1：完整流程

```dart
// 1. 进入选择页面
Get.toNamed(Routes.ADVANCED_PICKER);

// 2. 用户选择图片（最多9张）
// 3. 用户点击裁剪按钮进入裁剪页面
Get.toNamed(Routes.ADVANCED_CROP, arguments: {
  'asset': selectedAsset,
  'selectedAssets': selectedAssets,
});

// 4. 用户完成裁剪，返回结果
final croppedFile = await Get.toNamed(Routes.ADVANCED_CROP);
if (croppedFile != null) {
  // 处理裁剪后的图片
  print('裁剪完成: ${croppedFile.path}');
}
```

### 示例2：批量处理

```dart
class MyController extends GetxController {
  final selectedFiles = <File>[].obs;
  
  Future<void> processImages() async {
    // 获取选中的图片
    for (final asset in selectedAssets) {
      final file = await asset.file;
      if (file != null) {
        selectedFiles.add(file);
      }
    }
    
    // 批量压缩
    final compressedFiles = <File>[];
    for (final file in selectedFiles) {
      final compressed = await ImageUtil.compressToSize(
        file,
        maxSizeKB: 500,
      );
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }
    
    // 批量上传
    final response = await ImageUtil.uploadMultipleImages(
      compressedFiles,
      'https://api.example.com/upload-batch',
    );
  }
}
```

### 示例3：自定义裁剪比例

```dart
// 在 AdvancedCropController 中添加自定义比例
void addCustomRatio(double ratioX, double ratioY) {
  final customRatio = CropAspectRatio(ratioX: ratioX, ratioY: ratioY);
  aspectRatios.add(customRatio);
  ratioNames.add('${ratioX.toInt()}:${ratioY.toInt()}');
}
```

## 界面效果

### 选择页面
- **顶部预览区**：显示当前选中的图片
- **选择按钮**：相册选择 + 拍照按钮
- **图片网格**：3列网格显示选中的图片，带序号和操作按钮
- **底部操作栏**：批量处理和上传按钮

### 裁剪页面
- **裁剪区域**：黑色背景的裁剪区域
- **比例选择器**：水平滚动的比例按钮
- **圆形裁剪**：圆形裁剪切换按钮
- **底部操作栏**：保存和上传按钮

## 高级功能

### 1. 圆形裁剪

```dart
// 切换圆形裁剪模式
void toggleCircularCrop() {
  isCircularCrop.value = !isCircularCrop.value;
  if (isCircularCrop.value) {
    currentRatio.value = const CropAspectRatio(ratioX: 1, ratioY: 1);
  }
}
```

### 2. 进度显示

```dart
// 显示处理进度
Obx(() {
  if (controller.isProcessing.value) {
    return LinearProgressIndicator(
      value: controller.uploadProgress.value,
    );
  }
  return const SizedBox.shrink();
})
```

### 3. 手势操作

```dart
// 在裁剪页面支持的手势
- 双指缩放
- 单指拖拽
- 旋转手势
- 裁剪框调整
```

## 注意事项

1. **权限处理**：首次使用会自动请求相机和相册权限
2. **文件大小**：建议设置合理的压缩参数，避免文件过大
3. **内存管理**：处理大量图片时注意内存使用
4. **网络上传**：上传功能需要配置真实的API地址
5. **平台差异**：iOS和Android的权限配置略有不同

## 常见问题

### Q1: 相册权限被拒绝怎么办？

A: 引导用户到设置中手动开启权限：
```dart
if (!ps.isAuth) {
  Get.snackbar('提示', '需要相册权限才能选择图片');
  // 可以引导用户到设置页面
}
```

### Q2: 裁剪功能不显示？

A: 确保已正确配置 extended_image 依赖，并检查图片路径是否正确。

### Q3: 上传失败？

A: 检查网络连接和API地址配置，确保服务器支持文件上传。

### Q4: 图片质量太差？

A: 调整压缩参数，提高质量阈值或增大文件大小限制。

## 演示页面

运行项目后，在主页选择「🎨 高级图片选择与裁剪」即可体验完整功能：

1. **选择图片**：点击"选择图片"按钮，体验相册目录和多选功能
2. **拍照功能**：点击"拍照"按钮，体验相机拍照
3. **预览管理**：在网格中预览选中的图片，支持删除和裁剪
4. **高级裁剪**：点击裁剪按钮，体验多种比例和圆形裁剪
5. **批量处理**：使用底部操作栏进行批量压缩和上传

## 相关文档

- [IMAGE_UTIL_GUIDE.md](./IMAGE_UTIL_GUIDE.md) - 基础图片处理工具
- [IMAGE_UTIL_CONFIG.md](./IMAGE_UTIL_CONFIG.md) - 配置指南
- [wechat_assets_picker 官方文档](https://pub.dev/packages/wechat_assets_picker)
- [extended_image 官方文档](https://pub.dev/packages/extended_image)

## 更新日志

### v1.0.0 (2024-10-22)

- ✅ 初始版本发布
- ✅ 相册目录浏览和多选功能
- ✅ 拍照功能集成
- ✅ 高级裁剪（多比例、圆形）
- ✅ 压缩上传流程集成
- ✅ 进度显示和用户体验优化
