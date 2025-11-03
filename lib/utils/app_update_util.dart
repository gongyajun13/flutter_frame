import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

/// 应用更新信息
class AppUpdateInfo {
  final String latestVersion; // 例如: 1.2.3
  final int? latestBuild; // 例如: 42 （可选）
  final bool forceUpdate; // 是否强制
  final String? title; // 弹窗标题
  final String? description; // 升级说明（支持多行）
  final String? androidApkUrl; // Android APK下载地址
  final String? iosAppId; // iOS AppStore应用ID（纯数字）

  AppUpdateInfo({
    required this.latestVersion,
    this.latestBuild,
    required this.forceUpdate,
    this.title,
    this.description,
    this.androidApkUrl,
    this.iosAppId,
  });

  /// 容错解析：兼容常见字段命名
  factory AppUpdateInfo.fromMap(Map<String, dynamic> map) {
    final m = map;
    String version = (m['latestVersion'] ?? m['version'] ?? m['versionName'] ?? '').toString();
    int? build;
    final rawBuild = m['latestBuild'] ?? m['build'] ?? m['buildNumber'] ?? m['versionCode'];
    if (rawBuild != null) {
      try { build = int.parse(rawBuild.toString()); } catch (_) {}
    }
    final bool forced = (m['forceUpdate'] ?? m['force'] ?? m['isForce'] ?? false) == true ||
        m['updateType']?.toString() == 'force';
    return AppUpdateInfo(
      latestVersion: version,
      latestBuild: build,
      forceUpdate: forced,
      title: (m['title'] ?? '发现新版本').toString(),
      description: (m['description'] ?? m['desc'] ?? m['changelog'] ?? '').toString(),
      androidApkUrl: (m['androidApkUrl'] ?? m['apkUrl'] ?? m['androidUrl'])?.toString(),
      iosAppId: (m['iosAppId'] ?? m['appId'] ?? m['iosId'])?.toString(),
    );
  }
}

/// 应用更新工具类
class AppUpdateUtil {
  AppUpdateUtil._();
  static const MethodChannel _channel = MethodChannel('app_update');

  /// 版本比较：返回 true 表示需要更新
  static Future<bool> _shouldUpdate(AppUpdateInfo info) async {
    final pkg = await PackageInfo.fromPlatform();
    final currentVersion = pkg.version; // e.g. 1.0.0
    final currentBuild = int.tryParse(pkg.buildNumber);

    // 优先用 build 比较，其次语义化版本
    if (info.latestBuild != null && currentBuild != null) {
      if (info.latestBuild! > currentBuild) return true;
      if (info.latestBuild! < currentBuild) return false;
    }
    return _compareSemver(info.latestVersion, currentVersion) > 0;
  }

  /// 语义化版本比较：a>b 返回 1，a==b 返回 0，a<b 返回 -1
  static int _compareSemver(String a, String b) {
    List<int> pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (pa.length < 3) pa.add(0);
    while (pb.length < 3) pb.add(0);
    for (int i = 0; i < 3; i++) {
      if (pa[i] > pb[i]) return 1;
      if (pa[i] < pb[i]) return -1;
    }
    return 0;
  }

  /// 入口：通过自定义获取器获取更新信息
  static Future<void> checkAndUpdate({
    required Future<AppUpdateInfo> Function() fetcher,
    bool silent = false, // 静默检查：不满足时不提示
  }) async {
    try {
      final info = await fetcher();
      if (await _shouldUpdate(info)) {
        _showUpdateDialog(info);
      } else if (!silent) {
        _snackInfo('当前已是最新版本');
      }
    } catch (e) {
      if (!silent) {
        _snackError('检查更新失败：$e');
      }
    }
  }

