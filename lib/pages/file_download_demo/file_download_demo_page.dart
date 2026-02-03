import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_button.dart';
import 'file_download_demo_controller.dart';
import 'models/download_item_model.dart';

/// 文件下载演示页面
class FileDownloadDemoPage extends BasePage<FileDownloadDemoController> {
  const FileDownloadDemoPage({super.key});

  @override
  String? get pageTitle => '文件下载演示';

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // URL 输入区域
        _buildUrlInputSection(),
        // 预设链接区域
        _buildPresetUrlsSection(),
        // 统计信息
        _buildStatisticsSection(),
        // 下载列表
        Expanded(
          child: _buildDownloadList(),
        ),
      ],
    );
  }

  /// 构建 URL 输入区域
  Widget _buildUrlInputSection() {
    final urlController = TextEditingController();
    urlController.text = controller.presetUrls.first['url'] ?? '';

    return Container(
      margin: EdgeInsets.all(AppDesignTokens.spacing16),
      padding: EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesignTokens.primaryColor.withOpacity(0.1),
            AppDesignTokens.secondaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius16),
        boxShadow: [
          BoxShadow(
            color: AppDesignTokens.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppDesignTokens.spacing8),
                decoration: BoxDecoration(
                  color: AppDesignTokens.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                ),
                child: Icon(
                  Icons.download,
                  color: AppDesignTokens.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件下载',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize18,
                        fontWeight: AppDesignTokens.fontWeightBold,
                        color: AppDesignTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppDesignTokens.spacingV4),
                    Text(
                      '支持断点续传、暂停恢复',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize12,
                        color: AppDesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: '请输入文件下载链接',
              prefixIcon: Icon(Icons.link, color: AppDesignTokens.primaryColor),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: AppDesignTokens.textSecondary),
                onPressed: () => urlController.clear(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                borderSide: BorderSide(color: AppDesignTokens.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                borderSide: BorderSide(color: AppDesignTokens.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                borderSide: BorderSide(color: AppDesignTokens.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spacing16,
                vertical: AppDesignTokens.spacingV16,
              ),
            ),
            maxLines: 2,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '开始下载',
            icon: Icons.download,
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isEmpty) {
                controller.showError('请输入下载链接');
                return;
              }
              controller.startDownload(url);
            },
            type: AppButtonType.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  /// 构建预设链接区域
  Widget _buildPresetUrlsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing16),
      padding: EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        boxShadow: AppDesignTokens.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bookmark,
                size: 16,
                color: AppDesignTokens.textSecondary,
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              Text(
                '预设链接',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize14,
                  fontWeight: AppDesignTokens.fontWeightSemiBold,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV8),
          Wrap(
            spacing: AppDesignTokens.spacing8,
            runSpacing: AppDesignTokens.spacingV8,
            children: controller.presetUrls.map((preset) {
              return InkWell(
                onTap: () => controller.downloadPresetUrl(preset),
                borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing12,
                    vertical: AppDesignTokens.spacingV8,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                    border: Border.all(
                      color: AppDesignTokens.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link,
                        size: 14,
                        color: AppDesignTokens.primaryColor,
                      ),
                      SizedBox(width: AppDesignTokens.spacing4),
                      Text(
                        preset['name']!,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize12,
                          color: AppDesignTokens.primaryColor,
                          fontWeight: AppDesignTokens.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建统计信息区域
  Widget _buildStatisticsSection() {
    return Obx(() {
      final total = controller.downloadItems.length;
      final downloading = controller.downloadItems.where((e) => e.status == DownloadStatus.downloading).length;
      final paused = controller.downloadItems.where((e) => e.status == DownloadStatus.paused).length;
      final completed = controller.downloadItems.where((e) => e.status == DownloadStatus.completed).length;
      final failed = controller.downloadItems.where((e) => e.status == DownloadStatus.failed).length;

      if (total == 0) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.all(AppDesignTokens.spacing16),
        padding: EdgeInsets.all(AppDesignTokens.spacing12),
        decoration: BoxDecoration(
          color: AppDesignTokens.surfaceColor,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
          boxShadow: AppDesignTokens.shadowSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('全部', total, AppDesignTokens.textPrimary),
            _buildStatItem('下载中', downloading, AppDesignTokens.primaryColor),
            _buildStatItem('已暂停', paused, AppDesignTokens.warningColor),
            _buildStatItem('已完成', completed, AppDesignTokens.successColor),
            _buildStatItem('失败', failed, AppDesignTokens.errorColor),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppDesignTokens.spacing8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize12,
            color: AppDesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 构建下载列表
  Widget _buildDownloadList() {
    return Obx(() {
      if (controller.downloadItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDesignTokens.spacing24),
                decoration: BoxDecoration(
                  color: AppDesignTokens.grey100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.download_outlined,
                  size: AppDesignTokens.iconSizeXLarge,
                  color: AppDesignTokens.textDisabled,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingV16),
              Text(
                '暂无下载记录',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize16,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingV4),
              Text(
                '输入链接或点击预设链接开始下载',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                  color: AppDesignTokens.textDisabled,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // 列表头部
          Container(
            margin: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing16),
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignTokens.spacing12,
              vertical: AppDesignTokens.spacingV8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '下载列表 (${controller.downloadItems.length})',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
                if (controller.downloadItems.any((item) => item.status == DownloadStatus.completed))
                  TextButton.icon(
                    onPressed: controller.clearHistory,
                    icon: Icon(
                      Icons.delete_sweep,
                      size: 16,
                      color: AppDesignTokens.errorColor,
                    ),
                    label: Text(
                      '清空历史',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize12,
                        color: AppDesignTokens.errorColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 下载项列表
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing16),
              itemCount: controller.downloadItems.length,
              itemBuilder: (context, index) {
                final item = controller.downloadItems[index];
                return _buildDownloadItem(item);
              },
            ),
          ),
        ],
      );
    });
  }

  /// 构建下载项
  Widget _buildDownloadItem(DownloadItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingV12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        boxShadow: AppDesignTokens.shadowSmall,
        border: Border.all(
          color: _getStatusColor(item.status).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppDesignTokens.spacing12),
            child: Row(
              children: [
                // 文件图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(item.status).withOpacity(0.2),
                        _getStatusColor(item.status).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                  ),
                  child: Center(
                    child: Text(
                      item.fileTypeIcon,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing12),
                // 文件名和大小
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fileName,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize15,
                          fontWeight: AppDesignTokens.fontWeightSemiBold,
                          color: AppDesignTokens.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDesignTokens.spacingV4),
                      Row(
                        children: [
                          _buildStatusChip(item.status),
                          SizedBox(width: AppDesignTokens.spacing8),
                          Text(
                            item.status == DownloadStatus.completed
                                ? '${item.fileSizeText} • ${_formatTime(item.completedAt ?? item.createdAt)}'
                                : item.status == DownloadStatus.downloading || item.status == DownloadStatus.paused
                                    ? '${item.receivedSizeText} / ${item.fileSizeText}'
                                    : item.status == DownloadStatus.failed
                                        ? '下载失败'
                                        : item.status == DownloadStatus.cancelled
                                            ? '已取消'
                                            : '等待中',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize12,
                              color: AppDesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 操作按钮
                _buildActionButtons(item),
              ],
            ),
          ),
          // 进度条（仅在下载中或暂停时显示）
          if (item.status == DownloadStatus.downloading || item.status == DownloadStatus.paused) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: item.progress,
                    backgroundColor: AppDesignTokens.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(item.status)),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  SizedBox(height: AppDesignTokens.spacingV8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(item.progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize12,
                          fontWeight: AppDesignTokens.fontWeightMedium,
                          color: _getStatusColor(item.status),
                        ),
                      ),
                      if (item.totalBytes != null)
                        Text(
                          '${_formatSpeed(item.receivedBytes, item.totalBytes!)}',
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSize12,
                            color: AppDesignTokens.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
          ],
          // 错误信息（失败时显示）
          if (item.status == DownloadStatus.failed && item.errorMessage != null) ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
              padding: EdgeInsets.all(AppDesignTokens.spacing8),
              decoration: BoxDecoration(
                color: AppDesignTokens.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppDesignTokens.errorColor,
                  ),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Expanded(
                    child: Text(
                      item.errorMessage!,
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize12,
                        color: AppDesignTokens.errorColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
          ],
        ],
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(DownloadStatus status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing8,
        vertical: AppDesignTokens.spacingV4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: AppDesignTokens.spacing4),
          Text(
            text,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize12,
              color: color,
              fontWeight: AppDesignTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(DownloadItemModel item) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppDesignTokens.textSecondary),
      onSelected: (value) {
        switch (value) {
          case 'pause':
            controller.pauseDownload(item.id);
            break;
          case 'resume':
            controller.resumeDownload(item.id);
            break;
          case 'restart':
            controller.restartDownload(item.id);
            break;
          case 'cancel':
            controller.cancelDownload(item.id);
            break;
          case 'open':
            controller.openFile(item.savePath);
            break;
          case 'delete':
            controller.deleteDownloadItem(item.id);
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        switch (item.status) {
          case DownloadStatus.downloading:
            items.add(PopupMenuItem(
              value: 'pause',
              child: Row(
                children: [
                  Icon(Icons.pause, size: 18, color: AppDesignTokens.warningColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('暂停'),
                ],
              ),
            ));
            items.add(PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 18, color: AppDesignTokens.errorColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('取消'),
                ],
              ),
            ));
            break;
          case DownloadStatus.paused:
            items.add(PopupMenuItem(
              value: 'resume',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, size: 18, color: AppDesignTokens.primaryColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('继续'),
                ],
              ),
            ));
            items.add(PopupMenuItem(
              value: 'restart',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 18, color: AppDesignTokens.infoColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('重新开始'),
                ],
              ),
            ));
            items.add(PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 18, color: AppDesignTokens.errorColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('取消'),
                ],
              ),
            ));
            break;
          case DownloadStatus.completed:
            items.add(PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 18, color: AppDesignTokens.primaryColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('打开'),
                ],
              ),
            ));
            items.add(PopupMenuItem(
              value: 'restart',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 18, color: AppDesignTokens.infoColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('重新下载'),
                ],
              ),
            ));
            break;
          case DownloadStatus.failed:
          case DownloadStatus.cancelled:
            items.add(PopupMenuItem(
              value: 'restart',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 18, color: AppDesignTokens.infoColor),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text('重新开始'),
                ],
              ),
            ));
            break;
          default:
            break;
        }

        items.add(PopupMenuDivider());
        items.add(PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppDesignTokens.errorColor),
              SizedBox(width: AppDesignTokens.spacing8),
              Text('删除'),
            ],
          ),
        ));

        return items;
      },
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return AppDesignTokens.primaryColor;
      case DownloadStatus.paused:
        return AppDesignTokens.warningColor;
      case DownloadStatus.completed:
        return AppDesignTokens.successColor;
      case DownloadStatus.failed:
        return AppDesignTokens.errorColor;
      case DownloadStatus.cancelled:
        return AppDesignTokens.textSecondary;
      default:
        return AppDesignTokens.textSecondary;
    }
  }

  /// 获取状态文本
  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return '下载中';
      case DownloadStatus.paused:
        return '已暂停';
      case DownloadStatus.completed:
        return '已完成';
      case DownloadStatus.failed:
        return '失败';
      case DownloadStatus.cancelled:
        return '已取消';
      default:
        return '等待中';
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.failed:
        return Icons.error;
      case DownloadStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 格式化下载速度（简化版，实际需要计算时间差）
  String _formatSpeed(int received, int total) {
    // 这里简化处理，实际应该计算时间差
    return '剩余: ${_formatBytes(total - received)}';
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
}
