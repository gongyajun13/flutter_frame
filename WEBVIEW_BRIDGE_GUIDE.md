# WebView 桥接功能使用指南

## 📖 概述

WebView 桥接功能实现了 H5 ↔ Flutter 之间的双向通信，支持灵活的方法注册和扩展。

## 🎯 核心功能

### 1. H5 调用 Flutter

H5 可以通过 `window.FlutterBridge` 对象调用 Flutter 方法，并通过回调获取返回结果。

### 2. Flutter 调用 H5

Flutter 可以主动调用 H5 中定义的方法，支持传递参数和获取返回值。

### 3. 自定义方法扩展

开发者可以注册自定义桥接方法，实现特定业务逻辑。

## 🚀 快速开始

### 基础使用

```dart
SimpleFullScreenWebView(
  url: 'https://example.com',
  title: '示例页面',
  enableBridge: true,  // 启用桥接（默认启用）
  onBridgeReady: (bridgeManager) {
    // 桥接就绪后的回调
    print('桥接已初始化');
  },
)
```

### 注册自定义方法

```dart
SimpleFullScreenWebView(
  url: 'https://example.com',
  title: '示例页面',
  enableBridge: true,
  onBridgeReady: (bridgeManager) {
    // 注册自定义方法
    bridgeManager.registerHandler('customMethod', (params) async {
      final input = params['input'] as String?;
      // 处理业务逻辑
      return {'output': 'Processed: $input'};
    });
  },
)
```

## 📱 H5 端使用

### 调用 Flutter 方法

```javascript
// 基本调用
window.FlutterBridge.callFlutter('methodName', {
  param1: 'value1',
  param2: 'value2'
}, function(result) {
  if (result.success) {
    console.log('成功:', result.data);
  } else {
    console.error('失败:', result.error);
  }
});

// 快捷方式（无回调）
window.callFlutter('methodName', {param: 'value'});
```

### 示例：H5 调用内置方法

```javascript
// 1. 显示 Toast
window.FlutterBridge.callFlutter('showToast', {
  message: 'Hello from H5!',
  type: 'success'  // success, error, warning, info
}, function(result) {
  console.log('Toast 显示完成');
});

// 2. 获取用户信息
window.FlutterBridge.callFlutter('getUserInfo', {}, function(result) {
  if (result.success) {
    const user = result.data;
    console.log('用户ID:', user.userId);
    console.log('用户名:', user.userName);
  }
});

// 3. 获取设备信息
window.FlutterBridge.callFlutter('getDeviceInfo', {}, function(result) {
  if (result.success) {
    console.log('平台:', result.data.platform);
    console.log('版本:', result.data.version);
  }
});

// 4. 关闭当前页面
window.FlutterBridge.callFlutter('closePage', {}, function(result) {
  console.log('页面即将关闭');
});

// 5. 本地存储
// 保存数据
window.FlutterBridge.callFlutter('localStorage', {
  action: 'set',
  key: 'myKey',
  value: 'myValue'
}, function(result) {
  console.log('保存成功');
});

// 获取数据
window.FlutterBridge.callFlutter('localStorage', {
  action: 'get',
  key: 'myKey'
}, function(result) {
  if (result.success) {
    console.log('值:', result.data.value);
  }
});

// 删除数据
window.FlutterBridge.callFlutter('localStorage', {
  action: 'remove',
  key: 'myKey'
}, function(result) {
  console.log('删除成功');
});
```

### 定义 H5 方法供 Flutter 调用

```javascript
// 定义一个全局方法
window.onFlutterCall = function(data) {
  console.log('收到 Flutter 调用:', data);
  // 处理数据...
};

// 返回值的方法
window.getPageData = function() {
  return {
    title: document.title,
    url: window.location.href,
    timestamp: Date.now()
  };
};
```

## 🛠️ Flutter 端使用

### Flutter 调用 H5 方法（无返回值）

```dart
void callH5() {
  bridgeManager.callH5Method('onFlutterCall', {
    'message': 'Hello from Flutter',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}
```

