import 'package:get/get.dart';
import 'screen_adaptation_demo_controller.dart';

class ScreenAdaptationDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScreenAdaptationDemoController>(() => ScreenAdaptationDemoController());
  }
}
