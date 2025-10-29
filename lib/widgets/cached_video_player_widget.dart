import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 视频播放状态枚举
enum VideoPlayerState {
  loading,
  playing,
  paused,
  ended,
  error,
}

/// 缓存视频播放器Widget
class CachedVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final bool muted;
  final bool showControls;
  final bool showProgressBar;
  final bool isFullscreen;
  final String? coverImageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Function(VideoPlayerState state)? onStateChanged;
  final Function(Duration position, Duration duration)? onPositionChanged;
  final VoidCallback? onPlaybackCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onFullscreenToggle;
  final GlobalKey<_CachedVideoPlayerWidgetState>? playerKey;
  final VideoPlayerState? externalState;
  final Duration? externalPosition;
  final bool? externalIsPlaying;

  const CachedVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
    this.muted = false,
    this.showControls = true,
    this.showProgressBar = true,
    this.isFullscreen = false,
    this.coverImageUrl,
    this.placeholder,
    this.errorWidget,
    this.onStateChanged,
    this.onPositionChanged,
    this.onPlaybackCompleted,
    this.onTap,
    this.onFullscreenToggle,
    this.playerKey,
    this.externalState,
    this.externalPosition,
    this.externalIsPlaying,
  });

  @override
  State<CachedVideoPlayerWidget> createState() => _CachedVideoPlayerWidgetState();
}

