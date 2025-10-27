# 图片处理工具配置指南

本文档提供了图片处理工具在 Android 和 iOS 平台上的详细配置步骤。

## Android 配置

### 1. 权限配置

编辑 `android/app/src/main/AndroidManifest.xml`：

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
    
    <application
        android:label="flutter_frame"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- ... 其他配置 ... -->
        
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

创建文件：`android/app/src/main/res/xml/file_paths.xml`

如果 `xml` 目录不存在，需要先创建它：

```bash
mkdir -p android/app/src/main/res/xml
```

然后创建 `file_paths.xml` 文件：

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-files-path name="my_images" path="Pictures" />
    <cache-path name="my_cache" path="." />
    <external-path name="external_files" path="." />
</paths>
```

### 3. 配置 Gradle（可选）

如果遇到编译问题，可能需要在 `android/app/build.gradle.kts` 中添加：

```kotlin
android {
    // ... 其他配置 ...
    
    defaultConfig {
        // ... 其他配置 ...
        minSdk = 21  // 确保最小 SDK 版本
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}
```

### 4. ProGuard 配置（如果使用混淆）

在 `android/app/proguard-rules.pro` 中添加：

```proguard
# Image Cropper
-keep class androidx.appcompat.widget.** { *; }
-keep class androidx.appcompat.app.AppCompatDelegate { *; }

# Image Picker
-keep class androidx.lifecycle.** { *; }
```

## iOS 配置

### 1. 权限描述配置

编辑 `ios/Runner/Info.plist`，在 `<dict>` 标签内添加：

```xml
<!-- 相机权限描述 -->
<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄照片</string>

<!-- 相册读取权限描述 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择图片</string>

<!-- 相册添加权限描述 (iOS 11+) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存图片到相册</string>
```

### 2. 最低部署版本

编辑 `ios/Podfile`，确保最低版本为 iOS 11.0：

```ruby
platform :ios, '11.0'

# 如果遇到编译问题，可以添加以下配置
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
```

### 3. 相机控制器配置（可选）

如果需要自定义相机界面，可以在 `ios/Runner/Info.plist` 中添加：

```xml
<!-- 允许使用相机控制器 -->
<key>UIViewControllerBasedStatusBarAppearance</key>
<false/>
```

## 快速配置脚本

### Android 快速配置

在项目根目录创建并运行以下脚本：

```bash
#!/bin/bash

# 创建 xml 目录
mkdir -p android/app/src/main/res/xml

# 创建 file_paths.xml
cat > android/app/src/main/res/xml/file_paths.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-files-path name="my_images" path="Pictures" />
    <cache-path name="my_cache" path="." />
    <external-path name="external_files" path="." />
</paths>
EOF

echo "Android 配置完成！"
echo "请手动编辑 android/app/src/main/AndroidManifest.xml 添加权限配置"
```

### iOS 快速配置

在项目根目录创建并运行以下脚本：

```bash
#!/bin/bash

# 备份 Info.plist
cp ios/Runner/Info.plist ios/Runner/Info.plist.backup

# 提示手动编辑
echo "请手动编辑 ios/Runner/Info.plist 添加权限描述"
echo "备份文件已保存至 ios/Runner/Info.plist.backup"
```

## 验证配置

### 验证 Android 配置

1. 检查 AndroidManifest.xml 是否包含所需权限
2. 检查 file_paths.xml 是否存在
3. 运行应用并测试拍照功能

```bash
flutter run
```

### 验证 iOS 配置

1. 检查 Info.plist 是否包含权限描述
2. 检查 Podfile 中的最低版本设置
3. 清理并重新构建

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

## 常见问题

### Android

#### Q1: 提示 "FileProvider not found"

**解决方案**: 确保在 AndroidManifest.xml 中正确配置了 FileProvider，并创建了 file_paths.xml。

#### Q2: Android 13+ 无法访问相册

**解决方案**: 确保添加了 `READ_MEDIA_IMAGES` 权限。

#### Q3: 拍照后应用崩溃

**解决方案**: 检查 file_paths.xml 配置，确保路径正确。

### iOS

#### Q4: 提示 "This app has crashed because it attempted to access privacy-sensitive data"

**解决方案**: 在 Info.plist 中添加对应的权限描述。

#### Q5: 相机或相册无法打开

**解决方案**: 
1. 检查 Info.plist 权限描述是否正确
2. 在设置中手动授予权限
3. 卸载应用重新安装

#### Q6: 真机调试时裁剪功能不工作

**解决方案**: 
1. 确保 iOS 版本 >= 11.0
2. 清理并重新 pod install
3. 检查是否有编译警告

## 测试清单

配置完成后，请按照以下清单测试功能：

### Android

- [ ] 从相册选择单张图片
- [ ] 从相册选择多张图片
- [ ] 使用相机拍照
- [ ] 裁剪图片（各种比例）
- [ ] 压缩图片
- [ ] 完整流程测试

### iOS

- [ ] 从相册选择单张图片
- [ ] 从相册选择多张图片
- [ ] 使用相机拍照
- [ ] 裁剪图片（各种比例）
- [ ] 压缩图片
- [ ] 完整流程测试

## 其他注意事项

1. **权限请求时机**: 首次使用功能时会自动请求权限
2. **权限被拒绝**: 如果用户拒绝权限，需要引导用户到设置中手动开启
3. **临时文件**: 压缩和裁剪会创建临时文件，建议定期清理
4. **模拟器限制**: 某些功能在模拟器上可能不可用，建议使用真机测试
5. **版本兼容**: 注意不同 Android/iOS 版本的权限差异

## 权限引导示例

当用户拒绝权限后，可以使用以下代码引导用户到设置：

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestPermission() async {
  final status = await Permission.camera.status;
  
  if (status.isDenied) {
    // 请求权限
    final result = await Permission.camera.request();
    
    if (result.isDenied) {
      // 用户拒绝了权限
      Get.dialog(
        AlertDialog(
          title: Text('需要相机权限'),
          content: Text('请在设置中开启相机权限'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings(); // 打开应用设置
                Get.back();
              },
              child: Text('去设置'),
            ),
          ],
        ),
      );
    }
  } else if (status.isPermanentlyDenied) {
    // 用户永久拒绝了权限
    Get.dialog(
      AlertDialog(
        title: Text('需要相机权限'),
        content: Text('请在设置中手动开启相机权限'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Get.back();
            },
            child: Text('去设置'),
          ),
        ],
      ),
    );
  }
}
```

## 更新配置

如果更新了依赖版本，可能需要重新配置：

```bash
# 清理旧配置
flutter clean

# 获取最新依赖
flutter pub get

# Android
cd android
./gradlew clean
cd ..

# iOS
cd ios
pod deintegrate
pod install
cd ..

# 重新运行
flutter run
```

## 获取帮助

如果遇到问题，可以：

1. 查看 [IMAGE_UTIL_GUIDE.md](./IMAGE_UTIL_GUIDE.md) 使用指南
2. 查看官方文档：
   - [image_picker](https://pub.dev/packages/image_picker)
   - [image_cropper](https://pub.dev/packages/image_cropper)
   - [permission_handler](https://pub.dev/packages/permission_handler)
3. 查看演示页面的实现代码
4. 提交 Issue 或寻求社区帮助

