import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/theme_model.dart';
import '../services/theme_service.dart';

/// 主题管理器 - 核心控制器
/// 提供完整的主题切换功能，包含视觉、交互、个性化三种体验
class ThemeController extends GetxController {
  // 当前主题模式
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  
  // 当前应用主题
  final Rx<AppTheme> currentTheme = AppTheme.light.obs;
  
  // 主题服务
  final ThemeService _themeService = ThemeService();
  
  // 公开主题服务供外部访问
  ThemeService get themeService => _themeService;
  
  // 是否正在切换主题
  final RxBool isChangingTheme = false.obs;
  
  // 主题切换动画控制器
  AnimationController? _animationController;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
    _setupAnimationController();
  }
  
  @override
  void onClose() {
    _animationController?.dispose();
    super.onClose();
  }
  
  /// 设置动画控制器
  void _setupAnimationController() {
    // 动画控制器将在需要时创建
  }
  
  /// 从存储加载主题设置
  Future<void> _loadThemeFromStorage() async {
    try {
      final savedThemeMode = await _themeService.getThemeMode();
      final savedTheme = await _themeService.getCurrentTheme();
      
      themeMode.value = savedThemeMode;
      currentTheme.value = savedTheme;
    } catch (e) {
      debugPrint('加载主题设置失败: $e');
    }
  }
  
  /// 切换主题模式（浅色/深色/跟随系统）
  Future<void> switchThemeMode(ThemeMode mode) async {
    if (themeMode.value == mode) return;
    
    isChangingTheme.value = true;
    
    try {
      // 播放切换动画（如果有动画控制器）
      if (_animationController != null) {
        await _animationController!.forward();
      }
      
      themeMode.value = mode;
      await _themeService.saveThemeMode(mode);
      
      // 强制更新UI
      forceUpdateTheme();
      
      // 根据模式选择对应主题
      if (mode == ThemeMode.light) {
        await switchToTheme(AppTheme.light);
      } else if (mode == ThemeMode.dark) {
        await switchToTheme(AppTheme.dark);
      } else {
        // 跟随系统，根据系统设置选择主题
        final systemBrightness = MediaQuery.of(Get.context!).platformBrightness;
        await switchToTheme(systemBrightness == Brightness.dark ? AppTheme.dark : AppTheme.light);
      }
      
      // 反向播放动画（如果有动画控制器）
      if (_animationController != null) {
        await _animationController!.reverse();
      }
    } catch (e) {
      debugPrint('切换主题模式失败: $e');
      Get.snackbar('错误', '主题切换失败，请重试');
    } finally {
      isChangingTheme.value = false;
    }
  }
  
  /// 切换到指定主题
  Future<void> switchToTheme(AppTheme theme) async {
    if (currentTheme.value == theme) return;
    
    isChangingTheme.value = true;
    
    try {
      // 播放切换动画（如果有动画控制器）
      if (_animationController != null) {
        await _animationController!.forward();
      }
      
      currentTheme.value = theme;
      await _themeService.saveCurrentTheme(theme);
      
      // 强制更新UI
      forceUpdateTheme();
      
      // 反向播放动画（如果有动画控制器）
      if (_animationController != null) {
        await _animationController!.reverse();
      }
    } catch (e) {
      debugPrint('切换主题失败: $e');
      Get.snackbar('错误', '主题切换失败，请重试');
    } finally {
      isChangingTheme.value = false;
    }
  }
  
  /// 创建自定义主题
  Future<void> createCustomTheme({
    required String name,
    required Color primaryColor,
    required Color secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    Brightness? brightness,
  }) async {
    try {
      final isDark = brightness == Brightness.dark;
      final customTheme = AppTheme.custom(
        name: name,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        backgroundColor: backgroundColor ?? (isDark ? Colors.grey.shade900 : Colors.white),
        surfaceColor: surfaceColor ?? (isDark ? Colors.grey.shade800 : Colors.grey.shade50),
        textColor: textColor ?? (isDark ? Colors.white : Colors.black87),
        brightness: brightness ?? Brightness.light,
      );
      
      await switchToTheme(customTheme);
      await _themeService.saveCustomTheme(customTheme);
      Get.snackbar('成功', '自定义主题创建成功');
    } catch (e) {
      debugPrint('创建自定义主题失败: $e');
      Get.snackbar('错误', '创建自定义主题失败');
    }
  }
  
  /// 获取当前主题的Material主题数据
  ThemeData get currentThemeData {
    return ThemeData(
      colorScheme: currentTheme.value.colorScheme,
      useMaterial3: true,
      brightness: currentTheme.value.brightness,
      primaryColor: currentTheme.value.primaryColor,
      scaffoldBackgroundColor: currentTheme.value.backgroundColor,
      cardColor: currentTheme.value.surfaceColor,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      cardTheme: _buildCardTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
    );
  }
  
  /// 强制更新主题（用于实时预览）
  void forceUpdateTheme() {
    update();
  }
  
  /// 构建文本主题
  TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        color: currentTheme.value.textColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        color: currentTheme.value.textColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        color: currentTheme.value.textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        color: currentTheme.value.textColor,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        color: currentTheme.value.textColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        color: currentTheme.value.textColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: currentTheme.value.textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        color: currentTheme.value.textColor,
      ),
    );
  }
  
  /// 构建AppBar主题
  AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: currentTheme.value.surfaceColor,
      foregroundColor: currentTheme.value.textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: currentTheme.value.textColor,
      ),
    );
  }
  
  /// 构建按钮主题
  ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: currentTheme.value.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  /// 构建卡片主题
  CardTheme _buildCardTheme() {
    return CardTheme(
      color: currentTheme.value.surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
    );
  }
  
  /// 构建输入框主题
  InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: currentTheme.value.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: currentTheme.value.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: currentTheme.value.primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: currentTheme.value.primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: currentTheme.value.textColor),
      hintStyle: TextStyle(color: currentTheme.value.textColor.withOpacity(0.6)),
    );
  }
  
  /// 获取动画控制器
  AnimationController? get animationController => _animationController;
  
  /// 获取所有可用主题
  List<AppTheme> get availableThemes => AppTheme.presets;
  
  /// 检查是否为深色主题
  bool get isDarkTheme => currentTheme.value.brightness == Brightness.dark;
  
  /// 检查是否为浅色主题
  bool get isLightTheme => currentTheme.value.brightness == Brightness.light;
  
  /// 检查是否跟随系统
  bool get isSystemTheme => themeMode.value == ThemeMode.system;
  
  /// 重置为默认主题
  Future<void> resetToDefault() async {
    try {
      await _themeService.resetToDefault();
      await switchThemeMode(ThemeMode.system);
      await switchToTheme(AppTheme.light);
      Get.snackbar('成功', '已重置为默认主题');
    } catch (e) {
      debugPrint('重置为默认主题失败: $e');
      Get.snackbar('错误', '重置主题失败');
    }
  }
}
