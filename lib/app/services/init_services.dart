import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

/// 初始化所有全局服务
/// 
/// 在 main() 函数中调用，确保所有服务在应用启动前初始化完成
class InitServices {
  /// 初始化服务
  static Future<void> init() async {
    // 初始化存储服务
    await Get.putAsync(() => StorageService().init());
    
    // 可以在这里添加其他全局服务的初始化
    // 例如：网络服务、日志服务等
    
    debugPrint('✅ 所有服务初始化完成');
  }
}

