import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_frame/utils/pixelize_util.dart';

/// 本地草稿展示名：本地草稿 + 最后保存时间（如 本地草稿 10:00）
String localDraftDisplayTitle(int updatedAtMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(updatedAtMs);
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '本地草稿 $hh:$mm';
}

/// 草稿未绑定老作品时的默认 beanProjectId
const String kEmptyDraftBeanProjectId = '';

/// 读取草稿绑定的老作品 id（仅用于保存/发布后判断是否删除草稿；不用于打开作品时恢复草稿）
String readDraftBeanProjectId(Map<String, dynamic>? meta) {
  if (meta == null) return kEmptyDraftBeanProjectId;
  final beanId = (meta['beanProjectId'] as String?)?.trim();
  if (beanId != null && beanId.isNotEmpty) return beanId;
  final legacyId = (meta['id'] as String?)?.trim();
  if (legacyId != null && legacyId.isNotEmpty) return legacyId;
  return kEmptyDraftBeanProjectId;
}

/// 是否为自动生成的草稿时间标题
bool isAutoLocalDraftTitle(String? title) {
  if (title == null || title.trim().isEmpty) return false;
  return RegExp(r'^本地草稿 \d{2}:\d{2}$').hasMatch(title.trim());
}

/// 本地草稿摘要（用于 manifest 列表）
class LocalDraftSummary {
  final String id;
  final String title;
  final int createdAt;
  final int updatedAt;
  final int gridWidth;
  final int gridHeight;
  final String? projectId;
  final String? picture;

  const LocalDraftSummary({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.gridWidth,
    required this.gridHeight,
    this.projectId,
    this.picture,
  });

  factory LocalDraftSummary.fromJson(Map<String, dynamic> json) {
    return LocalDraftSummary(
      id: json['id'] as String,
      title: json['title'] as String? ??
          localDraftDisplayTitle(json['updatedAt'] as int? ?? 0),
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
      gridWidth: json['gridWidth'] as int? ?? 0,
      gridHeight: json['gridHeight'] as int? ?? 0,
      projectId: json['projectId'] as String?,
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'gridWidth': gridWidth,
        'gridHeight': gridHeight,
        'projectId': projectId,
        'picture': picture,
      };
}

/// 单草稿本地存储（仅本地，不上传服务端）
class LocalDraftStore {
  LocalDraftStore._();

  static const String draftsDirName = 'drafts';
  static const String manifestFileName = 'manifest.json';
  static const String legacySingleDraftDirName = 'active_draft';

  /// 唯一草稿槽位 ID
  static const String singleDraftId = legacySingleDraftDirName;

  static bool _legacyMigrated = false;
  static bool _singleDraftConsolidated = false;

  /// 生成新草稿 ID（兼容旧调用，始终返回唯一槽位）
  static String generateLocalDraftId() => singleDraftId;

  /// 将 ID 转为安全的目录名
  static String sanitizeDraftId(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return generateLocalDraftId();
    return trimmed.replaceAll(RegExp(r'[^\w\-.]'), '_');
  }

