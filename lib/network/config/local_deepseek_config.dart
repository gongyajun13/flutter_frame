/// 本地 DeepSeek API 配置
/// 
/// ⚠️ 注意：此文件包含敏感信息，不应提交到版本控制系统
/// 请确保此文件已在 .gitignore 中
/// 
/// 使用方法：
/// 在应用启动时，可以从这里读取默认的 API 密钥
/// 
/// ```dart
/// import 'package:your_app/network/config/local_deepseek_config.dart';
/// import 'package:your_app/network/services/deepseek_service.dart';
/// 
/// void main() {
///   // 使用本地配置的 API 密钥（仅用于开发环境）
///   if (LocalDeepSeekConfig.defaultApiKey.isNotEmpty) {
///     DeepSeekService.initialize(LocalDeepSeekConfig.defaultApiKey);
///   }
///   
///   runApp(MyApp());
/// }
/// ```

class LocalDeepSeekConfig {
  /// 默认 API 密钥（本地开发使用）
  /// 
  /// 此密钥仅用于本地开发和测试
  /// 生产环境应通过安全的方式获取密钥（如环境变量、安全存储等）
  static const String defaultApiKey = 'sk-f064e0083b3142158542fde44618f348';
  
  /// 是否启用本地默认密钥
  /// 
  /// 设置为 false 可以禁用自动使用本地密钥
  /// 这样用户必须手动在应用中设置 API 密钥
  static const bool enableDefaultKey = false; // 默认禁用，需要用户手动设置
  
  /// 获取 API 密钥
  /// 
  /// 如果启用了默认密钥，返回默认密钥
  /// 否则返回空字符串，需要用户手动设置
  static String get apiKey {
    if (enableDefaultKey && defaultApiKey.isNotEmpty) {
      return defaultApiKey;
    }
    return '';
  }
}
