# Flutter Frame 📱

一个基于 **GetX + MVVM** 的 Flutter 框架项目，集成了丰富的工具类和功能演示，适合作为中大型应用的脚手架。

## ✨ 核心特性

- 🏗️ **MVVM 基础框架**：`BaseController` / `BasePage` / `BaseModel`，统一生命周期、Loading、错误处理
- 🎨 **设计令牌系统**：`AppDesignTokens` + `AppButton` + `AppCard`，全局统一 UI/UX 风格，支持动态主题
- 🌙 **多主题换肤**：内置多套预设主题（经典蓝、极夜黑、商务蓝、森林绿、霓虹紫、火焰橙）+ 自定义主题管理
- 🌐 **网络请求系统**：基于 Dio 的完整封装（`NetworkManager`、拦截器、统一错误处理）
- 🤝 **GetX 工具类**：Dialog / SnackBar / 工具方法的统一封装
- 📱 **屏幕适配**：`flutter_screenutil` 完整集成，支持多终端
- 🖼️ **缓存图片组件**：多种缓存图片 Widget，支持占位、错误图、重试等
- 📸 **图片处理工具**：选择、裁剪、压缩、上传一体化封装
- 💾 **本地缓存工具**：`SharedPreferences` 上层封装，支持过期/JSON/列表等
- 🔗 **URL 跳转工具**：统一处理浏览器、电话、邮件、地图、应用市场等跳转
- 🌍 **WebView 模块**：统一的 WebView 功能演示 + JSBridge 管理 + 缓存/文件选择等扩展
- 🤖 **DeepSeek AI 集成**：完整的 DeepSeek Chat & Code 演示页，支持 API Key 配置、连接检测等

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
应用首页提供了多个功能演示入口（当前约 13 个）：

1. **简化网络请求演示**（`SimpleNetworkDemo`）
2. **屏幕适配演示**（`ScreenAdaptationDemo`）
3. **GetX 工具演示**（SnackBar / Dialog 等）
4. **缓存图片演示**（多状态图片组件）
5. **本地缓存工具演示**（基本类型 & 复杂对象 & 过期策略）
6. **URL 跳转工具演示**（浏览器、电话、邮件、地图等）
7. **自定义对话框演示**
8. **图片处理工具演示** ⭐️（选择 + 裁剪 + 压缩 + 上传流程）
9. **视频播放器演示**
10. **DeepSeek AI 演示**（聊天对话 & 代码生成）
11. **主题设置 / 换肤演示**
12. **权限请求工具演示**
13. **WebView 功能演示（整合版）**（基础浏览 + JSBridge 交互）

## 📚 文档

> 文档位于项目根目录，按功能拆分，方便按需查阅。

#### 功能指南
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
- [图片处理工具指南](./IMAGE_UTIL_GUIDE.md) ⭐️
  - [配置指南](./IMAGE_UTIL_CONFIG.md)
- [高级图片选择与裁剪指南](./ADVANCED_IMAGE_PICKER_GUIDE.md) 🎨

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
  image_picker: ^1.0.7               # 图片选择
  image_cropper: ^5.0.1              # 图片裁剪
  flutter_image_compress: ^2.1.0     # 图片压缩
  permission_handler: ^11.2.0        # 权限处理
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

### 5. 图片处理工具 ⭐️
- 图片选择（相机/相册/多选）
- 图片裁剪（多种比例）
- 图片压缩（质量/大小）
- 图片上传（单张/批量）
- 完整流程一键处理

### 6. 高级图片选择与裁剪 🎨
- 相册目录浏览
- 多选图片（带序号标识）
- 实时预览
- 高级裁剪（多比例/圆形）
- 批量处理

## 📁 项目结构（简化版）

```
flutter_frame/
├── lib/
│   ├── app/                   # 应用层
│   │   ├── routes/           # 路由配置（AppPages / AppRoutes）
│   │   ├── services/         # 全局服务（主题、存储等）
│   │   └── widgets/          # 全局小部件（主题选择器等）
│   ├── base/                  # MVVM 基类
│   │   ├── base_controller.dart
│   │   ├── base_page.dart
│   │   └── base_model.dart
│   ├── network/               # 网络层
│   │   ├── core/             # NetworkManager、拦截器
│   │   ├── services/         # ApiService、DeepSeekService 等
│   │   └── config/           # 接口配置、DeepSeekConfig 等
│   ├── pages/                # 页面（MVVM）
│   │   ├── home/             # 首页
│   │   ├── *_demo/           # 各种功能演示页面
│   │   └── deepseek_demo/    # DeepSeek AI 演示
│   ├── widgets/              # 通用组件
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   └── simple_fullscreen_webview.dart
│   ├── theme/                # 设计令牌 & 主题系统
│   │   ├── app_design_tokens.dart
│   │   └── README_DESIGN_TOKENS_THEME.md
│   └── utils/                # 工具类
│       ├── getx_dialog_util.dart
│       ├── getx_snackbar_util.dart
│       ├── local_cache_util.dart
│       ├── image_util.dart        # 图片处理工具 ⭐️
│       ├── permission_util.dart   # 权限工具
│       └── webview_*.dart         # WebView 相关工具
└── 文档/                         # 各功能说明文档（README 中已列出部分）
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

// 图片处理 ⭐️
final file = await ImageUtil.pickFromGallery();
final cropped = await ImageUtil.cropImage(file);
final compressed = await ImageUtil.compressToSize(cropped, maxSizeKB: 500);
await ImageUtil.uploadImage(compressed, url);
```

## 📊 项目状态（当前全局分析）

| 指标           | 状态                    |
|----------------|-------------------------|
| Linter 错误    | 0 ✅                    |
| 已知崩溃       | 0 ✅                    |
| 主要功能完成度 | 高（核心演示全部可用）  |
| 文档覆盖       | 主要模块均有说明文档    |
| 运行状态       | ✅ 稳定                 |

### 现状与后续可优化点

- ✅ 所有演示页已迁移到 `BaseController` / `BasePage` 架构，并统一使用 `AppDesignTokens` + `AppButton` + `AppCard`
- ✅ Loading / 错误提示 / SnackBar 已通过基类和工具类统一管理
- ✅ DeepSeek AI、WebView、权限、图片处理等复杂模块已整理为独立 Demo
- 🔄 WebView Bridge 中部分功能（选图、扫码、分享、定位等）保留了 `TODO`，便于后续按业务需求接入对应插件
- 🔄 个别高级图片预览功能（如旋转、滤镜）在设计文档中留有扩展点，可视业务需要再实现

## 🎉 项目成就（里程碑）

- ✅ 多个完整的功能演示页面（网络、缓存、图片、WebView、权限、主题、AI 等）
- ✅ 一套可复用的 MVVM 基类 + 设计令牌 + 统一组件体系
- ✅ 覆盖常见场景的工具类（缓存、权限、对话框、SnackBar、URL、WebView 等）
- ✅ 完整的中文文档，方便二次开发与团队协作

## 📄 许可证

MIT License

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

---

**项目版本**: 2.3.0  
**更新日期**: 2026-01-27  
**状态**: ✅ 稳定运行
