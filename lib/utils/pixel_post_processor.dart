import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'color_delta.dart';
import 'merge_intensity.dart';
import 'pixel_subject_mask.dart';

/// 格子区域类型（拼豆图稿：描边 / 交界 / 内部填充）
enum _CellZone {
  outline,
  edge,
  fill,
}

/// 连通色块（后处理分析用）
class _ColorComponent {
  final String code;
  final List<List<int>> cells;
  final int size;

  const _ColorComponent({
    required this.code,
    required this.cells,
  }) : size = cells.length;
}

/// 拼豆网格后处理：Mode 滤波 + 分区连通块合并 + 平坦区相近色压缩
class PixelPostProcessor {
  PixelPostProcessor._();

  static const int _bgFillMergeMaxSize = 48;
  static const int _subjectFillMergeMaxSize = 8;
  static const int _flatSmallMaxSize = 20;
  static const double _edgeMergeThreshold = 3.0;
  static const double _edgeContrastDe = 12.0;

  /// 对 gridCodes 执行后处理（可同步更新预览图）
  static int apply({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required MergeIntensity intensity,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final labCache = _buildLabCache(colorRgbByCode);
    var roles = PixelSubjectMask.compute(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      labCache: labCache,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );
    var total = 0;

    total += _runPassGroup(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      roles: roles,
      intensity: intensity,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
      includeRegionalUnify: true,
    );

    total += _backgroundCleanupPass(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      roles: roles,
      intensity: intensity,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    roles = PixelSubjectMask.compute(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      labCache: labCache,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    // 第二轮：重建分区后再清一遍残余杂色
    final zones2 = _buildZoneGrid(
      gridCodes,
      gridWidth,
      gridHeight,
      labCache,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );
    total += _applyModeFilter(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones2,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      mergeThreshold: _fillMergeThreshold(intensity),
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
      backgroundOnly: true,
    );
    total += _mergeSmallComponents(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones2,
      roles: roles,
      requiredRole: BeadCellRole.background,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      allowedZones: const {_CellZone.fill},
      minSize: 1,
      maxSize: _bgFillMergeMaxSize,
      mergeThreshold: _fillMergeThreshold(intensity) + 2,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );
    total += _compressFlatRegions(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones2,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      similarThreshold: _flatSimilarThreshold(intensity),
      requiredRole: BeadCellRole.background,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    debugPrint('[后处理] 全部完成: 共调整 $total 格');
    return total;
  }

  static int _runPassGroup({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required Map<String, List<double>> labCache,
    required List<BeadCellRole> roles,
    required MergeIntensity intensity,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
    bool includeRegionalUnify = false,
  }) {
    final zones = _buildZoneGrid(
      gridCodes,
      gridWidth,
      gridHeight,
      labCache,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );
    var total = 0;

    total += _applyModeFilter(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      mergeThreshold: intensity.mergeThreshold,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    total += _mergeSmallComponents(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      allowedZones: const {_CellZone.edge},
      minSize: 1,
      maxSize: 3,
      mergeThreshold: _edgeMergeThreshold,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    total += _mergeSmallComponents(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      allowedZones: const {_CellZone.fill, _CellZone.edge},
      minSize: 1,
      maxSize: 1,
      mergeThreshold: intensity.mergeThreshold,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    total += _mergeSmallComponents(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      allowedZones: const {_CellZone.fill, _CellZone.edge},
      minSize: 2,
      maxSize: 5,
      mergeThreshold: intensity.mergeThreshold,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    // 背景 Fill：积极合并
    total += _mergeSmallComponents(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      requiredRole: BeadCellRole.background,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      allowedZones: const {_CellZone.fill},
      minSize: 4,
      maxSize: _bgFillMergeMaxSize,
      mergeThreshold: _fillMergeThreshold(intensity) + 1,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    // 主体 Fill：保守合并
    total += _mergeSmallComponents(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      requiredRole: BeadCellRole.subject,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      allowedZones: const {_CellZone.fill},
      minSize: 6,
      maxSize: _subjectFillMergeMaxSize,
      mergeThreshold: intensity.mergeThreshold,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    total += _compressFlatRegions(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      similarThreshold: _flatSimilarThreshold(intensity),
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    if (includeRegionalUnify) {
      total += _unifyFillRegions(
        gridCodes: gridCodes,
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        zones: zones,
        roles: roles,
        colorRgbByCode: colorRgbByCode,
        labCache: labCache,
        similarThreshold: _flatSimilarThreshold(intensity),
        requiredRole: BeadCellRole.background,
        image: image,
        xGridLines: xGridLines,
        yGridLines: yGridLines,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
    }

    return total;
  }

  static int _backgroundCleanupPass({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required Map<String, List<double>> labCache,
    required List<BeadCellRole> roles,
    required MergeIntensity intensity,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final zones = _buildZoneGrid(
      gridCodes,
      gridWidth,
      gridHeight,
      labCache,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );
    var total = 0;

    total += _applyModeFilter(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      zones: zones,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      mergeThreshold: _fillMergeThreshold(intensity) + 2,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
      backgroundOnly: true,
    );

    total += _capBackgroundPalette(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      roles: roles,
      colorRgbByCode: colorRgbByCode,
      labCache: labCache,
      maxColors: 2,
      similarThreshold: _flatSimilarThreshold(intensity) + 2,
      image: image,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    return total;
  }

  static bool _componentMatchesRole(
    List<List<int>> component,
    List<BeadCellRole> roles,
    int gridWidth,
    BeadCellRole requiredRole,
  ) {
    for (final cell in component) {
      final role = roles[cell[0] * gridWidth + cell[1]];
      if (role != requiredRole) return false;
    }
    return true;
  }

  /// 背景连通域内最多保留 [maxColors] 种珠色
  static int _capBackgroundPalette({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required List<BeadCellRole> roles,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required Map<String, List<double>> labCache,
    required int maxColors,
    required double similarThreshold,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final minRegion = math.max(12, (gridWidth * gridHeight * 0.03).round());
    final visited = List<bool>.filled(gridWidth * gridHeight, false);
    final replacements = <List<dynamic>>[];

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final local = row * gridWidth + col;
        if (visited[local] || roles[local] != BeadCellRole.background) {
          visited[local] = true;
          continue;
        }

        final region = <List<int>>[];
        final queue = <List<int>>[[row, col]];
        visited[local] = true;

        while (queue.isNotEmpty) {
          final cur = queue.removeAt(0);
          region.add(cur);

          for (final dir in const [
            [0, 1],
            [0, -1],
            [1, 0],
            [-1, 0],
          ]) {
            final nr = cur[0] + dir[0];
            final nc = cur[1] + dir[1];
            if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;
            final nLocal = nr * gridWidth + nc;
            if (visited[nLocal]) continue;
            if (roles[nLocal] != BeadCellRole.background) {
              visited[nLocal] = true;
              continue;
            }
            visited[nLocal] = true;
            queue.add([nr, nc]);
          }
        }

        if (region.length < minRegion) continue;

        final counts = <String, int>{};
        for (final cell in region) {
          final code = _codeAt(
            gridCodes,
            cell[0],
            cell[1],
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          );
          if (code.isEmpty) continue;
          counts[code] = (counts[code] ?? 0) + 1;
        }
        if (counts.length <= maxColors) continue;

        final sorted = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final keep = sorted.take(maxColors).map((e) => e.key).toSet();

        for (final cell in region) {
          final code = _codeAt(
            gridCodes,
            cell[0],
            cell[1],
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          );
          if (code.isEmpty || keep.contains(code)) continue;

          String? target;
          var minDe = double.infinity;
          for (final k in keep) {
            final de = ColorDelta.deltaE00BetweenCodes(code, k, labCache);
            if (de < minDe) {
              minDe = de;
              target = k;
            }
          }
          if (target == null || minDe > similarThreshold) continue;
          replacements.add([cell[0], cell[1], target]);
        }
      }
    }

    for (final item in replacements) {
      _paintCell(
        gridCodes,
        item[0] as int,
        item[1] as int,
        item[2] as String,
        gridWidth,
        gridHeight,
        colorRgbByCode,
        image: image,
        xGridLines: xGridLines,
        yGridLines: yGridLines,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
    }

    if (replacements.isNotEmpty) {
      debugPrint('[后处理] 背景色号压缩: ${replacements.length} 格');
    }
    return replacements.length;
  }

  static double _fillMergeThreshold(MergeIntensity intensity) {
    switch (intensity) {
      case MergeIntensity.low:
        return 3.0;
      case MergeIntensity.medium:
        return 8.0;
      case MergeIntensity.high:
        return 10.0;
    }
  }

  static double _flatSimilarThreshold(MergeIntensity intensity) {
    switch (intensity) {
      case MergeIntensity.low:
        return 4.0;
      case MergeIntensity.medium:
        return 6.0;
      case MergeIntensity.high:
        return 8.0;
    }
  }

  static int _modeFilterMinVotes(int gridWidth, int gridHeight) {
    if (gridWidth * gridHeight < 1600) return 4;
    return 5;
  }

  static int _flatRegionMinSize(int gridWidth, int gridHeight) {
    return math.max(15, (gridWidth * gridHeight * 0.025).round());
  }

  /// 预计算每格区域类型
  static List<_CellZone> _buildZoneGrid(
    List<String> gridCodes,
    int gridWidth,
    int gridHeight,
    Map<String, List<double>> labCache, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final zones = List<_CellZone>.filled(gridWidth * gridHeight, _CellZone.fill);

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final code = _codeAt(
          gridCodes,
          row,
          col,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        if (code.isEmpty) continue;

        zones[row * gridWidth + col] = _classifyCell(
          row,
          col,
          code,
          gridCodes,
          gridWidth,
          gridHeight,
          labCache,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
      }
    }
    return zones;
  }

  static _CellZone _classifyCell(
    int row,
    int col,
    String code,
    List<String> gridCodes,
    int gridWidth,
    int gridHeight,
    Map<String, List<double>> labCache, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final selfLab = labCache[code];
    if (selfLab != null && selfLab[0] < 48) {
      var lighterNeighbors = 0;
      for (final dir in const [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ]) {
        final nr = row + dir[0];
        final nc = col + dir[1];
        final nCode = _codeAt(
          gridCodes,
          nr,
          nc,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        if (nCode.isEmpty || nCode == code) continue;
        final nLab = labCache[nCode];
        if (nLab != null && nLab[0] > 55) lighterNeighbors++;
      }
      if (lighterNeighbors >= 1) return _CellZone.outline;
    }

    if (_distinctFourNeighborFills(
          row,
          col,
          code,
          gridCodes,
          gridWidth,
          gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        ) >=
        2) {
      return _CellZone.edge;
    }

    if (selfLab != null) {
      for (final dir in const [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ]) {
        final nr = row + dir[0];
        final nc = col + dir[1];
        final nCode = _codeAt(
          gridCodes,
          nr,
          nc,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        if (nCode.isEmpty || nCode == code) continue;
        final de = ColorDelta.deltaE00BetweenCodes(code, nCode, labCache);
        if (de > _edgeContrastDe) return _CellZone.edge;
      }
    }

    return _CellZone.fill;
  }

  static bool _componentAllowedInZones(
    List<List<int>> component,
    List<_CellZone> zones,
    int gridWidth,
    Set<_CellZone> allowedZones, {
    bool requireAllAllowed = false,
  }) {
    var hasAllowed = false;
    for (final cell in component) {
      final zone = zones[cell[0] * gridWidth + cell[1]];
      if (zone == _CellZone.outline) return false;
      if (!allowedZones.contains(zone)) {
        if (requireAllAllowed) return false;
      } else {
        hasAllowed = true;
      }
    }
    return hasAllowed;
  }

  /// 8 邻域多数票：Fill 区内清单点杂色
  static int _applyModeFilter({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required List<_CellZone> zones,
    required List<BeadCellRole> roles,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required Map<String, List<double>> labCache,
    required double mergeThreshold,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
    bool backgroundOnly = false,
  }) {
    final baseMinVotes = _modeFilterMinVotes(gridWidth, gridHeight);
    final replacements = <List<dynamic>>[];

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final localIndex = row * gridWidth + col;
        if (zones[localIndex] != _CellZone.fill) continue;

        final role = roles[localIndex];
        if (backgroundOnly && role != BeadCellRole.background) continue;
        if (!backgroundOnly && role == BeadCellRole.subject) continue;

        final minVotes = role == BeadCellRole.background
            ? math.max(3, baseMinVotes - 1)
            : baseMinVotes;
        final threshold = role == BeadCellRole.background
            ? mergeThreshold + 1.5
            : mergeThreshold;

        final code = _codeAt(
          gridCodes,
          row,
          col,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        if (code.isEmpty) continue;

        final neighborCounts = <String, int>{};
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = row + dr;
            final nc = col + dc;
            if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;
            if (zones[nr * gridWidth + nc] == _CellZone.outline) continue;

            final nCode = _codeAt(
              gridCodes,
              nr,
              nc,
              gridWidth: gridWidth,
              gridHeight: gridHeight,
              targetGridW: targetGridW,
              offsetX: offsetX,
              offsetY: offsetY,
            );
            if (nCode.isEmpty || nCode == code) continue;
            neighborCounts[nCode] = (neighborCounts[nCode] ?? 0) + 1;
          }
        }

        if (neighborCounts.isEmpty) continue;

        final sorted = neighborCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (final entry in sorted) {
          if (entry.value < minVotes) break;
          final de = ColorDelta.deltaE00BetweenCodes(code, entry.key, labCache);
          if (de <= threshold) {
            replacements.add([row, col, entry.key]);
            break;
          }
        }
      }
    }

    for (final item in replacements) {
      _paintCell(
        gridCodes,
        item[0] as int,
        item[1] as int,
        item[2] as String,
        gridWidth,
        gridHeight,
        colorRgbByCode,
        image: image,
        xGridLines: xGridLines,
        yGridLines: yGridLines,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
    }

    if (replacements.isNotEmpty) {
      debugPrint('[后处理] Mode 滤波: ${replacements.length} 格');
    }
    return replacements.length;
  }

  /// 平坦区：小相近色块并入邻接大色块（肤色/背景杂色压缩）
  static int _compressFlatRegions({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required List<_CellZone> zones,
    required List<BeadCellRole> roles,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required Map<String, List<double>> labCache,
    required double similarThreshold,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
    BeadCellRole? requiredRole,
  }) {
    final flatMinSize = _flatRegionMinSize(gridWidth, gridHeight);
    final components = _findAllColorComponents(
      gridCodes,
      gridWidth,
      gridHeight,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    final largeCodes = <String>{};
    for (final comp in components) {
      if (comp.size >= flatMinSize) largeCodes.add(comp.code);
    }
    if (largeCodes.isEmpty) return 0;

    final replacements = <List<dynamic>>[];

    for (final comp in components) {
      if (comp.size > _flatSmallMaxSize || comp.size < 2) continue;
      if (!_componentAllowedInZones(
        comp.cells,
        zones,
        gridWidth,
        const {_CellZone.fill},
        requireAllAllowed: true,
      )) {
        continue;
      }

      if (requiredRole != null &&
          !_componentMatchesRole(comp.cells, roles, gridWidth, requiredRole)) {
        continue;
      }

      if (_isDetailProtected(
        comp.code,
        comp.cells,
        gridCodes,
        gridWidth,
        gridHeight,
        labCache,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      )) {
        continue;
      }

      final target = _findAdjacentLargeColor(
        comp,
        largeCodes,
        gridCodes,
        gridWidth,
        gridHeight,
        labCache,
        similarThreshold,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
      if (target == null || target == comp.code) continue;

      for (final cell in comp.cells) {
        replacements.add([cell[0], cell[1], target]);
      }
    }

    for (final item in replacements) {
      _paintCell(
        gridCodes,
        item[0] as int,
        item[1] as int,
        item[2] as String,
        gridWidth,
        gridHeight,
        colorRgbByCode,
        image: image,
        xGridLines: xGridLines,
        yGridLines: yGridLines,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
    }

    if (replacements.isNotEmpty) {
      debugPrint('[后处理] 平坦区压缩: ${replacements.length} 格');
    }
    return replacements.length;
  }

  /// Fill 空间区域统一：同一填充区内相近色（肤色/背景渐变）并入区域主色
  static int _unifyFillRegions({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required List<_CellZone> zones,
    required List<BeadCellRole> roles,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required Map<String, List<double>> labCache,
    required double similarThreshold,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
    BeadCellRole? requiredRole,
  }) {
    final minRegionSize = math.max(20, (gridWidth * gridHeight * 0.04).round());
    final visited = List<bool>.filled(gridWidth * gridHeight, false);
    final replacements = <List<dynamic>>[];

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final localIndex = row * gridWidth + col;
        if (visited[localIndex]) continue;
        if (zones[localIndex] != _CellZone.fill) {
          visited[localIndex] = true;
          continue;
        }
        if (requiredRole != null && roles[localIndex] != requiredRole) {
          visited[localIndex] = true;
          continue;
        }

        final regionCells = <List<int>>[];
        final queue = <List<int>>[[row, col]];
        visited[localIndex] = true;

        while (queue.isNotEmpty) {
          final current = queue.removeAt(0);
          regionCells.add(current);

          for (final dir in const [
            [0, 1],
            [0, -1],
            [1, 0],
            [-1, 0],
          ]) {
            final nr = current[0] + dir[0];
            final nc = current[1] + dir[1];
            if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;

            final nLocal = nr * gridWidth + nc;
            if (visited[nLocal]) continue;
            if (zones[nLocal] != _CellZone.fill) {
              visited[nLocal] = true;
              continue;
            }
            if (requiredRole != null && roles[nLocal] != requiredRole) {
              visited[nLocal] = true;
              continue;
            }

            visited[nLocal] = true;
            queue.add([nr, nc]);
          }
        }

        if (regionCells.length < minRegionSize) continue;

        final colorCounts = <String, int>{};
        for (final cell in regionCells) {
          final code = _codeAt(
            gridCodes,
            cell[0],
            cell[1],
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          );
          if (code.isEmpty) continue;
          colorCounts[code] = (colorCounts[code] ?? 0) + 1;
        }
        if (colorCounts.length < 2) continue;

        final sortedColors = colorCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final dominant = sortedColors.first;
        final minDominantShare =
            requiredRole == BeadCellRole.background ? 0.32 : 0.38;
        if (dominant.value / regionCells.length < minDominantShare) continue;

        for (final cell in regionCells) {
          final code = _codeAt(
            gridCodes,
            cell[0],
            cell[1],
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          );
          if (code.isEmpty || code == dominant.key) continue;

          final de = ColorDelta.deltaE00BetweenCodes(code, dominant.key, labCache);
          if (de > similarThreshold) continue;

          if (_isDetailProtected(
            code,
            [cell],
            gridCodes,
            gridWidth,
            gridHeight,
            labCache,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          )) {
            continue;
          }

          replacements.add([cell[0], cell[1], dominant.key]);
        }
      }
    }

    for (final item in replacements) {
      _paintCell(
        gridCodes,
        item[0] as int,
        item[1] as int,
        item[2] as String,
        gridWidth,
        gridHeight,
        colorRgbByCode,
        image: image,
        xGridLines: xGridLines,
        yGridLines: yGridLines,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
    }

    if (replacements.isNotEmpty) {
      debugPrint('[后处理] Fill 区域统一: ${replacements.length} 格');
    }
    return replacements.length;
  }

  static String? _findAdjacentLargeColor(
    _ColorComponent comp,
    Set<String> largeCodes,
    List<String> gridCodes,
    int gridWidth,
    int gridHeight,
    Map<String, List<double>> labCache,
    double similarThreshold, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final compSet = comp.cells.map((c) => '${c[0]},${c[1]}').toSet();
    final adjacency = <String, int>{};
    final bestDe = <String, double>{};

    for (final cell in comp.cells) {
      final row = cell[0];
      final col = cell[1];
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = row + dr;
          final nc = col + dc;
          if (compSet.contains('$nr,$nc')) continue;

          final nCode = _codeAt(
            gridCodes,
            nr,
            nc,
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          );
          if (nCode.isEmpty || nCode == comp.code) continue;
          if (!largeCodes.contains(nCode)) continue;

          final de = ColorDelta.deltaE00BetweenCodes(comp.code, nCode, labCache);
          if (de > similarThreshold) continue;

          adjacency[nCode] = (adjacency[nCode] ?? 0) + 1;
          bestDe[nCode] = math.min(bestDe[nCode] ?? double.infinity, de);
        }
      }
    }

    if (adjacency.isEmpty) return null;

    final sorted = adjacency.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        return (bestDe[a.key] ?? double.infinity)
            .compareTo(bestDe[b.key] ?? double.infinity);
      });

    return sorted.first.key;
  }

  static List<_ColorComponent> _findAllColorComponents(
    List<String> gridCodes,
    int gridWidth,
    int gridHeight, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final visited = List<bool>.filled(gridWidth * gridHeight, false);
    final result = <_ColorComponent>[];

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final localIndex = row * gridWidth + col;
        if (visited[localIndex]) continue;

        final code = _codeAt(
          gridCodes,
          row,
          col,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        if (code.isEmpty) {
          visited[localIndex] = true;
          continue;
        }

        final cells = <List<int>>[];
        final queue = <List<int>>[[row, col]];
        visited[localIndex] = true;

        while (queue.isNotEmpty) {
          final current = queue.removeAt(0);
          cells.add(current);

          for (final dir in const [
            [0, 1],
            [0, -1],
            [1, 0],
            [-1, 0],
          ]) {
            final nr = current[0] + dir[0];
            final nc = current[1] + dir[1];
            if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;

            final nLocal = nr * gridWidth + nc;
            if (visited[nLocal]) continue;

            final nCode = _codeAt(
              gridCodes,
              nr,
              nc,
              gridWidth: gridWidth,
              gridHeight: gridHeight,
              targetGridW: targetGridW,
              offsetX: offsetX,
              offsetY: offsetY,
            );
            if (nCode != code) continue;

            visited[nLocal] = true;
            queue.add([nr, nc]);
          }
        }

        result.add(_ColorComponent(code: code, cells: cells));
      }
    }

    return result;
  }

  static Map<String, List<double>> _buildLabCache(
    Map<String, ({int r, int g, int b})> colorRgbByCode,
  ) {
    final cache = <String, List<double>>{};
    for (final entry in colorRgbByCode.entries) {
      final rgb = entry.value;
      cache[entry.key] = ColorDelta.rgbToLab(rgb.r, rgb.g, rgb.b);
    }
    return cache;
  }

  static int _cellIndex(
    int row,
    int col, {
    required int gridWidth,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final effectiveW = targetGridW > 0 ? targetGridW : gridWidth;
    return (row + offsetY) * effectiveW + (col + offsetX);
  }

  static String _codeAt(
    List<String> gridCodes,
    int row,
    int col, {
    required int gridWidth,
    required int gridHeight,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    if (row < 0 || row >= gridHeight || col < 0 || col >= gridWidth) return '';
    return gridCodes[_cellIndex(
      row,
      col,
      gridWidth: gridWidth,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    )];
  }

  static int _mergeSmallComponents({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required List<_CellZone> zones,
    required List<BeadCellRole> roles,
    required Map<String, ({int r, int g, int b})> colorRgbByCode,
    required Map<String, List<double>> labCache,
    required Set<_CellZone> allowedZones,
    required int minSize,
    required int maxSize,
    required double mergeThreshold,
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
    BeadCellRole? requiredRole,
  }) {
    final visited = List<bool>.filled(gridWidth * gridHeight, false);
    final replacements = <List<dynamic>>[];

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final localIndex = row * gridWidth + col;
        if (visited[localIndex]) continue;

        final code = _codeAt(
          gridCodes,
          row,
          col,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        if (code.isEmpty) {
          visited[localIndex] = true;
          continue;
        }

        final component = <List<int>>[];
        final queue = <List<int>>[[row, col]];
        visited[localIndex] = true;

        while (queue.isNotEmpty) {
          final current = queue.removeAt(0);
          final cr = current[0];
          final cc = current[1];
          component.add(current);

          for (final dir in const [
            [0, 1],
            [0, -1],
            [1, 0],
            [-1, 0],
          ]) {
            final nr = cr + dir[0];
            final nc = cc + dir[1];
            if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;

            final nLocal = nr * gridWidth + nc;
            if (visited[nLocal]) continue;

            final neighborCode = _codeAt(
              gridCodes,
              nr,
              nc,
              gridWidth: gridWidth,
              gridHeight: gridHeight,
              targetGridW: targetGridW,
              offsetX: offsetX,
              offsetY: offsetY,
            );
            if (neighborCode != code) continue;

            visited[nLocal] = true;
            queue.add([nr, nc]);
          }
        }

        final size = component.length;
        if (size < minSize || size > maxSize) continue;

        if (requiredRole != null &&
            !_componentMatchesRole(component, roles, gridWidth, requiredRole)) {
          continue;
        }

        if (!_componentAllowedInZones(
          component,
          zones,
          gridWidth,
          allowedZones,
          requireAllAllowed: allowedZones.length == 1 &&
              allowedZones.contains(_CellZone.fill),
        )) {
          continue;
        }

        if (_isDetailProtected(
          code,
          component,
          gridCodes,
          gridWidth,
          gridHeight,
          labCache,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        )) {
          continue;
        }

        if (_isContourProtected(
          code,
          component,
          gridCodes,
          gridWidth,
          gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        )) {
          continue;
        }

        final replacement = _findBestNeighborReplacement(
          component,
          code,
          gridCodes,
          gridWidth,
          gridHeight,
          labCache,
          mergeThreshold,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );

        if (replacement == null || replacement == code) continue;

        for (final cell in component) {
          replacements.add([cell[0], cell[1], replacement]);
        }
      }
    }

    for (final item in replacements) {
      _paintCell(
        gridCodes,
        item[0] as int,
        item[1] as int,
        item[2] as String,
        gridWidth,
        gridHeight,
        colorRgbByCode,
        image: image,
        xGridLines: xGridLines,
        yGridLines: yGridLines,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
    }

    return replacements.length;
  }

  /// 与周边主色最小 ΔE00 > 20 → 关键细节，不合并
  static bool _isDetailProtected(
    String code,
    List<List<int>> component,
    List<String> gridCodes,
    int gridWidth,
    int gridHeight,
    Map<String, List<double>> labCache, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final selfLab = labCache[code];
    if (selfLab == null) return false;

    final neighborCodes = <String>{};
    final componentSet = component.map((c) => '${c[0]},${c[1]}').toSet();

    for (final cell in component) {
      final row = cell[0];
      final col = cell[1];
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = row + dr;
          final nc = col + dc;
          if (componentSet.contains('$nr,$nc')) continue;

          final ncCode = _codeAt(
            gridCodes,
            nr,
            nc,
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          );
          if (ncCode.isNotEmpty && ncCode != code) {
            neighborCodes.add(ncCode);
          }
        }
      }
    }

    if (neighborCodes.isEmpty) return false;

    var minDe = double.infinity;
    for (final neighbor in neighborCodes) {
      final de = ColorDelta.deltaE00BetweenCodes(code, neighbor, labCache);
      if (de < minDe) minDe = de;
    }

    return minDe > MergeIntensity.detailProtectThreshold;
  }

  /// 轮廓线保护：薄描边/细线色块夹在两种填充色之间时不合并
  static bool _isContourProtected(
    String code,
    List<List<int>> component,
    List<String> gridCodes,
    int gridWidth,
    int gridHeight, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    if (component.length > 3) return false;

    final componentSet = component.map((c) => '${c[0]},${c[1]}').toSet();

    if (component.length <= 2) {
      for (final cell in component) {
        if (_distinctFourNeighborFills(
              cell[0],
              cell[1],
              code,
              gridCodes,
              gridWidth,
              gridHeight,
              targetGridW: targetGridW,
              offsetX: offsetX,
              offsetY: offsetY,
            ) >=
            2) {
          return true;
        }
      }
      return false;
    }

    return _isThinComponent(component) &&
        _externalFillColorCount(
          code,
          component,
          componentSet,
          gridCodes,
          gridWidth,
          gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        ) >=
            2;
  }

  static int _distinctFourNeighborFills(
    int row,
    int col,
    String code,
    List<String> gridCodes,
    int gridWidth,
    int gridHeight, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final neighborFills = <String>{};

    for (final dir in const [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
    ]) {
      final nr = row + dir[0];
      final nc = col + dir[1];

      final neighborCode = _codeAt(
        gridCodes,
        nr,
        nc,
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
      if (neighborCode.isNotEmpty && neighborCode != code) {
        neighborFills.add(neighborCode);
      }
    }

    return neighborFills.length;
  }

  static bool _isThinComponent(List<List<int>> component) {
    var minRow = component.first[0];
    var maxRow = component.first[0];
    var minCol = component.first[1];
    var maxCol = component.first[1];

    for (final cell in component) {
      minRow = math.min(minRow, cell[0]);
      maxRow = math.max(maxRow, cell[0]);
      minCol = math.min(minCol, cell[1]);
      maxCol = math.max(maxCol, cell[1]);
    }

    final h = maxRow - minRow + 1;
    final w = maxCol - minCol + 1;
    final longer = math.max(h, w);
    final shorter = math.min(h, w);
    if (shorter == 0) return false;
    return longer / shorter >= 2.0;
  }

  static int _externalFillColorCount(
    String code,
    List<List<int>> component,
    Set<String> componentSet,
    List<String> gridCodes,
    int gridWidth,
    int gridHeight, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final externalFills = <String>{};

    for (final cell in component) {
      for (final dir in const [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ]) {
        final nr = cell[0] + dir[0];
        final nc = cell[1] + dir[1];
        if (componentSet.contains('$nr,$nc')) continue;

        final neighborCode = _codeAt(
          gridCodes,
          nr,
          nc,
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        if (neighborCode.isNotEmpty && neighborCode != code) {
          externalFills.add(neighborCode);
        }
      }
    }

    return externalFills.length;
  }

  /// 在 8 邻域中找占比最高、且 ΔE00 < mergeThreshold 的主色
  static String? _findBestNeighborReplacement(
    List<List<int>> component,
    String code,
    List<String> gridCodes,
    int gridWidth,
    int gridHeight,
    Map<String, List<double>> labCache,
    double mergeThreshold, {
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final neighborCounts = <String, int>{};
    final componentSet = component.map((c) => '${c[0]},${c[1]}').toSet();

    for (final cell in component) {
      final row = cell[0];
      final col = cell[1];
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = row + dr;
          final nc = col + dc;
          if (componentSet.contains('$nr,$nc')) continue;

          final neighborCode = _codeAt(
            gridCodes,
            nr,
            nc,
            gridWidth: gridWidth,
            gridHeight: gridHeight,
            targetGridW: targetGridW,
            offsetX: offsetX,
            offsetY: offsetY,
          );
          if (neighborCode.isEmpty || neighborCode == code) continue;
          neighborCounts[neighborCode] = (neighborCounts[neighborCode] ?? 0) + 1;
        }
      }
    }

    if (neighborCounts.isEmpty) return null;

    final sorted = neighborCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      final de = ColorDelta.deltaE00BetweenCodes(code, entry.key, labCache);
      if (de <= mergeThreshold) return entry.key;
    }

    return null;
  }

  static void _paintCell(
    List<String> gridCodes,
    int row,
    int col,
    String code,
    int gridWidth,
    int gridHeight,
    Map<String, ({int r, int g, int b})> colorRgbByCode, {
    img.Image? image,
    List<int>? xGridLines,
    List<int>? yGridLines,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final index = _cellIndex(
      row,
      col,
      gridWidth: gridWidth,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );
    gridCodes[index] = code;

    if (image == null || xGridLines == null || yGridLines == null) return;

    final rgb = colorRgbByCode[code];
    if (rgb == null) return;

    final startX = xGridLines[col];
    final startY = yGridLines[row];
    final endX = xGridLines[col + 1];
    final endY = yGridLines[row + 1];

    if (endX > startX && endY > startY) {
      img.fillRect(
        image,
        x1: startX,
        y1: startY,
        x2: endX - 1,
        y2: endY - 1,
        color: img.ColorRgb8(rgb.r, rgb.g, rgb.b),
      );
    }
  }
}
