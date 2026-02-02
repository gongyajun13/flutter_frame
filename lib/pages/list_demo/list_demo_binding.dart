import 'package:get/get.dart';
import 'list_demo_controller.dart';

/// 数据列表演示页面绑定
class ListDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ListDemoController());
  }
}
