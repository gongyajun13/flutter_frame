import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 图片加载状态枚举
enum ImageLoadState {
  loading,
  loaded,
  error,
}

/// 图片类型枚举
enum ImageType {
  avatar,      // 头像
  rounded,     // 圆角
  glass,       // 毛玻璃
  placeholder, // 占位图
  custom,      // 自定义
}

/// 自定义图片Widget基类
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;
  final ImageType imageType;
  final VoidCallback? onTap;
  final VoidCallback? onError;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 100),
    this.fadeInCurve = Curves.easeIn,
    this.fadeOutCurve = Curves.easeOut,
    this.imageType = ImageType.custom,
    this.onTap,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      fadeInCurve: fadeInCurve,
      fadeOutCurve: fadeOutCurve,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) {
        onError?.call();
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );

    // 根据图片类型应用不同的样式
    switch (imageType) {
      case ImageType.avatar:
        return _buildAvatarStyle(imageWidget);
      case ImageType.rounded:
        return _buildRoundedStyle(imageWidget);
      case ImageType.glass:
        return _buildGlassStyle(imageWidget);
      case ImageType.placeholder:
        return _buildPlaceholderStyle(imageWidget);
      case ImageType.custom:
        return _buildCustomStyle(imageWidget);
    }
  }

  /// 构建头像样式
  Widget _buildAvatarStyle(Widget imageWidget) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 60.w,
        height: height ?? 60.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipOval(
          child: imageWidget,
        ),
      ),
    );
  }

  /// 构建圆角样式
  Widget _buildRoundedStyle(Widget imageWidget) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: imageWidget,
        ),
      ),
    );
  }

  /// 构建毛玻璃样式
  Widget _buildGlassStyle(Widget imageWidget) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              imageWidget,
              // 毛玻璃效果层
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建占位图样式
  Widget _buildPlaceholderStyle(Widget imageWidget) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.w,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: imageWidget,
        ),
      ),
    );
  }

  /// 构建自定义样式
  Widget _buildCustomStyle(Widget imageWidget) {
    return GestureDetector(
      onTap: onTap,
      child: imageWidget,
    );
  }

  /// 构建默认占位图
  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  /// 构建默认错误Widget
  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 24.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 4.h),
          Flexible(
            child: Text(
              '加载失败',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 头像图片Widget
class AvatarImageWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onError;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AvatarImageWidget({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.onTap,
    this.onError,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: size.w,
      height: size.w,
      imageType: ImageType.avatar,
      onTap: onTap,
      onError: onError,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

/// 圆角图片Widget
class RoundedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final VoidCallback? onTap;
  final VoidCallback? onError;
  final Widget? placeholder;
  final Widget? errorWidget;

  const RoundedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.onTap,
    this.onError,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      imageType: ImageType.rounded,
      onTap: onTap,
      onError: onError,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

/// 毛玻璃效果图片Widget
class GlassImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final VoidCallback? onTap;
  final VoidCallback? onError;
  final Widget? placeholder;
  final Widget? errorWidget;

  const GlassImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.onTap,
    this.onError,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      imageType: ImageType.glass,
      onTap: onTap,
      onError: onError,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

/// 占位图图片Widget
class PlaceholderImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final VoidCallback? onTap;
  final VoidCallback? onError;
  final Widget? placeholder;
  final Widget? errorWidget;

  const PlaceholderImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.onTap,
    this.onError,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      imageType: ImageType.placeholder,
      onTap: onTap,
      onError: onError,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

/// 自定义占位图Widget
class CustomPlaceholderWidget extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? width;
  final double? height;

  const CustomPlaceholderWidget({
    super.key,
    this.title,
    this.icon,
    this.backgroundColor,
    this.iconColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade200,
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 24.sp,
              color: iconColor ?? Colors.grey.shade400,
            ),
            SizedBox(height: 4.h),
          ],
          if (title != null)
            Flexible(
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: iconColor ?? Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

/// 自定义错误Widget
class CustomErrorWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? width;
  final double? height;

  const CustomErrorWidget({
    super.key,
    this.message,
    this.icon,
    this.backgroundColor,
    this.iconColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade100,
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.broken_image,
            size: 24.sp,
            color: iconColor ?? Colors.grey.shade400,
          ),
          if (message != null) ...[
            SizedBox(height: 4.h),
            Flexible(
              child: Text(
                message!,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: iconColor ?? Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
