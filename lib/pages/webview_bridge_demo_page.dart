import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/simple_fullscreen_webview.dart';
import '../utils/webview_bridge_manager.dart';
import '../utils/webview_cache_manager.dart';

/// WebView 桥接功能演示页面
class WebViewBridgeDemoPage extends StatefulWidget {
  const WebViewBridgeDemoPage({super.key});

  @override
  State<WebViewBridgeDemoPage> createState() => _WebViewBridgeDemoPageState();
}

class _WebViewBridgeDemoPageState extends State<WebViewBridgeDemoPage> {
  WebViewBridgeManager? _bridgeManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WebView 桥接演示',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // 清除缓存按钮
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: '清除缓存',
            onPressed: _clearCache,
          ),
        ],
      ),
      body: Column(
        children: [
          // 操作按钮区域
          _buildControlButtons(),
          
          // WebView 区域
          Expanded(
            child: SimpleFullScreenWebView(
              url: _getDemoHtmlUrl(),
              title: '桥接测试',
              enableBridge: true,
              onBridgeReady: (bridgeManager) {
                setState(() {
                  _bridgeManager = bridgeManager;
                });
                
                // 注册自定义桥接方法
                _registerCustomMethods(bridgeManager);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButtons() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          _buildButton(
            'Flutter调H5',
            Colors.blue,
            _bridgeManager != null ? _callH5Method : null,
          ),
          _buildButton(
            '发送数据',
            Colors.green,
            _bridgeManager != null ? _sendDataToH5 : null,
          ),
          _buildButton(
            '更新标题',
            Colors.orange,
            _bridgeManager != null ? _updateH5Title : null,
          ),
          _buildButton(
            '获取H5数据',
            Colors.purple,
            _bridgeManager != null ? _getH5Data : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        elevation: onPressed == null ? 0 : 2,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.sp),
      ),
    );
  }

  /// 注册自定义桥接方法
  void _registerCustomMethods(WebViewBridgeManager manager) {
    // 示例：自定义方法 - 计算两数之和
    manager.registerHandler('calculate', (params) async {
      final a = params['a'] as num? ?? 0;
      final b = params['b'] as num? ?? 0;
      return {'result': a + b};
    });

    // 示例：自定义方法 - 获取当前时间
    manager.registerHandler('getCurrentTime', (params) async {
      return {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'datetime': DateTime.now().toString(),
      };
    });

    // 示例：自定义方法 - 打印日志
    manager.registerHandler('logMessage', (params) async {
      final message = params['message'] as String? ?? '';
      debugPrint('H5日志: $message');
      return {'logged': true};
    });
  }

  /// Flutter 调用 H5 方法
  void _callH5Method() {
    _bridgeManager?.callH5Method('onFlutterCall', {
      'message': '这是来自 Flutter 的消息',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 发送数据到 H5
  void _sendDataToH5() {
    _bridgeManager?.callH5Method('receiveData', {
      'type': 'user_info',
      'data': {
        'name': 'Flutter User',
        'age': 25,
        'interests': ['编程', '旅游', '音乐'],
      },
    });
  }

  /// 更新 H5 页面标题
  void _updateH5Title() {
    _bridgeManager?.callH5Method('updateTitle', {
      'title': '新标题 - ${DateTime.now().second}秒',
    });
  }

  /// 获取 H5 数据
  void _getH5Data() async {
    final result = await _bridgeManager?.callH5MethodWithResult('getPageData', null);
    if (result != null) {
      debugPrint('H5返回数据: $result');
    }
  }

  /// 清除 WebView 缓存
  void _clearCache() async {
    try {
      // 使用 WebViewCacheManager 清除全局缓存
      await WebViewCacheManager.clearAllCache();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ 缓存已清除（Cookies）'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      debugPrint('缓存清除成功');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 缓存清除失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('缓存清除失败: $e');
    }
  }

  /// 获取演示 HTML 页面的 URL
  String _getDemoHtmlUrl() {
    // 返回内联的 HTML 测试页面
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WebView 桥接测试</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      padding: 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
    }
    .container {
      background: white;
      border-radius: 16px;
      padding: 20px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    }
    h1 {
      color: #667eea;
      margin-bottom: 20px;
      font-size: 24px;
    }
    .section {
      margin-bottom: 20px;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 12px;
      border-left: 4px solid #667eea;
    }
    .section-title {
      font-weight: bold;
      color: #495057;
      margin-bottom: 10px;
      font-size: 16px;
    }
    button {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      padding: 12px 24px;
      border-radius: 8px;
      font-size: 14px;
      cursor: pointer;
      margin: 5px;
      transition: all 0.3s;
      box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
    }
    button:active {
      transform: translateY(2px);
      box-shadow: 0 2px 6px rgba(102, 126, 234, 0.4);
    }
    .log {
      background: #212529;
      color: #00ff00;
      padding: 15px;
      border-radius: 8px;
      font-family: 'Courier New', monospace;
      font-size: 12px;
      max-height: 300px;
      overflow-y: auto;
      margin-top: 10px;
      line-height: 1.6;
    }
    .log-item {
      margin-bottom: 8px;
      padding: 5px;
      border-bottom: 1px solid #333;
    }
    .timestamp {
      color: #6c757d;
      font-size: 11px;
    }
    .success {
      color: #00ff00;
    }
    .error {
      color: #ff4444;
    }
    .info {
      color: #44aaff;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1 id="page-title">🌉 WebView 桥接测试页面</h1>
    
    <div class="section">
      <div class="section-title">📱 H5 调用 Flutter 方法</div>
      <button onclick="testShowToast()">显示Toast</button>
      <button onclick="testGetUserInfo()">获取用户信息</button>
      <button onclick="testGetDeviceInfo()">获取设备信息</button>
      <button onclick="testCustomMethod()">自定义计算</button>
      <button onclick="testGetTime()">获取当前时间</button>
    </div>
    
    <div class="section">
      <div class="section-title">🔄 接收 Flutter 调用</div>
      <div style="color: #6c757d; font-size: 13px;">
        Flutter 可以调用以下 H5 方法：<br>
        • onFlutterCall(data)<br>
        • receiveData(data)<br>
        • updateTitle(data)<br>
        • getPageData()
      </div>
    </div>
    
    <div class="section">
      <div class="section-title">📋 调用日志</div>
      <div id="log" class="log">
        <div class="log-item info">等待桥接初始化...</div>
      </div>
    </div>
  </div>

  <script>
    let logCount = 0;
    
    // 添加日志
    function addLog(message, type = 'info') {
      const logEl = document.getElementById('log');
      const time = new Date().toLocaleTimeString();
      const logItem = document.createElement('div');
      logItem.className = 'log-item ' + type;
      logItem.innerHTML = '<span class="timestamp">[' + time + ']</span> ' + message;
      logEl.appendChild(logItem);
      logEl.scrollTop = logEl.scrollHeight;
      logCount++;
      
      // 限制日志数量
      if (logCount > 50) {
        logEl.removeChild(logEl.firstChild);
        logCount--;
      }
    }
    
    // 检测桥接是否就绪
    function checkBridge() {
      if (window.FlutterBridge) {
        addLog('✅ 桥接初始化成功！', 'success');
        return true;
      } else {
        addLog('❌ 桥接未初始化', 'error');
        return false;
      }
    }
    
    // 延迟检测桥接
    setTimeout(checkBridge, 500);
    
    // H5 调用 Flutter：显示 Toast
    function testShowToast() {
      if (!window.FlutterBridge) {
        addLog('❌ FlutterBridge 未就绪', 'error');
        return;
      }
      
      addLog('📤 调用 showToast 方法...', 'info');
      window.FlutterBridge.callFlutter('showToast', {
        message: '这是来自 H5 的 Toast 消息！',
        type: 'success'
      }, function(result) {
        if (result.success) {
          addLog('✅ Toast 显示成功', 'success');
        } else {
          addLog('❌ Toast 显示失败: ' + result.error, 'error');
        }
      });
    }
    
    // H5 调用 Flutter：获取用户信息
    function testGetUserInfo() {
      if (!window.FlutterBridge) return;
      
      addLog('📤 调用 getUserInfo 方法...', 'info');
      window.FlutterBridge.callFlutter('getUserInfo', {}, function(result) {
        if (result.success) {
          addLog('✅ 用户信息: ' + JSON.stringify(result.data), 'success');
        } else {
          addLog('❌ 获取失败: ' + result.error, 'error');
        }
      });
    }
    
    // H5 调用 Flutter：获取设备信息
    function testGetDeviceInfo() {
      if (!window.FlutterBridge) return;
      
      addLog('📤 调用 getDeviceInfo 方法...', 'info');
      window.FlutterBridge.callFlutter('getDeviceInfo', {}, function(result) {
        if (result.success) {
          addLog('✅ 设备信息: ' + JSON.stringify(result.data), 'success');
        } else {
          addLog('❌ 获取失败: ' + result.error, 'error');
        }
      });
    }
    
    // H5 调用 Flutter：自定义计算方法
    function testCustomMethod() {
      if (!window.FlutterBridge) return;
      
      const a = Math.floor(Math.random() * 100);
      const b = Math.floor(Math.random() * 100);
      
      addLog('📤 调用 calculate(' + a + ', ' + b + ')...', 'info');
      window.FlutterBridge.callFlutter('calculate', {a: a, b: b}, function(result) {
        if (result.success) {
          addLog('✅ 计算结果: ' + a + ' + ' + b + ' = ' + result.data.result, 'success');
        } else {
          addLog('❌ 计算失败: ' + result.error, 'error');
        }
      });
    }
    
    // H5 调用 Flutter：获取当前时间
    function testGetTime() {
      if (!window.FlutterBridge) return;
      
      addLog('📤 调用 getCurrentTime 方法...', 'info');
      window.FlutterBridge.callFlutter('getCurrentTime', {}, function(result) {
        if (result.success) {
          addLog('✅ 当前时间: ' + result.data.datetime, 'success');
        } else {
          addLog('❌ 获取失败: ' + result.error, 'error');
        }
      });
    }
    
    // =========================
    // Flutter 调用 H5 方法
    // =========================
    
    // Flutter 调用此方法
    window.onFlutterCall = function(data) {
      addLog('📥 收到 Flutter 调用: ' + JSON.stringify(data), 'info');
    };
    
    // Flutter 发送数据
    window.receiveData = function(data) {
      addLog('📥 收到 Flutter 数据: ' + JSON.stringify(data), 'info');
    };
    
    // Flutter 更新标题
    window.updateTitle = function(data) {
      document.getElementById('page-title').textContent = data.title;
      addLog('📥 标题已更新: ' + data.title, 'info');
    };
    
    // Flutter 获取页面数据
    window.getPageData = function() {
      const data = {
        title: document.getElementById('page-title').textContent,
        logCount: logCount,
        timestamp: Date.now()
      };
      addLog('📥 Flutter 请求页面数据', 'info');
      return data;
    };
    
    // 页面加载完成
    addLog('📄 页面加载完成', 'info');
  </script>
</body>
</html>
    ''';

    // 使用 data URL
    return Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();
  }
}

