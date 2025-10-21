# 🖼️ 缓存图片Widget使用指南

## 📋 概述

基于`cached_network_image`插件创建的自定义图片展示Widget，支持多种样式和效果，包括头像类型、圆角类型、毛玻璃效果、不同占位图等。

## 🎯 功能特点

### 1. 多种图片类型
- ✅ **头像类型** - 圆形头像，带边框和阴影
- ✅ **圆角类型** - 可自定义圆角大小的矩形图片
- ✅ **毛玻璃效果** - 带有毛玻璃渐变效果的图片
- ✅ **占位图类型** - 带边框的占位图样式
- ✅ **自定义类型** - 完全自定义的样式

### 2. 智能缓存管理
- ✅ 自动缓存网络图片
- ✅ 支持占位图和错误处理
- ✅ 淡入淡出动画效果
- ✅ 内存和磁盘缓存优化

### 3. 丰富的自定义选项
- ✅ 自定义占位图Widget
- ✅ 自定义错误处理Widget
- ✅ 支持点击回调
- ✅ 支持错误回调

## 🚀 使用方法

### 1. 基础图片Widget

```dart
import '../widgets/cached_image_widgets.dart';

// 基础使用
CachedImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.w,
  height: 200.h,
  imageType: ImageType.rounded,
  onTap: () => print('图片被点击'),
  onError: () => print('图片加载失败'),
)
```

### 2. 头像图片Widget

```dart
// 基础头像
AvatarImageWidget(
  imageUrl: 'https://example.com/avatar.jpg',
  size: 60,
  onTap: () => print('头像被点击'),
)

// 自定义占位图的头像
AvatarImageWidget(
  imageUrl: 'https://example.com/avatar.jpg',
  size: 80,
  placeholder: CustomPlaceholderWidget(
    icon: Icons.person,
    title: '加载中...',
    backgroundColor: Colors.blue.shade50,
    iconColor: Colors.blue.shade400,
  ),
  errorWidget: CustomErrorWidget(
    icon: Icons.person_off,
    message: '头像加载失败',
    backgroundColor: Colors.red.shade50,
    iconColor: Colors.red.shade400,
    onRetry: () => print('重试加载'),
  ),
)
```

### 3. 圆角图片Widget

```dart
// 基础圆角图片
RoundedImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.w,
  height: 150.h,
  borderRadius: 12,
  onTap: () => print('圆角图片被点击'),
)

// 全宽圆角图片
RoundedImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  width: double.infinity,
  height: 200.h,
  fit: BoxFit.cover,
)
```

### 4. 毛玻璃效果图片Widget

```dart
// 毛玻璃效果图片
GlassImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.w,
  height: 200.h,
  onTap: () => print('毛玻璃图片被点击'),
)

// 全宽毛玻璃效果
GlassImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  width: double.infinity,
  height: 150.h,
  fit: BoxFit.cover,
)
```

### 5. 占位图图片Widget

```dart
// 占位图样式图片
PlaceholderImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.w,
  height: 200.h,
  onTap: () => print('占位图图片被点击'),
)
```

### 6. 自定义占位图和错误Widget

```dart
// 自定义占位图
CustomPlaceholderWidget(
  icon: Icons.image,
  title: '加载中...',
  backgroundColor: Colors.blue.shade50,
  iconColor: Colors.blue.shade400,
  width: 200.w,
  height: 200.h,
)

// 自定义错误Widget
CustomErrorWidget(
  icon: Icons.error_outline,
  message: '加载失败',
  backgroundColor: Colors.red.shade50,
  iconColor: Colors.red.shade400,
  width: 200.w,
  height: 200.h,
  onRetry: () => print('重试加载'),
)
```

## 🎨 样式配置

### 1. 图片类型枚举

```dart
enum ImageType {
  avatar,      // 头像 - 圆形，带边框和阴影
  rounded,     // 圆角 - 可自定义圆角大小
  glass,       // 毛玻璃 - 带渐变效果
  placeholder, // 占位图 - 带边框样式
  custom,      // 自定义 - 完全自定义
}
```

