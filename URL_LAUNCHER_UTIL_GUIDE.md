# 🚀 URL跳转工具类使用指南

## 📋 概述

基于`url_launcher`插件创建的URL跳转工具类，支持各种跳转处理，包括网页跳转、电话拨打、邮件发送、地图打开、应用跳转等。

## 🎯 功能特点

### 1. 基础URL跳转
- ✅ **网页跳转** - 支持外部浏览器和应用内浏览器
- ✅ **自动检测** - 自动检测URL类型和跳转方式
- ✅ **多种模式** - 支持平台默认、外部应用、应用内浏览器等模式

### 2. 电话相关跳转
- ✅ **拨打电话** - 直接拨打指定电话号码
- ✅ **发送短信** - 打开短信应用发送消息
- ✅ **支持检查** - 检查设备是否支持电话功能

### 3. 邮件相关跳转
- ✅ **发送邮件** - 打开邮件应用发送邮件
- ✅ **多参数支持** - 支持主题、正文、抄送、密送等参数
- ✅ **自动编码** - 自动处理URL编码

### 4. 地图相关跳转
- ✅ **坐标跳转** - 通过经纬度打开地图
- ✅ **地址跳转** - 通过地址打开地图
- ✅ **平台适配** - iOS使用Apple Maps，Android使用Google Maps

### 5. 应用相关跳转
- ✅ **应用商店** - 打开App Store或Google Play
- ✅ **系统设置** - 打开系统设置页面
- ✅ **文件打开** - 打开本地文件

### 6. 社交媒体跳转
- ✅ **微信跳转** - 打开微信应用
- ✅ **QQ跳转** - 打开QQ应用
- ✅ **支付宝跳转** - 打开支付宝应用

### 7. 高级功能
- ✅ **带确认跳转** - 跳转前显示确认对话框
- ✅ **错误处理** - 完整的错误处理和回调机制
- ✅ **平台检测** - 自动检测当前平台
- ✅ **支持检查** - 检查各种功能是否支持

## 🚀 使用方法

### 1. 基础URL跳转

#### 网页跳转
```dart
import '../utils/url_launcher_util.dart';

// 外部浏览器跳转
await UrlLauncherUtil.launchWebUrl(
  'https://www.baidu.com',
  mode: LaunchMode.externalApplication,
  onResult: (result, error) {
    if (result == LaunchResult.success) {
      print('跳转成功');
    } else {
      print('跳转失败: $error');
    }
  },
);

// 应用内浏览器跳转
await UrlLauncherUtil.launchInAppWebView(
  'https://www.baidu.com',
  onResult: (result, error) {
    print('跳转结果: $result');
  },
);
```

#### 通用URL跳转
```dart
// 自动检测跳转方式
await UrlLauncherUtil.launchUrl(
  'https://www.example.com',
  mode: LaunchMode.platformDefault,
  onResult: (result, error) {
    print('跳转结果: $result');
  },
);
```

### 2. 电话相关跳转

#### 拨打电话
```dart
// 拨打电话
await UrlLauncherUtil.makePhoneCall(
  '10086',
  onResult: (result, error) {
    if (result == LaunchResult.success) {
      print('拨打电话成功');
    } else {
      print('拨打电话失败: $error');
    }
  },
);

// 检查是否支持拨打电话
bool canCall = await UrlLauncherUtil.canMakePhoneCall('10086');
if (canCall) {
  await UrlLauncherUtil.makePhoneCall('10086');
}
```

#### 发送短信
```dart
// 发送短信
await UrlLauncherUtil.sendSms(
  '10086',
  message: '这是一条测试短信',
  onResult: (result, error) {
    print('发送短信结果: $result');
  },
);

// 检查是否支持发送短信
bool canSms = await UrlLauncherUtil.canSendSms();
if (canSms) {
  await UrlLauncherUtil.sendSms('10086', message: '测试短信');
}
```

### 3. 邮件相关跳转

#### 发送邮件
```dart
// 发送邮件
await UrlLauncherUtil.sendEmail(
  to: 'test@example.com',
  subject: '测试邮件',
  body: '这是一封测试邮件',
  cc: ['cc@example.com'],
  bcc: ['bcc@example.com'],
  onResult: (result, error) {
    print('发送邮件结果: $result');
  },
);

// 检查是否支持发送邮件
bool canEmail = await UrlLauncherUtil.canSendEmail();
if (canEmail) {
  await UrlLauncherUtil.sendEmail(
    to: 'test@example.com',
    subject: '测试邮件',
    body: '邮件内容',
  );
}
```

