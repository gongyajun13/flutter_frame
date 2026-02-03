import 'package:get/get.dart';
import '../../network/config/api_config.dart';
import '../../network/config/network_config.dart';

/// 应用运行环境
enum AppEnvironment {
  development,
  test,
  production,
}

/// 环境与配置管理服务
/// - 管理当前运行环境（dev/test/prod）及其相关配置
/// - 统一控制 baseUrl、日志开关、错误上报开关等
class EnvironmentConfig extends GetxService {
  /// 当前环境（默认 production，可通过 --dart-define APP_ENV=dev 覆盖）
  final Rx<AppEnvironment> env = AppEnvironment.production.obs;

  /// 当前 API 基础地址
  late final String apiBaseUrl;

  /// 是否启用网络日志（Dio 日志拦截器）
  late final bool enableNetworkLog;

  /// 是否在控制台输出错误日志
  late final bool enableConsoleLog;

  /// 是否启用错误上报（Sentry / Crashlytics 等）
  late final bool enableErrorReporting;

  /// 是否为开发环境
  bool get isDev => env.value == AppEnvironment.development;

  /// 是否为测试环境
  bool get isTest => env.value == AppEnvironment.test;

  /// 是否为生产环境
  bool get isProd => env.value == AppEnvironment.production;

  /// 初始化环境配置
  Future<EnvironmentConfig> init() async {
    // 从编译参数中读取环境变量（可通过 --dart-define APP_ENV=dev 传入）
    const envString = String.fromEnvironment('APP_ENV', defaultValue: 'prod');

    switch (envString.toLowerCase()) {
      case 'dev':
      case 'development':
        env.value = AppEnvironment.development;
        apiBaseUrl = ApiConfig.devBaseUrl;
        enableNetworkLog = true;
        enableConsoleLog = true;
        enableErrorReporting = false;
        break;
      case 'test':
        env.value = AppEnvironment.test;
        apiBaseUrl = ApiConfig.testBaseUrl;
        enableNetworkLog = true;
        enableConsoleLog = true;
        enableErrorReporting = true;
        break;
      case 'prod':
      case 'production':
      default:
        env.value = AppEnvironment.production;
        apiBaseUrl = ApiConfig.baseUrl;
        enableNetworkLog = false;
        enableConsoleLog = false;
        enableErrorReporting = true;
        break;
    }

    // 更新 Dio 的 baseUrl
    NetworkConfig.updateBaseUrl(apiBaseUrl);

    return this;
  }
}

