import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import 'getx_dialog_util.dart';
import 'getx_snackbar_util.dart';

/// URL跳转结果枚举
enum LaunchResult {
  success,
  failed,
  cancelled,
  notSupported,
}

// 说明：不再自定义 LaunchMode，直接使用 url_launcher 的 ul.LaunchMode，避免命名冲突

/// 跳转结果回调类型
typedef LaunchCallback = void Function(LaunchResult result, String? error);

/// URL跳转工具类
/// 基于url_launcher实现各种跳转处理
class UrlLauncherUtil {
  // 私有构造函数，防止实例化
  UrlLauncherUtil._();

  // ==================== 基础URL跳转 ====================

  /// 跳转到URL（自动检测类型）
  static Future<LaunchResult> openUrl(
    String url, {
    ul.LaunchMode mode = ul.LaunchMode.platformDefault,
    LaunchCallback? onResult,
  }) async {
    try {
      final uri = Uri.parse(url);
      
      if (!await ul.canLaunchUrl(uri)) {
        final error = '无法打开URL: $url';
        onResult?.call(LaunchResult.notSupported, error);
        return LaunchResult.notSupported;
      }

      final launched = await ul.launchUrl(uri, mode: mode);
      
      final result = launched ? LaunchResult.success : LaunchResult.failed;
      onResult?.call(result, launched ? null : '跳转失败');
      return result;
    } catch (e) {
      final error = '跳转异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  /// 跳转到网页
  static Future<LaunchResult> launchWebUrl(
    String url, {
    ul.LaunchMode mode = ul.LaunchMode.externalApplication,
    LaunchCallback? onResult,
  }) async {
    return await openUrl(url, mode: mode, onResult: onResult);
  }

  /// 跳转到应用内浏览器
  static Future<LaunchResult> launchInAppWebView(
    String url, {
    LaunchCallback? onResult,
  }) async {
    return await openUrl(url, mode: ul.LaunchMode.inAppBrowserView, onResult: onResult);
  }

  // ==================== 电话相关跳转 ====================

  /// 拨打电话
  static Future<LaunchResult> makePhoneCall(
    String phoneNumber, {
    LaunchCallback? onResult,
  }) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (!await ul.canLaunchUrl(uri)) {
        final error = '设备不支持拨打电话';
        onResult?.call(LaunchResult.notSupported, error);
        return LaunchResult.notSupported;
      }

      final launched = await ul.launchUrl(uri);
      final result = launched ? LaunchResult.success : LaunchResult.failed;
      onResult?.call(result, launched ? null : '拨打电话失败');
      return result;
    } catch (e) {
      final error = '拨打电话异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  /// 发送短信
  static Future<LaunchResult> sendSms(
    String phoneNumber, {
    String? message,
    LaunchCallback? onResult,
  }) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        query: message != null ? 'body=$message' : null,
      );
      
      if (!await ul.canLaunchUrl(uri)) {
        final error = '设备不支持发送短信';
        onResult?.call(LaunchResult.notSupported, error);
        return LaunchResult.notSupported;
      }

      final launched = await ul.launchUrl(uri);
      final result = launched ? LaunchResult.success : LaunchResult.failed;
      onResult?.call(result, launched ? null : '发送短信失败');
      return result;
    } catch (e) {
      final error = '发送短信异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  // ==================== 邮件相关跳转 ====================

  /// 发送邮件
  static Future<LaunchResult> sendEmail({
    required String to,
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
    LaunchCallback? onResult,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: to,
        query: _buildEmailQuery(subject, body, cc, bcc),
      );
      
      if (!await ul.canLaunchUrl(uri)) {
        final error = '设备不支持发送邮件';
        onResult?.call(LaunchResult.notSupported, error);
        return LaunchResult.notSupported;
      }

      final launched = await ul.launchUrl(uri);
      final result = launched ? LaunchResult.success : LaunchResult.failed;
      onResult?.call(result, launched ? null : '发送邮件失败');
      return result;
    } catch (e) {
      final error = '发送邮件异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  // ==================== 地图相关跳转 ====================

  /// 打开地图应用
  static Future<LaunchResult> openMap({
    double? latitude,
    double? longitude,
    String? address,
    String? label,
    LaunchCallback? onResult,
  }) async {
    try {
      String url;
      
      if (Platform.isIOS) {
        // iOS使用Apple Maps
        if (latitude != null && longitude != null) {
          url = 'https://maps.apple.com/?q=$latitude,$longitude';
          if (label != null) {
            url += '&t=m&z=15';
          }
        } else if (address != null) {
          url = 'https://maps.apple.com/?q=${Uri.encodeComponent(address)}';
        } else {
          final error = '需要提供坐标或地址';
          onResult?.call(LaunchResult.failed, error);
          return LaunchResult.failed;
        }
      } else {
        // Android使用Google Maps
        if (latitude != null && longitude != null) {
          url = 'https://www.google.com/maps?q=$latitude,$longitude';
          if (label != null) {
            url += '&t=m&z=15';
          }
        } else if (address != null) {
          url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
        } else {
          final error = '需要提供坐标或地址';
          onResult?.call(LaunchResult.failed, error);
          return LaunchResult.failed;
        }
      }

      return await openUrl(url, onResult: onResult);
    } catch (e) {
      final error = '打开地图异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  // ==================== 应用相关跳转 ====================

  /// 打开应用商店
  static Future<LaunchResult> openAppStore({
    String? appId,
    String? packageName,
    LaunchCallback? onResult,
  }) async {
    try {
      String url;
      
      if (Platform.isIOS) {
        if (appId == null) {
          final error = 'iOS需要提供appId';
          onResult?.call(LaunchResult.failed, error);
          return LaunchResult.failed;
        }
        url = 'https://apps.apple.com/app/id$appId';
      } else {
        if (packageName == null) {
          final error = 'Android需要提供packageName';
          onResult?.call(LaunchResult.failed, error);
          return LaunchResult.failed;
        }
        url = 'https://play.google.com/store/apps/details?id=$packageName';
      }

      return await openUrl(url, onResult: onResult);
    } catch (e) {
      final error = '打开应用商店异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  /// 打开系统设置
  static Future<LaunchResult> openSettings({
    LaunchCallback? onResult,
  }) async {
    try {
      String url;
      
      if (Platform.isIOS) {
        url = 'app-settings:';
      } else {
        url = 'package:${Platform.environment['PACKAGE_NAME'] ?? 'com.example.app'}/settings';
      }

      return await openUrl(url, onResult: onResult);
    } catch (e) {
      final error = '打开设置异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  // ==================== 社交媒体跳转 ====================

  /// 打开微信
  static Future<LaunchResult> openWeChat({
    String? url,
    LaunchCallback? onResult,
  }) async {
    try {
      final wechatUrl = url ?? 'weixin://';
      return await openUrl(wechatUrl, onResult: onResult);
    } catch (e) {
      final error = '打开微信异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  /// 打开QQ
  static Future<LaunchResult> openQQ({
    String? qqNumber,
    LaunchCallback? onResult,
  }) async {
    try {
      String url;
      if (qqNumber != null) {
        url = 'mqqwpa://im/chat?chat_type=wpa&uin=$qqNumber';
      } else {
        url = 'mqq://';
      }
      return await openUrl(url, onResult: onResult);
    } catch (e) {
      final error = '打开QQ异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  /// 打开支付宝
  static Future<LaunchResult> openAlipay({
    String? url,
    LaunchCallback? onResult,
  }) async {
    try {
      final alipayUrl = url ?? 'alipays://';
      return await openUrl(alipayUrl, onResult: onResult);
    } catch (e) {
      final error = '打开支付宝异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  // ==================== 文件相关跳转 ====================

  /// 打开文件
  static Future<LaunchResult> openFile(
    String filePath, {
    LaunchCallback? onResult,
  }) async {
    try {
      final uri = Uri.file(filePath);
      
      if (!await ul.canLaunchUrl(uri)) {
        final error = '无法打开文件: $filePath';
        onResult?.call(LaunchResult.notSupported, error);
        return LaunchResult.notSupported;
      }

      final launched = await ul.launchUrl(uri);
      final result = launched ? LaunchResult.success : LaunchResult.failed;
      onResult?.call(result, launched ? null : '打开文件失败');
      return result;
    } catch (e) {
      final error = '打开文件异常: $e';
      onResult?.call(LaunchResult.failed, error);
      return LaunchResult.failed;
    }
  }

  // ==================== 带确认的跳转 ====================

  /// 带确认对话框的URL跳转
  static Future<void> launchUrlWithConfirm(
    BuildContext context,
    String url, {
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
    ul.LaunchMode mode = ul.LaunchMode.platformDefault,
  }) async {
    GetXDialogUtil.showConfirm(
      title: title ?? '确认跳转',
      message: message ?? '即将跳转到：\n$url',
      confirmText: confirmText ?? '确认',
      cancelText: cancelText ?? '取消',
      onConfirm: () async {
        final launchResult = await openUrl(url, mode: mode);
        _handleLaunchResult(context, launchResult, url);
      },
    );
  }

  /// 带确认对话框的电话拨打
  static Future<void> makePhoneCallWithConfirm(
    BuildContext context,
    String phoneNumber, {
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
  }) async {
    GetXDialogUtil.showConfirm(
      title: title ?? '确认拨打电话',
      message: message ?? '即将拨打电话：\n$phoneNumber',
      confirmText: confirmText ?? '拨打',
      cancelText: cancelText ?? '取消',
      onConfirm: () async {
        final result = await makePhoneCall(phoneNumber);
        _handleLaunchResult(context, result, phoneNumber);
      },
    );
  }

  /// 带确认对话框的邮件发送
  static Future<void> sendEmailWithConfirm(
    BuildContext context, {
    required String to,
    String? subject,
    String? body,
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
  }) async {
    GetXDialogUtil.showConfirm(
      title: title ?? '确认发送邮件',
      message: message ?? '即将发送邮件到：\n$to',
      confirmText: confirmText ?? '发送',
      cancelText: cancelText ?? '取消',
      onConfirm: () async {
        final result = await sendEmail(
          to: to,
          subject: subject,
          body: body,
        );
        _handleLaunchResult(context, result, to);
      },
    );
  }

  // ==================== 工具方法 ====================

  /// 检查URL是否可以打开
  static Future<bool> canOpenUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await ul.canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// 检查电话是否可以拨打
  static Future<bool> canMakePhoneCall(String phoneNumber) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      return await ul.canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// 检查邮件是否可以发送
  static Future<bool> canSendEmail() async {
    try {
      final uri = Uri(scheme: 'mailto', path: 'test@example.com');
      return await ul.canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// 检查短信是否可以发送
  static Future<bool> canSendSms() async {
    try {
      final uri = Uri(scheme: 'sms', path: '1234567890');
      return await ul.canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// 获取平台信息
  static String getPlatformInfo() {
    if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  // ==================== 私有方法 ====================

  // 不再需要转换方法，直接使用 ul.LaunchMode

  /// 构建邮件查询参数
  static String? _buildEmailQuery(
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  ) {
    final queryParams = <String>[];
    
    if (subject != null) {
      queryParams.add('subject=${Uri.encodeComponent(subject)}');
    }
    
    if (body != null) {
      queryParams.add('body=${Uri.encodeComponent(body)}');
    }
    
    if (cc != null && cc.isNotEmpty) {
      queryParams.add('cc=${cc.join(',')}');
    }
    
    if (bcc != null && bcc.isNotEmpty) {
      queryParams.add('bcc=${bcc.join(',')}');
    }
    
    return queryParams.isNotEmpty ? queryParams.join('&') : null;
  }

  /// 处理跳转结果
  static void _handleLaunchResult(
    BuildContext context,
    LaunchResult result,
    String target,
  ) {
    switch (result) {
      case LaunchResult.success:
        GetXSnackBarUtil.success(
          message: '跳转成功',
          title: '操作完成',
        );
        break;
      case LaunchResult.failed:
        GetXSnackBarUtil.error(
          message: '跳转失败：$target',
          title: '操作失败',
        );
        break;
      case LaunchResult.notSupported:
        GetXSnackBarUtil.warning(
          message: '当前设备不支持此操作',
          title: '不支持',
        );
        break;
      case LaunchResult.cancelled:
        GetXSnackBarUtil.info(
          message: '用户取消了操作',
          title: '已取消',
        );
        break;
    }
  }
}