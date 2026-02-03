import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage_service.dart';
import '../../database/app_database.dart';
import '../config/environment_config.dart';
import '../../utils/error_monitor_service.dart';

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
    
    // 3. 初始化存储服务
    await Get.putAsync(() => StorageService().init());
    
    // 4. 初始化数据库
    await AppDatabase.instance.database;
    
    // 可以在这里添加其他全局服务的初始化
    // 例如：网络服务、日志服务等
    
    debugPrint('✅ 所有服务初始化完成');
  }
}

