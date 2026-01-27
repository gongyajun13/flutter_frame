import 'package:flutter/material.dart';
import '../widgets/permission_explanation_dialog.dart' show PermissionExplanation;

/// 权限说明配置管理
/// 
/// 用于配置各个权限的使用说明，符合 Android 应用市场审核要求
class PermissionExplanationConfig {
  PermissionExplanationConfig._();

  /// 默认应用名称
  static const String defaultAppName = '应用';

  /// 获取权限说明配置
  /// 
  /// [permissionType] 权限类型
  /// [appName] 应用名称（可选，默认使用 defaultAppName）
  static PermissionExplanation getExplanation(
    String permissionType, {
    String? appName,
  }) {
    final app = appName ?? defaultAppName;
    
    switch (permissionType) {
      case 'camera':
        return PermissionExplanation(
          title: '相机权限使用说明',
          description: '"$app"想访问您的相机，用于帮助您进行后续的拍摄照片或视频',
          icon: Icons.camera_alt,
          iconColor: Colors.blue,
          appName: app,
        );
      
      case 'photos':
      case 'storage':
        return PermissionExplanation(
          title: '存储权限场景使用说明',
          description: '开启访问系统相册权限用于展示、发送、分享、保存等，更好的提供功能体验',
          icon: Icons.photo_library,
          iconColor: Colors.purple,
          appName: app,
        );
      
      case 'location':
        return PermissionExplanation(
          title: '位置权限使用说明',
          description: '"$app"想访问您的位置信息，用于提供基于位置的服务和功能',
          icon: Icons.location_on,
          iconColor: Colors.green,
          appName: app,
        );
      
      case 'notification':
        return PermissionExplanation(
          title: '通知权限使用说明',
          description: '"$app"想向您发送通知，用于及时提醒您重要信息和更新',
          icon: Icons.notifications,
          iconColor: Colors.orange,
          appName: app,
        );
      
      case 'microphone':
        return PermissionExplanation(
          title: '麦克风权限使用说明',
          description: '"$app"想访问您的麦克风，用于录制音频、语音识别等功能',
          icon: Icons.mic,
          iconColor: Colors.red,
          appName: app,
        );
      
      case 'contacts':
        return PermissionExplanation(
          title: '联系人权限使用说明',
          description: '"$app"想访问您的联系人，用于选择联系人、分享内容等功能',
          icon: Icons.contacts,
          iconColor: Colors.teal,
          appName: app,
        );
      
      case 'calendar':
        return PermissionExplanation(
          title: '日历权限使用说明',
          description: '"$app"想访问您的日历，用于创建和管理日程安排',
          icon: Icons.calendar_today,
          iconColor: Colors.indigo,
          appName: app,
        );
      
      case 'phone':
        return PermissionExplanation(
          title: '电话权限使用说明',
          description: '"$app"想访问您的电话功能，用于拨打电话、识别来电等功能',
          icon: Icons.phone,
          iconColor: Colors.cyan,
          appName: app,
        );
      
      case 'sms':
        return PermissionExplanation(
          title: '短信权限使用说明',
          description: '"$app"想访问您的短信功能，用于发送验证码、分享内容等功能',
          icon: Icons.sms,
          iconColor: Colors.blueGrey,
          appName: app,
        );
      
      default:
        return PermissionExplanation(
          title: '权限使用说明',
          description: '"$app"需要此权限以提供相关功能',
          icon: Icons.lock,
          iconColor: Colors.grey,
          appName: app,
        );
    }
  }

  /// 自定义权限说明
  /// 
  /// 允许外部自定义权限说明内容
  static final Map<String, PermissionExplanation> _customExplanations = {};

  /// 设置自定义权限说明
  static void setCustomExplanation(
    String permissionType,
    PermissionExplanation explanation,
  ) {
    _customExplanations[permissionType] = explanation;
  }

  /// 获取权限说明（优先使用自定义配置）
  static PermissionExplanation getExplanationWithCustom(
    String permissionType, {
    String? appName,
  }) {
    // 优先使用自定义配置
    if (_customExplanations.containsKey(permissionType)) {
      return _customExplanations[permissionType]!;
    }
    
    // 使用默认配置
    return getExplanation(permissionType, appName: appName);
  }

  /// 清除所有自定义配置
  static void clearCustomExplanations() {
    _customExplanations.clear();
  }
}
