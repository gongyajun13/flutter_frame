import 'package:get/get.dart';
import 'webview_demo_controller.dart';

/// WebView 演示页面 Binding
class WebViewDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebViewDemoController>(() => WebViewDemoController());
  }
}
