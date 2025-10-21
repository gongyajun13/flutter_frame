# MVVM 架构指南

## 📖 概述

本项目采用 **MVVM (Model-View-ViewModel)** 架构模式，结合 **GetX** 框架进行状态管理和路由管理。

## 🏗️ 项目结构

```
lib/
├── app/                          # 应用核心配置
│   ├── routes/                   # 路由配置
│   │   ├── app_pages.dart       # 路由页面定义
│   │   └── app_routes.dart      # 路由路径常量
│   ├── services/                 # 全局服务
│   │   ├── init_services.dart   # 服务初始化
│   │   └── storage_service.dart # 存储服务
│   └── middleware/               # 路由中间件
│       └── route_middleware.dart
├── pages/                        # 页面
│   ├── home/                    # 首页模块
│   │   ├── home_page.dart       # 视图 (View)
│   │   ├── home_controller.dart # 控制器 (ViewModel)
│   │   └── home_binding.dart    # 依赖绑定
│   ├── simple_network_demo/     # 其他功能模块...
│   └── ...
├── widgets/                      # 通用组件
├── utils/                        # 工具类
├── network/                      # 网络层
└── main.dart                     # 应用入口
```

## 🎯 MVVM 模式说明

### Model (模型层)
- **职责**：数据模型、业务逻辑、数据持久化
- **位置**：`lib/network/models/`, `lib/utils/`
- **示例**：
  ```dart
  class UserModel {
    final String id;
    final String name;
    
    UserModel({required this.id, required this.name});
    
    factory UserModel.fromJson(Map<String, dynamic> json) {
      return UserModel(
        id: json['id'],
        name: json['name'],
      );
    }
  }
  ```

### View (视图层)
- **职责**：UI 展示、用户交互
- **位置**：`lib/pages/*/(*_page.dart)`
- **特点**：
  - 使用 `GetView<Controller>` 基类
  - 只负责 UI 渲染
  - 通过 `controller` 访问 ViewModel
  - 使用 `Obx()` 或 `GetX()` 监听状态变化

- **示例**：
  ```dart
  class HomePage extends GetView<HomeController> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Obx(() => Text('${controller.counter}')),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.increment,
        ),
      );
    }
  }
  ```

### ViewModel (视图模型层)
- **职责**：状态管理、业务逻辑处理、与 Model 交互
- **位置**：`lib/pages/*/(*_controller.dart)`
- **特点**：
  - 继承 `GetxController`
  - 使用 `.obs` 创建响应式变量
  - 提供方法供 View 调用
  - 处理生命周期 (onInit, onReady, onClose)

- **示例**：
  ```dart
  class HomeController extends GetxController {
    final counter = 0.obs;
    
    @override
    void onInit() {
      super.onInit();
      // 初始化逻辑
    }
    
    void increment() {
      counter.value++;
    }
    
    @override
    void onClose() {
      // 清理资源
      super.onClose();
    }
  }
  ```

### Binding (依赖绑定)
- **职责**：依赖注入、Controller 生命周期管理
- **位置**：`lib/pages/*/(*_binding.dart)`
- **特点**：
  - 实现 `Bindings` 接口
  - 在路由跳转时自动注入 Controller
  - 页面销毁时自动清理

- **示例**：
  ```dart
  class HomeBinding extends Bindings {
    @override
    void dependencies() {
      Get.lazyPut<HomeController>(() => HomeController());
    }
  }
  ```

## 🚦 路由管理

### 路由定义

在 `app/routes/app_pages.dart` 中定义：

```dart
GetPage(
  name: _Paths.HOME,
  page: () => const HomePage(),
  binding: HomeBinding(),
  middlewares: [RouteMiddleware()], // 可选的中间件
),
```

### 路由跳转

```dart
// 1. 命名路由跳转
Get.toNamed(Routes.HOME);

// 2. 带参数跳转
Get.toNamed(Routes.DETAIL, parameters: {'id': '123'});

// 3. 带参数和 arguments 跳转
Get.toNamed(
  Routes.DETAIL,
  arguments: UserModel(...),
  parameters: {'tab': 'info'},
);

// 4. 替换当前页面
Get.offNamed(Routes.LOGIN);

// 5. 清空路由栈并跳转
Get.offAllNamed(Routes.HOME);

// 6. 返回上一页
Get.back();

// 7. 返回并传递结果
Get.back(result: {'success': true});
```

### 接收参数

```dart
class DetailController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    
    // 获取 parameters
    final id = Get.parameters['id'];
    
    // 获取 arguments
    final user = Get.arguments as UserModel;
  }
}
```

## 📦 状态管理

### 1. 响应式变量

```dart
// 声明响应式变量
final count = 0.obs;
final name = ''.obs;
final user = Rx<UserModel?>(null);
final list = <String>[].obs;

// 更新值
count.value++;
name.value = 'New Name';
user.value = UserModel(...);
list.add('item');

// 批量更新（仅触发一次刷新）
user.update((val) {
  val?.name = 'New Name';
  val?.age = 25;
});
```