### 2. 加载状态枚举

```dart
enum ImageLoadState {
  loading,  // 加载中
  loaded,   // 加载完成
  error,    // 加载失败
}
```

## 📱 演示页面

### 功能展示
1. **头像类型演示**
   - 不同尺寸的头像（40px, 60px, 80px）
   - 自定义占位图的头像
   - 错误处理示例

2. **圆角类型演示**
   - 不同尺寸的圆角图片
   - 长宽比不同的圆角图片
   - 全宽圆角图片

3. **毛玻璃效果演示**
   - 方形毛玻璃效果图片
   - 全宽毛玻璃效果图片

4. **占位图演示**
   - 不同尺寸的占位图样式
   - 全宽占位图样式

5. **自定义演示**
   - 自定义占位图
   - 自定义错误处理
   - 重试功能

### 测试功能
- **测试图片加载** - 验证图片加载功能
- **测试错误处理** - 验证错误处理机制
- **清除图片缓存** - 清除缓存数据
- **刷新图片** - 重新加载图片

## 🔧 高级配置

### 1. 动画配置

```dart
CachedImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  fadeInDuration: Duration(milliseconds: 500),
  fadeOutDuration: Duration(milliseconds: 200),
  fadeInCurve: Curves.easeInOut,
  fadeOutCurve: Curves.easeOut,
)
```

### 2. 图片适配配置

```dart
CachedImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,  // 填充模式
  // BoxFit.contain,  // 包含模式
  // BoxFit.fill,     // 拉伸模式
  // BoxFit.fitWidth, // 适应宽度
  // BoxFit.fitHeight,// 适应高度
)
```

### 3. 回调配置

```dart
CachedImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  onTap: () {
    // 图片点击回调
    print('图片被点击');
  },
  onError: () {
    // 图片加载错误回调
    print('图片加载失败');
  },
)
```

## 🎯 最佳实践

### 1. 性能优化
- 合理设置图片尺寸，避免加载过大的图片
- 使用合适的`BoxFit`模式
- 为不同场景选择合适的图片类型

### 2. 用户体验
- 提供有意义的占位图
- 实现友好的错误处理
- 添加适当的加载动画

### 3. 错误处理
- 提供重试机制
- 显示有意义的错误信息
- 使用合适的错误图标

## 📊 使用示例

### 1. 用户头像列表

```dart
ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    final user = users[index];
    return ListTile(
      leading: AvatarImageWidget(
        imageUrl: user.avatarUrl,
        size: 50,
        onTap: () => _showUserProfile(user),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
    );
  },
)
```

### 2. 图片网格展示

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8.w,
    mainAxisSpacing: 8.h,
  ),
  itemCount: images.length,
  itemBuilder: (context, index) {
    return RoundedImageWidget(
      imageUrl: images[index].url,
      width: double.infinity,
      height: 150.h,
      onTap: () => _showImageDetail(images[index]),
    );
  },
)
```

### 3. 轮播图展示

```dart
PageView.builder(
  itemCount: banners.length,
  itemBuilder: (context, index) {
    return GlassImageWidget(
      imageUrl: banners[index].imageUrl,
      width: double.infinity,
      height: 200.h,
      fit: BoxFit.cover,
      onTap: () => _handleBannerTap(banners[index]),
    );
  },
)
```

## 🎊 总结

**缓存图片Widget提供了完整的图片展示解决方案：**

- ✅ **多种样式** - 头像、圆角、毛玻璃、占位图等
- ✅ **智能缓存** - 自动缓存管理，提升性能
- ✅ **丰富配置** - 支持自定义占位图、错误处理等
- ✅ **用户友好** - 淡入淡出动画，点击回调等
- ✅ **易于使用** - 简单的API，丰富的示例

**现在您可以在项目中使用这些Widget来展示各种类型的图片，提升用户体验！** 🚀

## 🚀 快速开始

1. 导入Widget文件
2. 选择合适的图片类型
3. 配置必要的参数
4. 处理回调和错误
5. 享受流畅的图片展示体验

**缓存图片Widget使用指南完成！** 🎉
