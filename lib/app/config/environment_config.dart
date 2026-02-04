import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../network/config/api_config.dart';
import '../../network/config/network_config.dart';
import '../../utils/local_cache_util.dart';

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

  /// 当前 API 基础地址（启动时初始化，可在调试模式下运行时切换）
  late String apiBaseUrl;

  /// 是否启用网络日志（Dio 日志拦截器）
  late bool enableNetworkLog;

  /// 是否在控制台输出错误日志
  late bool enableConsoleLog;

  /// 是否启用错误上报（Sentry / Crashlytics 等）
  late bool enableErrorReporting;

  /// 当前网络代理地址（例如 127.0.0.1:8888），仅用于调试
  String? proxy;

  /// 是否启用网络代理
  bool enableProxy = false;

  /// 是否为开发环境
  bool get isDev => env.value == AppEnvironment.development;

  /// 是否为测试环境
  bool get isTest => env.value == AppEnvironment.test;

  /// 是否为生产环境
  bool get isProd => env.value == AppEnvironment.production;

  /// 初始化环境配置
  Future<EnvironmentConfig> init() async {
    // 1. 先看本地是否有用户手动选择的环境（调试面板设置）
    final savedEnv = await LocalCacheUtil.getString('app_env_override');

    // 2. 没有保存的覆盖值时，再根据构建参数 / kDebugMode 推断
    String envString;
    if (savedEnv != null && savedEnv.isNotEmpty) {
      envString = savedEnv;
    } else {
      const rawEnvString = String.fromEnvironment('APP_ENV', defaultValue: '');
      envString = rawEnvString.isEmpty
          ? (kDebugMode ? 'dev' : 'prod')
          : rawEnvString;
    }

    _applyEnv(envString.toLowerCase());

    // 初始化 Dio
    final _ = NetworkConfig.dio;

    // 3. 读取并应用网络代理配置
    final savedProxy = await LocalCacheUtil.getString('net_proxy');
    final savedProxyEnabled =
        await LocalCacheUtil.getBool('net_proxy_enabled') ?? false;

    proxy = savedProxy;
    enableProxy = savedProxyEnabled && (savedProxy?.isNotEmpty ?? false);

    if (enableProxy && proxy != null && proxy!.isNotEmpty) {
      NetworkConfig.setProxy(proxy!);
    } else {
      NetworkConfig.clearProxy();
    }

    // 更新 Dio 的 baseUrl
    NetworkConfig.updateBaseUrl(apiBaseUrl);

    return this;
  }

  /// 运行时切换环境（用于调试面板）
  void setRuntimeEnvironment(AppEnvironment target) {
    switch (target) {
      case AppEnvironment.development:
        _applyEnv('dev');
        LocalCacheUtil.setString('app_env_override', 'dev');
        break;
      case AppEnvironment.test:
        _applyEnv('test');
        LocalCacheUtil.setString('app_env_override', 'test');
        break;
      case AppEnvironment.production:
        _applyEnv('prod');
        LocalCacheUtil.setString('app_env_override', 'prod');
        break;
    }
    // 更新 Dio 的 baseUrl
    NetworkConfig.updateBaseUrl(apiBaseUrl);
  }

  /// 设置 / 关闭网络代理
  Future<void> setProxyConfig(String? proxyAddress, {required bool enabled}) async {
    proxy = proxyAddress;
    enableProxy = enabled && proxyAddress != null && proxyAddress.isNotEmpty;

    if (enableProxy && proxy != null && proxy!.isNotEmpty) {
      NetworkConfig.setProxy(proxy!);
      await LocalCacheUtil.setString('net_proxy', proxy!);
      await LocalCacheUtil.setBool('net_proxy_enabled', true);
    } else {
      NetworkConfig.clearProxy();
      await LocalCacheUtil.setString('net_proxy', '');
      await LocalCacheUtil.setBool('net_proxy_enabled', false);
    }
  }

  void _applyEnv(String envString) {
    switch (envString) {
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
  }
}

