import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cached_video_player_widget.dart';
import 'video_player_demo_controller.dart';

/// 视频播放器演示页面
class VideoPlayerDemoPage extends BaseScrollPage<VideoPlayerDemoController> {
  const VideoPlayerDemoPage({super.key});

  @override
  String? get pageTitle => '视频播放器演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      backgroundColor: AppDesignTokens.infoColor,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 状态显示
        _buildStatusCard(),
        SizedBox(height: AppDesignTokens.spacingV16),
        
        // 主播放器
        _buildMainPlayer(),
        SizedBox(height: AppDesignTokens.spacingV16),
        
        // 控制按钮组
        SizedBox(height: AppDesignTokens.spacingV24),



        // 功能说明
        _buildFeaturesCard(),
      ],
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return Obx(() => AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '播放状态',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Row(
            children: [
              _buildStatusItem('状态', controller.getStateText(controller.currentState.value)),
              SizedBox(width: AppDesignTokens.spacing16),
              _buildStatusItem('时长', controller.formatDuration(controller.totalDuration.value)),
              SizedBox(width: AppDesignTokens.spacing16),
              _buildStatusItem('进度', controller.formatDuration(controller.currentPosition.value)),
            ],
          ),
        ],
      ),
    ));
  }

  /// 构建状态项
  Widget _buildStatusItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize12,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主播放器
  Widget _buildMainPlayer() {
    return Obx(() => AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDesignTokens.radius12),
              topRight: Radius.circular(AppDesignTokens.radius12),
            ),
            child: Container(
              width: double.infinity,
              height: 200.h,
              child: CachedVideoPlayerWidget(
              videoUrl: controller.videoUrl,
              coverImageUrl: controller.coverImageUrl,
              autoPlay: false,
              showControls: true,
              showProgressBar: true,
              isFullscreen: controller.isFullscreen.value,
              externalState: controller.currentState.value,
              externalPosition: controller.currentPosition.value,
              externalIsPlaying: controller.currentState.value == VideoPlayerState.playing,
              onStateChanged: (state) {
                controller.updateState(state);
              },
              onPositionChanged: (position, duration) {
                controller.updatePosition(position, duration);
              },
              onPlaybackCompleted: () {
                controller.onPlaybackCompleted();
              },
              onFullscreenToggle: controller.openFullscreenPlayer,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDesignTokens.spacing12),
            child: Text(
              '主播放器 - 带封面图和控制条',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  /// 构建功能说明卡片
  Widget _buildFeaturesCard() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '使用说明',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          _buildInstructionItem('1', '点击视频区域可以显示/隐藏控制条'),
          _buildInstructionItem('2', '拖动进度条可以跳转到指定位置'),
          _buildInstructionItem('3', '点击播放/暂停按钮控制播放'),
          _buildInstructionItem('4', '视频会自动缓存，再次播放更流畅'),
          _buildInstructionItem('5', '双击屏幕可以播放/暂停视频'),
          _buildInstructionItem('6', '左右滑动可以快进/快退10秒'),
          _buildInstructionItem('7', '点击音量按钮可以调节音量'),
        ],
      ),
    );
  }

  /// 构建说明项
  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDesignTokens.spacingV8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: AppDesignTokens.infoColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppDesignTokens.fontSize12,
                  fontWeight: AppDesignTokens.fontWeightBold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
