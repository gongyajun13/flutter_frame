import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import '../config/environment_config.dart';
import '../../utils/error_monitor_service.dart';
import '../../utils/local_cache_util.dart';
import '../controllers/theme_controller.dart';
import '../services/theme_service.dart';

/// 初始化所有全局服务
/// 
/// 在 main() 函数中调用，确保所有服务在应用启动前初始化完成
class InitServices {
  /// 初始化服务
  static Future<void> init() async {
    // 1. 初始化环境配置（最先初始化，用于控制后续服务行为）
    final envConfig = await Get.putAsync(() => EnvironmentConfig().init());
    
    // 2. 初始化错误监控服务（依赖环境配置）
    await Get.putAsync(() => ErrorMonitorService().init(
          enableConsoleLog: envConfig.enableConsoleLog,
          enableErrorReporting: envConfig.enableErrorReporting,
        ));
    
    // 3. 初始化 SharedPreferences（预初始化，避免重复调用）
    final prefs = await SharedPreferences.getInstance();
    LocalCacheUtil.setInstance(prefs);
    
    // 4. 初始化存储服务（使用已初始化的 SharedPreferences）
    await Get.putAsync(() => StorageService().init());
    
    // 5. 预加载主题设置（避免 ThemeController 异步加载导致延迟）
    final themeService = ThemeService();
    final themeMode = await themeService.getThemeMode();
    final currentTheme = await themeService.getCurrentTheme();
    
    // 6. 创建并初始化主题控制器（同步设置主题，避免首次渲染闪烁）
    final themeController = Get.put(ThemeController());
    themeController.themeMode.value = themeMode;
    themeController.currentTheme.value = currentTheme;
    
    // 注意：数据库初始化已延迟到首页加载后，以提升启动速度
    // 数据库初始化将在 HomeController.onInit() 中异步执行
    
    debugPrint('✅ 所有关键服务初始化完成');
  }
}

