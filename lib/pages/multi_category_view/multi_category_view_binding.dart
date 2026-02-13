import 'package:get/get.dart';
import 'multi_category_view_controller.dart';

class MultiCategoryViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MultiCategoryViewController>(() => MultiCategoryViewController());
  }
}
