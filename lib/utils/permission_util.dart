import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:device_info_plus/device_info_plus.dart';
import 'getx_dialog_util.dart';
import 'url_launcher_util.dart';
import 'permission_explanation_config.dart';
import '../widgets/permission_explanation_dialog.dart';

/// 权限请求工具类
/// 
/// 提供统一的权限请求接口，自动处理 iOS 和 Android 平台差异
/// 
/// ## 使用示例
/// 
/// ```dart
/// // 请求相机权限
/// final granted = await PermissionUtil.requestCamera();
/// if (granted) {
///   // 使用相机功能
/// }
/// 
/// // 请求相册权限（自动处理 Android 版本差异）
/// final granted = await PermissionUtil.requestPhotos();
/// 
/// // 检查权限状态
/// final status = await PermissionUtil.checkPermission(Permission.camera);
/// 
/// // 引导用户到设置页面
/// await PermissionUtil.openAppSettings();
/// ```
class PermissionUtil {
  PermissionUtil._();

  /// 记录已经在本次应用生命周期内请求过的权限
  /// 用于配合 shouldShowRequestRationale 判断「用户已选择不再询问」的场景
  static final Set<ph.Permission> _requestedPermissions = {};

  // ==================== 权限状态检查 ====================

  /// 检查权限状态
  /// 
  /// [permission] 要检查的权限
  /// 
  /// 返回权限状态
  static Future<ph.PermissionStatus> checkPermission(ph.Permission permission) async {
    return await permission.status;
  }

