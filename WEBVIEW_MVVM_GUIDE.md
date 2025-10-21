# WebView MVVM 架构指南

## 🎯 概述

基于 GetX 的 MVVM 架构 WebView 实现，将业务逻辑与 UI 完全分离。

## 📁 文件结构

```
lib/pages/webview_mvvm_demo/
├── webview_mvvm_controller.dart        # ViewModel（业务逻辑）
├── webview_mvvm_page.dart             # View（UI 界面）
├── webview_mvvm_binding.dart          # Binding（依赖注入）
├── webview_mvvm_demo_page.dart        # 演示入口页面
└── webview_mvvm_demo_binding.dart     # 演示入口 Binding
```

## 🏗️ MVVM 架构

### Model（数据模型）
- WebView 状态数据
- 加载进度、错误信息、URL 等

### View（视图层）
- `WebViewMvvmPage`：纯 UI 展示
- 使用 `GetView<WebViewMvvmController>`
- 通过 `Obx` 响应状态变化

### ViewModel（视图模型层）
- `WebViewMvvmController`：业务逻辑
- 管理 WebView 状态
- 处理用户交互
- 提供数据给 View

## 🔧 核心功能

### 1. WebView 管理
```dart
// Controller 中
late WebViewController webViewController;

// 初始化
void initializeWebView() {
  webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setUserAgent('...');
}

// 加载 URL
void loadUrl(String url) {
  webViewController.loadRequest(Uri.parse(url));
}
```

### 2. 响应式状态
```dart
// 所有状态都是响应式的
final isLoading = true.obs;
final loadingProgress = 0.0.obs;
final errorMessage = Rx<String?>(null);
final currentUrl = ''.obs;
final canGoBack = false.obs;
final canGoForward = false.obs;
```

### 3. 业务逻辑
```dart
// 刷新页面
void reload() {
  errorMessage.value = null;
  isLoading.value = true;
  webViewController.reload();
}

// 返回上一页
Future<void> goBack() async {
  if (await webViewController.canGoBack()) {
    webViewController.goBack();
  }
}

// 前进下一页
Future<void> goForward() async {
  if (await webViewController.canGoForward()) {
    webViewController.goForward();
  }
}
```

### 4. 错误处理
```dart
// 处理 Web 资源错误
void handleWebResourceError(WebResourceError error) {
  // 只处理主 frame 的错误
  if (error.isForMainFrame != true) return;
  
  // 忽略特定错误
  if (_shouldIgnoreError(error)) return;
  
  // 显示错误
  isLoading.value = false;
  errorMessage.value = formatErrorMessage(error);
}
```

### 5. 特殊协议处理
```dart
// 处理 tel:, mailto:, sms: 等协议
Future<void> handleSpecialScheme(String url, Uri uri) async {
  switch (uri.scheme) {
    case 'tel':
      await UrlLauncherUtil.makePhoneCall(uri.path);
      break;
    case 'mailto':
      await UrlLauncherUtil.sendEmail(to: uri.path);
      break;
    // ...
  }
}
```

### 6. 缓存管理
```dart
// 清除所有缓存
Future<void> clearCache({bool includeDiskFiles = true}) async {
  // 清除 Cookies
  // 清除 LocalStorage/SessionStorage
  // 清除磁盘缓存（Android）
}

// 清除 Cookies
Future<void> clearCookies() async { ... }

// 清除 LocalStorage
Future<void> clearLocalStorage() async { ... }
```

## 💡 使用示例

### 基础使用
```dart
// 打开 WebView（通过路由）
Get.toNamed(
  Routes.WEBVIEW_MVVM,
  parameters: {
    'url': 'https://flutter.dev',
    'enableBridge': 'false',
  },
);
```

### 启用桥接
```dart
Get.toNamed(
  Routes.WEBVIEW_MVVM,
  parameters: {
    'url': 'https://your-h5-app.com',
    'enableBridge': 'true',
  },
);
```

### 在 Controller 中使用
```dart
class MyController extends GetxController {
  void openWebPage() {
    Get.toNamed(
      Routes.WEBVIEW_MVVM,
      parameters: {
        'url': 'https://example.com',
        'enableBridge': 'true',
      },
    );
  }
}
```

## 🎨 View 层实现

### 响应式 UI
```dart
class WebViewMvvmPage extends GetView<WebViewMvvmController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() {
        // 响应式显示错误或 WebView
        if (controller.errorMessage.value != null) {
          return _buildErrorWidget();
        }
        return _buildWebView();
      }),
    );
  }
}
```

### AppBar 按钮状态
```dart
// 后退按钮（根据状态启用/禁用）
Obx(() => IconButton(
      onPressed: controller.canGoBack.value
          ? () => controller.goBack()
          : null,
      icon: Icon(Icons.arrow_back_ios),
    ))
```

