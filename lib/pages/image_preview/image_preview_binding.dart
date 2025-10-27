import 'package:get/get.dart';
import 'image_preview_controller.dart';

/// 图片预览页面绑定
class ImagePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImagePreviewController>(() => ImagePreviewController());
  }
}