### Flutter 调用 H5 方法（有返回值）

```dart
Future<void> getH5Data() async {
  final result = await bridgeManager.callH5MethodWithResult('getPageData', null);
  if (result != null) {
    print('H5 返回数据: $result');
  }
}
```

### 注册自定义桥接方法

```dart
// 方法 1: 在 onBridgeReady 中注册
SimpleFullScreenWebView(
  url: 'https://example.com',
  title: '示例',
  onBridgeReady: (bridgeManager) {
    // 注册计算方法
    bridgeManager.registerHandler('calculate', (params) async {
      final a = params['a'] as num? ?? 0;
      final b = params['b'] as num? ?? 0;
      return {'result': a + b};
    });
    
    // 注册异步方法
    bridgeManager.registerHandler('fetchData', (params) async {
      final url = params['url'] as String;
      // 执行网络请求
      final response = await http.get(Uri.parse(url));
      return {'data': response.body};
    });
  },
)

// 方法 2: 保存 bridgeManager 引用后注册
WebViewBridgeManager? _bridgeManager;

// 在 onBridgeReady 中保存引用
onBridgeReady: (manager) {
  _bridgeManager = manager;
  _registerCustomMethods();
}

void _registerCustomMethods() {
  _bridgeManager?.registerHandler('myMethod', (params) async {
    // 业务逻辑
    return {'status': 'ok'};
  });
}
```

### 移除已注册的方法

```dart
bridgeManager.unregisterHandler('methodName');
```

## 📋 内置桥接方法列表

| 方法名 | 功能 | 参数 | 返回值 |
|--------|------|------|--------|
| `showToast` | 显示提示消息 | `{message: String, type: String}` | `{message: String}` |
| `getUserInfo` | 获取用户信息 | `{}` | `{userId, userName, avatar, token}` |
| `openPage` | 打开新页面 | `{url: String, title: String}` | `{message: String}` |
| `closePage` | 关闭当前页面 | `{}` | `{message: String}` |
| `getDeviceInfo` | 获取设备信息 | `{}` | `{platform, version, deviceId, osVersion}` |
| `localStorage` | 本地存储操作 | `{action: String, key: String, value: any}` | 根据 action 不同 |
| `selectImage` | 拍照/选择图片 | `{source: String}` | `{imagePath, imageUrl}` |
| `share` | 分享功能 | `{title, content, url}` | `{message: String}` |
| `scanQRCode` | 扫码功能 | `{}` | `{code, type}` |
| `getLocation` | 获取位置信息 | `{}` | `{latitude, longitude, address}` |

## 🎨 完整示例

### H5 页面完整示例

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Flutter Bridge Demo</title>
</head>
<body>
  <h1>Flutter Bridge 测试</h1>
  
  <button onclick="testFlutterCall()">调用 Flutter 方法</button>
  <div id="result"></div>

  <script>
    // 等待桥接就绪
    function checkBridge() {
      if (window.FlutterBridge) {
        console.log('桥接已就绪');
        return true;
      }
      console.log('桥接未就绪');
      return false;
    }
    
    setTimeout(checkBridge, 500);
    
    // H5 调用 Flutter
    function testFlutterCall() {
      window.FlutterBridge.callFlutter('showToast', {
        message: 'Hello from H5!',
        type: 'success'
      }, function(result) {
        document.getElementById('result').textContent = 
          JSON.stringify(result, null, 2);
      });
    }
    
    // Flutter 调用 H5
    window.onFlutterMessage = function(data) {
      console.log('收到 Flutter 消息:', data);
      alert('Flutter 说: ' + data.message);
    };
    
    window.getPageInfo = function() {
      return {
        title: document.title,
        url: window.location.href
      };
    };
  </script>
