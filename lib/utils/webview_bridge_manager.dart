import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../overlay/overlay.dart';

/// WebView 桥接管理器
/// 负责管理 H5 ↔ Flutter 之间的双向通信
class WebViewBridgeManager {
  final WebViewController controller;
  
  // 桥接方法映射表（方法名 -> 处理函数）
  final Map<String, Future<dynamic> Function(Map<String, dynamic>)> _handlers = {};
  
  // JavaScript 桥接代码（注入到 H5 中）
  static const String _bridgeJavaScript = '''
    // Flutter 桥接对象
    window.FlutterBridge = {
      // H5 调用 Flutter 方法
      callFlutter: function(method, params, callback) {
        const callId = Date.now() + '_' + Math.random();
        
        // 保存回调函数
        if (callback && typeof callback === 'function') {
          window.FlutterBridge._callbacks = window.FlutterBridge._callbacks || {};
          window.FlutterBridge._callbacks[callId] = callback;
        }
        
        // 发送消息到 Flutter
        const message = {
          callId: callId,
          method: method,
          params: params || {}
        };
        
        // 使用 postMessage 发送到 Flutter
        if (window.FlutterJavaScriptChannel) {
          window.FlutterJavaScriptChannel.postMessage(JSON.stringify(message));
        } else {
          console.error('FlutterJavaScriptChannel is not available');
        }
        
        return callId;
      },
      
      // Flutter 回调 H5 (由 Flutter 调用)
      _handleCallback: function(callId, result) {
        const callbacks = window.FlutterBridge._callbacks || {};
        const callback = callbacks[callId];
        
        if (callback && typeof callback === 'function') {
          callback(result);
          delete callbacks[callId];
        }
      },
      
      // 用于调试的方法
      log: function(message) {
        console.log('[FlutterBridge]', message);
      }
    };
    
    // 快捷方式：直接调用方法（不需要回调）
    window.callFlutter = function(method, params) {
      return window.FlutterBridge.callFlutter(method, params);
    };
    
    console.log('FlutterBridge initialized');
  ''';

  WebViewBridgeManager(this.controller) {
    _registerDefaultHandlers();
  }

  /// 注册默认的桥接方法
  void _registerDefaultHandlers() {
    // 1. 显示 Toast 提示
    registerHandler('showToast', _handleShowToast);
    
    // 2. 获取用户信息
    registerHandler('getUserInfo', _handleGetUserInfo);
    
    // 3. 打开新页面
    registerHandler('openPage', _handleOpenPage);
    
    // 4. 关闭当前页面
    registerHandler('closePage', _handleClosePage);
    
    // 5. 获取设备信息
    registerHandler('getDeviceInfo', _handleGetDeviceInfo);
    
    // 6. 本地存储操作
    registerHandler('localStorage', _handleLocalStorage);
    
    // 7. 拍照/选择图片
    registerHandler('selectImage', _handleSelectImage);
    
    // 8. 分享功能
    registerHandler('share', _handleShare);
    
    // 9. 扫码功能
    registerHandler('scanQRCode', _handleScanQRCode);
    
    // 10. 获取位置信息
    registerHandler('getLocation', _handleGetLocation);
  }

  /// 注册自定义桥接方法
  /// 
  /// [method] 方法名
  /// [handler] 处理函数，接收参数并返回结果
  void registerHandler(
    String method,
    Future<dynamic> Function(Map<String, dynamic>) handler,
  ) {
    _handlers[method] = handler;
    debugPrint('WebViewBridge: 注册方法 "$method"');
  }

  /// 移除已注册的方法
  void unregisterHandler(String method) {
    _handlers.remove(method);
    debugPrint('WebViewBridge: 移除方法 "$method"');
  }

  /// 初始化桥接（注入 JavaScript 代码）
  Future<void> initializeBridge() async {
    try {
      // 注入桥接 JavaScript 代码
      await controller.runJavaScript(_bridgeJavaScript);
      debugPrint('WebViewBridge: 桥接初始化成功');
    } catch (e) {
      debugPrint('WebViewBridge: 桥接初始化失败 - $e');
    }
  }

