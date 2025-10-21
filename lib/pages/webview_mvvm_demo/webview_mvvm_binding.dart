import 'package:get/get.dart';
import 'webview_mvvm_controller.dart';

class WebViewMvvmBinding extends Bindings {
  @override
  void dependencies() {
    // 从路由参数获取 URL
    final String url = Get.parameters['url'] ?? 'https://flutter.dev';
    final bool enableBridge = Get.parameters['enableBridge'] == 'true';
    
    Get.lazyPut<WebViewMvvmController>(
      () => WebViewMvvmController(
        initialUrl: url,
        enableBridge: enableBridge,
      ),
    );
  }
}
