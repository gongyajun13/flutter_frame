import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../app/controllers/theme_controller.dart';
import '../app/models/theme_model.dart';

/// 应用设计令牌（Design Tokens）
/// 统一管理颜色、字体、间距、圆角等设计规范
/// 支持主题切换，颜色值会根据当前主题动态变化
class AppDesignTokens {
  AppDesignTokens._();

  // ==================== 主题访问 ====================
  
  /// 获取当前主题控制器（如果已注册）
  static ThemeController? get _themeController {
    try {
      return Get.find<ThemeController>();
    } catch (e) {
      return null;
    }
  }

  /// 获取当前主题（如果可用）
  static AppTheme? get _currentTheme => _themeController?.currentTheme.value;

  // ==================== 颜色系统 ====================

  /// 主色调（从当前主题获取，如果主题不可用则使用默认值）
  static Color get primaryColor => _currentTheme?.primaryColor ?? const Color(0xFF2196F3);
  static Color get primaryLight => _currentTheme?.primaryColor.withOpacity(0.7) ?? const Color(0xFF64B5F6);
  static Color get primaryDark => _currentTheme?.primaryColor.withOpacity(0.8) ?? const Color(0xFF1976D2);

  /// 辅助色（从当前主题获取，如果主题不可用则使用默认值）
  static Color get secondaryColor => _currentTheme?.secondaryColor ?? const Color(0xFF9C27B0);
  static Color get secondaryLight => _currentTheme?.secondaryColor.withOpacity(0.7) ?? const Color(0xFFBA68C8);
  static Color get secondaryDark => _currentTheme?.secondaryColor.withOpacity(0.8) ?? const Color(0xFF7B1FA2);

  /// 成功色（从当前主题获取，如果主题不可用则使用默认值）
  static Color get successColor => _currentTheme?.successColor ?? const Color(0xFF4CAF50);
  static Color get successLight => _currentTheme?.successColor.withOpacity(0.7) ?? const Color(0xFF81C784);
  static Color get successDark => _currentTheme?.successColor.withOpacity(0.8) ?? const Color(0xFF388E3C);

  /// 警告色（从当前主题获取，如果主题不可用则使用默认值）
  static Color get warningColor => _currentTheme?.warningColor ?? const Color(0xFFFF9800);
  static Color get warningLight => _currentTheme?.warningColor.withOpacity(0.7) ?? const Color(0xFFFFB74D);
  static Color get warningDark => _currentTheme?.warningColor.withOpacity(0.8) ?? const Color(0xFFF57C00);

  /// 错误色（从当前主题获取，如果主题不可用则使用默认值）
  static Color get errorColor => _currentTheme?.errorColor ?? const Color(0xFFF44336);
  static Color get errorLight => _currentTheme?.errorColor.withOpacity(0.7) ?? const Color(0xFFE57373);
  static Color get errorDark => _currentTheme?.errorColor.withOpacity(0.8) ?? const Color(0xFFD32F2F);

  /// 信息色（从当前主题获取，如果主题不可用则使用默认值）
  static Color get infoColor => _currentTheme?.infoColor ?? const Color(0xFF2196F3);
  static Color get infoLight => _currentTheme?.infoColor.withOpacity(0.7) ?? const Color(0xFF64B5F6);
  static Color get infoDark => _currentTheme?.infoColor.withOpacity(0.8) ?? const Color(0xFF1976D2);

  /// 中性色（固定值，不受主题影响）
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  /// 背景色（从当前主题获取，如果主题不可用则使用默认值）
  static Color get backgroundColor => _currentTheme?.backgroundColor ?? const Color(0xFFF5F5F5);
  static Color get surfaceColor => _currentTheme?.surfaceColor ?? Colors.white;
  static Color get cardColor => _currentTheme?.surfaceColor ?? Colors.white;

  /// 文字颜色（从当前主题获取，如果主题不可用则使用默认值）
  static Color get textPrimary => _currentTheme?.textColor ?? const Color(0xFF212121);
  static Color get textSecondary => _currentTheme?.textColor.withOpacity(0.7) ?? const Color(0xFF757575);
  static Color get textDisabled => _currentTheme?.textColor.withOpacity(0.4) ?? const Color(0xFFBDBDBD);
  static Color get textHint => _currentTheme?.textColor.withOpacity(0.6) ?? const Color(0xFF9E9E9E);

