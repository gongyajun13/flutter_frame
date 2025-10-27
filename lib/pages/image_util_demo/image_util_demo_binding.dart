import 'package:get/get.dart';
import 'image_util_demo_controller.dart';

/// 图片处理演示绑定
class ImageUtilDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageUtilDemoController>(() => ImageUtilDemoController());
  }
}

