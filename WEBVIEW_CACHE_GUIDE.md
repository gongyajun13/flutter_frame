# WebView 缓存清除功能使用指南

## 📖 概述

`WebViewCacheManager` 提供了一套完整的 WebView 缓存管理方法，支持清除各种类型的缓存数据。

## 🎯 支持的缓存类型

- ✅ **Cookies** - HTTP Cookies
- ✅ **LocalStorage** - 本地存储
- ✅ **SessionStorage** - 会话存储
- ✅ **IndexedDB** - 索引数据库
- ✅ **磁盘缓存** - Android 平台的缓存文件

## 🚀 使用方法

### 1. 导入工具类

```dart
import 'package:flutter_frame/utils/webview_cache_manager.dart';
```

### 2. 清除所有缓存（全局）

这是最简单的方式，适用于退出登录、切换账号等场景：

```dart
// 清除所有 WebView 的 Cookies
await WebViewCacheManager.clearAllCache();
```

> **注意**：此方法仅清除 Cookies，因为 LocalStorage 和 SessionStorage 需要通过 WebViewController 在 WebView 加载后才能清除。

### 3. 清除指定 WebView 的完整缓存

如果你有 `WebViewController` 实例，可以清除该 WebView 的所有缓存：

```dart
// 获取 WebViewController
final controller = /* ... */;

// 清除该 WebView 的所有缓存
await WebViewCacheManager.clearCache(
  controller,
  includeDiskFiles: true,  // 是否清除磁盘缓存文件
);
```

这会清除：
- Cookies
- LocalStorage
- SessionStorage
- IndexedDB
- 磁盘缓存文件（Android）

### 4. 仅清除 Cookies

```dart
await WebViewCacheManager.clearCookies();
```

### 5. 仅清除 LocalStorage

```dart
final controller = /* ... */;
await WebViewCacheManager.clearLocalStorage(controller);
```

### 6. 仅清除 SessionStorage

```dart
final controller = /* ... */;
await WebViewCacheManager.clearSessionStorage(controller);
```

### 7. 仅清除 IndexedDB

```dart
final controller = /* ... */;
await WebViewCacheManager.clearIndexedDB(controller);
```

### 8. 仅清除磁盘缓存（Android）

```dart
final controller = /* ... */;
await WebViewCacheManager.clearDiskCache(controller);
// 注意：此方法仅适用于 Android 平台
```

## 📱 实际应用场景

### 场景 1: 退出登录

```dart
Future<void> logout() async {
  try {
    // 1. 清除所有 WebView 缓存
    await WebViewCacheManager.clearAllCache();
    
    // 2. 清除其他应用数据
    await clearUserData();
    
    // 3. 跳转到登录页
    Navigator.pushReplacementNamed(context, '/login');
    
    // 显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已退出登录')),
    );
  } catch (e) {
    debugPrint('退出登录失败: $e');
  }
}
```

### 场景 2: 切换账号

```dart
Future<void> switchAccount() async {
  try {
    // 清除当前账号的缓存
    await WebViewCacheManager.clearAllCache();
    
    // 重新加载 WebView
    await controller.reload();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('缓存已清除，请重新登录')),
    );
  } catch (e) {
    debugPrint('切换账号失败: $e');
  }
}
```

### 场景 3: 清除特定域名的缓存

```dart
Future<void> clearDomainCache(String domain) async {
  try {
    // 注意：当前版本不支持按域名清除，只能清除全部
    await WebViewCacheManager.clearAllCache();
    
    debugPrint('已清除所有缓存');
  } catch (e) {
    debugPrint('清除缓存失败: $e');
  }
}
```

### 场景 4: 在应用设置中提供清除缓存选项

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.cleaning_services),
            title: Text('清除缓存'),
            subtitle: Text('清除所有 WebView 缓存数据'),
            onTap: () => _showClearCacheDialog(context),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清除缓存'),
        content: Text('确定要清除所有 WebView 缓存吗？\n这将删除所有 Cookies、本地存储等数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await WebViewCacheManager.clearAllCache();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ 缓存已清除'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ 清除失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}
