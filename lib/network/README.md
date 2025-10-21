# 网络请求工具包

基于dio插件封装的完整网络请求解决方案，提供统一的API接口、拦截器、错误处理等功能。

## 功能特性

- ✅ **拦截器支持**：认证拦截器、日志拦截器、重试拦截器、错误处理拦截器
- ✅ **统一响应模型**：标准化的API响应格式
- ✅ **错误处理**：统一的错误处理和分类
- ✅ **Token管理**：自动token添加和刷新
- ✅ **文件上传/下载**：支持单文件、多文件上传和文件下载
- ✅ **请求取消**：支持请求取消和超时控制
- ✅ **重试机制**：自动重试失败的请求
- ✅ **日志记录**：详细的请求和响应日志

## 目录结构

```
lib/network/
├── config/                 # 配置文件
│   ├── api_config.dart     # API配置和路由
│   └── network_config.dart # 网络配置管理
├── interceptors/           # 拦截器
│   ├── auth_interceptor.dart    # 认证拦截器
│   └── log_interceptor.dart     # 日志拦截器
├── models/                 # 数据模型
│   └── api_response.dart   # API响应模型
├── services/               # 服务类
│   └── network_service.dart # 网络请求服务
├── examples/               # 使用示例
│   └── usage_example.dart  # 使用示例代码
├── network.dart           # 导出文件
└── README.md              # 说明文档
```

## 快速开始

### 1. 导入工具包

```dart
import 'package:flutter_frame/network/network.dart';
```

### 2. 基础使用

```dart
// 使用便捷方法
final response = await NetworkUtils.login(
  username: 'test@example.com',
  password: 'password123',
);

if (response.success) {
  print('登录成功: ${response.data}');
} else {
  print('登录失败: ${response.message}');
}
```

### 3. 自定义请求

```dart
final service = NetworkService();

final response = await service.get<Map<String, dynamic>>(
  '/custom/endpoint',
  queryParameters: {'param1': 'value1'},
  headers: {'Custom-Header': 'custom-value'},
);
```

## 配置说明

### API配置

在 `api_config.dart` 中配置：

```dart
class ApiConfig {
  // 基础URL
  static const String _baseUrl = 'https://api.example.com';
  
  // 超时配置
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // 重试配置
  static const int maxRetries = 3;
  static const int retryDelay = 1000;
}
```

### 环境配置

```dart
enum Environment {
  development,  // 开发环境
  test,         // 测试环境
  production,   // 生产环境
}
```

## 拦截器说明

### 认证拦截器 (AuthInterceptor)

- 自动添加Authorization头
- 处理401错误，自动刷新token
- 支持token存储和清除

```dart
// 保存token
await AuthInterceptor.saveToken('your-token');

// 清除token
await AuthInterceptor.clearToken();
```

### 日志拦截器 (LogInterceptor)

- 记录请求和响应详情
- 仅在调试模式下启用
- 支持自定义日志格式

### 重试拦截器 (RetryInterceptor)

- 自动重试失败的请求
- 支持指数退避策略
- 可配置重试次数和延迟

### 错误处理拦截器 (ErrorHandlerInterceptor)

- 统一错误处理
- 友好的错误信息
- 支持自定义错误处理逻辑

## 响应模型

### ApiResponse<T>

```dart
class ApiResponse<T> {
  final bool success;        // 是否成功
  final int code;           // 状态码
  final String message;     // 消息
  final T? data;           // 数据
  final String? error;     // 错误信息
  final Map<String, dynamic>? extra; // 额外信息
}
```

### PaginatedResponse<T>

```dart
class PaginatedResponse<T> {
  final List<T> items;      // 数据列表
  final int total;          // 总数
  final int page;           // 当前页
  final int pageSize;       // 每页大小
  final bool hasMore;       // 是否有更多
}
```

## 使用示例

### 用户认证

```dart
// 登录
final loginResponse = await NetworkUtils.login(
  username: 'user@example.com',
  password: 'password123',
);

// 获取用户信息
final profileResponse = await NetworkUtils.getUserProfile();

// 更新用户信息
final updateResponse = await NetworkUtils.updateUserProfile(
  profile: {'name': '新用户名'},
);
```

### 文件操作

```dart
// 上传头像
final uploadResponse = await NetworkUtils.uploadAvatar(
  filePath: '/path/to/avatar.jpg',
  onProgress: (sent, total) {
    print('上传进度: ${(sent / total * 100).toStringAsFixed(2)}%');
  },
);

// 文件下载
final downloadResponse = await NetworkService().download(
  '/files/document.pdf',
  savePath: '/local/path/document.pdf',
  onReceiveProgress: (received, total) {
    print('下载进度: ${(received / total * 100).toStringAsFixed(2)}%');
  },
);
```

### 分页数据

```dart
final response = await NetworkUtils.getProducts(
  page: 1,
  pageSize: 20,
  filters: {
    'category': 'electronics',
    'price_min': 100,
  },
);

if (response.success && response.data != null) {
  final products = response.data!;
  print('产品总数: ${products.total}');
  print('产品列表: ${products.items}');
}
```

### 请求取消

```dart
final cancelToken = CancelToken();

// 5秒后取消请求
Future.delayed(Duration(seconds: 5), () {
  if (!cancelToken.isCancelled) {
    cancelToken.cancel('请求超时');
  }
});

try {
  final response = await NetworkService().get<Map<String, dynamic>>(
    '/long-running-endpoint',
    cancelToken: cancelToken,
  );
} catch (e) {
  if (e is DioException && e.type == DioExceptionType.cancel) {
    print('请求已取消');
  }
}
```

### 批量请求

```dart
final futures = [
  NetworkUtils.getUserProfile(),
  NetworkUtils.getProducts(page: 1, pageSize: 10),
  NetworkService().get<Map<String, dynamic>>('/config'),
];

final results = await Future.wait(futures);
```

## 错误处理

```dart
try {
  final response = await NetworkUtils.getProductDetail(
    productId: 'product-id',
  );

  if (response.success) {
    // 处理成功响应
    print('产品详情: ${response.data}');
  } else {
    // 处理业务错误
    switch (response.code) {
      case 404:
        print('产品不存在');
        break;
      case 403:
        print('没有权限访问该产品');
        break;
      default:
        print('获取产品详情失败: ${response.message}');
    }
  }
} catch (e) {
  // 处理网络异常
  print('网络异常: $e');
}
```

## 自定义配置

### 更新基础URL

```dart
NetworkConfig.updateBaseUrl('https://new-api.example.com');
```

### 添加自定义请求头

```dart
NetworkConfig.updateHeaders({
  'Custom-Header': 'custom-value',
  'X-App-Version': '1.0.0',
});
```

### 设置代理（调试用）

```dart
NetworkConfig.setProxy('127.0.0.1:8888');
```

## 注意事项

1. **Token管理**：确保在用户登录后调用 `AuthInterceptor.saveToken()` 保存token
2. **错误处理**：建议在业务层统一处理错误，提供友好的用户提示
3. **超时设置**：根据实际网络环境调整超时时间
4. **日志记录**：生产环境建议关闭详细日志记录
5. **重试策略**：避免对幂等性要求高的接口进行重试

## 扩展功能

如需添加新的API接口，可以在 `NetworkUtils` 类中添加新的静态方法，或者直接使用 `NetworkService` 进行自定义请求。

```dart
// 在NetworkUtils中添加新方法
static Future<ApiResponse<Map<String, dynamic>>> getNewData() async {
  return _service.get<Map<String, dynamic>>('/new-endpoint');
}
```
