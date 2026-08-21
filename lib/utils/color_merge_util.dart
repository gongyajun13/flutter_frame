import 'package:flutter/foundation.dart';

import 'color_delta.dart';
import 'merge_intensity.dart';

/// 统一减色/色号合并工具
class ColorMergeUtil {
  ColorMergeUtil._();

  static Map<String, int> countFromGrid(List<String> gridCodes) {
    final counts = <String, int>{};
    for (final code in gridCodes) {
      if (code.isEmpty) continue;
      counts[code] = (counts[code] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, String> buildMergeMapping({
    required Map<String, int> colorCount,
    required Map<String, List<double>> labByCode,
    required int maxColors,
    double diversityThreshold = MergeIntensity.defaultMergeThreshold,
  }) {
    if (maxColors <= 0 || colorCount.length <= maxColors) {
      return {};
    }

    final sortedByFreq = colorCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var anchors = _selectAnchorCodes(
      sortedByFreq,
      labByCode,
      maxColors,
      diversityThreshold,
    );

    if (anchors.length < maxColors) {
      for (final entry in sortedByFreq) {
        if (anchors.length >= maxColors) break;
        anchors.add(entry.key);
      }
    }

    final anchorSet = anchors.toSet();
    var mapping = _mapNonAnchorsToNearest(
      colorCount.keys,
      anchorSet,
      labByCode,
    );

    mapping = _enforceLimitByAreaAsc(
      colorCount: colorCount,
      labByCode: labByCode,
      maxColors: maxColors,
      existingMapping: mapping,
    );

    debugPrint(
      '[色号合并] 锚点${anchorSet.length}个, 合并${mapping.length}种 → 目标≤$maxColors色',
    );
    return mapping;
  }

  static int applyMapping(List<String> gridCodes, Map<String, String> mapping) {
    if (mapping.isEmpty) return 0;
    var count = 0;
    for (int i = 0; i < gridCodes.length; i++) {
      final code = gridCodes[i];
      if (code.isEmpty) continue;
      final target = mapping[code];
      if (target != null && target != code) {
        gridCodes[i] = target;
        count++;
      }
    }
    return count;
  }

  static String resolveCode(String code, Map<String, String> mapping) {
    var current = code;
    final visited = <String>{};
    while (mapping.containsKey(current) && !visited.contains(current)) {
      visited.add(current);
      current = mapping[current]!;
    }
    return current;
  }

  static List<String> _selectAnchorCodes(
    List<MapEntry<String, int>> sortedByFreq,
    Map<String, List<double>> labByCode,
    int maxColors,
    double diversityThreshold,
  ) {
    if (sortedByFreq.length <= maxColors) {
      return sortedByFreq.map((e) => e.key).toList();
    }

    final anchors = <String>[];
    final guaranteedCount = (maxColors * 0.3).ceil().clamp(1, maxColors ~/ 2);
    var guaranteedSelected = 0;

    for (final entry in sortedByFreq) {
      if (anchors.length >= maxColors) break;
      if (!labByCode.containsKey(entry.key)) continue;
      if (anchors.contains(entry.key)) continue;

      if (guaranteedSelected < guaranteedCount) {
        anchors.add(entry.key);
        guaranteedSelected++;
        continue;
      }

      final lab = labByCode[entry.key]!;
      var isDiverse = true;
      for (final anchor in anchors) {
        final anchorLab = labByCode[anchor];
        if (anchorLab == null) continue;
        if (ColorDelta.deltaE00FromLab(lab, anchorLab) < diversityThreshold) {
          isDiverse = false;
          break;
        }
      }
      if (isDiverse) anchors.add(entry.key);
    }

    if (anchors.length < maxColors) {
      for (final entry in sortedByFreq) {
        if (anchors.length >= maxColors) break;
        if (!anchors.contains(entry.key) && labByCode.containsKey(entry.key)) {
          anchors.add(entry.key);
        }
      }
    }

    return anchors;
  }

  static Map<String, String> _mapNonAnchorsToNearest(
    Iterable<String> allCodes,
    Set<String> anchorSet,
    Map<String, List<double>> labByCode,
  ) {
    final mapping = <String, String>{};

    for (final code in allCodes) {
      if (anchorSet.contains(code)) continue;
      final lab = labByCode[code];
      if (lab == null) continue;

      String? bestAnchor;
      var minDe = double.infinity;
      for (final anchor in anchorSet) {
        final anchorLab = labByCode[anchor];
        if (anchorLab == null) continue;
        final de = ColorDelta.deltaE00FromLab(lab, anchorLab);
        if (de < minDe) {
          minDe = de;
          bestAnchor = anchor;
        }
      }
      if (bestAnchor != null) mapping[code] = bestAnchor;
    }

    return mapping;
  }

  static Map<String, String> _enforceLimitByAreaAsc({
    required Map<String, int> colorCount,
    required Map<String, List<double>> labByCode,
    required int maxColors,
    required Map<String, String> existingMapping,
  }) {
    final directMerge = Map<String, String>.from(existingMapping);

    String effectiveCode(String code) => resolveCode(code, directMerge);

    Map<String, int> effectiveCounts() {
      final counts = <String, int>{};
      for (final entry in colorCount.entries) {
        final root = effectiveCode(entry.key);
        counts[root] = (counts[root] ?? 0) + entry.value;
      }
      return counts;
    }

    while (effectiveCounts().length > maxColors) {
      final counts = effectiveCounts();
      final sorted = counts.entries.toList()
        ..sort((a, b) {
          final cmp = a.value.compareTo(b.value);
          return cmp != 0 ? cmp : a.key.compareTo(b.key);
        });

      final victim = sorted.first.key;
      final victimLab = labByCode[victim] ?? _labForEffective(victim, labByCode, directMerge);
      if (victimLab == null) {
        if (sorted.length < 2) break;
        directMerge[victim] = sorted[1].key;
        continue;
      }

      String? nearest;
      var minDe = double.infinity;
      for (final other in counts.keys) {
        if (other == victim) continue;
        final otherLab = labByCode[other] ?? _labForEffective(other, labByCode, directMerge);
        if (otherLab == null) continue;
        final de = ColorDelta.deltaE00FromLab(victimLab, otherLab);
        if (de < minDe) {
          minDe = de;
          nearest = other;
        }
      }
      if (nearest == null) break;

      directMerge[victim] = nearest;
      for (final code in colorCount.keys) {
        if (effectiveCode(code) == victim) {
          directMerge[code] = nearest;
        }
      }
      for (final entry in directMerge.entries.toList()) {
        if (entry.value == victim) {
          directMerge[entry.key] = nearest;
        }
      }
    }

    final result = <String, String>{};
    for (final code in colorCount.keys) {
      final resolved = resolveCode(code, directMerge);
      if (resolved != code) result[code] = resolved;
    }
    return result;
  }

  static List<double>? _labForEffective(
    String code,
    Map<String, List<double>> labByCode,
    Map<String, String> mapping,
  ) {
    if (labByCode.containsKey(code)) return labByCode[code];
    var current = code;
    final visited = <String>{};
    while (mapping.containsKey(current) && !visited.contains(current)) {
      visited.add(current);
      current = mapping[current]!;
    }
    return labByCode[current];
  }
}