### 4. 地图相关跳转

#### 通过坐标打开地图
```dart
// 通过坐标打开地图
await UrlLauncherUtil.openMap(
  latitude: 39.9042,
  longitude: 116.4074,
  label: '天安门广场',
  onResult: (result, error) {
    print('打开地图结果: $result');
  },
);
```

#### 通过地址打开地图
```dart
// 通过地址打开地图
await UrlLauncherUtil.openMap(
  address: '北京市天安门广场',
  onResult: (result, error) {
    print('打开地图结果: $result');
  },
);
```

### 5. 应用相关跳转

#### 打开应用商店
```dart
// 打开应用商店
await UrlLauncherUtil.openAppStore(
  appId: '1234567890', // iOS App ID
  packageName: 'com.example.app', // Android包名
  onResult: (result, error) {
    print('打开应用商店结果: $result');
  },
);
```

#### 打开系统设置
```dart
// 打开系统设置
await UrlLauncherUtil.openSettings(
  onResult: (result, error) {
    print('打开设置结果: $result');
  },
);
```

#### 打开文件
```dart
// 打开文件
await UrlLauncherUtil.openFile(
  '/path/to/file.pdf',
  onResult: (result, error) {
    print('打开文件结果: $result');
  },
);
```

### 6. 社交媒体跳转

#### 打开微信
```dart
// 打开微信
await UrlLauncherUtil.openWeChat(
  onResult: (result, error) {
    print('打开微信结果: $result');
  },
);
```

#### 打开QQ
```dart
// 打开QQ
await UrlLauncherUtil.openQQ(
  qqNumber: '123456789',
  onResult: (result, error) {
    print('打开QQ结果: $result');
  },
);
```

#### 打开支付宝
```dart
// 打开支付宝
await UrlLauncherUtil.openAlipay(
  onResult: (result, error) {
    print('打开支付宝结果: $result');
  },
);
```

### 7. 带确认的跳转

#### 带确认的URL跳转
```dart
// 带确认对话框的URL跳转
await UrlLauncherUtil.launchUrlWithConfirm(
  context,
  'https://www.example.com',
  title: '确认跳转',
  message: '即将跳转到外部网站',
  confirmText: '确认',
  cancelText: '取消',
);
```

#### 带确认的电话拨打
```dart
// 带确认对话框的电话拨打
await UrlLauncherUtil.makePhoneCallWithConfirm(
  context,
  '10086',
  title: '确认拨打电话',
  message: '即将拨打电话：10086',
  confirmText: '拨打',
  cancelText: '取消',
);
```

#### 带确认的邮件发送
```dart
// 带确认对话框的邮件发送
await UrlLauncherUtil.sendEmailWithConfirm(
  context,
  to: 'test@example.com',
  subject: '测试邮件',
  body: '邮件内容',
  title: '确认发送邮件',
  message: '即将发送邮件到：test@example.com',
  confirmText: '发送',
  cancelText: '取消',
);
```

### 8. 工具方法

#### 检查功能支持
```dart
// 检查URL是否可以打开
bool canLaunch = await UrlLauncherUtil.canLaunchUrl('https://www.example.com');

// 检查电话是否可以拨打
bool canCall = await UrlLauncherUtil.canMakePhoneCall('10086');

// 检查邮件是否可以发送
bool canEmail = await UrlLauncherUtil.canSendEmail();

// 检查短信是否可以发送
bool canSms = await UrlLauncherUtil.canSendSms();
```

#### 获取平台信息
```dart
// 获取当前平台信息
String platform = UrlLauncherUtil.getPlatformInfo();
print('当前平台: $platform'); // iOS, Android, Windows, macOS, Linux
```

## 📱 演示页面功能

### 1. 平台信息展示
- 当前平台显示
- 支持状态检查
- 实时信息更新

### 2. 基础URL跳转测试
- 外部浏览器跳转
- 应用内浏览器跳转
- 自定义URL输入

### 3. 电话相关跳转测试
- 拨打电话功能
- 发送短信功能
- 电话号码输入

### 4. 邮件相关跳转测试
- 发送邮件功能
- 邮箱地址输入
- 邮件参数设置