</body>
</html>
```

### Flutter 端完整示例

```dart
class MyWebViewPage extends StatefulWidget {
  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  WebViewBridgeManager? _bridgeManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendToH5,
          ),
        ],
      ),
      body: SimpleFullScreenWebView(
        url: 'https://example.com',
        title: 'Demo',
        enableBridge: true,
        onBridgeReady: (manager) {
          _bridgeManager = manager;
          _registerHandlers(manager);
        },
      ),
    );
  }

  void _registerHandlers(WebViewBridgeManager manager) {
    // 注册自定义方法
    manager.registerHandler('processData', (params) async {
      final input = params['data'] as String;
      // 处理数据
      await Future.delayed(Duration(seconds: 1));
      return {'processed': input.toUpperCase()};
    });
  }

  void _sendToH5() {
    _bridgeManager?.callH5Method('onFlutterMessage', {
      'message': 'Hello from Flutter!',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
```

## 🔧 高级用法

### 1. 异步处理

```dart
bridgeManager.registerHandler('asyncOperation', (params) async {
  // 模拟耗时操作
  await Future.delayed(Duration(seconds: 2));
  
  // 可以调用其他服务
  final result = await someService.fetchData();
  
  return {'data': result};
});
```

### 2. 错误处理

```dart
bridgeManager.registerHandler('safeOperation', (params) async {
  try {
    final result = await riskyOperation(params);
    return {'success': true, 'data': result};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
});
```

### 3. 条件注册

```dart
void _registerHandlers(WebViewBridgeManager manager) {
  // 根据用户权限注册不同方法
  if (userHasPermission) {
    manager.registerHandler('adminMethod', _handleAdminMethod);
  }
  
  // 根据平台注册不同方法
  if (Platform.isAndroid) {
    manager.registerHandler('androidSpecific', _handleAndroidMethod);
  } else if (Platform.isIOS) {
    manager.registerHandler('iosSpecific', _handleIOSMethod);
  }
}
```

### 4. 动态方法替换

```dart
// 移除旧方法
bridgeManager.unregisterHandler('oldMethod');

// 注册新方法
bridgeManager.registerHandler('oldMethod', (params) async {
  // 新的实现
  return {'version': 2};
});
```

## 🐛 调试技巧

### 1. 查看桥接日志

在 Flutter 端，所有桥接相关的日志都会输出到控制台：

```
WebViewBridge: 注册方法 "calculate"
WebViewBridge: H5 调用方法 "calculate"，参数: {a: 10, b: 20}
WebViewBridge: Flutter 调用 H5 方法 "onFlutterCall"
```

### 2. H5 端调试

```javascript
// 检查桥接是否可用
if (window.FlutterBridge) {
  console.log('✅ 桥接可用');
  window.FlutterBridge.log('测试消息');
} else {
  console.error('❌ 桥接不可用');
}
```

### 3. 捕获错误

```javascript
window.FlutterBridge.callFlutter('method', {}, function(result) {
  if (result.success) {
    console.log('成功:', result.data);
  } else {
    console.error('错误:', result.error);
    // 上报错误...
  }
});
```

## ⚠️ 注意事项

1. **桥接初始化时机**：桥接在页面加载完成（`onPageFinished`）后才初始化，H5 端应延迟检测。

2. **参数序列化**：所有传递的参数都会通过 JSON 序列化，不支持传递函数或特殊对象。

3. **异步回调**：H5 调用 Flutter 方法时，结果通过回调返回，注意处理异步逻辑。

4. **方法命名**：避免使用保留字或特殊字符作为方法名。

5. **性能考虑**：频繁的桥接调用可能影响性能，合理控制调用频率。

6. **错误处理**：始终在桥接方法中进行错误处理，避免未捕获的异常。

## 📚 扩展阅读

- [WebView Flutter 官方文档](https://pub.dev/packages/webview_flutter)
- [JavaScript Channel 说明](https://pub.dev/documentation/webview_flutter/latest/)
- [GetX 框架文档](https://pub.dev/packages/get)

## 🤝 贡献

如需添加新的内置方法或改进现有功能，请在 `WebViewBridgeManager` 中注册或修改相应方法。

---

**版本**: 1.0.0  
**更新日期**: 2025-10-21