  /// 检查权限是否已授予
  /// 
  /// [permission] 要检查的权限
  /// 
  /// 返回 true 表示已授予，false 表示未授予
  static Future<bool> isGranted(ph.Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// 检查权限是否被永久拒绝
  /// 
  /// [permission] 要检查的权限
  /// 
  /// 返回 true 表示被永久拒绝，需要引导用户到设置页面
  static Future<bool> isPermanentlyDenied(ph.Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  // ==================== 权限请求 ====================

  /// 请求权限
  /// 
  /// [permission] 要请求的权限
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [permissionType] 权限类型（用于获取权限说明，如 'camera', 'photos' 等）
  /// [showExplanation] 是否显示权限说明对话框（默认 true，符合应用市场审核要求）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框引导用户到设置（默认 true）
  /// [dialogTitle] 对话框标题（可选）
  /// [dialogMessage] 对话框内容（可选）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予，false 表示未授予
  static Future<bool> request(
    ph.Permission permission, {
    BuildContext? context,
    String? permissionType,
    bool showExplanation = true,
    bool showDialog = true,
    String? dialogTitle,
    String? dialogMessage,
    String? appName,
  }) async {
    // 检查当前权限状态
    final status = await permission.status;

    // 如果已经授予，直接返回
    if (status.isGranted) {
      debugPrint('PermissionUtil: 权限已授予，直接返回');
      return true;
    }

    // iOS 特殊处理：在 iOS 上，即使权限被拒绝，也应该尝试请求
    // 因为 iOS 的权限状态可能不准确，或者用户可能想重新授权
    if (Platform.isIOS) {
      // iOS 上，如果权限被永久拒绝，直接引导用户到设置页面
      // 因为 iOS 上如果权限被永久拒绝，调用 request() 不会弹出对话框，会直接返回 permanentlyDenied
      if (status.isPermanentlyDenied) {
        if (showDialog) {
          await _showPermissionDeniedDialog(
            permission,
            dialogTitle: dialogTitle,
            dialogMessage: dialogMessage,
          );
        }
        return false;
      }

      // iOS 上不显示权限说明弹窗，直接请求权限
      // 注意：在 iOS 上，如果状态是 denied，调用 request() 应该会弹出系统对话框
      // 但如果状态是 permanentlyDenied，request() 不会弹出对话框，会直接返回 permanentlyDenied
      // 
      // 重要：在 iOS 上，如果权限之前被拒绝过，再次调用 request() 时，
      // 系统可能会直接返回 permanentlyDenied 而不弹出对话框
      // 这种情况下，需要引导用户到设置页面手动开启权限
      try {
        final result = await permission.request();
        
        // 如果请求后是永久拒绝，说明系统没有弹出对话框
        // 需要引导用户到设置页面
        if (result.isPermanentlyDenied) {
          if (showDialog) {
            // 优化提示信息，说明为什么需要到设置中开启
            final customMessage = dialogMessage ?? 
              (Platform.isIOS 
                ? '权限之前被拒绝过，系统不再弹出权限请求对话框。请在设置中手动开启此权限。'
                : '应用需要此权限才能正常工作，请在设置中开启。');
            
            await _showPermissionDeniedDialog(
              permission,
              dialogTitle: dialogTitle,
              dialogMessage: customMessage,
            );
          }
          return false;
        }
        
        // 如果请求后是 denied，说明用户拒绝了权限（系统弹出了对话框，用户选择了拒绝）
        if (result.isDenied) {
          return false;
        }
        
        // 权限已授予或有限权限
        if (result.isGranted || result == ph.PermissionStatus.limited) {
          return true;
        }
        return false;
      } catch (_) {
        return false;
      }
    }

    // Android 处理逻辑
    // 注意：shouldShowRequestRationale 在「第一次请求前」通常也是 false，
    // 所以不能单独用它来判断永久拒绝。
    final bool canShowRationale =
        await permission.shouldShowRequestRationale;
    final bool hasRequestedBefore = _requestedPermissions.contains(permission);

    // 情况 1：明确的 permanentlyDenied -> 直接引导到设置
    if (status.isPermanentlyDenied) {
      if (showDialog) {
        await _showPermissionDeniedDialog(
          permission,
          dialogTitle: dialogTitle,
          dialogMessage: dialogMessage,
        );
      }
      return false;
    }

    // 情况 2：本次生命周期内已经请求过，并且现在为 denied 且 cannotShowRationale，
    // 说明用户已经选择了「不再询问」或系统不再弹窗，也视为永久拒绝。
    if (hasRequestedBefore && status.isDenied && !canShowRationale) {
      if (showDialog) {
        await _showPermissionDeniedDialog(
          permission,
          dialogTitle: dialogTitle,
          dialogMessage: dialogMessage,
        );
      }
      return false;
    }

    // 记录本次请求，后续可以用来判断「已经请求过」的场景
    _requestedPermissions.add(permission);

    // 显示权限说明并立即拉起系统权限请求
    if (showExplanation && context != null && permissionType != null) {
      final explanation = PermissionExplanationConfig.getExplanationWithCustom(
        permissionType,
        appName: appName,
      );
      
      // 显示权限说明（仅展示），同时拉起系统权限请求
      return await PermissionExplanationDialog.showAndRequest(
        context,
        explanation: explanation,
        onRequestPermission: () async {
          final result = await permission.request();
          return result.isGranted || result == ph.PermissionStatus.limited;
        },
      );
    }

    // 如果不显示说明，直接请求权限
    try {
      final result = await permission.request();
      return result.isGranted || result == ph.PermissionStatus.limited;
    } catch (_) {
      return false;
    }
  }

  /// 请求多个权限
  /// 
  /// [permissions] 要请求的权限列表
  /// 
  /// 返回权限请求结果映射，key 为权限，value 为是否授予
  static Future<Map<ph.Permission, bool>> requestMultiple(
    List<ph.Permission> permissions,
  ) async {
    final Map<ph.Permission, ph.PermissionStatus> statuses =
        await permissions.request();

    return statuses.map((permission, status) => MapEntry(
          permission,
          status.isGranted,
        ));
  }

  // ==================== 相机权限 ====================

  /// 请求相机权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android**: 需要 `CAMERA` 权限，默认显示权限说明弹窗（符合应用市场审核要求）
  /// - **iOS**: 需要 `NSCameraUsageDescription` 在 Info.plist 中配置，不显示权限说明弹窗
  static Future<bool> requestCamera({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    // iOS 不显示权限说明弹窗，Android 默认显示
    final shouldShowExplanation = showExplanation ?? Platform.isAndroid;
    
    return await request(
      ph.Permission.camera,
      context: context ?? Get.context,
      permissionType: 'camera',
      showExplanation: shouldShowExplanation,
      showDialog: showDialog,
      dialogTitle: '需要相机权限',
      dialogMessage: '应用需要访问相机以拍摄照片，请在设置中开启相机权限。',
      appName: appName ?? PermissionExplanationConfig.defaultAppName,
    );
  }

  /// 检查相机权限是否已授予
  static Future<bool> isCameraGranted() async {
    return await isGranted(ph.Permission.camera);
  }

  // ==================== 相册/照片权限 ====================

  /// 请求相册/照片权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android 13+ (API 33+)**: 使用 `READ_MEDIA_IMAGES` 权限，默认显示权限说明弹窗
  /// - **Android 12 及以下 (API 32-)**: 使用 `READ_EXTERNAL_STORAGE` 权限，默认显示权限说明弹窗
  /// - **iOS**: 需要 `NSPhotoLibraryUsageDescription` 在 Info.plist 中配置，不显示权限说明弹窗
  static Future<bool> requestPhotos({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    // iOS 不显示权限说明弹窗，Android 默认显示
    final shouldShowExplanation = showExplanation ?? Platform.isAndroid;
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) 使用新的照片权限
      if (await _getAndroidSdkVersion() >= 33) {
        return await request(
          ph.Permission.photos,
          context: context ?? Get.context,
          permissionType: 'photos',
          showExplanation: shouldShowExplanation,
          showDialog: showDialog,
          dialogTitle: '需要相册权限',
          dialogMessage: '应用需要访问相册以选择图片，请在设置中开启相册权限。',
          appName: appName ?? PermissionExplanationConfig.defaultAppName,
        );
      } else {
        // Android 12 及以下使用存储权限
        return await request(
          ph.Permission.storage,
          context: context ?? Get.context,
          permissionType: 'storage',
          showExplanation: shouldShowExplanation,
          showDialog: showDialog,
          dialogTitle: '需要存储权限',
          dialogMessage: '应用需要访问存储以选择图片，请在设置中开启存储权限。',
          appName: appName ?? PermissionExplanationConfig.defaultAppName,
        );
      }
    } else if (Platform.isIOS) {
      return await request(
        ph.Permission.photos,
        context: context ?? Get.context,
        permissionType: 'photos',
        showExplanation: shouldShowExplanation,
        showDialog: showDialog,
        dialogTitle: '需要相册权限',
        dialogMessage: '应用需要访问相册以选择图片，请在设置中开启相册权限。',
        appName: appName ?? PermissionExplanationConfig.defaultAppName,
      );
    }
    return true;
  }

  /// 检查相册权限是否已授予
  static Future<bool> isPhotosGranted() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      // Android 13+ 使用 READ_MEDIA_IMAGES（photos），以下版本使用存储权限
      if (sdkInt >= 33) {
        return await isGranted(ph.Permission.photos);
      } else {
        return await isGranted(ph.Permission.storage);
      }
    } else if (Platform.isIOS) {
      return await isGranted(ph.Permission.photos);
    }
    return true;
  }

