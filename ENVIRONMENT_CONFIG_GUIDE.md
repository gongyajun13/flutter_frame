# 🌍 环境 & 配置管理指南

## 📋 概述

本项目通过 `EnvironmentConfig` 统一管理 **运行环境** 与 **基础配置**，支持：

- 开发 / 测试 / 生产环境区分
- 不同环境的 API 基础地址
- 日志与错误上报开关
- 后续可扩展的 Feature 开关

## 🏗 架构概览

- `lib/network/config/api_config.dart`
  - 定义各环境的基础 URL：`baseUrl / devBaseUrl / testBaseUrl`
  - 定义 API 版本、超时时间、重试次数等
- `lib/app/config/environment_config.dart`
  - `EnvironmentConfig`（GetxService）：管理当前环境和相关开关
  - 根据编译参数 `APP_ENV`（dev/test/prod）选择配置
  - 初始化时调用 `NetworkConfig.updateBaseUrl` 更新网络层 baseUrl
- `lib/app/services/init_services.dart`
  - 启动时最先初始化 `EnvironmentConfig`
  - 使用环境配置控制错误监控服务的行为（是否打印日志、是否上报）

## 🚀 使用方式

### 1. 切换环境

通过 `--dart-define` 在编译/运行时指定环境：

```bash
# 开发环境
flutter run --dart-define=APP_ENV=dev

# 测试环境
flutter run --dart-define=APP_ENV=test

# 生产环境（默认）
flutter run --dart-define=APP_ENV=prod
```

支持的取值：

- `dev` / `development`
- `test`
- `prod` / `production`（默认）

### 2. 环境配置说明

文件：`lib/app/config/environment_config.dart`

```dart
enum AppEnvironment { development, test, production }

class EnvironmentConfig extends GetxService {
  final Rx<AppEnvironment> env = AppEnvironment.production.obs;

  late final String apiBaseUrl;
  late final bool enableNetworkLog;
  late final bool enableConsoleLog;
  late final bool enableErrorReporting;

  bool get isDev => env.value == AppEnvironment.development;
  bool get isTest => env.value == AppEnvironment.test;
  bool get isProd => env.value == AppEnvironment.production;

  Future<EnvironmentConfig> init() async {
    const envString = String.fromEnvironment('APP_ENV', defaultValue: 'prod');
    // ... 根据 envString 设置各项配置
    NetworkConfig.updateBaseUrl(apiBaseUrl);
    return this;
  }
}
```

各环境默认配置：

- **dev**
  - `apiBaseUrl = ApiConfig.devBaseUrl`
  - `enableNetworkLog = true`
  - `enableConsoleLog = true`
  - `enableErrorReporting = false`
- **test**
  - `apiBaseUrl = ApiConfig.testBaseUrl`
  - `enableNetworkLog = true`
  - `enableConsoleLog = true`
  - `enableErrorReporting = true`
- **prod**
  - `apiBaseUrl = ApiConfig.baseUrl`
  - `enableNetworkLog = false`
  - `enableConsoleLog = false`
  - `enableErrorReporting = true`

### 3. 启动时初始化流程

文件：`lib/app/services/init_services.dart`

```dart
class InitServices {
  static Future<void> init() async {
    // 1. 环境配置（最先初始化）
    final envConfig = await Get.putAsync(() => EnvironmentConfig().init());

    // 2. 错误监控服务（根据环境控制）
    await Get.putAsync(() => ErrorMonitorService().init(
          enableConsoleLog: envConfig.enableConsoleLog,
          enableErrorReporting: envConfig.enableErrorReporting,
        ));

    // 3. 存储服务
    await Get.putAsync(() => StorageService().init());

    // 4. 数据库
    await AppDatabase.instance.database;
  }
}
```

### 4. 在代码中使用环境信息

```dart
final env = Get.find<EnvironmentConfig>();

if (env.isDev) {
  // 开发环境专用逻辑
}

// 获取当前 API 基础地址
final baseUrl = env.apiBaseUrl;
```

## 🔧 ApiConfig 中的基础配置

文件：`lib/network/config/api_config.dart`

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.example.com';
  static const String devBaseUrl = 'https://dev-api.example.com';
  static const String testBaseUrl = 'https://test-api.example.com';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  static const int maxRetries = 3;
  static const int retryDelay = 1000;

  static const String apiVersion = 'v1';
}
```

> 说明：`EnvironmentConfig` 会根据当前环境选择其中一个 baseUrl，并调用 `NetworkConfig.updateBaseUrl`。

## 📈 与其他模块的联动

### 1. 与错误监控

- 开发环境：只在控制台输出错误日志，不上报
- 测试环境：打印日志并开启错误上报，便于预发布验证
- 生产环境：关闭控制台详细日志，开启错误上报

### 2. 与网络日志

- 开发 / 测试环境：强烈建议开启 `enableNetworkLog`，配合 `Dio` 日志拦截器调试请求
- 生产环境：默认关闭，避免泄露敏感信息和影响性能

> 当前 `NetworkConfig` 中已经在 `kDebugMode` 下添加日志拦截器，后续可以根据 `EnvironmentConfig.enableNetworkLog` 再细化控制。

## 🧩 下一步可扩展点

1. **Feature Flag（功能开关）**
   - 在 `EnvironmentConfig` 中增加如 `enableNewUI`, `enableMockLogin` 等开关
   - 通过远程配置（Remote Config）动态调整

2. **多后端环境**
   - 针对不同模块（如 AI、支付、文件上传）分别配置 baseUrl
   - 在 `EnvironmentConfig` 中增加对应字段

3. **构建配置文档**
   - 为 CI/CD 或本地打包整理一份环境说明文档（各环境对应的 dart-define 参数）

## 🔗 相关文件

- `lib/network/config/api_config.dart`
- `lib/network/config/network_config.dart`
- `lib/app/config/environment_config.dart`
- `lib/app/services/init_services.dart`

