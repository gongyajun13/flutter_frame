# 简洁网络请求工具包使用说明

## 🎯 设计理念

这个简洁的网络请求工具包采用**中间类**的设计模式，提供最简洁的API调用方式：

1. **中间类处理** - `NetworkManager`作为中间类统一处理网络请求
2. **回调返回** - 通过回调函数返回成功、失败、异常结果
3. **参数传递** - 直接传递请求参数和回调函数
4. **自动处理** - 自动处理loading、错误提示、成功提示

## 📁 文件结构

```
lib/network/
├── core/
│   └── network_manager.dart    # 网络请求管理器（中间类）
├── services/
│   └── api_service.dart        # 业务API服务
├── models/                     # 数据模型
│   ├── user_model.dart
│   ├── product_model.dart
│   └── api_response.dart
└── simple_network.dart         # 统一导出文件
```

## 🚀 使用方法

### 1. 基础使用

```dart
import 'package:flutter_frame/network/simple_network.dart';

// 用户登录
ApiService.login(
  username: 'test@example.com',
  password: 'password123',
  onSuccess: (LoginResponseModel data) {
    print('登录成功: ${data.user.username}');
    // 更新UI状态
  },
  onError: (String message, int code) {
    print('登录失败: $message');
    // 处理错误
  },
  onException: (dynamic error) {
    print('登录异常: $error');
    // 处理异常
  },
);
```

### 2. 静默请求

```dart
// 不显示loading和错误提示的静默请求
ApiService.getUserProfile(
  showLoading: false,   // 不显示loading
  showError: false,     // 不显示错误提示
  onSuccess: (UserModel data) {
    print('获取用户信息成功: ${data.username}');
    // 静默更新用户信息
  },
  onError: (String message, int code) {
    print('获取用户信息失败: $message');
    // 静默处理错误
  },
);
```

### 3. 分页请求

```dart
ApiService.getProducts(
  page: 1,
  pageSize: 20,
  filters: {
    'category': 'electronics',
    'price_min': 100,
    'isActive': true,
  },
  onSuccess: (PaginatedResponse<ProductModel> data) {
    print('获取产品列表成功: 共${data.total}个产品');
    print('当前页: ${data.page}/${(data.total / data.pageSize).ceil()}');
    print('产品列表: ${data.items.map((p) => p.name).join(', ')}');
  },
  onError: (String message, int code) {
    print('获取产品列表失败: $message');
  },
);
```

### 4. 文件上传

```dart
ApiService.uploadAvatar(
  filePath: '/path/to/avatar.jpg',
  onSuccess: (Map<String, dynamic> data) {
    print('头像上传成功: $data');
    // 更新用户头像显示
  },
  onError: (String message, int code) {
    print('头像上传失败: $message');
  },
  onProgress: (int sent, int total) {
    print('上传进度: ${(sent / total * 100).toStringAsFixed(2)}%');
    // 更新进度条
  },
);
```

### 5. 直接使用NetworkManager

```dart
final networkManager = NetworkManager();

networkManager.get<Map<String, dynamic>>(
  url: '/custom/endpoint',
  params: {'param1': 'value1'},
  headers: {'Custom-Header': 'custom-value'},
  fromJson: (data) => Map<String, dynamic>.from(data),
  onSuccess: (Map<String, dynamic> data) {
    print('自定义请求成功: $data');
  },
  onError: (String message, int code) {
    print('自定义请求失败: $message');
  },
  onException: (dynamic error) {
    print('自定义请求异常: $error');
  },
);
```

## 🛠️ 创建自定义API

### 1. 在ApiService中添加新方法

```dart
class ApiService {
  // ... 现有方法

  /// 自定义API
  static void customApi({
    required String customParam,
    required void Function(Map<String, dynamic>) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.post<Map<String, dynamic>>(
      url: '/custom/endpoint',
      data: {
        'customParam': customParam,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      fromJson: (data) => Map<String, dynamic>.from(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '执行自定义操作中...',
      successText: '自定义操作成功',
    );
  }
}
```

### 2. 使用自定义API

```dart
ApiService.customApi(
  customParam: 'custom_value',
  onSuccess: (Map<String, dynamic> data) {
    print('自定义API成功: $data');
  },
  onError: (String message, int code) {
    print('自定义API失败: $message');
  },
);
```

## 🎨 在Widget中使用

```dart
class ExampleWidget extends StatefulWidget {
  @override
  _ExampleWidgetState createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  UserModel? _user;
  List<ProductModel> _products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('示例页面')),
      body: Column(
        children: [
          if (_user != null)
            Text('欢迎, ${_user!.username}!'),
          
          if (_products.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('¥${product.price}'),
                  );
                },
              ),
            ),
          
          ElevatedButton(
            onPressed: _loadData,
            child: Text('加载数据'),
          ),
        ],
      ),
    );
  }

  void _loadData() {
    // 获取用户信息
    ApiService.getUserProfile(
      onSuccess: (UserModel data) {
        setState(() {
          _user = data;
        });
      },
      onError: (String message, int code) {
        // 错误提示已由中间类处理
      },
    );

    // 获取产品列表
    ApiService.getProducts(
      page: 1,
      pageSize: 10,
      onSuccess: (PaginatedResponse<ProductModel> data) {
        setState(() {
          _products = data.items;
        });
      },
      onError: (String message, int code) {
        // 错误提示已由中间类处理
      },
    );
  }
}
```

## 🔧 配置选项

### Loading配置
- `showLoading`: 是否显示loading对话框
- `loadingText`: loading提示文本

### 错误提示配置
- `showError`: 是否显示错误提示
- 错误提示使用GetX的snackbar显示

### 成功提示配置
- `successText`: 成功提示文本（为空则不显示）
- 成功提示使用GetX的snackbar显示

## 📱 演示页面

运行应用后，点击"简洁网络请求演示"按钮可以体验：
- 用户登录（带loading和成功提示）
- 获取用户信息（带loading，无成功提示）
- 获取产品列表（分页数据）
- 创建产品（带loading和成功提示）
- 静默请求（无loading和错误提示）

## ✨ 优势

1. **极简API** - 只需传递参数和回调函数
2. **中间类处理** - 统一处理网络请求逻辑
3. **自动UI** - 自动显示loading和错误提示
4. **类型安全** - 完整的泛型支持
5. **灵活配置** - 可控制是否显示loading和错误提示
6. **回调支持** - 支持成功、失败、异常回调

## 🎯 适用场景

- 需要最简洁网络请求接口的项目
- 希望减少代码量的项目
- 需要统一处理loading和错误提示的项目
- 使用GetX状态管理的项目

## 🔄 与之前方案的对比

| 特性 | 基于继承的方案 | 简洁中间类方案 |
|------|----------------|----------------|
| 代码量 | 较多 | 极少 |
| 使用复杂度 | 中等 | 极简 |
| 扩展性 | 高 | 中等 |
| 学习成本 | 高 | 低 |
| 维护成本 | 中等 | 低 |

**简洁中间类方案更适合快速开发和简单项目！**
