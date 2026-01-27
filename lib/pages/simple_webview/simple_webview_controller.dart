import '../../base/base_webview_controller.dart';

/// Simple WebView Controller
/// 
/// 用于 SimpleFullScreenWebView 的 Controller
class SimpleWebViewController extends BaseWebViewController {
  SimpleWebViewController({
    required super.initialUrl,
    super.enableBridge,
    super.onBridgeReady,
  });
}