### 加载进度条
```dart
Obx(() {
  if (controller.isLoading.value && 
      controller.loadingProgress.value < 1.0) {
    return LinearProgressIndicator(
      value: controller.loadingProgress.value,
    );
  }
  return SizedBox.shrink();
})
```

## 🔄 与 SimpleFullScreenWebView 的对比

### SimpleFullScreenWebView（Widget 方式）
```dart
// 优点：
✅ 简单直接，易于使用
✅ 适合简单场景
✅ 自包含，无需额外配置

// 缺点：
❌ 逻辑和 UI 混合
❌ 状态管理不够灵活
❌ 难以复用逻辑
```

**使用场景**：
- 简单的网页展示
- 一次性使用
- 不需要复杂交互

### WebView MVVM（Controller 方式）
```dart
// 优点：
✅ 逻辑和 UI 完全分离
✅ 状态管理响应式
✅ 易于测试和维护
✅ 逻辑可复用

// 缺点：
❌ 文件较多
❌ 需要配置路由和 Binding
```

**使用场景**：
- 复杂的 WebView 功能
- 需要状态管理
- 需要复用逻辑
- 需要单元测试

## 📊 架构对比

| 特性 | SimpleFullScreenWebView | WebView MVVM |
|------|------------------------|--------------|
| 架构模式 | Widget | MVVM |
| 状态管理 | setState | GetX 响应式 |
| 逻辑位置 | Widget 内 | Controller |
| UI 位置 | Widget | View |
| 文件数量 | 1 个 | 4 个 |
| 复杂度 | 低 | 中 |
| 可维护性 | 中 | 高 ✅ |
| 可测试性 | 低 | 高 ✅ |
| 逻辑复用 | 难 | 易 ✅ |

## 🎯 选择建议

### 使用 SimpleFullScreenWebView
```dart
// 简单场景
SimpleFullScreenWebView(
  url: 'https://flutter.dev',
  title: 'Flutter 官网',
)
```

适用于：
- ✅ 简单的网页展示
- ✅ 临时性的 WebView
- ✅ 不需要复杂状态管理

### 使用 WebView MVVM
```dart
// 复杂场景
Get.toNamed(
  Routes.WEBVIEW_MVVM,
  parameters: {'url': 'https://your-app.com'},
);
```

适用于：
- ✅ 复杂的 WebView 功能
- ✅ 需要状态管理和响应式 UI
- ✅ 需要单元测试
- ✅ 逻辑需要复用

## 📱 功能特性

### 1. 完整的导航控制
- ✅ 前进/后退按钮
- ✅ 刷新按钮
- ✅ 返回键处理
- ✅ 按钮状态响应式更新

### 2. 加载状态管理
- ✅ 加载进度条
- ✅ 错误状态显示
- ✅ 重试功能
- ✅ 响应式更新

### 3. 缓存管理
- ✅ 清除所有缓存
- ✅ 清除 Cookies
- ✅ 清除 LocalStorage
- ✅ 菜单操作

### 4. 特殊协议处理
- ✅ tel:（电话）
- ✅ mailto:（邮件）
- ✅ sms:（短信）
- ✅ market:（应用商店）

### 5. 桥接功能（可选）
- ✅ H5 → Flutter 通信
- ✅ Flutter → H5 通信
- ✅ 方法注册和调用

## 🚀 快速开始

### 1. 访问演示页面
```
首页 → WebView MVVM 演示
```

### 2. 选择示例
- 加载 Flutter 官网
- 加载 GitHub
- 加载百度
- 启用桥接的 WebView

### 3. 体验功能
- 点击前进/后退按钮
- 查看加载进度
- 测试错误处理
- 使用缓存管理

## 📚 相关文档

- [SimpleFullScreenWebView](./simple_fullscreen_webview.dart)
- [WebView 桥接指南](./WEBVIEW_BRIDGE_GUIDE.md)
- [WebView 缓存指南](./WEBVIEW_CACHE_GUIDE.md)
- [MVVM 架构指南](./MVVM_ARCHITECTURE_GUIDE.md)

## 🎉 总结

WebView MVVM 架构实现完成！

- ✅ **完整的 MVVM 架构**：Model-View-ViewModel 分离
- ✅ **GetX 状态管理**：响应式 UI 更新
- ✅ **业务逻辑分离**：Controller 管理所有逻辑
- ✅ **UI 层纯净**：View 只负责展示
- ✅ **易于测试**：Controller 可独立测试
- ✅ **逻辑可复用**：Controller 可在多处使用

现在你有两种 WebView 实现方式可选：
- **SimpleFullScreenWebView**：简单快速
- **WebView MVVM**：规范可维护

根据需求选择合适的方式！🚀

---

**功能版本**: 1.0.0  
**完成日期**: 2025-10-21  
**功能**: WebView MVVM 架构实现
