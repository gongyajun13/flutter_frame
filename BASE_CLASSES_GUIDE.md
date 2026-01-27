# 基类系统设计指南

## 🎯 设计目标

为项目提供统一的基类系统，减少代码重复，提高代码质量和可维护性。

## 📋 基类系统概览

### 1. BaseController - Controller 基类
**文件**: `lib/base/base_controller.dart`

**功能**:
- ✅ 通用的加载状态管理
- ✅ 通用的错误状态管理
- ✅ 自动资源清理（TextEditingController、PageController、Timer、StreamSubscription、AnimationController）
- ✅ 统一的异步操作处理
- ✅ 统一的提示方法
- ✅ 统一的导航方法

### 2. BasePage - 页面基类
**文件**: `lib/base/base_page.dart`

**功能**:
- ✅ 统一的 AppBar 配置
- ✅ 自动错误状态显示
- ✅ 自动加载状态显示
- ✅ 统一的页面布局

### 3. BaseModel - 模型基类
**文件**: `lib/base/base_model.dart`

**功能**:
- ✅ 统一的 JSON 序列化/反序列化
- ✅ 数据验证
- ✅ 模型复制
- ✅ 相等性比较

## 📖 使用指南

### BaseController 使用

#### 基础使用

```dart
class MyController extends BaseController {
  @override
  void _onInit() {
    super._onInit();
    // 初始化逻辑
  }

  @override
  void _onReady() {
    super._onReady();
    // 准备完成后的逻辑
  }

  @override
  void _onClose() {
    super._onClose();
    // 关闭前的清理逻辑
  }
}
```

#### 资源自动清理

```dart
class MyController extends BaseController {
  late TextEditingController textController;
  late PageController pageController;

  @override
  void _onInit() {
    super._onInit();
    
    // 注册资源，会自动清理
    textController = TextEditingController();
    registerTextController(textController);
    
    pageController = PageController();
    registerPageController(pageController);
  }
  
  // 不需要手动在 onClose 中清理，基类会自动处理
}
```

#### 状态管理

```dart
class MyController extends BaseController {
  void loadData() {
    // 设置加载状态
    setLoading(true);
    
    // 执行异步操作
    fetchData().then((data) {
      setLoading(false);
      // 处理数据
    }).catchError((error) {
      setLoading(false);
      setError(error.toString());
    });
  }
  
  // 或者使用 executeAsync 自动管理状态
  void loadDataAuto() {
    executeAsync(
      action: () => fetchData(),
      onSuccess: (data) {
        // 处理数据
      },
      onError: (error) {
        // 处理错误
      },
    );
  }
}
```

#### 提示和导航

```dart
class MyController extends BaseController {
  void saveData() {
    executeAsync(
      action: () => api.saveData(),
      onSuccess: (result) {
        showSuccess('保存成功');
        goBack(); // 返回上一页
      },
      onError: (error) {
        showError('保存失败: $error');
      },
    );
  }
  
  void navigateToDetail(String id) {
    navigateTo('/detail', parameters: {'id': id});
  }
}
```

### BaseLoadingController 使用

适用于需要显示加载对话框的场景：

```dart
class MyController extends BaseLoadingController {
  @override
  String get loadingMessage => '正在加载数据...';
  
  void loadData() {
    executeAsync(
      action: () => fetchData(),
      showLoading: true, // 会显示加载对话框
      onSuccess: (data) {
        // 处理数据
      },
    );
  }
}
```

### BasePage 使用

#### 基础页面

```dart
class MyPage extends BasePage<MyController> {
  const MyPage({super.key});
  
  @override
  String? get pageTitle => '我的页面';
  
  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        Text('页面内容'),
      ],
    );
  }
}
```

#### 滚动页面

```dart
class MyScrollPage extends BaseScrollPage<MyController> {
  const MyScrollPage({super.key});
  
  @override
  String? get pageTitle => '滚动页面';
  
  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      children: [
        Text('滚动内容'),
        // 更多内容...
      ],
    );
  }
}
```

