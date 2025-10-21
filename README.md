# Flutter Frame 📱

一个基于 GetX 的 MVVM 架构 Flutter 项目，集成了丰富的工具类和功能演示。

## ✨ 特性

- 🌐 **网络请求系统**：基于 Dio 的完整封装
- 🎨 **GetX 工具类**：Dialog、SnackBar 等全局工具
- 📱 **屏幕适配**：flutter_screenutil 完整集成
- 🖼️ **图片组件**：多种缓存图片 Widget
- 💾 **本地缓存**：SharedPreferences 封装
- 🔗 **URL 跳转**：各种跳转场景支持
- 🌍 **WebView**：H5 ↔ Flutter 桥接通信
- 🏗️ **MVVM 架构**：清晰的代码组织

## 🚀 快速开始

### 运行项目
```bash
# 进入项目目录
cd /Users/bd/HotDog/flutter_frame

# 运行应用
flutter run

# 指定设备运行
flutter run -d <device_id>
```

### 查看演示
应用包含 **9 个功能演示页面**：

1. 简化网络请求演示
2. 屏幕适配演示
3. GetX 工具演示
4. 缓存图片 Widget 演示
5. 本地缓存工具演示
6. URL 跳转工具演示
7. 全屏 WebView 演示
8. WebView 桥接演示
9. 自定义对话框演示

## 📚 文档

### 📖 [完整文档索引](./DOCS_INDEX.md)

#### 功能指南（10 个）
- [网络请求使用指南](./SIMPLE_NETWORK_USAGE.md)
- [GetX 工具指南](./GETX_UTILS_GUIDE.md)
- [自定义对话框指南](./CUSTOM_DIALOG_GUIDE.md)
- [屏幕适配指南](./SCREEN_ADAPTATION_GUIDE.md)
- [缓存图片组件指南](./CACHED_IMAGE_WIDGETS_GUIDE.md)
- [本地缓存工具指南](./LOCAL_CACHE_UTIL_GUIDE.md)
- [URL 跳转工具指南](./URL_LAUNCHER_UTIL_GUIDE.md)
- [WebView 桥接指南](./WEBVIEW_BRIDGE_GUIDE.md)
- [WebView 缓存指南](./WEBVIEW_CACHE_GUIDE.md)
- [MVVM 架构指南](./MVVM_ARCHITECTURE_GUIDE.md)

#### 重要总结（4 个）
- [项目最终总结](./FINAL_SUMMARY.md)
- [所有崩溃修复总结](./ALL_CRASHES_FIXED_SUMMARY.md)
- [缓存图片简化优化](./CACHED_IMAGE_SIMPLIFICATION.md)
- [SnackBar 防抖机制](./SNACKBAR_DEBOUNCE_FEATURE.md)

## 🛠️ 技术栈

### 核心框架
- Flutter 3.x
- Dart 3.x
- GetX 4.x/5.x

### 主要依赖
```yaml
dependencies:
  get: ^4.x                          # 状态管理、路由
  dio: ^5.x                          # 网络请求
  flutter_screenutil: ^5.9.3         # 屏幕适配
  cached_network_image: ^3.3.0       # 图片缓存
  shared_preferences: ^2.2.2         # 本地缓存
  url_launcher: ^6.2.2               # URL 跳转
  webview_flutter: ^4.13.0           # WebView
```

## 🌟 核心亮点

### 1. 自定义对话框系统
- 5 种对话框类型
- 4 种便捷按钮
- 完美的标题居中
- 终极关闭方法

### 2. SnackBar 防抖机制
- 500ms 防抖窗口
- 智能复用窗口
- 快速内容更新

### 3. 简洁的图片组件
- 三种核心状态
- 零布局溢出
- 自适应尺寸

### 4. WebView 桥接
- H5 ↔ Flutter 双向通信
- 方法注册和调用
- 完整的缓存管理

## 📁 项目结构

```
flutter_frame/
├── lib/
│   ├── app/                # 应用层
│   │   ├── routes/        # 路由配置
│   │   ├── services/      # 全局服务
│   │   └── middleware/    # 路由中间件
│   ├── network/           # 网络层
│   │   ├── core/         # NetworkManager
│   │   ├── services/     # NetworkService、ApiService
│   │   └── ...
│   ├── pages/            # 页面（MVVM）
│   │   ├── home/
│   │   ├── *_demo/      # 各种演示页面
│   │   └── ...
│   ├── widgets/          # 自定义组件
│   │   ├── cached_image_widgets.dart
│   │   └── simple_fullscreen_webview.dart
│   └── utils/            # 工具类
│       ├── getx_dialog_util.dart
│       ├── getx_snackbar_util.dart
│       ├── local_cache_util.dart
│       └── ...
└── 文档/
    ├── 功能指南（10 个）
    └── 重要总结（4 个）
```

## 🎯 开发指南

### 添加新页面
```bash
# 1. 创建页面目录
mkdir lib/pages/my_page

# 2. 创建必要文件
lib/pages/my_page/
├── my_page.dart          # View
├── my_controller.dart    # ViewModel
└── my_binding.dart       # Binding

# 3. 注册路由
# 在 lib/app/routes/app_routes.dart 和 app_pages.dart 中添加路由
```

### 使用工具类
```dart
// Dialog
GetXDialogUtil.showLoading(message: '加载中...');
GetXDialogUtil.showConfirm(title: '确认', message: '确定吗？');

// SnackBar
GetXSnackBarUtil.success(message: '操作成功');
GetXSnackBarUtil.error(message: '操作失败');

// 本地缓存
await LocalCacheUtil.setString('key', 'value');
String? value = await LocalCacheUtil.getString('key');
```

## 📊 项目状态

| 指标 | 状态 |
|------|------|
| Linter 错误 | 0 ✅ |
| 已知崩溃 | 0 ✅ |
| 功能完成度 | 100% ✅ |
| 文档完整度 | 100% ✅ |
| 运行状态 | ✅ 稳定 |

## 🎉 项目成就

- ✅ **9 个演示页面**
- ✅ **7 个工具类**
- ✅ **8 个自定义 Widget**
- ✅ **14 个文档**
- ✅ **0 个已知问题**

## 📄 许可证

MIT License

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

---

**项目版本**: 2.0.0  
**更新日期**: 2025-10-21  
**状态**: ✅ 稳定运行

查看 **[完整文档索引](./DOCS_INDEX.md)** 了解更多详情。