### 5. 地图相关跳转测试
- 坐标打开地图
- 地址打开地图
- 经纬度输入

### 6. 应用相关跳转测试
- 打开应用商店
- 打开系统设置
- 应用信息配置

### 7. 社交媒体跳转测试
- 打开微信
- 打开QQ
- 打开支付宝

### 8. 带确认的跳转测试
- 带确认的URL跳转
- 带确认的电话拨打
- 带确认的邮件发送

### 9. 工具方法测试
- URL支持检查
- 电话支持检查
- 邮件支持检查
- 短信支持检查

## 🎨 界面设计

### 1. 现代化UI设计
- 渐变AppBar设计
- 卡片式布局
- 统一的按钮样式
- 清晰的信息展示

### 2. 响应式布局
- 适配不同屏幕尺寸
- 统一的间距规范
- 优化的组件尺寸
- 流畅的交互体验

### 3. 用户体验
- 实时操作反馈
- 清晰的结果提示
- 友好的错误处理
- 直观的功能展示

## 🎯 最佳实践

### 1. 错误处理
```dart
await UrlLauncherUtil.launchUrl(
  'https://www.example.com',
  onResult: (result, error) {
    switch (result) {
      case LaunchResult.success:
        print('跳转成功');
        break;
      case LaunchResult.failed:
        print('跳转失败: $error');
        break;
      case LaunchResult.notSupported:
        print('设备不支持此操作');
        break;
      case LaunchResult.cancelled:
        print('用户取消了操作');
        break;
    }
  },
);
```

### 2. 功能检查
```dart
// 在跳转前检查功能是否支持
bool canLaunch = await UrlLauncherUtil.canLaunchUrl(url);
if (canLaunch) {
  await UrlLauncherUtil.launchUrl(url);
} else {
  print('设备不支持打开此URL');
}
```

### 3. 平台适配
```dart
// 根据平台选择不同的跳转方式
String platform = UrlLauncherUtil.getPlatformInfo();
if (platform == 'iOS') {
  // iOS特定处理
} else if (platform == 'Android') {
  // Android特定处理
}
```

### 4. 用户体验优化
```dart
// 使用带确认的跳转提升用户体验
await UrlLauncherUtil.launchUrlWithConfirm(
  context,
  url,
  title: '确认跳转',
  message: '即将跳转到外部网站，是否继续？',
);
```

## 🔧 高级用法

### 1. 自定义跳转处理
```dart
class CustomLauncher {
  static Future<void> launchWithRetry(String url, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      final result = await UrlLauncherUtil.launchUrl(url);
      if (result == LaunchResult.success) {
        return;
      }
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(seconds: 1));
      }
    }
    print('跳转失败，已达到最大重试次数');
  }
}
```

### 2. 批量跳转处理
```dart
class BatchLauncher {
  static Future<List<LaunchResult>> launchMultiple(List<String> urls) async {
    List<LaunchResult> results = [];
    
    for (String url in urls) {
      final result = await UrlLauncherUtil.launchUrl(url);
      results.add(result);
      
      // 添加延迟避免过快跳转
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    return results;
  }
}
```

### 3. 跳转历史记录
```dart
class LaunchHistory {
  static final List<String> _history = [];
  
  static Future<LaunchResult> launchWithHistory(String url) async {
    final result = await UrlLauncherUtil.launchUrl(url);
    if (result == LaunchResult.success) {
      _history.add(url);
    }
    return result;
  }
  
  static List<String> getHistory() => List.from(_history);
  
  static void clearHistory() => _history.clear();
}
```

## 🎊 总结

**URL跳转工具类提供了完整的跳转解决方案：**

- ✅ **多种跳转类型** - 支持网页、电话、邮件、地图、应用等
- ✅ **平台适配** - 自动适配iOS和Android平台
- ✅ **错误处理** - 完整的错误处理和回调机制
- ✅ **用户体验** - 带确认的跳转和友好的提示
- ✅ **工具方法** - 丰富的工具方法和支持检查

**现在您可以在项目中使用这个工具类来处理各种跳转需求，提升应用的功能性和用户体验！** 🚀

## 🚀 快速开始

1. 导入工具类
2. 选择相应的跳转方法
3. 处理跳转结果回调
4. 利用高级功能提升用户体验
5. 享受完整的跳转解决方案

**URL跳转工具类使用指南完成！** 🎉
