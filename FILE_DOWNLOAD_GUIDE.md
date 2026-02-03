# 文件下载功能指南

## 功能概述

文件下载模块提供了完整的下载管理功能，支持断点续传、暂停、恢复、取消、重新开始、打开和安装等功能。

## 核心功能

### 1. 下载管理
- **开始下载**：支持自定义文件名，自动从 URL 提取扩展名
- **暂停下载**：使用 CancelToken 取消请求，保留已下载数据
- **恢复下载**：从断点继续下载，支持 Range 请求
- **取消下载**：取消下载并清理资源
- **重新开始**：在原任务上重新开始，不创建新任务
- **删除下载**：删除下载项和本地文件

### 2. 断点续传
- 使用流式下载（`ResponseType.stream`）手动写入文件
- 所有下载都使用临时文件（`.tmp`），确保暂停时文件不丢失
- 恢复时自动合并临时文件到原文件，只追加新增部分
- 支持 Range 请求头，从指定字节位置继续下载

### 3. 文件处理
- **打开文件**：使用平台通道（Android）或 url_launcher 打开文件
- **安装 APK**：自动识别 APK 文件并触发安装流程
- **文件扩展名**：自动从 URL 补充缺失的扩展名

## 技术实现

### 下载流程

```
开始下载
  ├─ 新下载模式
  │   ├─ 检查是否已有相同任务
  │   ├─ 检查文件是否已存在（询问覆盖）
  │   └─ 创建新下载项
  │
  └─ 恢复下载模式
      ├─ 查找已存在的任务
      ├─ 合并临时文件到原文件（如果有）
      ├─ 计算起始字节（原文件大小）
      └─ 更新任务状态为 downloading

下载执行
  ├─ 创建临时文件（如果不存在）
  ├─ 从原文件复制到临时文件（断点续传）
  ├─ 设置 Range 请求头（断点续传）
  ├─ 流式下载并写入临时文件
  ├─ 实时更新进度
  └─ 下载完成后合并或重命名文件
```

### 关键数据结构

```dart
// 下载项模型
class DownloadItemModel {
  final String id;              // 唯一标识
  final String url;              // 下载 URL
  final String fileName;         // 文件名
  final String savePath;         // 保存路径
  final int? totalBytes;         // 总大小
  final int receivedBytes;       // 已接收大小
  final double progress;         // 进度 0.0-1.0
  final DownloadStatus status;   // 状态
  final DateTime createdAt;     // 创建时间
  final DateTime? completedAt;   // 完成时间
  final String? errorMessage;    // 错误信息
}

// 下载状态
enum DownloadStatus {
  pending,      // 等待中
  downloading,  // 下载中
  paused,      // 已暂停
  completed,   // 已完成
  failed,       // 失败
  cancelled,   // 已取消
}
```

### 文件管理

- **保存目录**：`{临时目录}/downloads/`
- **临时文件**：`{savePath}.tmp`
- **文件命名**：支持自定义文件名，自动补充扩展名

### 状态管理

- **暂停标记**：使用 `_pausedTaskIds` 集合区分暂停和取消
- **取消令牌**：使用 `_cancelTokens` 管理下载请求的取消
- **状态更新**：通过 `downloadItems` 的响应式更新触发 UI 刷新

## 使用示例

### 开始下载

```dart
// 使用 URL 下载
controller.startDownload('https://example.com/file.apk');

// 使用自定义文件名
controller.startDownload(
  'https://example.com/file.apk',
  customFileName: '我的文件.apk',
);
```

### 暂停和恢复

```dart
// 暂停下载
controller.pauseDownload(itemId);

// 恢复下载
controller.resumeDownload(itemId);
```

### 打开文件

```dart
// 打开文件（自动识别 APK 并安装）
controller.openFile(filePath);
```

## 注意事项

1. **文件扩展名**：确保文件名包含扩展名，否则可能无法正确识别文件类型
2. **断点续传**：需要服务器支持 Range 请求
3. **临时文件**：下载过程中使用临时文件，完成后才合并或重命名
4. **资源清理**：页面关闭时自动取消所有正在进行的下载

## 错误处理

- 下载失败时保留临时文件，支持断点续传
- 网络错误、文件系统错误等都会记录到错误日志
- 用户友好的错误提示（通过 `showError` 显示）

## 平台支持

- **Android**：使用平台通道打开文件，支持 FileProvider
- **iOS**：使用 url_launcher 打开文件
- **APK 安装**：仅支持 Android 平台
