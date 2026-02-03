/// 下载项模型
class DownloadItemModel {
  final String id;
  final String url;
  final String fileName;
  final String savePath;
  final int? totalBytes;
  final int receivedBytes;
  final double progress; // 0.0 - 1.0
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  DownloadItemModel({
    required this.id,
    required this.url,
    required this.fileName,
    required this.savePath,
    this.totalBytes,
    this.receivedBytes = 0,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  /// 复制并更新
  DownloadItemModel copyWith({
    String? id,
    String? url,
    String? fileName,
    String? savePath,
    int? totalBytes,
    int? receivedBytes,
    double? progress,
    DownloadStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return DownloadItemModel(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      savePath: savePath ?? this.savePath,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 获取文件大小文本
  String get fileSizeText {
    if (totalBytes == null) {
      if (receivedBytes > 0) {
        return _formatBytes(receivedBytes);
      }
      return '未知';
    }
    return _formatBytes(totalBytes!);
  }

  /// 获取已下载大小文本
  String get receivedSizeText {
    return _formatBytes(receivedBytes);
  }

  /// 格式化字节数
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 获取文件扩展名
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// 获取文件类型图标
  String get fileTypeIcon {
    switch (fileExtension) {
      case 'apk':
        return '📱';
      case 'pdf':
        return '📄';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'mp4':
      case 'avi':
      case 'mov':
        return '🎬';
      case 'mp3':
      case 'wav':
        return '🎵';
      case 'zip':
      case 'rar':
        return '📦';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      default:
        return '📎';
    }
  }
}

/// 下载状态
enum DownloadStatus {
  pending,    // 等待中
  downloading, // 下载中
  paused,     // 已暂停
  completed,  // 已完成
  failed,     // 失败
  cancelled,  // 已取消
}
