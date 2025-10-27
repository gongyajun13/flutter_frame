# 🎬 缓存视频播放器Widget使用指南

## 📋 概述

基于`video_player`插件创建的带缓存功能的视频播放器Widget，支持播放控制、进度条拖动、封面图显示等功能。

## 🎯 功能特点

### 1. 核心功能
- ✅ **视频播放** - 支持网络视频播放
- ✅ **播放控制** - 播放/暂停功能
- ✅ **进度控制** - 拖动进度条跳转
- ✅ **时长显示** - 当前时间和总时长
- ✅ **封面图** - 支持自定义封面图
- ✅ **状态监听** - 播放状态变化回调

### 2. 用户体验
- ✅ **加载状态** - 加载中提示
- ✅ **错误处理** - 错误状态显示
- ✅ **自动播放** - 支持自动播放
- ✅ **循环播放** - 支持循环播放
- ✅ **静音控制** - 支持静音播放

### 3. 自定义选项
- ✅ **控制条显示** - 可控制显示/隐藏
- ✅ **进度条显示** - 可控制显示/隐藏
- ✅ **自定义占位图** - 自定义加载占位
- ✅ **自定义错误处理** - 自定义错误显示
- ✅ **点击回调** - 支持点击事件

## 🚀 使用方法

### 1. 基础使用

```dart
import '../widgets/cached_video_player_widget.dart';

CachedVideoPlayerWidget(
  videoUrl: 'https://example.com/video.mp4',
  width: 375,
  height: 200,
)
```

### 2. 带封面图的播放器

```dart
CachedVideoPlayerWidget(
  videoUrl: 'https://example.com/video.mp4',
  coverImageUrl: 'https://example.com/cover.jpg',
  width: double.infinity,
  height: 200,
  autoPlay: false,
)
```

### 3. 完整配置

```dart
CachedVideoPlayerWidget(
  videoUrl: 'https://example.com/video.mp4',
  coverImageUrl: 'https://example.com/cover.jpg',
  width: double.infinity,
  height: 200,
  autoPlay: false,
  looping: false,
  muted: false,
  showControls: true,
  showProgressBar: true,
  placeholder: YourCustomPlaceholder(),
  errorWidget: YourCustomErrorWidget(),
  onStateChanged: (state) {
    print('播放状态: $state');
  },
  onPositionChanged: (position, duration) {
    print('当前进度: $position / $duration');
  },
  onPlaybackCompleted: () {
    print('播放完成');
  },
  onTap: () {
    print('视频被点击');
  },
)
```

## 🎮 API说明

### 必需参数

| 参数 | 类型 | 说明 |
|------|------|------|
| videoUrl | String | 视频URL地址 |

### 可选参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| width | double? | null | 视频宽度 |
| height | double? | null | 视频高度 |
| autoPlay | bool | false | 是否自动播放 |
| looping | bool | false | 是否循环播放 |
| muted | bool | false | 是否静音 |
| showControls | bool | true | 是否显示控制条 |
| showProgressBar | bool | true | 是否显示进度条 |
| coverImageUrl | String? | null | 封面图URL |
| placeholder | Widget? | null | 自定义占位Widget |
| errorWidget | Widget? | null | 自定义错误Widget |
| onStateChanged | Function? | null | 状态变化回调 |
| onPositionChanged | Function? | null | 位置变化回调 |
| onPlaybackCompleted | VoidCallback? | null | 播放完成回调 |
| onTap | VoidCallback? | null | 点击回调 |

### 播放状态枚举

```dart
enum VideoPlayerState {
  loading,   // 加载中
  playing,   // 播放中
  paused,    // 已暂停
  ended,     // 已结束
  error,     // 错误
}
```

## 📱 演示页面

### 功能展示
1. **主播放器**
   - 带封面图的播放器
   - 播放控制
   - 进度条拖动

2. **小播放器**
   - 简化版播放器
   - 基础播放功能