  /// 处理来自 H5 的消息
  Future<void> handleMessage(String message) async {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final callId = data['callId'] as String?;
      final method = data['method'] as String?;
      final params = data['params'] as Map<String, dynamic>? ?? {};

      if (method == null) {
        debugPrint('WebViewBridge: 无效的方法调用');
        return;
      }

      debugPrint('WebViewBridge: H5 调用方法 "$method"，参数: $params');

      // 查找对应的处理函数
      final handler = _handlers[method];
      if (handler == null) {
        debugPrint('WebViewBridge: 未找到方法 "$method"');
        _sendCallbackToH5(callId, {
          'success': false,
          'error': '未找到方法: $method',
        });
        return;
      }

      // 执行处理函数
      try {
        final result = await handler(params);
        _sendCallbackToH5(callId, {
          'success': true,
          'data': result,
        });
      } catch (e) {
        debugPrint('WebViewBridge: 方法 "$method" 执行失败 - $e');
        _sendCallbackToH5(callId, {
          'success': false,
          'error': e.toString(),
        });
      }
    } catch (e) {
      debugPrint('WebViewBridge: 消息解析失败 - $e');
    }
  }

  /// 发送回调结果到 H5
  void _sendCallbackToH5(String? callId, Map<String, dynamic> result) {
    if (callId == null) return;

    final resultJson = jsonEncode(result);
    final js = '''
      if (window.FlutterBridge && window.FlutterBridge._handleCallback) {
        window.FlutterBridge._handleCallback('$callId', $resultJson);
      }
    ''';

    controller.runJavaScript(js).catchError((e) {
      debugPrint('WebViewBridge: 回调发送失败 - $e');
    });
  }

  /// Flutter 主动调用 H5 方法
  /// 
  /// [method] H5 中定义的方法名
  /// [params] 传递给 H5 的参数
  Future<void> callH5Method(String method, Map<String, dynamic>? params) async {
    try {
      final paramsJson = jsonEncode(params ?? {});
      final js = '''
        if (window.$method && typeof window.$method === 'function') {
          window.$method($paramsJson);
        } else {
          console.error('H5 方法 "$method" 不存在');
        }
      ''';
      
      await controller.runJavaScript(js);
      debugPrint('WebViewBridge: Flutter 调用 H5 方法 "$method"');
    } catch (e) {
      debugPrint('WebViewBridge: 调用 H5 方法失败 - $e');
    }
  }

  /// Flutter 主动调用 H5 方法并获取返回值
  Future<String?> callH5MethodWithResult(String method, Map<String, dynamic>? params) async {
    try {
      final paramsJson = jsonEncode(params ?? {});
      final js = '''
        (function() {
          if (window.$method && typeof window.$method === 'function') {
            const result = window.$method($paramsJson);
            return JSON.stringify(result);
          } else {
            return JSON.stringify({error: 'H5 方法 "$method" 不存在'});
          }
        })();
      ''';
      
      final result = await controller.runJavaScriptReturningResult(js);
      debugPrint('WebViewBridge: Flutter 调用 H5 方法 "$method"，返回: $result');
      return result.toString();
    } catch (e) {
      debugPrint('WebViewBridge: 调用 H5 方法失败 - $e');
      return null;
    }
  }

  // ==================== 默认桥接方法实现 ====================

  /// 1. 显示 Toast
  Future<Map<String, dynamic>> _handleShowToast(Map<String, dynamic> params) async {
    final message = params['message'] as String? ?? '无内容';
    final type = params['type'] as String? ?? 'info'; // info, success, error, warning
    
    switch (type) {
      case 'success':
        AppOverlay.snack.success(message: message);
        break;
      case 'error':
        AppOverlay.snack.error(message: message);
        break;
      case 'warning':
        AppOverlay.snack.warning(message: message);
        break;
      default:
        AppOverlay.snack.info(message: message);
    }
    
    return {'message': '显示成功'};
  }

  /// 2. 获取用户信息（示例）
  Future<Map<String, dynamic>> _handleGetUserInfo(Map<String, dynamic> params) async {
    // TODO: 从实际的用户服务中获取
    return {
      'userId': '123456',
      'userName': 'Flutter User',
      'avatar': 'https://via.placeholder.com/100',
      'token': 'sample_token_123',
    };
  }

  /// 3. 打开新页面
  Future<Map<String, dynamic>> _handleOpenPage(Map<String, dynamic> params) async {
    final url = params['url'] as String?;
    final title = params['title'] as String? ?? '新页面';
    
    if (url == null) {
      return {'error': '缺少 url 参数'};
    }
    
    // TODO: 根据实际需求打开新页面
    debugPrint('打开新页面: $url (标题: $title)');
    
    return {'message': '页面打开成功'};
  }

  /// 4. 关闭当前页面
  Future<Map<String, dynamic>> _handleClosePage(Map<String, dynamic> params) async {
    if (Get.context != null) {
      Navigator.of(Get.context!).pop();
    }
    return {'message': '页面已关闭'};
  }

  /// 5. 获取设备信息
  Future<Map<String, dynamic>> _handleGetDeviceInfo(Map<String, dynamic> params) async {
    return {
      'platform': 'Flutter',
      'version': '1.0.0',
      'deviceId': 'flutter_device_001',
      'osVersion': 'Android 13', // 或 iOS 16
    };
  }

  /// 6. 本地存储操作
  Future<Map<String, dynamic>> _handleLocalStorage(Map<String, dynamic> params) async {
    final action = params['action'] as String?; // get, set, remove
    final key = params['key'] as String?;
    final value = params['value'];
    
    if (key == null) {
      return {'error': '缺少 key 参数'};
    }
    
    switch (action) {
      case 'set':
        // TODO: 使用 LocalCacheUtil 保存
        debugPrint('保存本地数据: $key = $value');
        return {'message': '保存成功'};
        
      case 'get':
        // TODO: 使用 LocalCacheUtil 获取
        debugPrint('获取本地数据: $key');
        return {'value': 'sample_value'};
        
      case 'remove':
        // TODO: 使用 LocalCacheUtil 删除
        debugPrint('删除本地数据: $key');
        return {'message': '删除成功'};
        
      default:
        return {'error': '不支持的操作: $action'};
    }
  }

  /// 7. 拍照/选择图片
  Future<Map<String, dynamic>> _handleSelectImage(Map<String, dynamic> params) async {
    final source = params['source'] as String? ?? 'gallery'; // camera, gallery
    
    // TODO: 集成 image_picker 插件
    debugPrint('选择图片: $source');
    
    return {
      'imagePath': '/path/to/image.jpg',
      'imageUrl': 'https://via.placeholder.com/500',
    };
  }

  /// 8. 分享功能
  Future<Map<String, dynamic>> _handleShare(Map<String, dynamic> params) async {
    final title = params['title'] as String?;
    final content = params['content'] as String?;
    final url = params['url'] as String?;
    
    // TODO: 集成分享插件
    debugPrint('分享内容: 标题=$title, 内容=$content, 链接=$url');
    
    return {'message': '分享成功'};
  }

  /// 9. 扫码功能
  Future<Map<String, dynamic>> _handleScanQRCode(Map<String, dynamic> params) async {
    // TODO: 集成扫码插件
    debugPrint('打开扫码');
    
    return {
      'code': 'sample_qr_code_result',
      'type': 'QR_CODE',
    };
  }

  /// 10. 获取位置信息
  Future<Map<String, dynamic>> _handleGetLocation(Map<String, dynamic> params) async {
    // TODO: 集成定位插件
    debugPrint('获取位置');
    
    return {
      'latitude': 39.9042,
      'longitude': 116.4074,
      'address': '北京市朝阳区',
    };
  }

  /// 清理资源
  void dispose() {
    _handlers.clear();
    debugPrint('WebViewBridge: 资源已清理');
  }
}

