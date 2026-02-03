import 'package:get/get.dart';
import 'file_download_demo_controller.dart';

/// 文件下载演示页面绑定
class FileDownloadDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FileDownloadDemoController());
  }
}
