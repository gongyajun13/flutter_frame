import 'package:get/get.dart';
import 'database_demo_controller.dart';

/// 数据库演示页面绑定
class DatabaseDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DatabaseDemoController());
  }
}
