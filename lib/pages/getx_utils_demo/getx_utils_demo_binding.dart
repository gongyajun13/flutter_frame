import 'package:get/get.dart';
import 'getx_utils_demo_controller.dart';

class GetXUtilsDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetXUtilsDemoController>(() => GetXUtilsDemoController());
  }
}
