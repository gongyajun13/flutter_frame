import 'package:get/get.dart';
import 'video_player_demo_controller.dart';

/// 视频播放器演示绑定
class VideoPlayerDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayerDemoController>(() => VideoPlayerDemoController());
  }
}
