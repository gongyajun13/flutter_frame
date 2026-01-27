import 'package:get/get.dart';
import 'cached_image_demo_controller.dart';

class CachedImageDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CachedImageDemoController>(() => CachedImageDemoController());
  }
}
