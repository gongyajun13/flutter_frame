import 'package:get/get.dart';
import 'pixelize_demo_controller.dart';
import 'pixelize_result_controller.dart';

class PixelizeDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PixelizeDemoController());
  }
}

/// 像素化结果页面绑定
class PixelizeResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PixelizeResultController());
  }
}