```

### 场景 5: 定期自动清除缓存

```dart
class WebViewManager {
  Timer? _clearCacheTimer;

  void startPeriodicCacheClear() {
    // 每天清除一次缓存
    _clearCacheTimer = Timer.periodic(
      Duration(days: 1),
      (timer) async {
        try {
          await WebViewCacheManager.clearAllCache();
          debugPrint('定期缓存清除完成');
        } catch (e) {
          debugPrint('定期缓存清除失败: $e');
        }
      },
    );
  }

  void stopPeriodicCacheClear() {
    _clearCacheTimer?.cancel();
    _clearCacheTimer = null;
  }
}
```

## 🔧 高级用法

### 使用 SimpleFullScreenWebView 的静态方法

`SimpleFullScreenWebView` 也提供了静态方法来清除缓存：

```dart
// 清除全局缓存
await SimpleFullScreenWebView.clearAllCache();
```

### 在 SimpleFullScreenWebView 内部清除缓存

如果你需要在 WebView 内部清除缓存，可以保存 State 引用：

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey<_SimpleFullScreenWebViewState> _webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.cleaning_services),
            onPressed: () async {
              // 使用 GlobalKey 访问 State 的方法
              await _webViewKey.currentState?.clearCache();
            },
          ),
        ],
      ),
      body: SimpleFullScreenWebView(
        key: _webViewKey,
        url: 'https://example.com',
        title: 'Example',
      ),
    );
  }
}
```

## 📋 API 参考

### WebViewCacheManager 类

#### 静态方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `clearAllCache()` | 无 | `Future<void>` | 清除全局 Cookies |
| `clearCache(controller, {includeDiskFiles})` | `WebViewController`, `bool` | `Future<void>` | 清除指定 WebView 的所有缓存 |
| `clearCookies()` | 无 | `Future<void>` | 仅清除 Cookies |
| `clearLocalStorage(controller)` | `WebViewController` | `Future<void>` | 清除 LocalStorage |
| `clearSessionStorage(controller)` | `WebViewController` | `Future<void>` | 清除 SessionStorage |
| `clearIndexedDB(controller)` | `WebViewController` | `Future<void>` | 清除 IndexedDB |
| `clearDiskCache(controller)` | `WebViewController` | `Future<void>` | 清除磁盘缓存（仅 Android） |
| `setCookie(url, name, value, {domain, path})` | `String`, `String`, `String`, `String?`, `String` | `Future<void>` | 设置 Cookie |

## ⚠️ 注意事项

1. **LocalStorage 和 SessionStorage 清除时机**
   - 必须在 WebView 加载完成后才能清除
   - 需要通过 `WebViewController` 执行 JavaScript

2. **平台差异**
   - 磁盘缓存清除仅支持 Android 平台
   - iOS 平台的缓存管理由系统自动处理

3. **异常处理**
   - 所有方法都可能抛出异常
   - 建议使用 try-catch 捕获错误

4. **性能考虑**
   - 清除缓存是异步操作，可能需要一些时间
   - 避免频繁清除缓存，影响用户体验

5. **数据丢失风险**
   - 清除缓存会删除所有相关数据
   - 清除前应提示用户确认

## 🐛 常见问题

### Q: 清除缓存后为什么还有数据？

A: `clearAllCache()` 方法仅清除 Cookies。如果需要清除 LocalStorage 等数据，需要使用 `clearCache(controller)` 方法，并确保 WebView 已加载完成。

### Q: 如何清除特定域名的缓存？

A: 当前版本不支持按域名清除，只能清除全部缓存。

### Q: 清除缓存会影响其他应用吗？

A: 不会。WebView 的缓存是应用独立的，不会影响其他应用或系统浏览器。

### Q: iOS 平台如何清除磁盘缓存？

A: iOS 平台的 WebView 缓存由系统管理，不需要手动清除。如果确实需要，可以尝试清除 Cookies 和 LocalStorage。

## 📚 相关文档

- [WebView Flutter 官方文档](https://pub.dev/packages/webview_flutter)
- [WebView 桥接功能指南](WEBVIEW_BRIDGE_GUIDE.md)

---

**版本**: 1.0.0  
**更新日期**: 2025-10-21