  // ==================== 存储权限 ====================

  /// 请求存储权限
  /// 
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android 13+**: 不再需要存储权限，使用媒体权限（照片、视频、音频）
  /// - **Android 12 及以下**: 需要 `READ_EXTERNAL_STORAGE` 和 `WRITE_EXTERNAL_STORAGE`
  /// - **iOS**: 不需要存储权限，使用相册权限
  static Future<bool> requestStorage({bool showDialog = true}) async {
    if (Platform.isAndroid) {
      // Android 13+ 不再需要存储权限
      if (await _getAndroidSdkVersion() >= 33) {
        // Android 13+ 使用媒体权限，这里返回 true 表示不需要
        return true;
      } else {
        // Android 12 及以下需要存储权限
        final readGranted = await request(
          ph.Permission.storage,
          showDialog: showDialog,
          dialogTitle: '需要存储权限',
          dialogMessage: '应用需要访问存储以保存文件，请在设置中开启存储权限。',
        );
        return readGranted;
      }
    } else if (Platform.isIOS) {
      // iOS 不需要存储权限
      return true;
    }
    return true;
  }

  /// 检查存储权限是否已授予
  static Future<bool> isStorageGranted() async {
    if (Platform.isAndroid) {
      if (await _getAndroidSdkVersion() >= 33) {
        return true; // Android 13+ 不需要存储权限
      } else {
        return await isGranted(ph.Permission.storage);
      }
    } else if (Platform.isIOS) {
      return true; // iOS 不需要存储权限
    }
    return true;
  }

