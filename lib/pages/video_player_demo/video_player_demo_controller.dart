import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/base_controller.dart';
import '../../widgets/cached_video_player_widget.dart';
import '../../widgets/fullscreen_video_player_widget.dart';

/// 视频播放器演示控制器
class VideoPlayerDemoController extends BaseController {
  // 测试视频URL（使用可公开访问的测试视频）
  final String videoUrl = 'https://aweme.snssdk.com/aweme/v1/play/?line=0&logo_name=aweme_diversion_search&ratio=720p&video_id=v0200fg10000d37678fog65ijq963q4g';
  final String coverImageUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg';
  
  // 播放状态（响应式）
  final currentState = VideoPlayerState.loading.obs;
  final currentPosition = Duration.zero.obs;
  final totalDuration = Duration.zero.obs;
  final isFullscreen = false.obs;

  /// 更新播放状态
  void updateState(VideoPlayerState state) {
    currentState.value = state;
  }

  /// 更新播放位置
  void updatePosition(Duration position, Duration duration) {
    currentPosition.value = position;
    totalDuration.value = duration;
  }

  /// 获取状态文本
  String getStateText(VideoPlayerState state) {
    switch (state) {
      case VideoPlayerState.loading:
        return '加载中';
      case VideoPlayerState.playing:
        return '播放中';
      case VideoPlayerState.paused:
        return '已暂停';
      case VideoPlayerState.ended:
        return '已结束';
      case VideoPlayerState.error:
        return '错误';
    }
  }

  /// 格式化时长
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 打开全屏播放器
  void openFullscreenPlayer() {
    isFullscreen.value = true;
    
    Get.to(
      () => FullscreenVideoPlayerWidget(
        videoUrl: videoUrl,
        coverImageUrl: coverImageUrl,
        currentPosition: currentPosition.value,
        isPlaying: currentState.value == VideoPlayerState.playing,
        onStateChanged: (state) {
          updateState(state);
        },
        onPositionChanged: (position, duration) {
          updatePosition(position, duration);
        },
        onExit: () {
          isFullscreen.value = false;
          Get.back();
        },
      ),
    );
  }

  /// 显示功能说明对话框
  void showFeaturesDialog() {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '视频播放器特点',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              _buildFeatureItem('✅', '支持视频缓存'),
              _buildFeatureItem('✅', '自定义封面图'),
              _buildFeatureItem('✅', '播放控制'),
              _buildFeatureItem('✅', '进度条拖动'),
              _buildFeatureItem('✅', '时长显示'),
              _buildFeatureItem('✅', '状态监听'),
              _buildFeatureItem('✅', '加载/错误处理'),
              _buildFeatureItem('✅', '全屏播放'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// 播放完成回调
  void onPlaybackCompleted() {
    showSuccess('视频播放已完成');
  }
}
