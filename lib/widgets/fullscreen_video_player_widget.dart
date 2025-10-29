import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'cached_video_player_widget.dart';

/// 全屏视频播放器Widget
class FullscreenVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? coverImageUrl;
  final Duration currentPosition;
  final bool isPlaying;
  final VoidCallback? onExit;
  final Function(VideoPlayerState state)? onStateChanged;
  final Function(Duration position, Duration duration)? onPositionChanged;

  const FullscreenVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.coverImageUrl,
    this.currentPosition = Duration.zero,
    this.isPlaying = false,
    this.onExit,
    this.onStateChanged,
    this.onPositionChanged,
  });

  @override
  State<FullscreenVideoPlayerWidget> createState() =>
      _FullscreenVideoPlayerWidgetState();
}

class _FullscreenVideoPlayerWidgetState
    extends State<FullscreenVideoPlayerWidget> {
  VideoPlayerState _currentState = VideoPlayerState.loading;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    // 初始化状态
    _currentState = widget.isPlaying ? VideoPlayerState.playing : VideoPlayerState.paused;
    _currentPosition = widget.currentPosition;
    
    // 设置全屏模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 设置屏幕方向为横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 恢复系统UI和屏幕方向
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined),
          onPressed: () => Get.back(),
          iconSize: 18.sp,
        ),
      ),
             body: CachedVideoPlayerWidget(
               videoUrl: widget.videoUrl,
               autoPlay: _currentState == VideoPlayerState.playing,
               showControls: true,
               showProgressBar: true,
               isFullscreen: true,
               externalState: _currentState,
               externalPosition: _currentPosition,
               externalIsPlaying: _currentState == VideoPlayerState.playing,
               onStateChanged: (state) {
                 setState(() {
                   _currentState = state;
                 });
                 // 同步状态到父组件
                 widget.onStateChanged?.call(state);
               },
               onPositionChanged: (position, duration) {
                 setState(() {
                   _currentPosition = position;
                 });
                 // 同步位置到父组件
                 widget.onPositionChanged?.call(position, duration);
               },
               onFullscreenToggle: () {
                 // 全屏状态下点击全屏按钮退出全屏
                 Get.back();
               },
             ),
    );
  }

}
