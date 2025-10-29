import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/cached_video_player_widget.dart';
import '../../widgets/fullscreen_video_player_widget.dart';

/// 视频播放器演示页面
class VideoPlayerDemoPage extends StatefulWidget {
  const VideoPlayerDemoPage({super.key});

  @override
  State<VideoPlayerDemoPage> createState() => _VideoPlayerDemoPageState();
}

class _VideoPlayerDemoPageState extends State<VideoPlayerDemoPage> {
  // 测试视频URL（使用可公开访问的测试视频）
  final String _videoUrl = 'https://aweme.snssdk.com/aweme/v1/play/?line=0&logo_name=aweme_diversion_search&ratio=720p&video_id=v0200fg10000d37678fog65ijq963q4g';
  final String _coverImageUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg';
  
  VideoPlayerState _currentState = VideoPlayerState.loading;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isFullscreen = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放器演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示
            _buildStatusCard(),
            SizedBox(height: 16.h),
            
            // 主播放器
            _buildMainPlayer(),
            SizedBox(height: 16.h),
            
            // 控制按钮组
            _buildControlButtons(),
            SizedBox(height: 24.h),
            
            // 小播放器示例
            _buildSmallPlayer(),
            SizedBox(height: 24.h),
            
            // 功能说明
            _buildFeaturesCard(),
          ],
        ),
      ),
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '播放状态',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildStatusItem('状态', _getStateText(_currentState)),
                SizedBox(width: 16.w),
                _buildStatusItem('时长', _formatDuration(_totalDuration)),
                SizedBox(width: 16.w),
                _buildStatusItem('进度', _formatDuration(_currentPosition)),
              ],
            ),
          ],
        ),
      ),
    );
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
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取状态文本
  String _getStateText(VideoPlayerState state) {
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
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 构建主播放器
  Widget _buildMainPlayer() {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200.h,
            child: CachedVideoPlayerWidget(
              videoUrl: _videoUrl,
              coverImageUrl: _coverImageUrl,
              autoPlay: false,
              showControls: true,
              showProgressBar: true,
              isFullscreen: _isFullscreen,
              externalState: _currentState,
              externalPosition: _currentPosition,
              externalIsPlaying: _currentState == VideoPlayerState.playing,
              onStateChanged: (state) {
                setState(() {
                  _currentState = state;
                });
              },
              onPositionChanged: (position, duration) {
                setState(() {
                  _currentPosition = position;
                  _totalDuration = duration;
                });
              },
              onPlaybackCompleted: () {
                Get.snackbar(
                  '播放完成',
                  '视频播放已完成',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              onFullscreenToggle: _openFullscreenPlayer,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(
              '主播放器 - 带封面图和控制条',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮组
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
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
          },
          icon: const Icon(Icons.info_outline),
          label: const Text('功能说明'),
        ),
        ElevatedButton.icon(
          onPressed: _openFullscreenPlayer,
          icon: const Icon(Icons.fullscreen),
          label: const Text('全屏播放'),
        ),
      ],
    );
  }

  /// 构建功能项
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

  /// 构建小播放器
  Widget _buildSmallPlayer() {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150.h,
            child: CachedVideoPlayerWidget(
              videoUrl: _videoUrl,
              autoPlay: false,
              showControls: true,
              showProgressBar: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(
              '小播放器 - 无封面图',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能说明卡片
  Widget _buildFeaturesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用说明',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInstructionItem('1', '点击视频区域可以显示/隐藏控制条'),
            _buildInstructionItem('2', '拖动进度条可以跳转到指定位置'),
            _buildInstructionItem('3', '点击播放/暂停按钮控制播放'),
            _buildInstructionItem('4', '视频会自动缓存，再次播放更流畅'),
            _buildInstructionItem('5', '双击屏幕可以播放/暂停视频'),
            _buildInstructionItem('6', '左右滑动可以快进/快退10秒'),
            _buildInstructionItem('7', '点击音量按钮可以调节音量'),
          ],
        ),
      ),
    );
  }

  /// 构建说明项
  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 打开全屏播放器
  void _openFullscreenPlayer() {
    setState(() {
      _isFullscreen = true;
    });
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayerWidget(
          videoUrl: _videoUrl,
          coverImageUrl: _coverImageUrl,
          currentPosition: _currentPosition,
          isPlaying: _currentState == VideoPlayerState.playing,
          onStateChanged: (state) {
            setState(() {
              _currentState = state;
            });
          },
          onPositionChanged: (position, duration) {
            setState(() {
              _currentPosition = position;
              _totalDuration = duration;
            });
          },
          onExit: () {
            setState(() {
              _isFullscreen = false;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

