import 'package:get/get.dart';
import 'error_monitor_demo_controller.dart';

/// 错误监控演示页面绑定
class ErrorMonitorDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ErrorMonitorDemoController());
  }
}