class _CachedVideoPlayerWidgetState extends State<CachedVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  VideoPlayerState _currentState = VideoPlayerState.loading;
  bool _showControls = true;
  bool _isDragging = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _errorMessage;
  Timer? _hideControlsTimer;
  bool _isLongPressing = false;
  double _originalPlaybackSpeed = 1.0;
  Duration _dragPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(CachedVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果视频URL发生变化，重新初始化
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializePlayer();
      return;
    }
    
    // 同步外部状态
    if (widget.externalState != null && widget.externalState != _currentState) {
      _syncExternalState();
    }
    
    if (widget.externalPosition != null && widget.externalPosition != _currentPosition) {
      _syncExternalPosition();
    }
    
    if (widget.externalIsPlaying != null) {
      _syncExternalPlayingState();
    }
  }

  void _initializePlayer() async {
    // 先释放旧的controller
    await _disposeController();

    try {
      setState(() {
        _currentState = VideoPlayerState.loading;
        _errorMessage = null;
      });

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      );

      await _controller!.initialize();
      
      if (!mounted) return;
      
      await _controller!.setVolume(widget.muted ? 0.0 : 1.0);
      await _controller!.setLooping(widget.looping);
      _controller!.addListener(_onPlayerStateChanged);
      _controller!.addListener(_onPositionChanged);
      
      setState(() {
        _isInitialized = true;
        _currentState = VideoPlayerState.paused;
        _totalDuration = _controller!.value.duration;
        // 对于没有封面图片的播放器，初始化时就显示控制器
        if (widget.coverImageUrl == null) {
          _showControls = true;
        }
      });
      
      if (widget.autoPlay && _controller != null) {
        await _controller!.play();
      }
      
      // 同步外部状态
      _syncExternalState();
      _syncExternalPosition();
      _syncExternalPlayingState();
    } catch (e) {
      debugPrint('视频初始化失败: $e');
      if (mounted) {
        setState(() {
          _currentState = VideoPlayerState.error;
          _errorMessage = e.toString();
        });
      }
      await _disposeController();
    }
  }

  /// 同步外部状态
  void _syncExternalState() {
    if (widget.externalState != null && _controller != null) {
      setState(() {
        _currentState = widget.externalState!;
      });
    }
  }

  /// 同步外部播放位置
  void _syncExternalPosition() {
    if (widget.externalPosition != null && _controller != null) {
      _controller!.seekTo(widget.externalPosition!);
      setState(() {
        _currentPosition = widget.externalPosition!;
      });
    }
  }

  /// 同步外部播放状态
  void _syncExternalPlayingState() {
    if (widget.externalIsPlaying != null && _controller != null) {
      if (widget.externalIsPlaying! && !_controller!.value.isPlaying) {
        _controller!.play();
        setState(() {
          _currentState = VideoPlayerState.playing;
        });
      } else if (!widget.externalIsPlaying! && _controller!.value.isPlaying) {
        _controller!.pause();
        setState(() {
          _currentState = VideoPlayerState.paused;
        });
      }
    }
  }

  Future<void> _disposeController() async {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
    
    if (_controller != null) {
      try {
        _controller!.removeListener(_onPlayerStateChanged);
        _controller!.removeListener(_onPositionChanged);
        await _controller!.dispose();
      } catch (e) {
        debugPrint('释放controller失败: $e');
      }
      _controller = null;
    }
  }

  void _onPlayerStateChanged() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    VideoPlayerState newState;
    if (_controller!.value.isPlaying) {
      newState = VideoPlayerState.playing;
    } else if (_controller!.value.position >= _controller!.value.duration) {
      newState = VideoPlayerState.ended;
      widget.onPlaybackCompleted?.call();
    } else {
      newState = VideoPlayerState.paused;
    }
    
    if (_currentState != newState) {
      setState(() {
        _currentState = newState;
      });
      widget.onStateChanged?.call(newState);
      
      // 根据播放状态控制UI显示
      _handleControlsVisibility();
    }
  }

  /// 处理控制器UI显示逻辑
  void _handleControlsVisibility() {
    if (_currentState == VideoPlayerState.playing) {
      // 播放状态：显示控制器，2秒后自动隐藏
      _showControlsTemporarily();
    } else {
      // 暂停/结束/错误状态：取消定时器，保持显示
      _cancelHideTimer();
      // 对于没有封面图片的播放器，或者已经开始播放过的视频，显示控制器
      if (!_showControls && (widget.coverImageUrl == null || _currentPosition.inSeconds > 0)) {
        setState(() {
          _showControls = true;
        });
      }
    }
  }

  /// 临时显示控制器（2秒后隐藏）
  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    
    _cancelHideTimer();
    _hideControlsTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && _currentState == VideoPlayerState.playing) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  /// 取消隐藏定时器
  void _cancelHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  void _onPositionChanged() {
    if (_isDragging || _controller == null) return;
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    if (mounted) {
      setState(() {
        _currentPosition = position;
        _totalDuration = duration;
      });
      widget.onPositionChanged?.call(position, duration);
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    
    // 操作后临时显示控制器
    _showControlsTemporarily();
  }


  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      // 超过1小时显示时分秒
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      // 不足1小时显示分秒
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  /// 播放视频
  Future<void> play() async {
    if (_controller != null && _isInitialized) {
      await _controller!.play();
    }
  }

  /// 暂停视频
  Future<void> pause() async {
    if (_controller != null && _isInitialized) {
      await _controller!.pause();
    }
  }

  /// 切换播放/暂停状态
  Future<void> togglePlayPause() async {
    if (_controller != null && _isInitialized) {
      if (_controller!.value.isPlaying) {
        await _controller!.pause();
      } else {
        await _controller!.play();
      }
    }
  }

  /// 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    if (_controller != null && _isInitialized) {
      await _controller!.seekTo(position);
    }
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    if (_controller != null && _isInitialized) {
      await _controller!.setVolume(volume);
    }
  }

  /// 获取当前播放状态
  VideoPlayerState get currentState => _currentState;

  /// 获取当前播放位置
  Duration get currentPosition => _currentPosition;

  /// 获取总时长
  Duration get totalDuration => _totalDuration;

  /// 获取是否正在播放
  bool get isPlaying => _currentState == VideoPlayerState.playing;

  /// 根据屏幕尺寸动态计算播放按钮大小
  double _getPlayButtonSize() {
    final screenSize = MediaQuery.of(context).size;
    final minDimension = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    // 播放按钮大小为屏幕最小尺寸的8-12%
    return (minDimension * 0.1).clamp(40.0, 80.0);
  }

  /// 根据屏幕尺寸动态计算进度条高度
  double _getProgressBarHeight() {
    final screenSize = MediaQuery.of(context).size;
    final minDimension = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    // 进度条高度为屏幕最小尺寸的0.5-1%
    return (minDimension * 0.006).clamp(3.0, 6.0);
  }

  /// 根据屏幕尺寸动态计算文字大小
  double _getTextSize() {
    final screenSize = MediaQuery.of(context).size;
    final minDimension = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    // 文字大小为屏幕最小尺寸的1.5-3%
    return (minDimension * 0.025).clamp(10.0, 16.0);
  }

  /// 根据屏幕尺寸动态计算间距
  double _getSpacing() {
    final screenSize = MediaQuery.of(context).size;
    final minDimension = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    // 间距为屏幕最小尺寸的1-2%
    return (minDimension * 0.015).clamp(8.0, 16.0);
  }

  /// 开始长按（2倍速播放）
  void _startLongPress() {
    if (!_isInitialized || _controller == null) return;
    
    // 保存当前播放速度
    _originalPlaybackSpeed = _controller!.value.playbackSpeed;
    
    // 设置2倍速播放
    _controller!.setPlaybackSpeed(2.0);
    
    // 取消自动隐藏控制器的定时器
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
    
    // 使用 WidgetsBinding.instance.addPostFrameCallback 延迟执行 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLongPressing = true;
          _showControls = false;
        });
      }
    });
    
    debugPrint('开始2倍速播放');
  }

  /// 结束长按（恢复原速度）
  void _endLongPress() {
    if (!_isInitialized || _controller == null || !_isLongPressing) return;
    
    // 恢复原播放速度
    _controller!.setPlaybackSpeed(_originalPlaybackSpeed);
    
    // 使用 WidgetsBinding.instance.addPostFrameCallback 延迟执行 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLongPressing = false;
        });
        
        // 恢复控制器UI的正常显示逻辑
        _handleControlsVisibility();
      }
    });
    
    debugPrint('恢复正常播放速度');
  }

  /// 处理点击事件
  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.showControls) {
      if (_currentState == VideoPlayerState.playing) {
        // 播放状态：临时显示控制器
        _showControlsTemporarily();
      } else {
        // 其他状态：切换显示/隐藏
        setState(() {
          _showControls = !_showControls;
        });
      }
    }
  }

  /// 处理全屏切换
  void _handleFullscreenToggle() {
    widget.onFullscreenToggle?.call();
    // 操作后临时显示控制器
    _showControlsTemporarily();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPressStart: (_) => _startLongPress(),
      onLongPressEnd: (_) => _endLongPress(),
      onLongPressCancel: () => _endLongPress(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            _buildVideoPlayer(),
            // 长按提示覆盖层
            if (_isLongPressing)
              _buildLongPressOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_currentState == VideoPlayerState.error) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }
    if (!_isInitialized || _controller == null) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }
    return Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        if (widget.showControls && _showControls && !_isLongPressing &&
            !(_currentState == VideoPlayerState.paused && 
              _currentPosition.inSeconds == 0 && 
              widget.coverImageUrl != null)) 
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _buildControlsLayer(),
          ),
        if (widget.coverImageUrl != null && 
            _currentState == VideoPlayerState.paused &&
            _currentPosition.inSeconds == 0)
          _buildCoverImage(),
      ],
    );
  }

  Widget _buildControlsLayer() {
    if (_controller == null) return const SizedBox.shrink();
    
    return Stack(
      children: [
        // 居中的播放暂停按钮
        Center(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: _getPlayButtonSize(),
              height: _getPlayButtonSize(),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: _getPlayButtonSize() * 0.1,
                    offset: Offset(0, _getPlayButtonSize() * 0.03),
                  ),
                ],
              ),
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: _getPlayButtonSize() * 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        // 右上角全屏按钮（常驻显示）
        if (widget.onFullscreenToggle != null)
          Positioned(
            top: _getSpacing(),
            right: _getSpacing(),
            child: GestureDetector(
              onTap: _handleFullscreenToggle,
              child: Container(
                width: _getSpacing() * 4,
                height: _getSpacing() * 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: _getSpacing() * 0.2,
                      offset: Offset(0, _getSpacing() * 0.1),
                    ),
                  ],
                ),
                child: Icon(
                  widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  size: _getSpacing()*2 ,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        
        // 底部的时间和进度条
        if (widget.showProgressBar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              child: _buildProgressBar(),
            ),
          ),
      ],
    );
  }

  /// 构建长按提示覆盖层
  Widget _buildLongPressOverlay() {
    final overlaySize = _getSpacing() * 0.8;
    return Positioned(
      top: _getSpacing(),
      right: _getSpacing(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: overlaySize, vertical: overlaySize * 0.5),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.9),
          borderRadius: BorderRadius.circular(overlaySize),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: overlaySize * 0.25,
              offset: Offset(0, overlaySize * 0.125),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fast_forward,
              color: Colors.white,
              size: overlaySize,
            ),
            SizedBox(width: overlaySize * 0.3),
            Text(
              '2x',
              style: TextStyle(
                color: Colors.white,
                fontSize: overlaySize * 0.8,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    // 播放进度（当前播放位置 / 总时长）
    final playProgress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;
    
    // 缓存进度（已缓冲内容 / 总时长）
    double bufferProgress = 0.0;
    if (_controller?.value.buffered.isNotEmpty == true && _totalDuration.inMilliseconds > 0) {
      // 获取最大缓冲位置
      final maxBufferedPosition = _controller!.value.buffered
          .map((range) => range.end)
          .reduce((a, b) => a > b ? a : b);
      bufferProgress = maxBufferedPosition.inMilliseconds / _totalDuration.inMilliseconds;
    }
    
    // 根据总时长确定时间显示区域的固定宽度
    // 基于屏幕尺寸和时长格式动态计算宽度
    final screenSize = MediaQuery.of(context).size;
    final minDimension = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    final timeWidth = _totalDuration.inHours > 0 
        ? (minDimension * 0.12).clamp(60.0, 100.0)  // 有小时时更宽
        : (minDimension * 0.1).clamp(50.0, 80.0);   // 无小时时稍窄
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _getSpacing(),vertical: _getSpacing()),
      child: Row(
        children: [
          // 当前时间（固定宽度）
          SizedBox(
            width: timeWidth,
            child: Text(
              _formatDuration(_isDragging ? _dragPosition : _currentPosition),
              style: TextStyle(
                color: Colors.white,
                fontSize: _getTextSize(),
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
          
          SizedBox(width: _getSpacing() * 0.5),
          
          // 进度条（占据剩余空间）
          Expanded(
            child: GestureDetector(
              onHorizontalDragStart: (details) {
                if (_controller == null || _totalDuration.inMilliseconds == 0) return;
                
                setState(() {
                  _isDragging = true;
                  // 拖拽起点设置为当前播放位置
                  _dragPosition = _currentPosition;
                });
                
                // 显示控制器
                _showControlsTemporarily();
              },
              onHorizontalDragUpdate: (details) {
                if (_controller == null || _totalDuration.inMilliseconds == 0 || !_isDragging) return;
                
                // 获取进度条的渲染对象
                final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox == null) return;
                
                // 计算拖拽位置对应的播放进度
                final width = renderBox.size.width;
                final dx = details.localPosition.dx.clamp(0.0, width);
                final dragProgress = dx / width;
                
                // 计算拖拽对应的时间位置
                final targetPosition = Duration(
                  milliseconds: (_totalDuration.inMilliseconds * dragProgress).round(),
                );
                
                // 直接更新拖拽位置，用于实时显示
                setState(() {
                  _dragPosition = targetPosition;
                });
              },
              onHorizontalDragEnd: (details) {
                if (_controller == null || !_isDragging) return;
                
                // 跳转到拖拽位置
                _controller!.seekTo(_dragPosition);
                
                // 更新当前播放位置并结束拖拽状态
                setState(() {
                  _currentPosition = _dragPosition;
                  _isDragging = false;
                  _dragPosition = Duration.zero;
                });
              },
              onHorizontalDragCancel: () {
                setState(() {
                  _isDragging = false;
                  _dragPosition = Duration.zero;
                });
              },
              onTapDown: (details) {
                if (_controller == null || _totalDuration.inMilliseconds == 0) return;
                
                // 显示控制器
                _showControlsTemporarily();
                
                // 获取进度条的渲染对象
                final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox == null) return;
                
                // 计算点击位置对应的播放进度
                final width = renderBox.size.width;
                final dx = details.localPosition.dx.clamp(0.0, width);
                final clickProgress = dx / width;
                
                // 跳转到对应位置
                final targetPosition = Duration(
                  milliseconds: (_totalDuration.inMilliseconds * clickProgress).round(),
                );
                _controller!.seekTo(targetPosition);
              },
              child: Container(
                height: _getSpacing() * 1.5, // 动态触摸区域高度
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    // 背景进度条
                    Container(
                      height: _getProgressBarHeight(),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(_getProgressBarHeight() * 0.5),
                      ),
                    ),
                    
                    // 缓存进度条
                    if (bufferProgress > 0)
                      Container(
                        height: _getProgressBarHeight(),
                        width: double.infinity,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: bufferProgress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(_getProgressBarHeight() * 0.5),
                            ),
                          ),
                        ),
                      ),
                    
                    // 播放进度条
                    Container(
                      height: _getProgressBarHeight(),
                      width: double.infinity,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_isDragging 
                            ? (_dragPosition.inMilliseconds / _totalDuration.inMilliseconds)
                            : playProgress).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(_getProgressBarHeight() * 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(width: _getSpacing() * 0.5),
          
          // 总时长（固定宽度）
          SizedBox(
            width: timeWidth,
            child: Text(
              _formatDuration(_totalDuration),
              style: TextStyle(
                color: Colors.white,
                fontSize: _getTextSize(),
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    if (widget.coverImageUrl == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          // 点击封面图时开始播放
          _togglePlayPause();
        },
        child: Stack(
          children: [
            // 封面图
            Image.network(
              widget.coverImageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
            // 播放按钮覆盖层
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  child: Icon(
                    Icons.play_arrow,
                    size: 36.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    final loadingSize = _getSpacing() * 2.5;
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: loadingSize,
              height: loadingSize,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: loadingSize * 0.06,
              ),
            ),
            SizedBox(height: _getSpacing()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _getSpacing() * 1.5),
              child: Text(
                '视频加载中...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getTextSize(),
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    final errorSize = _getSpacing() * 2.5;
    return Container(
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(_getSpacing()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: errorSize,
                color: Colors.white.withOpacity(0.8),
              ),
              SizedBox(height: _getSpacing()),
              Text(
                '视频加载失败',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: _getTextSize(),
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: _getSpacing() * 0.5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _getSpacing() * 1.5),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: _getTextSize() * 0.85,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              SizedBox(height: _getSpacing()),
              ElevatedButton.icon(
                onPressed: _initializePlayer,
                icon: Icon(Icons.refresh, size: _getTextSize()),
                label: Text('重试', style: TextStyle(fontSize: _getTextSize(), fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: _getSpacing() * 2, vertical: _getSpacing() * 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_getSpacing() * 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
