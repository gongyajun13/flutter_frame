import 'package:get/get.dart';
import 'selector_demo_controller.dart';

/// 选择器 UI 组件演示 Binding
class SelectorDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectorDemoController>(() => SelectorDemoController());
  }
}

