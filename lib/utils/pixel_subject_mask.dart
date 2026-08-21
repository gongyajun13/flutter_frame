import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'color_delta.dart';

/// 网格格语义角色（启发式主体分割，无需 ML）
enum BeadCellRole {
  /// 主体（人物/动物/前景）
  subject,

  /// 背景（通常与画板边缘连通）
  background,

  /// 主体与背景交界缓冲带
  transition,
}

/// 基于 grid 色号的启发式主体/背景 mask（拼豆人物图常用）
class PixelSubjectMask {
  PixelSubjectMask._();

  static const double _floodExpandDe = 11.0;
  static const double _edgeSeedDe = 14.0;

  /// 从已映射的 bead grid 估计每格角色
  static List<BeadCellRole> compute({
    required List<String> gridCodes,
    required int gridWidth,
    required int gridHeight,
    required Map<String, List<double>> labCache,
    int targetGridW = 0,
    int offsetX = 0,
    int offsetY = 0,
  }) {
    final n = gridWidth * gridHeight;
    final borderReach = List<bool>.filled(n, false);
    final queue = <int>[];

    String? dominantEdgeCode;
    var dominantEdgeCount = 0;
    final edgeCounts = <String, int>{};

    void enqueue(int row, int col) {
      if (row < 0 || row >= gridHeight || col < 0 || col >= gridWidth) return;
      final local = row * gridWidth + col;
      if (borderReach[local]) return;
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
      if (code.isEmpty) return;
      borderReach[local] = true;
      queue.add(local);
      edgeCounts[code] = (edgeCounts[code] ?? 0) + 1;
    }

    for (int col = 0; col < gridWidth; col++) {
      enqueue(0, col);
      enqueue(gridHeight - 1, col);
    }
    for (int row = 0; row < gridHeight; row++) {
      enqueue(row, 0);
      enqueue(row, gridWidth - 1);
    }

    for (final e in edgeCounts.entries) {
      if (e.value > dominantEdgeCount) {
        dominantEdgeCount = e.value;
        dominantEdgeCode = e.key;
      }
    }

    final dominantEdgeLab =
        dominantEdgeCode != null ? labCache[dominantEdgeCode] : null;

    while (queue.isNotEmpty) {
      final local = queue.removeAt(0);
      final row = local ~/ gridWidth;
      final col = local % gridWidth;
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

      for (final dir in const [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ]) {
        final nr = row + dir[0];
        final nc = col + dir[1];
        if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;

        final nLocal = nr * gridWidth + nc;
        if (borderReach[nLocal]) continue;

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
        if (nCode.isEmpty) continue;

        final stepDe = ColorDelta.deltaE00BetweenCodes(code, nCode, labCache);
        if (stepDe > _floodExpandDe) continue;

        var seedOk = true;
        if (dominantEdgeLab != null) {
          final nLab = labCache[nCode];
          if (nLab != null) {
            final toSeed = ColorDelta.deltaE00FromLab(nLab, dominantEdgeLab);
            if (toSeed > _edgeSeedDe) {
              final centerDist = _centerDistance(nr, nc, gridWidth, gridHeight);
              if (centerDist < 0.42) seedOk = false;
            }
          }
        }
        if (!seedOk) continue;

        borderReach[nLocal] = true;
        queue.add(nLocal);
      }
    }

    final roles = List<BeadCellRole>.filled(n, BeadCellRole.subject);
    var bgCount = 0;
    var subCount = 0;

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final local = row * gridWidth + col;
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

        final centerDist = _centerDistance(row, col, gridWidth, gridHeight);
        final reached = borderReach[local];

        if (reached && (centerDist > 0.22 || _isLikelyBackgroundCode(code, labCache))) {
          roles[local] = BeadCellRole.background;
          bgCount++;
        } else {
          roles[local] = BeadCellRole.subject;
          subCount++;
        }
      }
    }

    _markTransitionBand(roles, gridWidth, gridHeight);

    debugPrint(
      '[主体估计] 背景≈$bgCount 主体≈$subCount '
      '(边色${dominantEdgeCode ?? "?"})',
    );
    return roles;
  }

  static bool _isLikelyBackgroundCode(
    String code,
    Map<String, List<double>> labCache,
  ) {
    final lab = labCache[code];
    if (lab == null) return false;
    return lab[0] > 72 || lab[0] < 18;
  }

  static double _centerDistance(int row, int col, int w, int h) {
    final cy = (h - 1) / 2.0;
    final cx = (w - 1) / 2.0;
    final dy = (row - cy).abs() / math.max(cy, 1);
    final dx = (col - cx).abs() / math.max(cx, 1);
    return math.sqrt(dy * dy + dx * dx) / math.sqrt(2);
  }

  static void _markTransitionBand(
    List<BeadCellRole> roles,
    int gridWidth,
    int gridHeight,
  ) {
    final snapshot = List<BeadCellRole>.from(roles);
    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final local = row * gridWidth + col;
        final self = snapshot[local];
        if (self != BeadCellRole.subject && self != BeadCellRole.background) {
          continue;
        }

        for (final dir in const [
          [0, 1],
          [0, -1],
          [1, 0],
          [-1, 0],
        ]) {
          final nr = row + dir[0];
          final nc = col + dir[1];
          if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;
          final other = snapshot[nr * gridWidth + nc];
          if (self != other &&
              (self == BeadCellRole.subject || self == BeadCellRole.background) &&
              (other == BeadCellRole.subject || other == BeadCellRole.background)) {
            roles[local] = BeadCellRole.transition;
            break;
          }
        }
      }
    }
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
    final effectiveW = targetGridW > 0 ? targetGridW : gridWidth;
    return gridCodes[(row + offsetY) * effectiveW + (col + offsetX)];
  }
}
