import 'package:get/get.dart';
import 'simple_webview_controller.dart';
import '../../utils/webview_bridge_manager.dart';

/// Simple WebView Binding
class SimpleWebViewBinding extends Bindings {
  final String url;
  final bool enableBridge;
  final void Function(WebViewBridgeManager)? onBridgeReady;

  SimpleWebViewBinding({
    required this.url,
    this.enableBridge = true,
    this.onBridgeReady,
  });

  @override
  void dependencies() {
    // 使用唯一的 tag 来区分不同的 WebView 实例
    // 基于 URL 和时间戳生成 tag，确保每次都是新实例
    final tag = 'simple_webview_${url.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    
    // 创建新的 Controller 实例（每次都创建新实例）
    Get.put<SimpleWebViewController>(
      SimpleWebViewController(
        initialUrl: url,
        enableBridge: enableBridge,
        onBridgeReady: onBridgeReady,
      ),
      tag: tag,
      permanent: false, // 页面关闭时自动删除
    );
  }
}
