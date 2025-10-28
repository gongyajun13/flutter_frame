import 'package:flutter/material.dart';

/// 应用主题数据模型
/// 定义主题的所有视觉属性
class AppTheme {
  final String name;
  final String id;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color infoColor;
  final Brightness brightness;
  final ColorScheme colorScheme;
  final bool isCustom;
  final DateTime? createdAt;
  
  const AppTheme({
    required this.name,
    required this.id,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.brightness,
    required this.colorScheme,
    this.isCustom = false,
    this.createdAt,
  });
  
  /// 浅色主题
  static const AppTheme light = AppTheme(
    name: '浅色主题',
    id: 'light',
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF03DAC6),
    backgroundColor: Color(0xFFFFFFFF),
    surfaceColor: Color(0xFFF5F5F5),
    textColor: Color(0xFF212121),
    errorColor: Color(0xFFE53935),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFF9800),
    infoColor: Color(0xFF2196F3),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFFF5F5F5),
      background: Color(0xFFFFFFFF),
      error: Color(0xFFE53935),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFF212121),
      onBackground: Color(0xFF212121),
      onError: Color(0xFFFFFFFF),
    ),
  );
  
  /// 深色主题
  static const AppTheme dark = AppTheme(
    name: '深色主题',
    id: 'dark',
    primaryColor: Color(0xFF90CAF9),
    secondaryColor: Color(0xFF03DAC6),
    backgroundColor: Color(0xFF121212),
    surfaceColor: Color(0xFF1E1E1E),
    textColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFCF6679),
    successColor: Color(0xFF81C784),
    warningColor: Color(0xFFFFB74D),
    infoColor: Color(0xFF90CAF9),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Color(0xFFCF6679),
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onBackground: Color(0xFFFFFFFF),
      onError: Color(0xFF000000),
    ),
  );
  
  /// 商务主题
  static const AppTheme business = AppTheme(
    name: '商务主题',
    id: 'business',
    primaryColor: Color(0xFF2E7D32),
    secondaryColor: Color(0xFF4CAF50),
    backgroundColor: Color(0xFFFAFAFA),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF1B5E20),
    errorColor: Color(0xFFD32F2F),
    successColor: Color(0xFF388E3C),
    warningColor: Color(0xFFF57C00),
    infoColor: Color(0xFF1976D2),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF4CAF50),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFFAFAFA),
      error: Color(0xFFD32F2F),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1B5E20),
      onBackground: Color(0xFF1B5E20),
      onError: Color(0xFFFFFFFF),
    ),
  );
  
  /// 清新主题
  static const AppTheme fresh = AppTheme(
    name: '清新主题',
    id: 'fresh',
    primaryColor: Color(0xFF00BCD4),
    secondaryColor: Color(0xFF4DD0E1),
    backgroundColor: Color(0xFFF0FDFF),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF006064),
    errorColor: Color(0xFFE91E63),
    successColor: Color(0xFF00E676),
    warningColor: Color(0xFFFFC107),
    infoColor: Color(0xFF00BCD4),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF00BCD4),
      secondary: Color(0xFF4DD0E1),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF0FDFF),
      error: Color(0xFFE91E63),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF006064),
      onBackground: Color(0xFF006064),
      onError: Color(0xFFFFFFFF),
    ),
  );
  
  /// 科技主题
  static const AppTheme tech = AppTheme(
    name: '科技主题',
    id: 'tech',
    primaryColor: Color(0xFF9C27B0),
    secondaryColor: Color(0xFFE1BEE7),
    backgroundColor: Color(0xFF0D1117),
    surfaceColor: Color(0xFF161B22),
    textColor: Color(0xFFF0F6FC),
    errorColor: Color(0xFFF85149),
    successColor: Color(0xFF3FB950),
    warningColor: Color(0xFFD29922),
    infoColor: Color(0xFF58A6FF),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF9C27B0),
      secondary: Color(0xFFE1BEE7),
      surface: Color(0xFF161B22),
      background: Color(0xFF0D1117),
      error: Color(0xFFF85149),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFFF0F6FC),
      onBackground: Color(0xFFF0F6FC),
      onError: Color(0xFF000000),
    ),
  );
  
  /// 暖色主题
  static const AppTheme warm = AppTheme(
    name: '暖色主题',
    id: 'warm',
    primaryColor: Color(0xFFFF5722),
    secondaryColor: Color(0xFFFFAB91),
    backgroundColor: Color(0xFFFFF8F5),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFFBF360C),
    errorColor: Color(0xFFD32F2F),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFF9800),
    infoColor: Color(0xFF2196F3),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFF5722),
      secondary: Color(0xFFFFAB91),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFFFF8F5),
      error: Color(0xFFD32F2F),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFFBF360C),
      onBackground: Color(0xFFBF360C),
      onError: Color(0xFFFFFFFF),
    ),
  );
  
  /// 创建自定义主题
  factory AppTheme.custom({
    required String name,
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color textColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Brightness? brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final defaultErrorColor = isDark ? const Color(0xFFCF6679) : const Color(0xFFE53935);
    final defaultSuccessColor = isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final defaultWarningColor = isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
    final defaultInfoColor = isDark ? const Color(0xFF90CAF9) : const Color(0xFF2196F3);
    
    return AppTheme(
      name: name,
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      backgroundColor: backgroundColor,
      surfaceColor: surfaceColor,
      textColor: textColor,
      errorColor: errorColor ?? defaultErrorColor,
      successColor: successColor ?? defaultSuccessColor,
      warningColor: warningColor ?? defaultWarningColor,
      infoColor: infoColor ?? defaultInfoColor,
      brightness: brightness ?? Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness ?? Brightness.light,
      ),
      isCustom: true,
      createdAt: DateTime.now(),
    );
  }
  
  /// 获取所有预设主题
  static const List<AppTheme> presets = [
    light,
    dark,
    business,
    fresh,
    tech,
    warm,
  ];
  
  /// 从JSON创建主题
  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      primaryColor: Color(json['primaryColor'] ?? 0xFF2196F3),
      secondaryColor: Color(json['secondaryColor'] ?? 0xFF03DAC6),
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFFFF),
      surfaceColor: Color(json['surfaceColor'] ?? 0xFFF5F5F5),
      textColor: Color(json['textColor'] ?? 0xFF212121),
      errorColor: Color(json['errorColor'] ?? 0xFFE53935),
      successColor: Color(json['successColor'] ?? 0xFF4CAF50),
      warningColor: Color(json['warningColor'] ?? 0xFFFF9800),
      infoColor: Color(json['infoColor'] ?? 0xFF2196F3),
      brightness: json['brightness'] == 'dark' ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(json['primaryColor'] ?? 0xFF2196F3),
        brightness: json['brightness'] == 'dark' ? Brightness.dark : Brightness.light,
      ),
      isCustom: json['isCustom'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'backgroundColor': backgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'textColor': textColor.value,
      'errorColor': errorColor.value,
      'successColor': successColor.value,
      'warningColor': warningColor.value,
      'infoColor': infoColor.value,
      'brightness': brightness == Brightness.dark ? 'dark' : 'light',
      'isCustom': isCustom,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
  
  /// 复制主题并修改部分属性
  AppTheme copyWith({
    String? name,
    String? id,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Brightness? brightness,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return AppTheme(
      name: name ?? this.name,
      id: id ?? this.id,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      brightness: brightness ?? this.brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor ?? this.primaryColor,
        brightness: brightness ?? this.brightness,
      ),
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTheme && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'AppTheme(name: $name, id: $id, brightness: $brightness)';
  }
}

