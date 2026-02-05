import 'package:get/get.dart';
import 'i18n_demo_controller.dart';

class I18nDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<I18nDemoController>(() => I18nDemoController());
  }
}
