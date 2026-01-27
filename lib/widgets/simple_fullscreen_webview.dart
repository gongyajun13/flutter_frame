import 'package:flutter/material.dart';
import '../pages/simple_webview/simple_webview_page.dart';
import '../utils/webview_cache_manager.dart';
import '../utils/webview_bridge_manager.dart';

/// 简单的全屏 WebView 组件
/// 
/// 已改为 MVVM 架构，使用 GetX Controller 管理状态
/// 
/// 使用示例：
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => SimpleFullScreenWebView(
///       url: 'https://example.com',
///       title: '示例页面',
///       enableBridge: true,
///       onBridgeReady: (bridgeManager) {
///         // 注册自定义桥接方法
///       },
///     ),
///   ),
/// );
/// ```
class SimpleFullScreenWebView extends StatelessWidget {
  final String url;
  final String title;
  
  /// 是否启用桥接功能（默认启用）
  final bool enableBridge;
  
  /// 自定义桥接方法注册回调
  final void Function(WebViewBridgeManager)? onBridgeReady;

  const SimpleFullScreenWebView({
    super.key,
    required this.url,
    required this.title,
    this.enableBridge = true,
    this.onBridgeReady,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 URL 作为 key，确保每次 URL 变化时都创建新的 Widget 实例
    // 这样 GetX 会自动管理 Controller 的生命周期
    return SimpleWebViewPage(
      key: ValueKey(url), // 使用 URL 作为 key
      title: title,
      url: url,
      enableBridge: enableBridge,
      onBridgeReady: onBridgeReady,
    );
  }
  
  /// 静态方法：清除所有 WebView 缓存
  /// 
  /// 这是一个全局方法，会清除所有 WebView 的缓存数据
  /// 适用于退出登录、切换账号等场景
  static Future<void> clearAllCache() async {
    await WebViewCacheManager.clearAllCache();
  }
}
