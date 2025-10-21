import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 屏幕适配工具类
/// 提供统一的屏幕适配方法和常用尺寸
class ScreenUtilHelper {
  // 私有构造函数，防止实例化
  ScreenUtilHelper._();

  /// 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;

  /// 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;

  /// 获取状态栏高度
  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  /// 获取底部安全区域高度
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  /// 获取屏幕像素密度
  static double get pixelRatio => ScreenUtil().pixelRatio ?? 1.0;

  /// 获取设计稿宽度
  static double get designWidth => 375.0;

  /// 获取设计稿高度
  static double get designHeight => 812.0;

  /// 获取屏幕宽度比例
  static double get widthRatio => screenWidth / designWidth;

  /// 获取屏幕高度比例
  static double get heightRatio => screenHeight / designHeight;

  /// 判断是否为小屏幕设备
  static bool get isSmallScreen => screenWidth < 360;

  /// 判断是否为大屏幕设备
  static bool get isLargeScreen => screenWidth > 414;

  /// 判断是否为平板设备
  static bool get isTablet => screenWidth > 768;

  /// 获取适配后的字体大小
  static double fontSize(double size) => size.sp;

  /// 获取适配后的宽度
  static double width(double width) => width.w;

  /// 获取适配后的高度
  static double height(double height) => height.h;

  /// 获取适配后的圆角半径
  static double radius(double radius) => radius.r;

  /// 获取适配后的边距
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(all.w);
    }
    return EdgeInsets.only(
      left: left?.w ?? horizontal?.w ?? 0,
      top: top?.h ?? vertical?.h ?? 0,
      right: right?.w ?? horizontal?.w ?? 0,
      bottom: bottom?.h ?? vertical?.h ?? 0,
    );
  }

  /// 获取适配后的间距
  static SizedBox spacing({
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width?.w,
      height: height?.h,
    );
  }

  /// 获取适配后的容器尺寸
  static Size containerSize({
    required double width,
    required double height,
  }) {
    return Size(width.w, height.h);
  }

  /// 获取适配后的边框半径
  static BorderRadius borderRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (all != null) {
      return BorderRadius.circular(all.r);
    }
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft?.r ?? 0),
      topRight: Radius.circular(topRight?.r ?? 0),
      bottomLeft: Radius.circular(bottomLeft?.r ?? 0),
      bottomRight: Radius.circular(bottomRight?.r ?? 0),
    );
  }

  /// 获取适配后的阴影
  static List<BoxShadow> boxShadow({
    Color color = Colors.black,
    double blurRadius = 4.0,
    double spreadRadius = 0.0,
    Offset offset = Offset.zero,
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius.r,
        spreadRadius: spreadRadius.r,
        offset: offset,
      ),
    ];
  }

  /// 获取常用字体大小
  static double get fontSizeXs => 10.sp;
  static double get fontSizeSm => 12.sp;
  static double get fontSizeBase => 14.sp;
  static double get fontSizeLg => 16.sp;
  static double get fontSizeXl => 18.sp;
  static double get fontSizeXxl => 20.sp;
  static double get fontSizeXxxl => 24.sp;
  static double get fontSizeHuge => 28.sp;
  static double get fontSizeGiant => 32.sp;

  /// 获取常用间距
  static double get spacingXs => 4.w;
  static double get spacingSm => 8.w;
  static double get spacingBase => 12.w;
  static double get spacingLg => 16.w;
  static double get spacingXl => 20.w;
  static double get spacingXxl => 24.w;
  static double get spacingXxxl => 32.w;
  static double get spacingHuge => 40.w;
  static double get spacingGiant => 48.w;

  /// 获取常用高度间距
  static double get heightSpacingXs => 4.h;
  static double get heightSpacingSm => 8.h;
  static double get heightSpacingBase => 12.h;
  static double get heightSpacingLg => 16.h;
  static double get heightSpacingXl => 20.h;
  static double get heightSpacingXxl => 24.h;
  static double get heightSpacingXxxl => 32.h;
  static double get heightSpacingHuge => 40.h;
  static double get heightSpacingGiant => 48.h;

  /// 获取常用圆角半径
  static double get radiusXs => 4.r;
  static double get radiusSm => 6.r;
  static double get radiusBase => 8.r;
  static double get radiusLg => 12.r;
  static double get radiusXl => 16.r;
  static double get radiusXxl => 20.r;
  static double get radiusXxxl => 24.r;
  static double get radiusHuge => 32.r;
  static double get radiusGiant => 40.r;

  /// 获取常用按钮高度
  static double get buttonHeightSmall => 32.h;
  static double get buttonHeightMedium => 40.h;
  static double get buttonHeightLarge => 48.h;
  static double get buttonHeightXlarge => 56.h;

  /// 获取常用图标大小
  static double get iconSizeXs => 12.sp;
  static double get iconSizeSm => 16.sp;
  static double get iconSizeBase => 20.sp;
  static double get iconSizeLg => 24.sp;
  static double get iconSizeXl => 28.sp;
  static double get iconSizeXxl => 32.sp;
  static double get iconSizeXxxl => 36.sp;
  static double get iconSizeHuge => 40.sp;
  static double get iconSizeGiant => 48.sp;

  /// 获取屏幕信息
  static Map<String, dynamic> getScreenInfo() {
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'statusBarHeight': statusBarHeight,
      'bottomBarHeight': bottomBarHeight,
      'pixelRatio': pixelRatio,
      'designWidth': designWidth,
      'designHeight': designHeight,
      'widthRatio': widthRatio,
      'heightRatio': heightRatio,
      'isSmallScreen': isSmallScreen,
      'isLargeScreen': isLargeScreen,
      'isTablet': isTablet,
    };
  }

  /// 打印屏幕信息（调试用）
  static void printScreenInfo() {
    final info = getScreenInfo();
    print('=== 屏幕适配信息 ===');
    info.forEach((key, value) {
      print('$key: $value');
    });
    print('==================');
  }
}
