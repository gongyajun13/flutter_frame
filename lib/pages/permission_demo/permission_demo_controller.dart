import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../utils/permission_util.dart';

/// 权限演示控制器
class PermissionDemoController extends BaseController {
  // 平台信息
  final platformInfo = ''.obs;
  
  // 权限项列表
  final List<PermissionItem> permissionItems = [
    PermissionItem(
      title: '相机权限',
      description: '用于拍摄照片和录制视频',
      icon: Icons.camera_alt,
      color: Colors.blue,
      permissionType: PermissionType.camera,
    ),
    PermissionItem(
      title: '相册权限',
      description: '用于访问和选择相册中的图片',
      icon: Icons.photo_library,
      color: Colors.purple,
      permissionType: PermissionType.photos,
    ),
    PermissionItem(
      title: '位置权限',
      description: '用于获取设备的地理位置信息',
      icon: Icons.location_on,
      color: Colors.green,
      permissionType: PermissionType.location,
    ),
    PermissionItem(
      title: '通知权限',
      description: '用于发送推送通知',
      icon: Icons.notifications,
      color: Colors.orange,
      permissionType: PermissionType.notification,
    ),
    PermissionItem(
      title: '麦克风权限',
      description: '用于录制音频和语音识别',
      icon: Icons.mic,
      color: Colors.red,
      permissionType: PermissionType.microphone,
    ),
    PermissionItem(
      title: '联系人权限',
      description: '用于访问和选择联系人信息',
      icon: Icons.contacts,
      color: Colors.teal,
      permissionType: PermissionType.contacts,
    ),
    PermissionItem(
      title: '日历权限',
      description: '用于访问和创建日历事件',
      icon: Icons.calendar_today,
      color: Colors.indigo,
      permissionType: PermissionType.calendar,
    ),
    PermissionItem(
      title: '电话权限',
      description: '用于拨打电话（仅 Android）',
      icon: Icons.phone,
      color: Colors.cyan,
      permissionType: PermissionType.phone,
    ),
    PermissionItem(
      title: '短信权限',
      description: '用于发送短信（仅 Android）',
      icon: Icons.sms,
      color: Colors.blueGrey,
      permissionType: PermissionType.sms,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initPlatformInfo();
    // 进入页面时初始化各权限的状态（只读 status，不会触发系统权限弹窗）
    _checkAllPermissions();
  }

  /// 检查所有权限状态（仅读取状态，不会触发系统权限请求）
  Future<void> _checkAllPermissions() async {
    for (var item in permissionItems) {
      await _updatePermissionStatus(item);
    }
  }

  /// 初始化平台信息
  void _initPlatformInfo() {
    if (Platform.isAndroid) {
      platformInfo.value = 'Android';
    } else if (Platform.isIOS) {
      platformInfo.value = 'iOS';
    } else {
      platformInfo.value = '未知平台';
    }
  }

  /// 更新权限状态
  Future<void> _updatePermissionStatus(PermissionItem item) async {
    try {
      bool isGranted = false;

      switch (item.permissionType) {
        case PermissionType.camera:
          isGranted = await PermissionUtil.isCameraGranted();
          break;
        case PermissionType.photos:
          isGranted = await PermissionUtil.isPhotosGranted();
          break;
        case PermissionType.location:
          isGranted = await PermissionUtil.isLocationGranted();
          break;
        case PermissionType.notification:
          isGranted = await PermissionUtil.isNotificationGranted();
          break;
        case PermissionType.microphone:
          isGranted = await PermissionUtil.isMicrophoneGranted();
          break;
        case PermissionType.contacts:
          isGranted = await PermissionUtil.isContactsGranted();
          break;
        case PermissionType.calendar:
          isGranted = await PermissionUtil.isCalendarGranted();
          break;
        case PermissionType.phone:
          isGranted = await PermissionUtil.isPhoneGranted();
          break;
        case PermissionType.sms:
          isGranted = await PermissionUtil.isSmsGranted();
          break;
      }

      // 列表只关注「是否授予」：已授予 / 未授予
      item.status.value = isGranted ? '已授予' : '未授予';
    } catch (e) {
      debugPrint('检查权限状态失败: $e');
      item.status.value = '未知';
    }
  }

  /// 请求权限
  Future<void> requestPermission(PermissionItem item) async {
    // 获取当前上下文
    final context = Get.context;
    if (context == null) {
      showError('无法获取上下文');
      return;
    }

    try {
      bool granted = false;

      switch (item.permissionType) {
        case PermissionType.camera:
          granted = await PermissionUtil.requestCamera(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.photos:
          granted = await PermissionUtil.requestPhotos(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.location:
          granted = await PermissionUtil.requestLocation(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.notification:
          granted = await PermissionUtil.requestNotification(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.microphone:
          granted = await PermissionUtil.requestMicrophone(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.contacts:
          granted = await PermissionUtil.requestContacts(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.calendar:
          granted = await PermissionUtil.requestCalendar(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.phone:
          granted = await PermissionUtil.requestPhone(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
        case PermissionType.sms:
          granted = await PermissionUtil.requestSms(
            context: context,
            appName: 'Flutter Frame',
          );
          break;
      }

      // 更新状态
      await _updatePermissionStatus(item);

      if (granted) {
        showSuccess('${item.title}已授予');
      } else {
        showWarning('${item.title}被拒绝');
      }
    } catch (e) {
      showError('请求权限时发生错误: $e');
    }
  }

}

/// 权限项数据模型
class PermissionItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final PermissionType permissionType;
  final RxString status = '未知'.obs;

  PermissionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.permissionType,
  });
}

/// 权限类型枚举
enum PermissionType {
  camera,
  photos,
  location,
  notification,
  microphone,
  contacts,
  calendar,
  phone,
  sms,
}