  // ==================== 位置权限 ====================

  /// 请求位置权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [locationAccuracy] 位置精度要求（Android 专用）
  ///   - `LocationAccuracy.reduced`: 粗略位置（Android 12+）
  ///   - `LocationAccuracy.precise`: 精确位置
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android 12+**: 需要选择粗略位置或精确位置，默认显示权限说明弹窗
  /// - **Android 11 及以下**: 只需要位置权限，默认显示权限说明弹窗
  /// - **iOS**: 需要 `NSLocationWhenInUseUsageDescription` 或 `NSLocationAlwaysUsageDescription` 在 Info.plist 中配置，不显示权限说明弹窗
  static Future<bool> requestLocation({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    LocationAccuracy locationAccuracy = LocationAccuracy.precise,
    String? appName,
  }) async {
    // iOS 不显示权限说明弹窗，Android 默认显示
    final shouldShowExplanation = showExplanation ?? Platform.isAndroid;
    if (Platform.isAndroid) {
      // Android 12+ 需要选择位置精度
      if (await _getAndroidSdkVersion() >= 31) {
        // 先请求粗略位置权限
        final coarseGranted = await request(
          ph.Permission.locationWhenInUse,
          context: context ?? Get.context,
          permissionType: 'location',
          showExplanation: shouldShowExplanation,
          showDialog: false, // 先不显示对话框
          appName: appName ?? PermissionExplanationConfig.defaultAppName,
        );

        if (!coarseGranted) {
          if (showDialog) {
            await _showPermissionDeniedDialog(
              ph.Permission.locationWhenInUse,
              dialogTitle: '需要位置权限',
              dialogMessage: '应用需要访问位置信息，请在设置中开启位置权限。',
            );
          }
          return false;
        }

          // 如果需要精确位置，请求精确位置权限
          if (locationAccuracy == LocationAccuracy.precise) {
            final preciseGranted = await request(
              ph.Permission.location,
              context: context ?? Get.context,
              permissionType: 'location',
              showExplanation: false, // 已经显示过说明，不再重复显示
              showDialog: false,
              appName: appName,
            );
          if (!preciseGranted && showDialog) {
            await _showPermissionDeniedDialog(
              ph.Permission.location,
              dialogTitle: '需要精确位置权限',
              dialogMessage: '应用需要访问精确位置信息，请在设置中开启精确位置权限。',
            );
          }
          return preciseGranted;
        }

        return coarseGranted;
      } else {
        // Android 11 及以下只需要位置权限
        return await request(
          ph.Permission.locationWhenInUse,
          context: context ?? Get.context,
          permissionType: 'location',
          showExplanation: shouldShowExplanation,
          showDialog: showDialog,
          dialogTitle: '需要位置权限',
          dialogMessage: '应用需要访问位置信息，请在设置中开启位置权限。',
          appName: appName ?? PermissionExplanationConfig.defaultAppName,
        );
      }
    } else if (Platform.isIOS) {
      return await request(
        ph.Permission.locationWhenInUse,
        context: context ?? Get.context,
        permissionType: 'location',
        showExplanation: shouldShowExplanation,
        showDialog: showDialog,
        dialogTitle: '需要位置权限',
        dialogMessage: '应用需要访问位置信息，请在设置中开启位置权限。',
        appName: appName ?? PermissionExplanationConfig.defaultAppName,
      );
    }
    return true;
  }

