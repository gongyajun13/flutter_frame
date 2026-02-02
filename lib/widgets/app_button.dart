import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_design_tokens.dart';

/// 按钮类型
enum AppButtonType {
  primary, // 主要按钮
  secondary, // 次要按钮
  outline, // 轮廓按钮
  text, // 文本按钮
  danger, // 危险按钮
}

/// 按钮大小
enum AppButtonSize {
  small,
  medium,
  large,
}

/// 统一的应用按钮组件
class AppButton extends StatelessWidget {
  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final AppButtonType type;

  /// 按钮大小
  final AppButtonSize size;

  /// 是否全宽
  final bool isFullWidth;

  /// 图标
  final IconData? icon;

  /// 图标位置
  final bool iconBeforeText;

  /// 自定义背景色
  final Color? backgroundColor;

  /// 自定义文字颜色
  final Color? textColor;

  /// 是否加载中
  final bool isLoading;

  /// 自定义样式
  final ButtonStyle? style;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
    this.iconBeforeText = true,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.style,
  });

  /// 主要按钮（快捷构造）
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
    this.iconBeforeText = true,
    this.isLoading = false,
  })  : type = AppButtonType.primary,
        backgroundColor = null,
        textColor = null,
        style = null;

  /// 次要按钮（快捷构造）
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
    this.iconBeforeText = true,
    this.isLoading = false,
  })  : type = AppButtonType.secondary,
        backgroundColor = null,
        textColor = null,
        style = null;

  /// 轮廓按钮（快捷构造）
  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
    this.iconBeforeText = true,
    this.isLoading = false,
  })  : type = AppButtonType.outline,
        backgroundColor = null,
        textColor = null,
        style = null;

  /// 文本按钮（快捷构造）
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
    this.iconBeforeText = true,
    this.isLoading = false,
  })  : type = AppButtonType.text,
        backgroundColor = null,
        textColor = null,
        style = null;

  /// 危险按钮（快捷构造）
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.icon,
    this.iconBeforeText = true,
    this.isLoading = false,
  })  : type = AppButtonType.danger,
        backgroundColor = null,
        textColor = null,
        style = null;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getButtonHeight();
    final buttonStyle = _getButtonStyle();

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
        break;
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
        break;
      case AppButtonType.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildButtonContent(),
        );
        break;
    }

    Widget result = SizedBox(
      height: buttonHeight,
      child: button,
    );

    if (isFullWidth) {
      result = SizedBox(
        width: double.infinity,
        child: result,
      );
    }

    return result;
  }

  /// 构建按钮内容
  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: AppDesignTokens.iconSizeMedium,
        height: AppDesignTokens.iconSizeMedium,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(),
          ),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.add(
        Icon(
          icon,
          size: _getIconSize(),
          // 风格 C：图标弱化，颜色稍微淡一点
          color: _getTextColor().withOpacity(0.7),
        ),
      );
      children.add(SizedBox(width: AppDesignTokens.spacing8));
    }

    // 文本不再使用 Flex，避免在不定宽约束下出现布局冲突
    children.add(
      Text(
        text,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: AppDesignTokens.fontWeightSemiBold,
          color: _getTextColor(),
        ),
      ),
    );

    // 使用 FittedBox 让内容在需要时轻微缩放，而不是溢出或被硬裁切；
    // Row 保持内容在按钮内部水平、垂直居中。
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: iconBeforeText ? children : children.reversed.toList(),
      ),
    );
  }

  /// 获取按钮高度
  double _getButtonHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppDesignTokens.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppDesignTokens.buttonHeightMedium;
      case AppButtonSize.large:
        return AppDesignTokens.buttonHeightLarge;
    }
  }

  /// 获取按钮内边距
  EdgeInsets _getButtonPadding() {
    switch (size) {
      case AppButtonSize.small:
        return AppDesignTokens.buttonPaddingSmall;
      case AppButtonSize.medium:
        return AppDesignTokens.buttonPaddingMedium;
      case AppButtonSize.large:
        return AppDesignTokens.buttonPaddingLarge;
    }
  }

  /// 获取字体大小
  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppDesignTokens.fontSize12;
      case AppButtonSize.medium:
        return AppDesignTokens.fontSize14;
      case AppButtonSize.large:
        return AppDesignTokens.fontSize16;
    }
  }

  /// 获取图标大小
  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        // 风格 C：弱化图标，略小于默认尺寸
        return AppDesignTokens.iconSizeSmall * 0.85;
      case AppButtonSize.medium:
        return AppDesignTokens.iconSizeMedium * 0.85;
      case AppButtonSize.large:
        return AppDesignTokens.iconSizeMedium * 0.9;
    }
  }

  /// 获取按钮样式
  ButtonStyle _getButtonStyle() {
    if (style != null) return style!;

    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final borderColor = _getBorderColor();
    final padding = _getButtonPadding();
    final borderRadius = BorderRadius.circular(AppDesignTokens.radius12);

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 2,
        );
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 1,
        );
      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.5.w),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: textColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 2,
        );
    }
  }

  /// 获取背景色
  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    switch (type) {
      case AppButtonType.primary:
        return AppDesignTokens.primaryColor;
      case AppButtonType.secondary:
        return AppDesignTokens.grey200;
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.transparent;
      case AppButtonType.danger:
        return AppDesignTokens.errorColor;
    }
  }

  /// 获取文字颜色
  Color _getTextColor() {
    if (textColor != null) return textColor!;

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return Colors.white;
      case AppButtonType.secondary:
        return AppDesignTokens.textPrimary;
      case AppButtonType.outline:
        return AppDesignTokens.primaryColor;
      case AppButtonType.text:
        return AppDesignTokens.primaryColor;
    }
  }

  /// 获取边框颜色
  Color _getBorderColor() {
    switch (type) {
      case AppButtonType.outline:
        return AppDesignTokens.primaryColor;
      default:
        return Colors.transparent;
    }
  }
}
