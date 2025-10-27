import 'package:get/get.dart';
import 'advanced_picker_controller.dart';

/// 高级图片选择绑定
class AdvancedPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdvancedPickerController>(() => AdvancedPickerController());
  }
}
