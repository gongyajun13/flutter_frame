import 'dart:async';
import 'package:flutter/material.dart';
import 'url_launcher_util.dart';

/// WebView 特殊协议处理工具类
/// 
/// 统一处理 tel:, mailto:, sms:, market: 等特殊协议
class WebViewSchemeHandler {
  WebViewSchemeHandler._();

  // 防止快速重复点击：记录正在处理的协议
  static final Map<String, DateTime> _processingSchemes = {};

  /// 处理特殊协议
  /// 
  /// [url] 完整的 URL
  /// [uri] 解析后的 URI
  /// 
  /// 返回 true 表示已处理，false 表示未处理
  static Future<bool> handleSpecialScheme(String url, Uri uri) async {
    try {
      final scheme = uri.scheme;

      // 【防止快速点击】检查该协议是否正在处理中
      if (_processingSchemes.containsKey(scheme)) {
        final lastTime = _processingSchemes[scheme]!;
        final now = DateTime.now();
        if (now.difference(lastTime).inMilliseconds < 500) {
          debugPrint('协议 $scheme 正在处理中，忽略重复请求');
          return true;
        }
      }

      // 标记为正在处理
      _processingSchemes[scheme] = DateTime.now();

      try {
        // 根据不同的协议类型处理
        switch (scheme) {
          case 'tel':
            // 电话协议
            debugPrint('尝试拨打电话: ${uri.path}');
            await UrlLauncherUtil.makePhoneCall(uri.path);
            return true;

          case 'mailto':
            // 邮件协议
            debugPrint('尝试发送邮件: ${uri.path}');
            await UrlLauncherUtil.sendEmail(to: uri.path);
            return true;

          case 'sms':
            // 短信协议
            debugPrint('尝试发送短信: ${uri.path}');
            await UrlLauncherUtil.sendSms(uri.path);
            return true;

          case 'market':
            // 应用市场协议
            debugPrint('尝试打开应用市场: $url');
            await UrlLauncherUtil.openUrl(url);
            return true;

          default:
            // 其他协议（如 baiduboxapp:, intent: 等）
            // 这些通常是应用特定协议，可以尝试打开
            debugPrint('尝试打开特殊协议: $url');
            final result = await UrlLauncherUtil.canOpenUrl(url);
            if (result) {
              await UrlLauncherUtil.openUrl(url);
              debugPrint('成功打开协议: $scheme');
              return true;
            } else {
              debugPrint('无法打开协议: $url (系统不支持或未安装相应应用)');
              return false;
            }
        }
      } finally {
        // 处理完成后，延迟移除标记（防止快速重复点击）
        Timer(const Duration(milliseconds: 500), () {
          _processingSchemes.remove(scheme);
        });
      }
    } catch (e) {
      debugPrint('处理特殊协议失败: $e');
      return false;
    }
  }

  /// 判断 URL 是否为特殊协议
  /// 
  /// [url] 要检查的 URL
  /// 
  /// 返回 true 表示是特殊协议，需要外部处理
  static bool isSpecialScheme(String url) {
    try {
      final uri = Uri.parse(url);
      final scheme = uri.scheme.toLowerCase();

      // 允许的 WebView 协议
      const allowedSchemes = ['http', 'https', 'about', 'data'];

      // 如果不是允许的协议，则认为是特殊协议
      return !allowedSchemes.contains(scheme);
    } catch (e) {
      return false;
    }
  }

  /// 清除所有正在处理的协议标记
  /// 
  /// 用于清理资源，通常在页面销毁时调用
  static void clearProcessingSchemes() {
    _processingSchemes.clear();
  }
}
