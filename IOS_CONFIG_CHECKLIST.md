# iOS 配置检查清单

## ✅ 已配置项

### 1. Info.plist 权限描述
所有需要的权限描述已配置：
- ✅ `NSCameraUsageDescription` - 相机权限
- ✅ `NSPhotoLibraryUsageDescription` - 相册读取权限
- ✅ `NSPhotoLibraryAddUsageDescription` - 相册添加权限
- ✅ `NSLocationWhenInUseUsageDescription` - 位置权限（使用时）
- ✅ `NSLocationAlwaysUsageDescription` - 位置权限（始终）
- ✅ `NSUserNotificationsUsageDescription` - 通知权限
- ✅ `NSMicrophoneUsageDescription` - 麦克风权限
- ✅ `NSContactsUsageDescription` - 联系人权限
- ✅ `NSCalendarsUsageDescription` - 日历权限

### 2. Podfile 配置
- ✅ `platform :ios, '12.0'` - iOS 最低版本已设置
- ✅ `use_frameworks!` - 使用动态框架
- ✅ `flutter_install_all_ios_pods` - Flutter 插件自动安装
- ✅ `post_install` 中统一设置 `IPHONEOS_DEPLOYMENT_TARGET = '12.0'`
- ✅ **重要**：添加了 `GCC_PREPROCESSOR_DEFINITIONS` 权限宏定义（必需配置）

### 3. AppDelegate.swift
- ✅ 标准的 Flutter AppDelegate 配置
- ✅ `GeneratedPluginRegistrant.register` 已调用

## ✅ 必需配置（已添加）

### 1. 权限预处理器定义（必需）
**重要**：对于 `permission_handler`，需要在 Podfile 的 `post_install` 中添加 `GCC_PREPROCESSOR_DEFINITIONS`，以启用权限功能。

**关键点**：
1. 使用 `installer.generated_projects.each` 而不是 `installer.pods_project.targets.each`，这样可以同时配置 Flutter 项目和 Pod 项目
2. 必须添加所有需要的权限宏定义

**当前配置**：
```ruby
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
                     '$(inherited)',
                     'PERMISSION_CAMERA=1',
                     'PERMISSION_PHOTOS=1',
                     'PERMISSION_LOCATION=1',
                     'PERMISSION_NOTIFICATIONS=1',
                     'PERMISSION_MICROPHONE=1',
                     'PERMISSION_CONTACTS=1',
                     'PERMISSION_EVENTS=1',
               ]
            end
        end
    end
    installer.pods_project.targets.each do |target|
        flutter_additional_ios_build_settings(target)
    end
end
```

**权限宏定义说明**：
- `PERMISSION_CAMERA=1` - 相机权限
- `PERMISSION_PHOTOS=1` - 相册权限
- `PERMISSION_LOCATION=1` - 位置权限
- `PERMISSION_NOTIFICATIONS=1` - 通知权限
- `PERMISSION_MICROPHONE=1` - 麦克风权限
- `PERMISSION_CONTACTS=1` - 联系人权限
- `PERMISSION_EVENTS=1` - 日历/事件权限

**为什么需要这个配置**：
这些预处理器定义告诉 `permission_handler` 插件在编译时启用哪些权限功能。如果没有这些定义，插件可能无法正确请求权限，导致权限请求直接返回 `permanentlyDenied` 而不弹出系统对话框。

### 2. 通知权限特殊处理（如果使用推送通知）
如果使用推送通知，可能需要在 `AppDelegate.swift` 中添加：
```swift
import UserNotifications

override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
  GeneratedPluginRegistrant.register(with: self)
  
  // 可选：配置通知权限（如果使用推送通知）
  // UNUserNotificationCenter.current().delegate = self
  
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

### 3. 其他权限描述（如果使用）
如果使用以下功能，需要添加对应的权限描述：
- `NSRemindersUsageDescription` - 提醒事项权限（如果使用）
- `NSBluetoothAlwaysUsageDescription` - 蓝牙权限（如果使用）
- `NSBluetoothPeripheralUsageDescription` - 蓝牙外设权限（如果使用）
- `NSSpeechRecognitionUsageDescription` - 语音识别权限（如果使用）
- `NSFaceIDUsageDescription` - Face ID 权限（如果使用）

## 📋 配置验证步骤

1. **检查 Info.plist**
   ```bash
   # 确认所有权限描述都已添加
   cat ios/Runner/Info.plist | grep -E "NS.*UsageDescription"
   ```

2. **检查 Podfile**
   ```bash
   # 确认平台版本和部署目标已设置
   cat ios/Podfile | grep -E "platform|IPHONEOS_DEPLOYMENT_TARGET"
   ```

3. **重新安装依赖**
   ```bash
   cd ios
   pod deintegrate  # 可选：清理旧的 Pod 配置
   pod install
   cd ..
   ```

4. **清理并重新构建**
   ```bash
   flutter clean
   flutter pub get
   flutter build ios --no-codesign  # 测试构建
   ```

## 🔍 常见问题排查

### 问题1：权限请求直接返回 permanentlyDenied
**原因**：权限之前被拒绝过，iOS 系统不再弹出对话框
**解决**：引导用户到设置页面手动开启权限（代码已实现）

### 问题2：权限请求没有弹出系统对话框
**原因**：
1. Info.plist 中缺少对应的权限描述
2. 权限之前被拒绝过
3. 应用被卸载后重新安装，但系统保留了权限状态

**解决**：
1. 检查 Info.plist 是否包含所有需要的权限描述
2. 在 iOS 设置中重置应用权限
3. 卸载并重新安装应用

### 问题3：编译错误
**原因**：Pod 依赖版本不一致
**解决**：
1. 确保 Podfile 中统一设置了 `IPHONEOS_DEPLOYMENT_TARGET`
2. 运行 `pod update` 更新依赖
3. 清理 Xcode 构建缓存

## 📝 当前配置总结

✅ **所有必需的配置都已正确设置**
- Info.plist 权限描述完整
- Podfile 配置正确（包括权限预处理器定义）
- AppDelegate.swift 配置标准

**关键配置要点**：
1. **Info.plist**：必须包含所有需要的权限描述键值对
2. **Podfile**：必须添加 `GCC_PREPROCESSOR_DEFINITIONS` 权限宏定义
3. **部署目标**：统一设置 `IPHONEOS_DEPLOYMENT_TARGET = '12.0'`

## 🎯 重要提示

### 为什么需要权限预处理器定义？

`permission_handler` 插件在编译时需要知道要启用哪些权限功能。通过 `GCC_PREPROCESSOR_DEFINITIONS` 定义的宏，插件会在编译时包含对应的权限处理代码。

**如果没有这些定义**：
- 权限请求可能直接返回 `permanentlyDenied`
- 系统不会弹出权限请求对话框
- 权限功能无法正常工作

**配置后的效果**：
- 权限请求会正常弹出系统对话框
- 用户可以正常授予或拒绝权限
- 权限状态检查正常工作

### 测试建议

配置完成后，需要：
1. 运行 `cd ios && pod install` 重新安装依赖
2. 清理并重新构建项目：`flutter clean && flutter pub get`
3. 在真机上测试权限请求功能

如果权限之前被拒绝过，可以：
1. 在 iOS 设置中重置应用的权限（关闭后再开启）
2. 或者卸载并重新安装应用