  /// 入口：通过后端接口直连
  /// 示例：path = '/app/version', 后端返回通用字段
  static Future<void> checkAndUpdateByApi(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    bool silent = false,
    AppUpdateInfo Function(Map<String, dynamic>)? parser,
  }) async {
    await checkAndUpdate(
      silent: silent,
      fetcher: () async {
        try {
          final resp = await Dio().get(
            path,
            queryParameters: query,
            options: Options(
              headers: headers,
              responseType: ResponseType.json,
              followRedirects: true,
              validateStatus: (status) => status != null && status >= 200 && status < 400,
            ),
          );
          if (resp.data is! Map) {
            throw '无效的响应数据';
          }
          final map = Map<String, dynamic>.from(resp.data as Map);
          final content = _unwrapCommonApi(map);
          return (parser ?? AppUpdateInfo.fromMap)(content);
        } catch (e) {
          throw '请求失败：$e';
        }
      },
    );
  }

  /// 适配常见的响应壳结构
  static Map<String, dynamic> _unwrapCommonApi(Map<String, dynamic> raw) {
    if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw['data']);
    }
    if (raw.containsKey('result') && raw['result'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw['result']);
    }
    return raw;
  }

  /// 展示更新弹窗：Android支持下载进度与安装，iOS跳转App Store
  static void _showUpdateDialog(AppUpdateInfo info) {
    double progress = 0.0;
    bool downloading = false;
    bool readyToInstall = false; // APK 已下载，可直接安装
    bool hasPartial = false; // 存在未完成的分片，可继续下载
    String statusText = '';
    String? downloadedApkPath;
    CancelToken? cancelToken;
    
    bool _canUpdateUI() => Get.isDialogOpen == true;

    Widget buildContent(void Function(void Function()) setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((info.description ?? '').isNotEmpty) ...[
            Text(
              info.description!,
              style: TextStyle(fontSize: 14.sp, height: 1.5, color: Colors.grey.shade800),
            ),
            SizedBox(height: 16.h),
          ],
          if (downloading) ...[
            LinearProgressIndicator(value: progress == 0 ? null : progress),
            SizedBox(height: 8.h),
            Text(
              statusText.isEmpty ? '正在下载更新...' : statusText,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ],
          if (!downloading) ...[
            Text(
              '最新版本：${info.latestVersion}${info.latestBuild != null ? " (${info.latestBuild})" : ''}',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
          ],
        ],
      );
    }

    // 异步探测是否已有完整APK，若有则直接进入可安装状态
    Future<void> _probeExistingApkState(void Function(void Function()) setState) async {
      if (!Platform.isAndroid) return;
      final apkUrl = info.androidApkUrl;
      if (apkUrl == null || apkUrl.isEmpty) return;
      try {
        final savePath = await _resolveApkSavePath(apkUrl);
        final targetFile = File(savePath);
        final partFile = File('$savePath.part');
        // HEAD 校验大小，若一致则认为完整
        final dio = Dio();
        int serverLen = 0;
        try {
          final head = await dio.head(apkUrl, options: Options(followRedirects: true));
          serverLen = int.tryParse(head.headers.value('content-length') ?? '0') ?? 0;
        } catch (_) {}
        if (await targetFile.exists()) {
          final localLen = await targetFile.length();
          if (serverLen > 0 && localLen == serverLen) {
            setState(() {
              readyToInstall = true;
              downloadedApkPath = savePath;
              statusText = '已下载，准备安装...';
            });
            return;
          }
        }
        if (await partFile.exists()) {
          // 存在部分下载数据，可继续
          final partLen = await partFile.length();
          if (partLen > 0) {
            setState(() {
              hasPartial = true;
              statusText = '检测到未完成下载，可继续...';
            });
          }
        }
      } catch (_) {}
    }

    Future<void> onUpdatePressed(void Function(void Function()) setState) async {
      if (Platform.isIOS) {
        final id = info.iosAppId;
        if (id == null || id.isEmpty) {
          _snackWarning('缺少iOS App ID');
          return;
        }
        await _openAppStoreIOS(id);
        return;
      }

      // Android 下载 APK
      final apkUrl = info.androidApkUrl;
      if (apkUrl == null || apkUrl.isEmpty) {
        _snackWarning('缺少Android APK下载地址');
        return;
      }

      try {
        if (_canUpdateUI()) {
          setState(() {
            downloading = true;
            progress = 0;
            statusText = hasPartial ? '继续下载中...' : '准备下载...';
            cancelToken = CancelToken();
          });
        } else {
          cancelToken = CancelToken();
        }

        final savePath = await _resolveApkSavePath(apkUrl);
        downloadedApkPath = await _downloadWithResume(
          url: apkUrl,
          targetPath: savePath,
          cancelToken: cancelToken,
          onProgress: (received, total) {
            if (_canUpdateUI()) {
              setState(() {
                if (total > 0) {
                  progress = received / total;
                  statusText = '下载中 ${(progress * 100).toStringAsFixed(0)}%';
                } else {
                  progress = 0;
                  statusText = '连接中...';
                }
              });
            }
          },
        );
        if (_canUpdateUI()) {
          setState(() {
            downloading = false;
            readyToInstall = true;
            hasPartial = false;
            progress = 1.0;
            statusText = '下载完成，准备安装...';
          });
        } else {
          readyToInstall = true;
        }

        // 触发系统安装（Android 走 MethodChannel，iOS 直接打开文件）
        if (Platform.isAndroid) {
          try {
            await _channel.invokeMethod('installApk', { 'path': downloadedApkPath });
            // 若无权限，系统会跳授权；返回应用后原生 onResume 会自动继续
          } on PlatformException catch (e) {
            _snackError('安装失败：${e.message}');
          }
        } else {
          await _openFileIOS(downloadedApkPath!);
        }
      } catch (e) {
        if (_canUpdateUI()) {
          setState(() {
            statusText = '下载失败：$e';
          });
        }
        _snackError('更新失败：$e');
      }
    }

    _showCustomDialog(
      title: info.title ?? '版本更新',
      barrierDismissible: false,
      child: StatefulBuilder(
        builder: (context, setState) {
          // 记录 setState 引用后探测现有APK
          // 只执行一次探测：当首次构建且尚未处于下载/安装就绪状态
          if (!downloading && !readyToInstall) {
            Future.microtask(() => _probeExistingApkState(setState));
          }
          return WillPopScope(
            onWillPop: () async {
              // 下载中或强更时禁用系统返回键
              return !(downloading || info.forceUpdate);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildContent(setState),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    // 非强更且下载中：提供“取消下载”，取消后暂停（保留.part），并关闭弹窗
                    if (!info.forceUpdate && downloading)
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: OutlinedButton(
                            onPressed: () {
                              try {
                                cancelToken?.cancel('user cancel');
                              } catch (_) {}
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red, width: 1.5.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              '取消下载',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    if (!info.forceUpdate && downloading) SizedBox(width: 8.w),
                    // “稍后”按钮：仅在非强更 且 未开始下载 时可见
                    if (!info.forceUpdate && !downloading)
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.back();
                              cancelToken?.cancel('dialog closed');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue, width: 1.5.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              '稍后',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    if (!info.forceUpdate && !downloading) SizedBox(width: 8.w),
                    // 重新下载：仅在Android 且 已具备安装文件 且 未下载中 显示
                    if (Platform.isAndroid && readyToInstall && !downloading)
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: OutlinedButton(
                            onPressed: () async {
                              final apkUrl = info.androidApkUrl;
                              if (apkUrl == null || apkUrl.isEmpty) return;
                              try {
                                final savePath = await _resolveApkSavePath(apkUrl);
                                // 删除已下载与分片，重新下载
                                try { await File(savePath).delete(); } catch (_) {}
                                try { await File('$savePath.part').delete(); } catch (_) {}
                                setState(() {
                                  readyToInstall = false;
                                  downloadedApkPath = null;
                                  statusText = '准备下载...';
                                });
                                await onUpdatePressed(setState);
                              } catch (e) {
                                _snackError('重下失败：$e');
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: BorderSide(color: Colors.orange, width: 1.5.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              '重新下载',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    if ((Platform.isAndroid && readyToInstall && !downloading) || (!info.forceUpdate && !downloading)) SizedBox(width: 8.w),
                    if (!downloading)
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (Platform.isAndroid && readyToInstall) {
                                if (downloadedApkPath != null) {
                                  try {
                                    await _channel.invokeMethod('installApk', { 'path': downloadedApkPath });
                                  } on PlatformException catch (e) {
                                    _snackError('安装失败：${e.message}');
                                  }
                                }
                                return;
                              }
                              await onUpdatePressed(setState);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              Platform.isIOS
                                  ? '前往升级'
                                  : (readyToInstall ? '安装' : (hasPartial ? '继续升级' : '立即升级')),
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<String> _resolveApkSavePath(String url) async {
    final fileName = url.split('?').first.split('/').last;
    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir!.path, 'updates'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return p.join(folder.path, fileName.isEmpty ? 'update.apk' : fileName);
  }

  /// 断点续传下载：
  /// - 使用 .part 临时文件进行追加写入
  /// - 支持 Range 续传，返回最终完成文件路径
  static Future<String> _downloadWithResume({
    required String url,
    required String targetPath,
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    final dio = Dio();

    // 目标与临时文件
    final targetFile = File(targetPath);
    final partFile = File('$targetPath.part');

    // 如果已完整存在，尝试通过 HEAD 校验大小（若支持），否则直接返回
    try {
      final head = await dio.head(url, options: Options(followRedirects: true));
      final total = int.tryParse(head.headers.value('content-length') ?? '0') ?? 0;
      if (await targetFile.exists() && total > 0) {
        final len = await targetFile.length();
        if (len == total) {
          onProgress?.call(total, total);
          return targetPath;
        } else {
          // 大小不一致，重新下载
          try { await targetFile.delete(); } catch (_) {}
        }
      }
    } catch (_) {
      // HEAD 失败，忽略，走常规流程
    }

    // 计算已下载大小
    int downloaded = 0;
    if (await partFile.exists()) {
      downloaded = await partFile.length();
    }

    // 获取总大小
    int totalSize = 0;
    try {
      final resp = await dio.head(url);
      totalSize = int.tryParse(resp.headers.value('content-length') ?? '0') ?? 0;
    } catch (_) {}

    // 如果已完成，直接重命名
    if (totalSize > 0 && downloaded >= totalSize && await partFile.exists()) {
      await partFile.rename(targetPath);
      onProgress?.call(totalSize, totalSize);
      return targetPath;
    }

    // 开始/续传
    final headers = <String, String>{};
    if (downloaded > 0) {
      headers['range'] = 'bytes=$downloaded-';
    }

    final response = await dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        followRedirects: true,
        validateStatus: (status) => status != null && status >= 200 && status < 400,
      ),
      cancelToken: cancelToken,
    );

    final statusCode = response.statusCode ?? 200;
    final isPartial = statusCode == 206;

    // 如果服务器返回 206，content-length 是剩余部分长度；尝试从 Content-Range 获取总长
    final contentRange = response.headers.value('content-range');
    if (contentRange != null) {
      final slash = contentRange.lastIndexOf('/');
      if (slash != -1) {
        final totalStr = contentRange.substring(slash + 1).trim();
        totalSize = int.tryParse(totalStr) ?? totalSize;
      }
    }

    // 若服务端不支持 Range（返回 200），且我们已有分片，则从头下载：删除分片、覆盖写入
    if (!isPartial && downloaded > 0) {
      try { await partFile.delete(); } catch (_) {}
      downloaded = 0;
    }

    // 若仍未知总长，使用返回的 content-length 估算
    final responseContentLength = int.tryParse(response.headers.value('content-length') ?? '0') ?? 0;
    if (totalSize == 0) {
      totalSize = isPartial ? (downloaded + responseContentLength) : responseContentLength;
    }

    final sink = partFile.openWrite(mode: downloaded > 0 && isPartial ? FileMode.append : FileMode.write);
    int receivedBytes = downloaded;
    final stream = response.data!.stream;

    final completer = Completer<void>();
    stream.listen(
      (chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalSize > 0) {
          onProgress?.call(receivedBytes, totalSize);
        } else {
          onProgress?.call(receivedBytes, 0);
        }
      },
      onDone: () async {
        await sink.flush();
        await sink.close();
        // 完成后重命名
        if (await targetFile.exists()) {
          try { await targetFile.delete(); } catch (_) {}
        }
        // 校验完整性：如已知总长，则必须匹配
        if (totalSize > 0 && receivedBytes != totalSize) {
          completer.completeError(Exception('incomplete download: $receivedBytes/$totalSize'));
          return;
        }
        await partFile.rename(targetPath);
        completer.complete();
      },
      onError: (e, st) async {
        try { await sink.close(); } catch (_) {}
        completer.completeError(e, st);
      },
      cancelOnError: true,
    );

    await completer.future;
    return targetPath;
  }

  // 轻量提示
  static void _snackSuccess(String message) {
    Get.snackbar('成功', message, snackPosition: SnackPosition.TOP, backgroundColor: Colors.green.shade600, colorText: Colors.white);
  }
  static void _snackError(String message) {
    Get.snackbar('错误', message, snackPosition: SnackPosition.TOP, backgroundColor: Colors.red.shade600, colorText: Colors.white);
  }
  static void _snackWarning(String message) {
    Get.snackbar('警告', message, snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange.shade600, colorText: Colors.white);
  }
  static void _snackInfo(String message) {
    Get.snackbar('提示', message, snackPosition: SnackPosition.TOP, backgroundColor: Colors.blue.shade600, colorText: Colors.white);
  }

  // iOS 打开文件 / App Store
  static Future<void> _openFileIOS(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw '无法打开文件: $path';
    }
  }
  static Future<void> _openAppStoreIOS(String appId) async {
    final uri = Uri.parse('https://apps.apple.com/app/id$appId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw '无法打开App Store';
    }
  }

  // 简易自定义Dialog
  static void _showCustomDialog({
    required String title,
    required Widget child,
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: Get.width * 0.08),
            constraints: BoxConstraints(
              minWidth: 280.w,
              maxWidth: Get.width * 0.85,
              maxHeight: Get.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    SizedBox(
                      height: 36.h,
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }
}