  /// 检查位置权限是否已授予
  static Future<bool> isLocationGranted() async {
    return await isGranted(ph.Permission.locationWhenInUse);
  }

  // ==================== 通知权限 ====================

  /// 请求通知权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android 13+**: 需要运行时请求通知权限，默认显示权限说明弹窗
  /// - **Android 12 及以下**: 安装时自动授予，不需要请求
  /// - **iOS**: 需要 `NSUserNotificationsUsageDescription` 在 Info.plist 中配置（可选），不显示权限说明弹窗
  static Future<bool> requestNotification({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    // iOS 不显示权限说明弹窗，Android 默认显示
    final shouldShowExplanation = showExplanation ?? Platform.isAndroid;
    if (Platform.isAndroid) {
      // Android 13+ 需要请求通知权限
      if (await _getAndroidSdkVersion() >= 33) {
        return await request(
          ph.Permission.notification,
          context: context ?? Get.context,
          permissionType: 'notification',
          showExplanation: shouldShowExplanation,
          showDialog: showDialog,
          dialogTitle: '需要通知权限',
          dialogMessage: '应用需要发送通知，请在设置中开启通知权限。',
          appName: appName ?? PermissionExplanationConfig.defaultAppName,
        );
      } else {
        // Android 12 及以下自动授予
        return true;
      }
    } else if (Platform.isIOS) {
      return await request(
        ph.Permission.notification,
        context: context ?? Get.context,
        permissionType: 'notification',
        showExplanation: shouldShowExplanation,
        showDialog: showDialog,
        dialogTitle: '需要通知权限',
        dialogMessage: '应用需要发送通知，请在设置中开启通知权限。',
        appName: appName ?? PermissionExplanationConfig.defaultAppName,
      );
    }
    return true;
  }

  /// 检查通知权限是否已授予
  static Future<bool> isNotificationGranted() async {
    if (Platform.isAndroid) {
      if (await _getAndroidSdkVersion() >= 33) {
        return await isGranted(ph.Permission.notification);
      } else {
        return true; // Android 12 及以下自动授予
      }
    } else if (Platform.isIOS) {
      return await isGranted(ph.Permission.notification);
    }
    return true;
  }

  // ==================== 麦克风权限 ====================

  /// 请求麦克风权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android**: 需要 `RECORD_AUDIO` 权限，默认显示权限说明弹窗
  /// - **iOS**: 需要 `NSMicrophoneUsageDescription` 在 Info.plist 中配置，不显示权限说明弹窗
  static Future<bool> requestMicrophone({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    // iOS 不显示权限说明弹窗，Android 默认显示
    final shouldShowExplanation = showExplanation ?? Platform.isAndroid;
    
    return await request(
      ph.Permission.microphone,
      context: context ?? Get.context,
      permissionType: 'microphone',
      showExplanation: shouldShowExplanation,
      showDialog: showDialog,
      dialogTitle: '需要麦克风权限',
      dialogMessage: '应用需要访问麦克风以录制音频，请在设置中开启麦克风权限。',
      appName: appName ?? PermissionExplanationConfig.defaultAppName,
    );
  }

  /// 检查麦克风权限是否已授予
  static Future<bool> isMicrophoneGranted() async {
    return await isGranted(ph.Permission.microphone);
  }

  // ==================== 联系人权限 ====================

  /// 请求联系人权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android**: 需要 `READ_CONTACTS` 权限，默认显示权限说明弹窗
  /// - **iOS**: 需要 `NSContactsUsageDescription` 在 Info.plist 中配置，不显示权限说明弹窗
  static Future<bool> requestContacts({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    // iOS 不显示权限说明弹窗，Android 默认显示
    final shouldShowExplanation = showExplanation ?? Platform.isAndroid;
    
    return await request(
      ph.Permission.contacts,
      context: context ?? Get.context,
      permissionType: 'contacts',
      showExplanation: shouldShowExplanation,
      showDialog: showDialog,
      dialogTitle: '需要联系人权限',
      dialogMessage: '应用需要访问联系人，请在设置中开启联系人权限。',
      appName: appName ?? PermissionExplanationConfig.defaultAppName,
    );
  }

  /// 检查联系人权限是否已授予
  static Future<bool> isContactsGranted() async {
    return await isGranted(ph.Permission.contacts);
  }

  // ==================== 日历权限 ====================

  /// 请求日历权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android**: 需要 `READ_CALENDAR` 权限，默认显示权限说明弹窗
  /// - **iOS**: 需要 `NSCalendarsUsageDescription` 在 Info.plist 中配置，不显示权限说明弹窗
  static Future<bool> requestCalendar({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    // iOS 不显示权限说明弹窗，Android 默认显示
    final shouldShowExplanation = showExplanation ?? Platform.isAndroid;
    
    return await request(
      ph.Permission.calendar,
      context: context ?? Get.context,
      permissionType: 'calendar',
      showExplanation: shouldShowExplanation,
      showDialog: showDialog,
      dialogTitle: '需要日历权限',
      dialogMessage: '应用需要访问日历，请在设置中开启日历权限。',
      appName: appName ?? PermissionExplanationConfig.defaultAppName,
    );
  }

  /// 检查日历权限是否已授予
  static Future<bool> isCalendarGranted() async {
    return await isGranted(ph.Permission.calendar);
  }

  // ==================== 电话权限 ====================

  /// 请求电话权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android**: 需要 `CALL_PHONE` 权限（仅用于拨打电话），默认显示权限说明弹窗
  /// - **iOS**: 不需要权限（系统会自动处理）
  static Future<bool> requestPhone({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    if (Platform.isAndroid) {
      // Android 默认显示权限说明弹窗
      final shouldShowExplanation = showExplanation ?? true;
      
      return await request(
        ph.Permission.phone,
        context: context ?? Get.context,
        permissionType: 'phone',
        showExplanation: shouldShowExplanation,
        showDialog: showDialog,
        dialogTitle: '需要电话权限',
        dialogMessage: '应用需要拨打电话，请在设置中开启电话权限。',
        appName: appName ?? PermissionExplanationConfig.defaultAppName,
      );
    } else if (Platform.isIOS) {
      // iOS 不需要电话权限
      return true;
    }
    return true;
  }

  /// 检查电话权限是否已授予
  static Future<bool> isPhoneGranted() async {
    if (Platform.isAndroid) {
      return await isGranted(ph.Permission.phone);
    } else if (Platform.isIOS) {
      return true; // iOS 不需要电话权限
    }
    return true;
  }

  // ==================== 短信权限 ====================

  /// 请求短信权限
  /// 
  /// [context] 上下文（用于显示权限说明对话框，可选）
  /// [showExplanation] 是否显示权限说明对话框（默认：Android true，iOS false）
  /// [showDialog] 如果权限被永久拒绝，是否显示对话框（默认 true）
  /// [appName] 应用名称（用于权限说明，可选）
  /// 
  /// 返回 true 表示权限已授予
  /// 
  /// ## 平台差异
  /// - **Android**: 需要 `SEND_SMS` 权限（仅用于发送短信），默认显示权限说明弹窗
  /// - **iOS**: 不需要权限（系统会自动处理）
  static Future<bool> requestSms({
    BuildContext? context,
    bool? showExplanation,
    bool showDialog = true,
    String? appName,
  }) async {
    if (Platform.isAndroid) {
      // Android 默认显示权限说明弹窗
      final shouldShowExplanation = showExplanation ?? true;
      
      return await request(
        ph.Permission.sms,
        context: context ?? Get.context,
        permissionType: 'sms',
        showExplanation: shouldShowExplanation,
        showDialog: showDialog,
        dialogTitle: '需要短信权限',
        dialogMessage: '应用需要发送短信，请在设置中开启短信权限。',
        appName: appName ?? PermissionExplanationConfig.defaultAppName,
      );
    } else if (Platform.isIOS) {
      // iOS 不需要短信权限
      return true;
    }
    return true;
  }

  /// 检查短信权限是否已授予
  static Future<bool> isSmsGranted() async {
    if (Platform.isAndroid) {
      return await isGranted(ph.Permission.sms);
    } else if (Platform.isIOS) {
      return true; // iOS 不需要短信权限
    }
    return true;
  }

  // ==================== 设置页面 ====================

  /// 打开应用设置页面
  /// 
  /// 用于引导用户手动开启权限
  static Future<bool> openAppSettings() async {
    // 使用 permission_handler 包的全局函数
    return await ph.openAppSettings();
  }

  /// 打开系统设置页面
  /// 
  /// 用于引导用户到系统设置页面
  static Future<void> openSystemSettings() async {
    await UrlLauncherUtil.openSettings();
  }

  // ==================== 工具方法 ====================

  /// 显示权限被拒绝的对话框
  static Future<void> _showPermissionDeniedDialog(
    ph.Permission permission, {
    String? dialogTitle,
    String? dialogMessage,
  }) async {
    GetXDialogUtil.showConfirm(
      title: dialogTitle ?? '需要权限',
      message: dialogMessage ?? '应用需要此权限才能正常工作，请在设置中开启。',
      confirmText: '去设置',
      cancelText: '取消',
      onConfirm: () async {
        await ph.openAppSettings();
      },
    );
  }

  /// 获取 Android SDK 版本
  /// 
  /// 返回 Android SDK 版本号，如果不是 Android 平台则返回 0
  /// 
  /// 注意：这是一个简化实现，实际项目中建议使用 device_info_plus 包获取准确的版本号
  static Future<int> _getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      try {
        final info = await DeviceInfoPlugin().androidInfo;
        return info.version.sdkInt;
      } catch (e) {
        // 出错时默认按 Android 13 处理，避免旧代码分支逻辑出错
        debugPrint('PermissionUtil: 获取 Android SDK 版本失败: $e，默认按 33 处理');
        return 33;
      }
    }
    return 0;
  }

  /// 获取权限名称（用于显示）
  static String getPermissionName(ph.Permission permission) {
    if (permission == ph.Permission.camera) return '相机';
    if (permission == ph.Permission.photos) return '相册';
    if (permission == ph.Permission.storage) return '存储';
    if (permission == ph.Permission.location || permission == ph.Permission.locationWhenInUse) {
      return '位置';
    }
    if (permission == ph.Permission.notification) return '通知';
    if (permission == ph.Permission.microphone) return '麦克风';
    if (permission == ph.Permission.contacts) return '联系人';
    if (permission == ph.Permission.calendar) return '日历';
    if (permission == ph.Permission.phone) return '电话';
    if (permission == ph.Permission.sms) return '短信';
    return '未知权限';
  }

  /// 获取权限状态描述（用于显示）
  static String getPermissionStatusText(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return '已授予';
      case ph.PermissionStatus.denied:
        return '已拒绝';
      case ph.PermissionStatus.restricted:
        return '受限';
      case ph.PermissionStatus.limited:
        return '有限权限';
      case ph.PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      default:
        return '未知';
    }
  }
}

/// 位置精度枚举
enum LocationAccuracy {
  /// 粗略位置（Android 12+）
  reduced,

  /// 精确位置
  precise,
}
