import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_design_tokens.dart';

/// 卡片大小
enum AppCardSize {
  small,
  medium,
  large,
}

/// 统一的应用卡片组件
class AppCard extends StatelessWidget {
  /// 卡片内容
  final Widget child;

  /// 卡片标题（可选）
  final String? title;

  /// 标题颜色
  final Color? titleColor;

  /// 卡片大小
  final AppCardSize size;

  /// 是否显示阴影
  final bool showShadow;

  /// 阴影类型
  final List<BoxShadow>? shadow;

  /// 自定义背景色
  final Color? backgroundColor;

  /// 自定义内边距
  final EdgeInsets? padding;

  /// 自定义外边距
  final EdgeInsets? margin;

  /// 自定义圆角
  final double? borderRadius;

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final Color? borderColor;

  /// 点击回调
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.titleColor,
    this.size = AppCardSize.medium,
    this.showShadow = true,
    this.shadow,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  });

  /// 小卡片（快捷构造）
  const AppCard.small({
    super.key,
    required this.child,
    this.title,
    this.titleColor,
    this.showShadow = true,
    this.shadow,
    this.backgroundColor,
    this.margin,
    this.borderRadius,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  })  : size = AppCardSize.small,
        padding = null;

  /// 大卡片（快捷构造）
  const AppCard.large({
    super.key,
    required this.child,
    this.title,
    this.titleColor,
    this.showShadow = true,
    this.shadow,
    this.backgroundColor,
    this.margin,
    this.borderRadius,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  })  : size = AppCardSize.large,
        padding = null;

  @override
  Widget build(BuildContext context) {
    final cardPadding = _getPadding();
    final cardBorderRadius = borderRadius ?? AppDesignTokens.cardRadius;
    final cardShadow = _getShadow();
    final cardBackgroundColor = backgroundColor ?? AppDesignTokens.cardColor;
    final cardBorderColor = borderColor ?? AppDesignTokens.grey200;

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: showShadow ? cardShadow : null,
        border: showBorder
            ? Border.all(
                color: cardBorderColor,
                width: 1.w,
              )
            : null,
      ),
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              _buildTitle(),
              SizedBox(height: AppDesignTokens.spacingV12),
            ],
            child,
          ],
        ),
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: content,
      );
    }

    return content;
  }

  /// 构建标题
  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: titleColor ?? AppDesignTokens.primaryColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: AppDesignTokens.spacing12),
        Expanded(
          child: Text(
            title!,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize17,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: titleColor ?? AppDesignTokens.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  /// 获取内边距
  EdgeInsets _getPadding() {
    if (padding != null) return padding!;

    switch (size) {
      case AppCardSize.small:
        return AppDesignTokens.cardPaddingSmall;
      case AppCardSize.medium:
        return AppDesignTokens.cardPaddingMedium;
      case AppCardSize.large:
        return AppDesignTokens.cardPaddingLarge;
    }
  }

  /// 获取阴影
  List<BoxShadow> _getShadow() {
    if (shadow != null) return shadow!;

    return AppDesignTokens.shadowMedium;
  }
}
