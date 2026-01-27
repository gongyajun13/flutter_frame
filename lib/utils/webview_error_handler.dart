import 'package:webview_flutter/webview_flutter.dart';

/// WebView 错误处理工具类
/// 
/// 统一处理 WebView 的错误判断和错误消息格式化
class WebViewErrorHandler {
  WebViewErrorHandler._();

  /// 判断是否应该忽略该错误
  /// 
  /// [error] WebView 资源错误
  /// 
  /// 返回 true 表示应该忽略，false 表示需要处理
  static bool shouldIgnoreError(WebResourceError error) {
    // 只处理主 frame 的错误
    if (error.isForMainFrame != true) {
      return true;
    }

    final desc = error.description;

    // 1. 忽略跨域资源阻止错误（不影响主页面显示）
    if (desc.contains('ERR_BLOCKED_BY_ORB')) {
      return true;
    }

    // 2. 忽略缓存相关错误（正常现象）
    if (desc.contains('ERR_CACHE_MISS') || desc.contains('ERR_CACHE_')) {
      return true;
    }

    // 3. 忽略访问被拒绝的资源（通常是第三方资源）
    if (desc.contains('ERR_ACCESS_DENIED')) {
      return true;
    }

    // 4. 忽略 JavaScript 控制台错误（不是加载错误）
    if (desc.contains('Uncaught') ||
        desc.contains('ReferenceError') ||
        desc.contains('TypeError') ||
        desc.contains('SyntaxError')) {
      return true;
    }

    // 5. 特殊处理：未知 URL 协议（如 tel:, mailto:, intent: 等）
    if (error.errorCode == -10 || desc.contains('ERR_UNKNOWN_URL_SCHEME')) {
      // 不显示错误，这些是系统调用，不是真正的错误
      return true;
    }

    return false;
  }

  /// 格式化错误消息，使其更友好
  /// 
  /// [error] WebView 资源错误
  /// 
  /// 返回格式化的错误消息
  static String formatErrorMessage(WebResourceError error) {
    switch (error.errorCode) {
      case -2:
        return '网址无法访问\n请检查网址是否正确';
      case -6:
        return '连接被拒绝\n网站服务器拒绝了连接';
      case -7:
        return '连接超时\n请检查网络连接后点击重试';
      case -8:
        return '连接超时\n网络响应时间过长\n请检查网络后重试';
      case -10:
        return '不支持的链接类型';
      default:
        // 简化错误描述
        String desc = error.description;

        // 特殊处理超时错误
        if (desc.contains('TIMED_OUT') || desc.contains('TIMEOUT')) {
          return '连接超时\n网络响应时间过长\n请检查网络后重试';
        }

        if (desc.contains('ERR_')) {
          // 提取错误类型
          final match = RegExp(r'ERR_[A-Z_]+').firstMatch(desc);
          if (match != null) {
            final errorType = match.group(0)!;
            // 根据错误类型提供友好提示
            switch (errorType) {
              case 'ERR_NAME_NOT_RESOLVED':
                return '域名解析失败\n无法找到该网站';
              case 'ERR_INTERNET_DISCONNECTED':
                return '网络已断开\n请检查网络连接';
              case 'ERR_CONNECTION_RESET':
                return '连接被重置\n请重试';
              case 'ERR_CONNECTION_CLOSED':
                return '连接已关闭\n请重试';
              default:
                return '网页加载失败\n$errorType';
            }
          }
        }
        return '网页加载失败\n${error.description}';
    }
  }

  /// 判断错误是否需要重试
  /// 
  /// [error] WebView 资源错误
  /// 
  /// 返回 true 表示可以重试，false 表示不应该重试
  static bool shouldRetry(WebResourceError error) {
    // 网络相关错误可以重试
    final retryableCodes = [-2, -6, -7, -8];
    if (retryableCodes.contains(error.errorCode)) {
      return true;
    }

    final desc = error.description;
    if (desc.contains('TIMED_OUT') ||
        desc.contains('TIMEOUT') ||
        desc.contains('ERR_INTERNET_DISCONNECTED') ||
        desc.contains('ERR_CONNECTION_RESET')) {
      return true;
    }

    return false;
  }

  /// 获取错误的最大重试次数
  /// 
  /// [error] WebView 资源错误
  /// 
  /// 返回建议的最大重试次数
  static int getMaxRetryCount(WebResourceError error) {
    // 超时错误可以多试几次
    if (error.errorCode == -7 || error.errorCode == -8) {
      return 3;
    }
    // 其他网络错误
    return 2;
  }
}