3. **状态监控**
   - 实时播放状态显示
   - 时长和进度显示

## 🎯 使用场景

### 1. 视频详情页

```dart
class VideoDetailPage extends StatelessWidget {
  final Video video;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CachedVideoPlayerWidget(
            videoUrl: video.url,
            coverImageUrl: video.coverUrl,
            width: double.infinity,
            height: 220,
          ),
          // 视频信息
          VideoInfoWidget(video: video),
        ],
      ),
    );
  }
}
```

### 2. 视频列表

```dart
ListView.builder(
  itemCount: videos.length,
  itemBuilder: (context, index) {
    final video = videos[index];
    return VideoListItem(
      child: CachedVideoPlayerWidget(
        videoUrl: video.url,
        coverImageUrl: video.thumbnail,
        width: 120,
        height: 80,
        showControls: false,
      ),
    );
  },
)
```

### 3. 横屏全屏播放

```dart
CachedVideoPlayerWidget(
  videoUrl: video.url,
  width: MediaQuery.of(context).size.width,
  height: MediaQuery.of(context).size.height,
  autoPlay: true,
)
```

## 🔧 高级配置

### 1. 监听播放状态

```dart
CachedVideoPlayerWidget(
  videoUrl: videoUrl,
  onStateChanged: (state) {
    switch (state) {
      case VideoPlayerState.loading:
        // 开始加载
        break;
      case VideoPlayerState.playing:
        // 开始播放
        break;
      case VideoPlayerState.paused:
        // 暂停播放
        break;
      case VideoPlayerState.ended:
        // 播放完成
        break;
      case VideoPlayerState.error:
        // 播放错误
        break;
    }
  },
)
```

### 2. 进度监听

```dart
CachedVideoPlayerWidget(
  videoUrl: videoUrl,
  onPositionChanged: (position, duration) {
    final progress = position.inSeconds / duration.inSeconds;
    setState(() {
      _progress = progress;
    });
  },
)
```

### 3. 自定义错误处理

```dart
CachedVideoPlayerWidget(
  videoUrl: videoUrl,
  errorWidget: Container(
    color: Colors.black,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.white),
        SizedBox(height: 16),
        Text('视频加载失败', style: TextStyle(color: Colors.white)),
        ElevatedButton(
          onPressed: () {
            // 重试逻辑
          },
          child: Text('重试'),
        ),
      ],
    ),
  ),
)
```

## 🎊 最佳实践

### 1. 性能优化
- 合理设置视频尺寸，避免加载过大的视频
- 使用封面图减少初始加载时间
- 及时释放播放器资源

### 2. 用户体验
- 提供清晰的加载状态提示
- 实现友好的错误处理
- 支持手势控制（暂停/播放）

### 3. 网络优化
- 使用适当的视频格式和码率
- 考虑使用CDN加速
- 实现视频预加载功能

## 📊 使用示例

### 完整的视频播放页面

```dart
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? coverUrl;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CachedVideoPlayerWidget(
            videoUrl: videoUrl,
            coverImageUrl: coverUrl,
            width: double.infinity,
            height: 220,
            showControls: true,
            showProgressBar: true,
            autoPlay: false,
            onStateChanged: (state) {
              debugPrint('播放状态: $state');
            },
          ),
          // 视频信息
          Expanded(
            child: VideoDetailInfo(),
          ),
        ],
      ),
    );
  }
}
```

## 🎊 总结

**缓存视频播放器Widget提供了完整的视频播放解决方案：**

- ✅ **视频播放** - 支持网络视频播放
- ✅ **播放控制** - 播放/暂停功能
- ✅ **进度控制** - 拖动进度条跳转
- ✅ **封面图** - 支持自定义封面图
- ✅ **状态监听** - 播放状态变化回调
- ✅ **易于使用** - 简单的API，丰富的配置

**现在您可以在项目中使用这个Widget来播放各种视频，提升用户体验！** 🚀