  static Future<Directory> _pixelProjectsRoot() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, PixelizeUtil.projectDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> _draftsRoot() async {
    final dir = Directory(
      p.join((await _pixelProjectsRoot()).path, draftsDirName),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 单份草稿目录：pixel_projects/drafts/{draftId}/
  static Future<Directory> draftDirectory(String draftId) async {
    final safeId = sanitizeDraftId(draftId);
    final dir = Directory(p.join((await _draftsRoot()).path, safeId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> _metaFile(String draftId) async {
    final dir = await draftDirectory(draftId);
    return File(p.join(dir.path, 'meta.json'));
  }

  static Future<File> _manifestFile() async {
    final root = await _draftsRoot();
    return File(p.join(root.path, manifestFileName));
  }

  /// 读取草稿 meta.json
  static Future<Map<String, dynamic>?> readMeta(String draftId) async {
    try {
      final file = await _metaFile(draftId);
      if (!await file.exists()) return null;
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[LocalDraftStore] 读取 meta 失败: $e');
      return null;
    }
  }

  /// 写入草稿 meta.json
  static Future<void> writeMeta(
    String draftId,
    Map<String, dynamic> meta, {
    bool syncWrite = false,
  }) async {
    final file = await _metaFile(draftId);
    final json = jsonEncode(meta);
    if (syncWrite) {
      file.writeAsStringSync(json);
    } else {
      await file.writeAsString(json);
    }
  }

  /// 更新 manifest 中的草稿摘要（仅保留一份）
  static Future<void> upsertManifestEntry(LocalDraftSummary summary) async {
    await _migrateLegacySingleDraftIfNeeded();
    await _consolidateToSingleDraftIfNeeded();

    final normalized = LocalDraftSummary(
      id: singleDraftId,
      title: summary.title,
      createdAt: summary.createdAt,
      updatedAt: summary.updatedAt,
      gridWidth: summary.gridWidth,
      gridHeight: summary.gridHeight,
      projectId: summary.projectId,
      picture: summary.picture,
    );

    final manifest = await _readManifest();
    manifest['drafts'] = [normalized.toJson()];
    await _writeManifest(manifest);
  }

  /// 解析草稿列表可用的本地预览图路径（仅画布缩略图，不用原图占位）
  static Future<String?> resolvePreviewPath(
    String draftId, {
    String? manifestPicture,
  }) async {
    if (manifestPicture != null && manifestPicture.isNotEmpty) {
      if (manifestPicture.startsWith('http')) {
        return manifestPicture;
      }
      if (await File(manifestPicture).exists()) {
        return manifestPicture;
      }
    }

    final meta = await readMeta(draftId);
    final savedThumb = meta?['thumbnailLocalPath'] as String?;
    if (savedThumb != null &&
        savedThumb.isNotEmpty &&
        await File(savedThumb).exists()) {
      return savedThumb;
    }

    final defaultThumb = File(
      p.join((await draftDirectory(draftId)).path, 'thumbnail.png'),
    );
    if (await defaultThumb.exists()) {
      return defaultThumb.path;
    }
    return null;
  }

  /// 列出本地草稿（最多一份）
  static Future<List<LocalDraftSummary>> listSummaries() async {
    await _migrateLegacySingleDraftIfNeeded();
    await _consolidateToSingleDraftIfNeeded();

    if (!await exists(singleDraftId)) {
      final manifest = await _readManifest();
      manifest['drafts'] = <Map<String, dynamic>>[];
      await _writeManifest(manifest);
      return [];
    }

    final meta = await readMeta(singleDraftId);
    if (meta == null) return [];

    final previewPath = await resolvePreviewPath(singleDraftId);
    final updatedAt = meta['updatedAt'] as int? ?? 0;
    final summary = LocalDraftSummary(
      id: singleDraftId,
      title: localDraftDisplayTitle(updatedAt),
      createdAt: meta['createdAt'] as int? ?? 0,
      updatedAt: updatedAt,
      gridWidth: meta['gridWidth'] as int? ?? 0,
      gridHeight: meta['gridHeight'] as int? ?? 0,
      projectId: () {
        final beanId = readDraftBeanProjectId(meta);
        return beanId.isNotEmpty ? beanId : null;
      }(),
      picture: previewPath,
    );

    final manifest = await _readManifest();
    manifest['drafts'] = [summary.toJson()];
    await _writeManifest(manifest);
    return [summary];
  }

  /// 删除单份草稿
  static Future<void> deleteDraft(String draftId) async {
    final safeId = sanitizeDraftId(draftId);
    try {
      final dir = Directory(p.join((await _draftsRoot()).path, safeId));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      final manifest = await _readManifest();
      final drafts = manifest['drafts'] as List<dynamic>;
      manifest['drafts'] = drafts
          .where((e) => (e as Map<String, dynamic>)['id'] != safeId)
          .toList();
      await _writeManifest(manifest);
      debugPrint('[LocalDraftStore] 已删除草稿: $safeId');
    } catch (e) {
      debugPrint('[LocalDraftStore] 删除草稿失败: $e');
    }
  }

  /// 草稿是否存在
  static Future<bool> exists(String draftId) async {
    final file = await _metaFile(draftId);
    return file.exists();
  }

  static Future<Map<String, dynamic>> _readManifest() async {
    final file = await _manifestFile();
    if (!await file.exists()) {
      return {'drafts': <Map<String, dynamic>>[]};
    }
    try {
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      raw.putIfAbsent('drafts', () => <Map<String, dynamic>>[]);
      return raw;
    } catch (_) {
      return {'drafts': <Map<String, dynamic>>[]};
    }
  }

  static Future<void> _writeManifest(Map<String, dynamic> manifest) async {
    final file = await _manifestFile();
    await file.writeAsString(jsonEncode(manifest));
  }

  /// 将多草稿合并为唯一槽位 active_draft（保留最新一份）
  static Future<void> _consolidateToSingleDraftIfNeeded() async {
    if (_singleDraftConsolidated) return;
    _singleDraftConsolidated = true;

    try {
      final root = await _draftsRoot();
      if (!await root.exists()) return;

      final candidates = <_DraftDirCandidate>[];
      await for (final entity in root.list()) {
        if (entity is! Directory) continue;
        final dirId = p.basename(entity.path);
        final metaFile = File(p.join(entity.path, 'meta.json'));
        if (!await metaFile.exists()) {
          await entity.delete(recursive: true);
          continue;
        }

        final raw =
            jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
        candidates.add(
          _DraftDirCandidate(
            dirId: dirId,
            updatedAt: raw['updatedAt'] as int? ?? 0,
            meta: raw,
          ),
        );
      }

      if (candidates.isEmpty) return;

      candidates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final winner = candidates.first;

      final targetDir = await draftDirectory(singleDraftId);
      if (winner.dirId != singleDraftId) {
        await for (final entity in targetDir.list()) {
          await entity.delete(recursive: true);
        }
        final sourceDir = Directory(p.join(root.path, winner.dirId));
        await for (final entity in sourceDir.list()) {
          final name = p.basename(entity.path);
          final dest = p.join(targetDir.path, name);
          if (entity is File) {
            await entity.copy(dest);
          }
        }
        winner.meta['localDraftId'] = singleDraftId;
        await writeMeta(singleDraftId, winner.meta);
      }

      for (final item in candidates) {
        if (item.dirId == singleDraftId) continue;
        final dir = Directory(p.join(root.path, item.dirId));
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      }

      debugPrint('[LocalDraftStore] 已合并为单草稿: $singleDraftId');
    } catch (e) {
      debugPrint('[LocalDraftStore] 合并单草稿失败: $e');
    }
  }

  /// 将旧版单草稿 active_draft 迁移到 drafts 目录
  static Future<void> _migrateLegacySingleDraftIfNeeded() async {
    if (_legacyMigrated) return;
    _legacyMigrated = true;

    try {
      final legacyDir = Directory(
        p.join(
          (await _pixelProjectsRoot()).path,
          legacySingleDraftDirName,
        ),
      );
      if (!await legacyDir.exists()) return;

      final legacyMeta = File(p.join(legacyDir.path, 'meta.json'));
      if (!await legacyMeta.exists()) {
        await legacyDir.delete(recursive: true);
        return;
      }

      final raw =
          jsonDecode(await legacyMeta.readAsString()) as Map<String, dynamic>;
      final draftId = sanitizeDraftId(
        (raw['localDraftId'] as String?)?.isNotEmpty == true
            ? raw['localDraftId'] as String
            : (raw['id'] as String?)?.isNotEmpty == true
                ? raw['id'] as String
                : generateLocalDraftId(),
      );

      final targetDir = await draftDirectory(draftId);
      await for (final entity in legacyDir.list()) {
        final name = p.basename(entity.path);
        final dest = p.join(targetDir.path, name);
        if (entity is File) {
          await entity.copy(dest);
        }
      }

      raw['localDraftId'] = draftId;
      await writeMeta(draftId, raw);

      final mergedUpdatedAt = raw['updatedAt'] as int? ?? 0;
      await upsertManifestEntry(
        LocalDraftSummary(
          id: draftId,
          title: localDraftDisplayTitle(mergedUpdatedAt),
          createdAt: raw['createdAt'] as int? ?? 0,
          updatedAt: mergedUpdatedAt,
          gridWidth: raw['gridWidth'] as int? ?? 0,
          gridHeight: raw['gridHeight'] as int? ?? 0,
          projectId: (raw['id'] as String?)?.isNotEmpty == true
              ? raw['id'] as String
              : null,
          picture: raw['picture'] as String?,
        ),
      );

      await legacyDir.delete(recursive: true);
      debugPrint('[LocalDraftStore] 已迁移旧版单草稿 -> $draftId');
    } catch (e) {
      debugPrint('[LocalDraftStore] 迁移旧草稿失败: $e');
    }
  }
}

class _DraftDirCandidate {
  final String dirId;
  final int updatedAt;
  final Map<String, dynamic> meta;

  const _DraftDirCandidate({
    required this.dirId,
    required this.updatedAt,
    required this.meta,
  });
}