  // ==================== 字体系统 ====================

  /// 字体大小
  static double get fontSize10 => 10.sp;
  static double get fontSize12 => 12.sp;
  static double get fontSize13 => 13.sp;
  static double get fontSize14 => 14.sp;
  static double get fontSize15 => 15.sp;
  static double get fontSize16 => 16.sp;
  static double get fontSize17 => 17.sp;
  static double get fontSize18 => 18.sp;
  static double get fontSize20 => 20.sp;
  static double get fontSize24 => 24.sp;
  static double get fontSize28 => 28.sp;
  static double get fontSize32 => 32.sp;
  static double get fontSize48 => 48.sp;

  /// 字体粗细
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// 行高
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // ==================== 间距系统 ====================

  /// 间距（基于 4px 网格系统）
  static double get spacing4 => 4.w;
  static double get spacing8 => 8.w;
  static double get spacing12 => 12.w;
  static double get spacing16 => 16.w;
  static double get spacing20 => 20.w;
  static double get spacing24 => 24.w;
  static double get spacing32 => 32.w;
  static double get spacing40 => 40.w;
  static double get spacing48 => 48.w;

  /// 垂直间距
  static double get spacingV4 => 4.h;
  static double get spacingV8 => 8.h;
  static double get spacingV12 => 12.h;
  static double get spacingV16 => 16.h;
  static double get spacingV18 => 18.h;
  static double get spacingV20 => 20.h;
  static double get spacingV24 => 24.h;
  static double get spacingV32 => 32.h;

  // ==================== 圆角系统 ====================

  /// 圆角大小
  static double get radius2 => 2.r;
  static double get radius4 => 4.r;
  static double get radius8 => 8.r;
  static double get radius12 => 12.r;
  static double get radius16 => 16.r;
  static double get radius20 => 20.r;
  static double get radius24 => 24.r;
  static double get radius32 => 32.r;

  // ==================== 阴影系统 ====================

  /// 阴影配置
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4.r,
          offset: Offset(0, 2.h),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6.r,
          offset: Offset(0, 2.h),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12.r,
          offset: Offset(0, 4.h),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20.r,
          offset: Offset(0, 10.h),
          spreadRadius: 0,
        ),
      ];

  /// 带颜色的阴影
  static List<BoxShadow> shadowWithColor(Color color, {double opacity = 0.1}) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 20.r,
          offset: Offset(0, 10.h),
          spreadRadius: 0,
        ),
      ];

  // ==================== 按钮样式 ====================

  /// 按钮高度
  static double get buttonHeightSmall => 32.h;
  static double get buttonHeightMedium => 40.h;
  static double get buttonHeightLarge => 48.h;

  /// 按钮内边距
  static EdgeInsets get buttonPaddingSmall => EdgeInsets.symmetric(
        horizontal: spacing12,
        vertical: spacingV8,
      );
  static EdgeInsets get buttonPaddingMedium => EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacingV12,
      );
  static EdgeInsets get buttonPaddingLarge => EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacingV16,
      );

  // ==================== 卡片样式 ====================

  /// 卡片内边距
  static EdgeInsets get cardPaddingSmall => EdgeInsets.all(spacing12);
  static EdgeInsets get cardPaddingMedium => EdgeInsets.all(spacing16);
  static EdgeInsets get cardPaddingLarge => EdgeInsets.all(spacing20);

  /// 卡片圆角
  static double get cardRadius => radius16;

  // ==================== 输入框样式 ====================

  /// 输入框高度
  static double get inputHeight => 48.h;

  /// 输入框内边距
  static EdgeInsets get inputPadding => EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacingV12,
      );

  /// 输入框圆角
  static double get inputRadius => radius12;

  // ==================== 图标大小 ====================

  /// 图标大小
  static double get iconSizeSmall => 16.sp;
  static double get iconSizeMedium => 24.sp;
  static double get iconSizeLarge => 24.sp;
  static double get iconSizeExtraLarge => 32.sp;
  static double get iconSizeXLarge => 48.sp;

  // ==================== 动画时长 ====================

  /// 动画时长
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  /// 动画曲线
  static const Curve animationCurve = Curves.easeInOut;
}
