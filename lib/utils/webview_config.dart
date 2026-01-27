import 'package:flutter/foundation.dart';

/// WebView 配置类
/// 
/// 提供统一的 WebView 配置管理
class WebViewConfig {
  WebViewConfig._();

  /// 默认 UserAgent
  static const String defaultUserAgent =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

  /// 是否启用文件下载
  static bool enableFileDownload = true;

  /// 是否启用长按菜单
  static bool enableLongPressMenu = false;

  /// 允许的域名列表（白名单，为空表示不限制）
  static List<String> allowedDomains = [];

  /// 禁止的域名列表（黑名单）
  static List<String> blockedDomains = [];

  /// 获取默认请求头
  static Map<String, String> getDefaultHeaders() {
    return {
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    };
  }

  /// 获取初始化延迟时间
  /// 
  /// 可以根据平台或配置返回不同的延迟
  /// [platform] 平台类型（可选，默认根据当前平台）
  static Duration getInitializationDelay({String? platform}) {
    // 可以根据平台返回不同的延迟
    // Android 可能需要更长的初始化时间
    return const Duration(milliseconds: 300);
  }

  /// 是否启用调试模式
  /// 
  /// [platform] 平台类型（可选，默认根据当前平台）
  static bool shouldEnableDebugging({String? platform}) {
    // 生产环境返回 false，开发环境返回 true
    return kDebugMode;
  }

  /// 检查 URL 是否允许访问
  /// 
  /// [url] 要检查的 URL
  /// 
  /// 返回 true 表示允许，false 表示禁止
  static bool isUrlAllowed(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      // 检查黑名单
      for (final blocked in blockedDomains) {
        if (host.contains(blocked.toLowerCase())) {
          return false;
        }
      }

      // 如果白名单为空，允许所有域名
      if (allowedDomains.isEmpty) {
        return true;
      }

      // 检查白名单
      for (final allowed in allowedDomains) {
        if (host.contains(allowed.toLowerCase()) || host.endsWith('.${allowed.toLowerCase()}')) {
          return true;
        }
      }

      return false;
    } catch (e) {
      // URL 解析失败，默认允许
      return true;
    }
  }
}

/// WebView 缓存策略
enum WebViewCachePolicy {
  /// 默认缓存策略
  defaultCache,

  /// 不使用缓存
  noCache,

  /// 仅使用缓存
  cacheOnly,
}

/// WebView 错误重试策略
class WebViewRetryStrategy {
  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟时间
  final Duration retryDelay;

  /// 是否启用指数退避
  final bool enableExponentialBackoff;

  const WebViewRetryStrategy({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.enableExponentialBackoff = true,
  });

  /// 获取重试延迟时间
  /// 
  /// [attempt] 当前重试次数（从 1 开始）
  Duration getRetryDelay(int attempt) {
    if (!enableExponentialBackoff) {
      return retryDelay;
    }

    // 指数退避：2秒、4秒、8秒...
    final multiplier = 1 << (attempt - 1); // 2^(attempt-1)
    return Duration(
      milliseconds: retryDelay.inMilliseconds * multiplier,
    );
  }
}
