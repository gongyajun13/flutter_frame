import 'package:get/get.dart';
import 'deepseek_demo_controller.dart';

/// DeepSeek 演示页面绑定
class DeepSeekDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeepSeekDemoController>(() => DeepSeekDemoController());
  }
}
