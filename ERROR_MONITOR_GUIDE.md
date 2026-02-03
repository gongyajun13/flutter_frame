# 🚨 错误监控使用指南

## 📋 概述

本项目实现了完整的错误监控系统，可以自动捕获 Flutter 框架错误、异步错误、Zone 错误，并提供错误上报、错误过滤、用户信息设置等功能。

## 🎯 功能特点

### 1. 自动错误捕获
- ✅ **Flutter 框架错误** - 自动捕获 Flutter 渲染和构建错误
- ✅ **异步错误** - 捕获异步操作中的错误
- ✅ **Zone 错误** - 捕获 Zone 内的未处理错误
- ✅ **手动上报** - 支持手动上报自定义错误

### 2. 错误管理
- ✅ **错误过滤** - 可以过滤不需要上报的错误
- ✅ **错误标签** - 为错误添加标签用于分类
- ✅ **错误上下文** - 记录错误发生的上下文信息
- ✅ **面包屑追踪** - 记录用户操作路径

### 3. 用户信息管理
- ✅ **用户标识** - 设置用户 ID、用户名、邮箱
- ✅ **用户上下文** - 记录用户相关的额外信息

## 🚀 快速开始

### 1. 初始化错误监控

错误监控已在 `InitServices` 中自动初始化：

```dart
// lib/app/services/init_services.dart
static Future<void> init() async {
  // 错误监控服务最先初始化，以便捕获后续初始化过程中的错误
  await Get.putAsync(() => ErrorMonitorService().init(
    enableConsoleLog: true,        // 是否在控制台输出错误日志
    enableErrorReporting: false,    // 是否启用错误上报（需要配置上报服务）
  ));
  // ... 其他服务初始化
}
```

### 2. 在 Controller 中使用

`BaseController` 已集成错误监控，错误会自动上报：

```dart
class YourController extends BaseController {
  Future<void> loadData() async {
    try {
      // 执行操作
      await someAsyncOperation();
    } catch (e, stackTrace) {
      // 错误会自动上报到错误监控系统
      showError('加载失败', error: e, stackTrace: stackTrace);
    }
  }
}
```

### 3. 手动上报错误

```dart
import '../../utils/error_monitor_service.dart';

final errorMonitor = Get.find<ErrorMonitorService>();

// 上报错误
errorMonitor.reportError(
  Exception('自定义错误'),
  stackTrace: stackTrace,
  context: '错误发生的上下文',
  tags: {
    'type': 'custom',
    'page': 'your_page',
  },
);
```

### 4. 设置用户信息

```dart
final errorMonitor = Get.find<ErrorMonitorService>();

errorMonitor.setUser(
  id: 'user_123',
  username: 'john_doe',
  email: 'john@example.com',
  extra: {
    'role': 'admin',
    'department': 'engineering',
  },
);
```

### 5. 添加面包屑

面包屑用于追踪用户操作路径，帮助理解错误发生的上下文：

```dart
final errorMonitor = Get.find<ErrorMonitorService>();

errorMonitor.addBreadcrumb(
  message: '用户点击了提交按钮',
  category: 'user_action',
  level: 'info',
  data: {
    'button': 'submit',
    'form': 'login',
  },
);
```

### 6. 设置标签

标签用于错误分类和过滤：

```dart
final errorMonitor = Get.find<ErrorMonitorService>();

errorMonitor.setTag('environment', 'production');
errorMonitor.setTag('version', '1.0.0');
errorMonitor.setTag('platform', 'android');
```

## 📚 高级功能

### 1. 错误过滤

可以添加错误过滤器，过滤不需要上报的错误：

```dart
import '../../utils/error_monitor.dart';

ErrorMonitor.instance.addErrorFilter((error, stack) {
  // 过滤某些已知的、不影响功能的错误
  if (error.toString().contains('某些已知错误')) {
    return true; // 返回 true 表示过滤该错误
  }
  return false;
});
```

### 2. 自定义错误上报

可以添加自定义的错误上报回调，例如集成 Sentry、Firebase Crashlytics 等：

```dart
import '../../utils/error_monitor.dart';

ErrorMonitor.instance.addReportCallback((errorInfo) {
  // 上报到 Sentry
  // Sentry.captureException(
  //   errorInfo.error,
  //   stackTrace: errorInfo.stackTrace,
  // );
  
  // 或上报到 Firebase Crashlytics
  // FirebaseCrashlytics.instance.recordError(
  //   errorInfo.error,
  //   errorInfo.stackTrace,
  // );
  
  // 或保存到本地数据库
  // await saveErrorToDatabase(errorInfo);
});
```

### 3. 集成 Sentry（推荐）

Sentry 是最流行的错误监控服务，支持 Flutter：

#### 安装依赖

```yaml
dependencies:
  sentry_flutter: ^7.0.0
```

#### 配置 Sentry

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = 'production';
      options.release = '1.0.0';
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await InitServices.init();
      Get.put(ThemeController());
      runApp(const MyApp());
    },
  );
}
```

#### 添加 Sentry 上报回调

```dart
// 在 InitServices.init() 中
ErrorMonitor.instance.addReportCallback((errorInfo) {
  Sentry.captureException(
    errorInfo.error,
    stackTrace: errorInfo.stackTrace,
    hint: Hint.withMap({
      'context': errorInfo.context,
      'tags': errorInfo.tags,
    }),
  );
});
```

## 📝 错误类型

### Flutter 框架错误
- 渲染错误（RenderFlex overflow 等）
- 构建错误（Widget 构建失败等）
- 布局错误（约束冲突等）

### 异步错误
- Future 中的未捕获错误
- Stream 中的错误
- Timer 中的错误

### Zone 错误
- Zone 内未处理的异常
- 异步操作中的异常

### 手动上报错误
- 业务逻辑错误
- 网络请求错误
- 数据验证错误

## 🔧 配置选项

### 初始化选项

```dart
await ErrorMonitorService().init(
  enableConsoleLog: true,        // 是否在控制台输出错误日志（开发环境建议 true）
  enableErrorReporting: false,   // 是否启用错误上报（生产环境建议 true）
);
```

### 错误信息结构

```dart
class ErrorInfo {
  final ErrorType type;              // 错误类型
  final Object error;                // 错误对象
  final StackTrace? stackTrace;      // 堆栈跟踪
  final String? context;             // 上下文信息
  final String? library;             // 错误发生的库
  final List<DiagnosticsNode>? information; // 诊断信息
  final Map<String, String>? tags;    // 标签
  final DateTime timestamp;          // 时间戳
}
```

## 📖 最佳实践

1. **开发环境**：启用控制台日志，禁用错误上报
2. **生产环境**：启用错误上报，配置 Sentry 或其他服务
3. **用户信息**：在用户登录后设置用户信息
4. **面包屑**：在关键操作点添加面包屑
5. **错误过滤**：过滤已知的、不影响功能的错误
6. **标签分类**：使用标签对错误进行分类

## 🔗 相关文件

- `lib/utils/error_monitor.dart` - 错误监控核心类
- `lib/utils/error_monitor_service.dart` - 错误监控服务
- `lib/base/base_controller.dart` - 已集成错误监控
- `lib/pages/error_monitor_demo/` - 错误监控演示页面

## 📖 更多示例

查看 `lib/pages/error_monitor_demo/` 目录下的演示代码，了解完整的使用示例。