#### 列表页面

```dart
class MyListPage extends BaseListPage<MyController, ItemModel> {
  const MyListPage({super.key});
  
  @override
  String? get pageTitle => '列表页面';
  
  @override
  List<ItemModel> get items => controller.items;
  
  @override
  Widget buildListItem(BuildContext context, ItemModel item, int index) {
    return ListTile(
      title: Text(item.title),
      onTap: () => controller.onItemTap(item),
    );
  }
}
```

### BaseModel 使用

```dart
class UserModel extends BaseModel {
  final String id;
  final String name;
  final String email;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });
  
  // 从 JSON 创建
  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        email = json['email'] as String;
  
  // 转换为 JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
  
  // 复制模型
  @override
  UserModel copy() {
    return UserModel(
      id: id,
      name: name,
      email: email,
    );
  }
  
  // 数据验证
  @override
  bool validate() {
    return id.isNotEmpty && name.isNotEmpty && email.isNotEmpty;
  }
  
  @override
  String? getValidationError() {
    if (id.isEmpty) return 'ID 不能为空';
    if (name.isEmpty) return '姓名不能为空';
    if (email.isEmpty) return '邮箱不能为空';
    return null;
  }
}

// 使用
final user = UserModel.fromJson(jsonData);
final userList = BaseModel.fromJsonList<UserModel>(jsonList, (json) => UserModel.fromJson(json));
```

## 🔄 迁移指南

### 迁移 Controller

**迁移前**:
```dart
class MyController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);
  late TextEditingController textController;
  
  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
  }
  
  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
```

**迁移后**:
```dart
class MyController extends BaseController {
  late TextEditingController textController;
  
  @override
  void _onInit() {
    super._onInit();
    textController = TextEditingController();
    registerTextController(textController);
  }
  
  // 不需要手动清理，基类会自动处理
}
```

### 迁移 Page

**迁移前**:
```dart
class MyPage extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('我的页面')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return Text('内容');
      }),
    );
  }
}
```

**迁移后**:
```dart
class MyPage extends BasePage<MyController> {
  @override
  String? get pageTitle => '我的页面';
  
  @override
  Widget buildContent(BuildContext context) {
    return Text('内容');
  }
}
```

## 📊 优势对比

### 代码减少

| 功能 | 迁移前 | 迁移后 | 减少 |
|------|--------|--------|------|
| Controller 基础代码 | ~30 行 | ~10 行 | 67% |
| Page 基础代码 | ~40 行 | ~15 行 | 63% |
| 资源清理代码 | ~20 行 | 0 行 | 100% |

### 功能增强

- ✅ 自动资源清理，避免内存泄漏
- ✅ 统一的状态管理
- ✅ 统一的错误处理
- ✅ 统一的加载状态显示
- ✅ 统一的提示和导航方法

### 可维护性提升

- ✅ 修改基类即可影响所有子类
- ✅ 统一的代码风格
- ✅ 减少重复代码
- ✅ 易于测试和维护

## 🎯 最佳实践

### 1. 优先使用基类
- ✅ 所有 Controller 继承 `BaseController`
- ✅ 所有 Page 继承 `BasePage` 或其子类
- ✅ 所有 Model 继承 `BaseModel`

### 2. 资源管理
- ✅ 使用 `registerXxx` 方法注册资源
- ✅ 不要在 `onClose` 中手动清理已注册的资源
- ✅ 只清理未注册的资源

### 3. 状态管理
- ✅ 使用 `executeAsync` 处理异步操作
- ✅ 使用 `setLoading` 和 `setError` 管理状态
- ✅ 使用基类提供的提示方法

### 4. 错误处理
- ✅ 使用 `setError` 设置错误
- ✅ 使用 `clearError` 清除错误
- ✅ 基类会自动显示错误状态

---

**创建时间**: 2025-01-XX  
**文件位置**: 
- `lib/base/base_controller.dart`
- `lib/base/base_page.dart`
- `lib/base/base_model.dart`
