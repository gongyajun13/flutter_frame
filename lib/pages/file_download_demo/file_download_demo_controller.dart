import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../base/base_controller.dart';
import '../../network/config/network_config.dart';
import '../../overlay/overlay.dart';
import '../../utils/app_logger.dart';
import 'models/download_item_model.dart';

/// 文件下载演示控制器
class FileDownloadDemoController extends BaseController {
  /// 下载项列表
  final RxList<DownloadItemModel> downloadItems = <DownloadItemModel>[].obs;

  /// 当前下载的 CancelToken（用于取消/暂停下载）
  final Map<String, CancelToken> _cancelTokens = {};
  
  /// 被暂停的任务ID集合（用于区分暂停和取消）
  final Set<String> _pausedTaskIds = {};

  /// 预设下载链接
  final List<Map<String, String>> presetUrls = [
    {
      'name': 'HotDog APK (测试).apk',
      'url': 'https://aiera-android.oss-cn-shanghai.aliyuncs.com/aiera_debug_speed/10000/hotdog-1.00.00-speed-20260202035207.apk',
    },
    {
      'name': '示例 PDF',
      'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    },
    {
      'name': '示例图片',
      'url': 'https://picsum.photos/1920/1080',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadDownloadHistory();
  }

  @override
  void onClose() {
    // 取消所有正在进行的下载
    for (final token in _cancelTokens.values) {
      if (!token.isCancelled) {
        token.cancel('页面关闭');
      }
    }
    _cancelTokens.clear();
    super.onClose();
  }

  /// 加载下载历史（从本地文件系统）
  Future<void> _loadDownloadHistory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final downloadDir = Directory('${tempDir.path}/downloads');
      
      if (!await downloadDir.exists()) {
        return;
      }

      final files = downloadDir.listSync();
      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final stat = await file.stat();
          final item = DownloadItemModel(
            id: 'history_${file.path.hashCode}',
            url: '', // 历史记录没有URL
            fileName: fileName,
            savePath: file.path,
            totalBytes: stat.size.toInt(),
            receivedBytes: stat.size.toInt(),
            progress: 1.0,
            status: DownloadStatus.completed,
            createdAt: stat.modified,
            completedAt: stat.modified,
          );
          downloadItems.add(item);
        }
      }
    } catch (e) {
      AppLogger.e('加载下载历史失败', error: e);
    }
  }

  /// 从URL获取文件名
  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        if (fileName.isNotEmpty && fileName.contains('.')) {
          return fileName;
        }
      }
      // 如果没有找到文件名，使用时间戳
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// 从URL获取文件扩展名
  String _getFileExtensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        if (fileName.contains('.')) {
          return fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// 获取下载保存目录
  Future<Directory> _getDownloadDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final downloadDir = Directory('${tempDir.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  /// 开始下载（支持断点续传）
  Future<void> startDownload(String url, {String? customFileName, String? resumeItemId, bool forceRestart = false}) async {
    try {
      DownloadItemModel item;
      int startByte = 0;
      bool isResume = resumeItemId != null;
      String savePath;
      String actualUrl = url;

      if (isResume) {
        // 恢复下载：通过 ID 查找已存在的任务
        final existingItem = downloadItems.firstWhereOrNull((e) => e.id == resumeItemId);
        if (existingItem == null) {
          AppLogger.e('找不到要恢复的下载任务: $resumeItemId', tag: 'Download');
          showError('找不到要恢复的下载任务');
          return;
        }
        
        // 确保使用原有任务的 URL（而不是传入的 url，可能不一致）
        actualUrl = existingItem.url.isNotEmpty ? existingItem.url : url;
        item = existingItem;
        savePath = item.savePath;
        
        // 如果是强制重新开始，删除文件并从头开始
        if (forceRestart) {
          final file = File(savePath);
          if (await file.exists()) {
            await file.delete();
          }
          startByte = 0;
        } else {
          // 断点续传：检查原文件和临时文件
          final file = File(savePath);
          final tempFile = File('$savePath.tmp');
          
          // 如果临时文件存在，说明上次下载被中断，需要先合并临时文件到原文件
          if (await tempFile.exists()) {
            try {
              final tempSize = await tempFile.length();
              
              // 如果原文件也存在，检查临时文件是否包含新数据
              if (await file.exists()) {
                final existingSize = await file.length();
                
                if (tempSize > existingSize) {
                  // 临时文件比原文件大，说明有新数据，只追加新增部分
                  final newDataSize = tempSize - existingSize;
                  
                  // 只读取新增部分（从 existingSize 开始）
                  final raf = await tempFile.open();
                  await raf.setPosition(existingSize);
                  final newData = await raf.read(newDataSize);
                  await raf.close();
                  
                  // 追加到原文件
                  final fileRaf = await file.open(mode: FileMode.append);
                  await fileRaf.writeFrom(newData);
                  await fileRaf.close();
                } else if (tempSize < existingSize) {
                  // 临时文件比原文件小，说明临时文件是旧的，删除它
                  AppLogger.w('临时文件大小小于原文件，可能是旧文件，删除临时文件', tag: 'Download');
                }
                
                // 删除临时文件
                await tempFile.delete();
              } else {
                // 如果原文件不存在，将临时文件重命名为原文件
                await tempFile.rename(savePath);
              }
            } catch (e, stackTrace) {
              AppLogger.e('处理临时文件失败', error: e, stackTrace: stackTrace, tag: 'Download');
              // 如果处理失败，尝试删除临时文件，从头开始
              try {
                if (await tempFile.exists()) {
                  await tempFile.delete();
                }
              } catch (_) {}
            }
          }
          
          // 计算起始字节：原文件大小（如果有）
          if (await file.exists()) {
            try {
              startByte = await file.length();
            } catch (e, stackTrace) {
              AppLogger.e('读取文件大小失败', error: e, stackTrace: stackTrace, tag: 'Download');
              startByte = 0;
            }
          } else {
            startByte = 0;
          }
        }
        
        // 更新状态为下载中（在同一任务上更新）
        final index = downloadItems.indexWhere((e) => e.id == item.id);
        if (index != -1) {
          downloadItems[index] = downloadItems[index].copyWith(
            status: DownloadStatus.downloading,
          );
        } else {
          AppLogger.e('未找到任务索引: ${item.id}', tag: 'Download');
        }
      } else {
        // 新下载
        String fileName = customFileName ?? _getFileNameFromUrl(url);
        
        // 如果提供了自定义文件名但没有扩展名，尝试从 URL 中提取扩展名并追加
        if (customFileName != null && !fileName.contains('.')) {
          final urlExtension = _getFileExtensionFromUrl(url);
          if (urlExtension.isNotEmpty) {
            fileName = '$fileName.$urlExtension';
          }
        }
        
        final downloadDir = await _getDownloadDirectory();
        savePath = '${downloadDir.path}/$fileName';

        // 检查是否已有相同的下载任务
        final existingItem = downloadItems.firstWhereOrNull(
          (item) => item.url == url && 
                    (item.status == DownloadStatus.downloading || item.status == DownloadStatus.paused),
        );

        if (existingItem != null) {
          showInfo('该文件已在下载列表中');
          return;
        }

        // 检查文件是否已存在
        final file = File(savePath);
        if (await file.exists()) {
          // 如果文件已存在，询问是否覆盖
          final shouldOverwrite = await AppOverlay.dialog.confirmAsync(
            title: '文件已存在',
            message: '文件 "$fileName" 已存在，是否覆盖？',
            confirmText: '覆盖',
            cancelText: '取消',
          );

          if (shouldOverwrite != true) {
            return;
          }
          await file.delete();
        }

        // 创建下载项
        final newId = 'download_${DateTime.now().millisecondsSinceEpoch}';
        item = DownloadItemModel(
          id: newId,
          url: url,
          fileName: fileName,
          savePath: savePath,
          status: DownloadStatus.downloading,
          createdAt: DateTime.now(),
        );

        downloadItems.insert(0, item);
      }

      // 创建取消令牌
      final cancelToken = CancelToken();
      _cancelTokens[item.id] = cancelToken;

      // 使用 Dio 直接下载，支持断点续传
      final dio = NetworkConfig.dio;
      
      // 设置 Range 请求头（断点续传）
      final headers = <String, dynamic>{};
      if (startByte > 0) {
        headers['Range'] = 'bytes=$startByte-';
      }

      // 所有下载都使用临时文件，确保暂停时文件不丢失
      final file = File(savePath);
      final tempPath = '$savePath.tmp';
      final tempFile = File(tempPath);
      
      // 如果是断点续传且原文件存在，需要先检查临时文件
      // 如果临时文件存在，说明上次下载被中断，需要先合并
      if (startByte > 0 && await file.exists()) {
        if (await tempFile.exists()) {
          // 临时文件存在，先合并到原文件
          try {
            final tempBytes = await tempFile.readAsBytes();
            final raf = await file.open(mode: FileMode.append);
            await raf.writeFrom(tempBytes);
            await raf.close();
            await tempFile.delete();
            // 重新计算 startByte
            startByte = await file.length();
            // 更新 Range 头
            if (startByte > 0) {
              headers['Range'] = 'bytes=$startByte-';
            }
          } catch (e, stackTrace) {
            AppLogger.e('合并临时文件失败', error: e, stackTrace: stackTrace, tag: 'Download');
            // 如果合并失败，删除临时文件，从头开始
            try {
              if (await tempFile.exists()) {
                await tempFile.delete();
              }
            } catch (_) {}
            startByte = 0;
            headers.remove('Range');
          }
        }
      }

      // 在下载开始前，确保临时文件存在
      if (startByte == 0) {
        // 新下载：创建空文件
        if (!await tempFile.exists()) {
          await tempFile.create(recursive: true);
        }
      } else {
        // 断点续传：如果临时文件不存在，从原文件复制（如果有）
        if (!await tempFile.exists()) {
          if (await file.exists()) {
            final existingBytes = await file.readAsBytes();
            await tempFile.writeAsBytes(existingBytes);
            // 更新 startByte 为实际文件大小
            startByte = existingBytes.length;
            if (startByte > 0) {
              headers['Range'] = 'bytes=$startByte-';
            }
          } else {
            // 原文件也不存在，从头开始
            await tempFile.create(recursive: true);
            startByte = 0;
            headers.remove('Range');
          }
        }
      }

      try {
        // 使用流式下载，手动写入文件，确保取消时文件不丢失
        final response = await dio.get(
          actualUrl,
          options: Options(
            headers: headers,
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(minutes: 30),
          ),
          cancelToken: cancelToken,
        );
        
        final responseStream = response.data as ResponseBody;
        final total = responseStream.contentLength; // 对于断点续传，这是剩余部分的大小
        final existingItem = downloadItems.firstWhereOrNull((e) => e.id == item.id);
        // 计算整个文件的期望大小
        // 对于断点续传，total 是剩余部分的大小，所以总大小 = startByte + total
        // 如果 total <= 0，使用之前保存的 totalBytes
        final actualTotal = total > 0
            ? (startByte + total)
            : (existingItem?.totalBytes != null 
                ? existingItem!.totalBytes 
                : null);
        
        // 打开文件用于追加写入
        final raf = await tempFile.open(mode: FileMode.writeOnlyAppend);
        int received = 0;
        
        bool wasCancelled = false;
        try {
          await for (final chunk in responseStream.stream) {
            if (cancelToken.isCancelled) {
              wasCancelled = true;
              break;
            }
            
            // 写入数据块
            await raf.writeFrom(chunk);
            received += chunk.length;
            
            // 更新进度
            final index = downloadItems.indexWhere((e) => e.id == item.id);
            if (index != -1 && !cancelToken.isCancelled) {
              final actualReceived = startByte + received;
              downloadItems[index] = downloadItems[index].copyWith(
                receivedBytes: actualReceived,
                totalBytes: actualTotal,
                progress: actualTotal != null && actualTotal > 0 ? actualReceived / actualTotal : 0.0,
                status: DownloadStatus.downloading,
              );
            }
          }
        } finally {
          await raf.close();
        }
        
        // 如果下载被取消，不处理文件，直接返回（让 catch 块处理）
        if (wasCancelled) {
          throw DioException(
            requestOptions: RequestOptions(path: actualUrl),
            type: DioExceptionType.cancel,
            error: '用户取消',
          );
        }

        // 下载完成，处理临时文件
        if (await tempFile.exists()) {
          final finalSize = await tempFile.length();
          
          // 检查是否真的下载完成
          final expectedTempSize = startByte + received;
          if (finalSize < expectedTempSize) {
            AppLogger.w('下载未完成：期望临时文件大小 $expectedTempSize 字节，实际大小 $finalSize 字节', tag: 'Download');
            throw Exception('下载未完成：期望临时文件大小 $expectedTempSize 字节，实际大小 $finalSize 字节');
          }
          
          // 如果知道总大小，检查是否达到
          if (actualTotal != null && (startByte + received) < actualTotal) {
            AppLogger.w('下载未完成：期望总大小 $actualTotal 字节，已下载 ${startByte + received} 字节', tag: 'Download');
            throw Exception('下载未完成：期望总大小 $actualTotal 字节，已下载 ${startByte + received} 字节');
          }
          
          if (startByte > 0 && await file.exists()) {
            // 断点续传：只追加新增部分（received）到原文件
            // 只读取新增部分（从 startByte 位置开始）
            final raf = await tempFile.open();
            await raf.setPosition(startByte);
            final newData = await raf.read(received);
            await raf.close();
            
            // 追加到原文件
            final finalRaf = await file.open(mode: FileMode.append);
            await finalRaf.writeFrom(newData);
            await finalRaf.close();
            
            await tempFile.delete();
          } else {
            // 新下载：将临时文件重命名为最终文件
            if (await file.exists()) {
              await file.delete();
            }
            await tempFile.rename(savePath);
          }
        }
      } catch (e) {
        // 下载失败时，保留临时文件（用于断点续传），不删除
        rethrow;
      }

      // 移除取消令牌
      _cancelTokens.remove(item.id);

        // 更新下载项状态
        final finalIndex = downloadItems.indexWhere((e) => e.id == item.id);
        if (finalIndex != -1) {
          final finalFile = File(savePath);
          final stat = await finalFile.stat();
          downloadItems[finalIndex] = downloadItems[finalIndex].copyWith(
            status: DownloadStatus.completed,
            completedAt: DateTime.now(),
            totalBytes: stat.size.toInt(),
            receivedBytes: stat.size.toInt(),
            progress: 1.0,
          );
          showSuccess('文件下载成功');
        }
    } catch (e, stackTrace) {
      AppLogger.e('下载文件失败', error: e, stackTrace: stackTrace, tag: 'Download');
      
      // 更新失败状态
      // 优先通过 resumeItemId 查找（恢复下载时使用）
      DownloadItemModel? failedItem;
      if (resumeItemId != null) {
        failedItem = downloadItems.firstWhereOrNull((e) => e.id == resumeItemId);
      } else {
        // 新下载时通过 URL 查找
        failedItem = downloadItems.firstWhereOrNull(
          (e) => e.url == url && 
                 (e.status == DownloadStatus.downloading || e.status == DownloadStatus.paused),
        );
      }
      
      if (failedItem != null) {
        final index = downloadItems.indexWhere((e) => e.id == failedItem!.id);
        if (index != -1) {
          // 如果任务状态已经是 paused，说明是用户主动暂停的，不要更新状态
          if (downloadItems[index].status == DownloadStatus.paused) {
            return;
          }
          
          if (e is DioException && e.type == DioExceptionType.cancel) {
            // 下载被取消或暂停
            if (_pausedTaskIds.contains(failedItem.id)) {
              // 暂停
              _pausedTaskIds.remove(failedItem.id);
              downloadItems[index] = downloadItems[index].copyWith(
                status: DownloadStatus.paused,
              );
            } else {
              // 取消
              downloadItems[index] = downloadItems[index].copyWith(
                status: DownloadStatus.cancelled,
              );
            }
          } else {
            // 失败
            downloadItems[index] = downloadItems[index].copyWith(
              status: DownloadStatus.failed,
              errorMessage: e.toString(),
            );
            showError('下载失败: $e');
          }
        }
      }
    }
  }

  /// 暂停下载
  void pauseDownload(String id) {
    final cancelToken = _cancelTokens[id];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('用户暂停');
      _cancelTokens.remove(id);
      
      // 标记为暂停的任务
      _pausedTaskIds.add(id);
      
      final index = downloadItems.indexWhere((e) => e.id == id);
      if (index != -1) {
        downloadItems[index] = downloadItems[index].copyWith(
          status: DownloadStatus.paused,
        );
      }
      showInfo('下载已暂停');
    }
  }

  /// 恢复下载
  void resumeDownload(String id) {
    final item = downloadItems.firstWhereOrNull((e) => e.id == id);
    if (item == null) {
      AppLogger.e('找不到要恢复的下载项: $id', tag: 'Download');
      showError('找不到要恢复的下载任务');
      return;
    }
    
    if (item.status == DownloadStatus.paused && item.url.isNotEmpty) {
      // 移除暂停标记
      _pausedTaskIds.remove(id);
      // 直接使用 item.id 来恢复，确保在同一个任务上继续
      startDownload(item.url, customFileName: item.fileName, resumeItemId: item.id);
    } else {
      AppLogger.w('无法恢复：状态=${item.status} (期望: paused), url为空=${item.url.isEmpty}', tag: 'Download');
      showError('无法恢复下载：状态不正确或URL为空');
    }
  }

  /// 取消下载
  void cancelDownload(String id) {
    final cancelToken = _cancelTokens[id];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('用户取消');
      _cancelTokens.remove(id);
    }
    
    // 移除暂停标记（如果是暂停的任务，取消时也要移除）
    _pausedTaskIds.remove(id);
    
    final index = downloadItems.indexWhere((e) => e.id == id);
    if (index != -1) {
      downloadItems[index] = downloadItems[index].copyWith(
        status: DownloadStatus.cancelled,
        errorMessage: '用户取消',
      );
    }
    showInfo('下载已取消');
  }

  /// 重新开始下载
  Future<void> restartDownload(String id) async {
    final item = downloadItems.firstWhereOrNull((e) => e.id == id);
    if (item != null && item.url.isNotEmpty) {
      // 如果正在下载或已暂停，先取消
      if (_cancelTokens.containsKey(id)) {
        _cancelTokens[id]?.cancel('用户重新开始');
        _cancelTokens.remove(id);
      }
      
      // 移除暂停标记
      _pausedTaskIds.remove(id);
      
      // 删除已下载的文件
      final file = File(item.savePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // 重置状态（在原任务上重置，不创建新任务）
      final index = downloadItems.indexWhere((e) => e.id == id);
      if (index != -1) {
        downloadItems[index] = downloadItems[index].copyWith(
          status: DownloadStatus.pending,
          receivedBytes: 0,
          progress: 0.0,
          totalBytes: null,
          errorMessage: null,
        );
      }
      
      // 重新开始下载（传递 resumeItemId 和 forceRestart=true，在原任务上重新开始）
      await startDownload(item.url, customFileName: item.fileName, resumeItemId: item.id, forceRestart: true);
    } else {
      AppLogger.w('无法重新开始下载: 任务不存在或URL为空', tag: 'Download');
      showError('无法重新开始下载');
    }
  }

  /// 删除下载项
  Future<void> deleteDownloadItem(String id) async {
    try {
      final item = downloadItems.firstWhere((e) => e.id == id);
      
      // 如果正在下载，先取消
      if (item.status == DownloadStatus.downloading) {
        cancelDownload(id);
      }
      
      // 如果已暂停，取消令牌
      if (item.status == DownloadStatus.paused) {
        _cancelTokens.remove(id);
      }

      // 删除文件
      final file = File(item.savePath);
      if (await file.exists()) {
        await file.delete();
      }

      // 从列表中移除
      downloadItems.removeWhere((e) => e.id == id);
      showSuccess('已删除');
    } catch (e) {
      showError('删除失败: $e');
    }
  }

  /// 打开文件（如果是 APK 则直接安装）
  Future<void> openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        showError('文件不存在');
        return;
      }

      // 检查文件扩展名，如果是 APK 则直接安装
      final fileName = filePath.split('/').last;
      String? extension;
      if (fileName.contains('.')) {
        extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
      }
      
      // 如果文件名中没有扩展名，尝试从下载项中获取
      if (extension == null || extension.isEmpty) {
        final item = downloadItems.firstWhereOrNull((item) => item.savePath == filePath);
        if (item != null) {
          extension = item.fileExtension;
          // 如果还是没有，尝试从 URL 获取
          if (extension.isEmpty && item.url.isNotEmpty) {
            extension = _getFileExtensionFromUrl(item.url);
          }
        }
      }
      
      // 只根据扩展名判断是否为 APK 文件
      if (extension == 'apk') {
        await _installApk(filePath);
        return;
      }

      // Android 上使用平台通道打开文件，避免特殊字符问题
      if (Platform.isAndroid) {
        try {
          const platform = MethodChannel('com.example.flutter_frame/file_opener');
          final result = await platform.invokeMethod('openFile', {'filePath': filePath});
          if (result == true) {
            showSuccess('文件已打开');
          } else {
            showError('无法打开文件');
          }
        } catch (e) {
          AppLogger.e('平台方法调用失败，尝试使用 url_launcher', error: e, tag: 'Download');
          // 如果平台方法失败，回退到 url_launcher
          final uri = Uri.file(filePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            showError('无法打开文件');
          }
        }
      } else {
        // iOS 或其他平台使用 url_launcher
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          showError('无法打开文件');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('打开文件失败', error: e, stackTrace: stackTrace, tag: 'Download');
      showError('打开文件失败: $e');
    }
  }

  /// 安装 APK 文件
  Future<void> _installApk(String apkPath) async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('app_update');
        await platform.invokeMethod('installApk', {'path': apkPath});
        showSuccess('正在安装 APK...');
      } else {
        showError('当前平台不支持 APK 安装');
      }
    } catch (e, stackTrace) {
      AppLogger.e('安装 APK 失败', error: e, stackTrace: stackTrace, tag: 'Download');
      showError('安装 APK 失败: $e');
    }
  }

  /// 清空下载历史
  Future<void> clearHistory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final downloadDir = Directory('${tempDir.path}/downloads');
      
      if (await downloadDir.exists()) {
        await downloadDir.delete(recursive: true);
        await downloadDir.create(recursive: true);
      }

      downloadItems.removeWhere((item) => item.status == DownloadStatus.completed);
      showSuccess('已清空下载历史');
    } catch (e) {
      showError('清空历史失败: $e');
    }
  }

  /// 使用预设链接下载
  void downloadPresetUrl(Map<String, String> preset) {
    startDownload(preset['url']!, customFileName: preset['name']);
  }
}
