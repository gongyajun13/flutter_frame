import 'package:get/get.dart';
import 'permission_demo_controller.dart';

class PermissionDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PermissionDemoController());
  }
}
