import 'package:get/get.dart';
import 'local_cache_demo_controller.dart';

class LocalCacheDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalCacheDemoController>(() => LocalCacheDemoController());
  }
}