### 2. 视图响应式更新

```dart
// 方式 1: Obx (推荐 - 轻量级)
Obx(() => Text('${controller.count}'))

// 方式 2: GetX
GetX<HomeController>(
  builder: (controller) => Text('${controller.count}'),
)

// 方式 3: GetBuilder (手动更新)
class Controller extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update(); // 手动触发更新
  }
}

GetBuilder<HomeController>(
  builder: (controller) => Text('${controller.count}'),
)
```

### 3. 全局状态管理

```dart
// 1. 注册全局 Controller
Get.put(GlobalController());

// 2. 在任何地方访问
final controller = Get.find<GlobalController>();

// 3. 延迟注入（首次使用时才创建）
Get.lazyPut(() => GlobalController());

// 4. 单例注入（永久保留）
Get.putAsync(() async => await GlobalController().init(), permanent: true);
```

## 🔧 服务管理

### 创建服务

```dart
class ApiService extends GetxService {
  Future<ApiService> init() async {
    // 初始化逻辑
    return this;
  }
  
  Future<void> request() async {
    // 网络请求
  }
}
```

### 注册服务

```dart
// 在 main() 中
await Get.putAsync(() => ApiService().init());

// 在任何地方使用
final api = Get.find<ApiService>();
```

## 🎨 最佳实践

### 1. Controller 命名规范

- **文件名**：`xxx_controller.dart`
- **类名**：`XxxController`
- **示例**：`home_controller.dart` -> `HomeController`

### 2. 页面命名规范

- **文件名**：`xxx_page.dart`
- **类名**：`XxxPage`
- **示例**：`home_page.dart` -> `HomePage`

### 3. Binding 命名规范

- **文件名**：`xxx_binding.dart`
- **类名**：`XxxBinding`
- **示例**：`home_binding.dart` -> `HomeBinding`

### 4. 避免在 View 中写业务逻辑

❌ **错误示例**：
```dart
class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // ❌ 不要在这里写业务逻辑
        if (controller.count > 10) {
          Get.snackbar('提示', '数量超过限制');
        }
        controller.count.value++;
      },
      child: Text('增加'),
    );
  }
}
```

✅ **正确示例**：
```dart
// Controller
class HomeController extends GetxController {
  void increment() {
    if (count > 10) {
      Get.snackbar('提示', '数量超过限制');
      return;
    }
    count.value++;
  }
}

// View
class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: controller.increment, // ✅ 只调用方法
      child: Text('增加'),
    );
  }
}
```

### 5. 合理使用响应式

```dart
// ✅ 需要响应式更新的数据
final count = 0.obs;

// ✅ 不需要响应式的数据（不会变化）
final String title = '首页';

// ❌ 避免过度使用响应式
final staticData = 'constant'.obs; // 不必要
```

### 6. 及时清理资源

```dart
class MyController extends GetxController {
  late StreamSubscription subscription;
  late Timer timer;
  
  @override
  void onInit() {
    super.onInit();
    subscription = stream.listen(...);
    timer = Timer.periodic(...);
  }
  
  @override
  void onClose() {
    // ✅ 清理资源
    subscription.cancel();
    timer.cancel();
    super.onClose();
  }
}
```

### 7. 使用 Workers 监听变化

```dart
class MyController extends GetxController {
  final count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // 每次变化都触发
    ever(count, (value) {
      print('count changed to $value');
    });
    
    // 只在第一次变化时触发
    once(count, (value) {
      print('count first changed to $value');
    });
    
    // 防抖（1秒内多次变化只触发一次）
    debounce(count, (value) {
      print('count debounced to $value');
    }, time: Duration(seconds: 1));
    
    // 节流（1秒内最多触发一次）
    interval(count, (value) {
      print('count interval to $value');
    }, time: Duration(seconds: 1));
  }
}
```

## 🔍 调试技巧

### 1. 开启 GetX 日志

```dart
GetMaterialApp(
  enableLog: true, // 开启日志
  logWriterCallback: (text, {isError = false}) {
    debugPrint('GetX: $text');
  },
);
```

### 2. 查看当前路由栈

```dart
debugPrint('Current Route: ${Get.currentRoute}');
debugPrint('Previous Route: ${Get.previousRoute}');
```

### 3. 查看注入的依赖

```dart
debugPrint('Registered: ${Get.isRegistered<HomeController>()}');
```

## 📚 参考资源

- [GetX 官方文档](https://pub.dev/packages/get)
- [GetX 中文文档](https://github.com/jonataslaw/getx/blob/master/README.zh-cn.md)
- [Flutter MVVM 最佳实践](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

---

**版本**: 1.0.0  
**更新日期**: 2025-10-21

