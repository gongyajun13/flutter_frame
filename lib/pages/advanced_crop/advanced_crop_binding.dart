import 'package:get/get.dart';
import 'advanced_crop_controller.dart';

/// 高级图片裁剪绑定
class AdvancedCropBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdvancedCropController>(() => AdvancedCropController());
  }
}
