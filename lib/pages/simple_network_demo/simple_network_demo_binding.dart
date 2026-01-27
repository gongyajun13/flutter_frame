import 'package:get/get.dart';
import 'simple_network_demo_controller.dart';

/// 简单网络请求演示页面绑定
class SimpleNetworkDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SimpleNetworkDemoController>(() => SimpleNetworkDemoController());
  }
}

