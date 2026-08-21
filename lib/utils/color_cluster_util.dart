import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'color_delta.dart';

/// 网格块颜色样本（块均色 + 权重）
class BlockColorSample {
  final int gridIndex;
  final int row;
  final int col;
  final double r;
  final double g;
  final double b;
  final int weight;
  final bool isBoundary;

  List<double>? _lab;

  BlockColorSample({
    required this.gridIndex,
    required this.row,
    required this.col,
    required this.r,
    required this.g,
    required this.b,
    this.weight = 1,
    this.isBoundary = false,
  });

  List<double> get lab =>
      _lab ??= ColorDelta.rgbToLab(r.round(), g.round(), b.round());
}

/// 带 RGB 的聚类中心（K-Means 输出）
class ColorClusterCentroid {
  final List<double> lab;
  final double r;
  final double g;
  final double b;

  ColorClusterCentroid({
    required this.lab,
    required this.r,
    required this.g,
    required this.b,
  });
}

/// 合并同珠色簇后的聚类结果
class ClusterBeadMapping {
  final List<ColorClusterCentroid> centroids;
  final List<String> beadCodes;

  const ClusterBeadMapping({
    required this.centroids,
    required this.beadCodes,
  });
}

/// K-Means 输出（中心 + 每样本所属簇）
class KMeansWeightedResult {
  final List<ColorClusterCentroid> centroids;
  final List<int> assignments;

  const KMeansWeightedResult({
    required this.centroids,
    required this.assignments,
  });
}

/// 网格块颜色密度聚类（Lab 空间加权 K-Means）
class ColorClusterUtil {
  ColorClusterUtil._();

  /// 根据 colorLimit 与网格规模确定聚类数 K
  static int resolveClusterCount({
    required int colorLimit,
    required int gridWidth,
    required int gridHeight,
    required int blockCount,
  }) {
    if (blockCount <= 1) return 1;

    if (colorLimit > 0) {
      return colorLimit.clamp(2, blockCount);
    }

    // 无减色限制：按画板面积自适应，避免小图过度合并、大图色号爆炸
    final adaptive = (gridWidth * gridHeight / 25).round().clamp(12, 64);
    return adaptive.clamp(2, blockCount);
  }

  /// 加权 K-Means（Lab 空间；分配用 ΔE76，最终映射仍用 ΔE00）
  static KMeansWeightedResult kMeansWeighted(
    List<BlockColorSample> samples,
    int k, {
    int maxIterations = 20,
  }) {
    if (samples.isEmpty) {
      return const KMeansWeightedResult(centroids: [], assignments: []);
    }
    if (k >= samples.length) {
      return KMeansWeightedResult(
        centroids: samples
            .map(
              (s) => ColorClusterCentroid(
                lab: List<double>.from(s.lab),
                r: s.r,
                g: s.g,
                b: s.b,
              ),
            )
            .toList(),
        assignments: List<int>.generate(samples.length, (i) => i),
      );
    }

    k = k.clamp(1, samples.length);
    var centroids = _initCentroidsKMeansPlusPlus(samples, k);
    final assignments = List<int>.filled(samples.length, 0);

    var gridW = 1;
    var gridH = 1;
    for (final s in samples) {
      gridW = math.max(gridW, s.col + 1);
      gridH = math.max(gridH, s.row + 1);
    }
    var centroidRows = List<double>.filled(k, 0);
    var centroidCols = List<double>.filled(k, 0);
    for (int i = 0; i < k; i++) {
      var bestJ = 0;
      var minDe = double.infinity;
      for (int j = 0; j < samples.length; j++) {
        final de = ColorDelta.deltaE76SqFromLab(centroids[i].lab, samples[j].lab);
        if (de < minDe) {
          minDe = de;
          bestJ = j;
        }
      }
      centroidRows[i] = samples[bestJ].row.toDouble();
      centroidCols[i] = samples[bestJ].col.toDouble();
    }

    const spatialWeight = 2.8;

    for (int iter = 0; iter < maxIterations; iter++) {
      var changed = false;

      for (int i = 0; i < samples.length; i++) {
        final nearest = _nearestCentroidIndexSpatial(
          samples[i],
          centroids,
          centroidRows,
          centroidCols,
          gridW,
          gridH,
          spatialWeight,
        );
        if (assignments[i] != nearest) {
          assignments[i] = nearest;
          changed = true;
        }
      }

      if (!changed && iter > 0) break;

      final recomputed = _recomputeCentroids(
        samples,
        assignments,
        k,
        centroids,
        centroidRows,
        centroidCols,
      );
      centroids = recomputed.centroids;
      centroidRows = recomputed.rows;
      centroidCols = recomputed.cols;
    }

    debugPrint('[聚类] K=$k, 样本${samples.length}个, 中心${centroids.length}个');
    return KMeansWeightedResult(centroids: centroids, assignments: assignments);
  }

  /// 样本到最近聚类中心的索引（ΔE00）
  static int nearestClusterIndex(
    List<double> lab,
    List<ColorClusterCentroid> centroids,
  ) {
    return _nearestCentroidIndex(lab, centroids);
  }

  /// 将映射到同一珠色的多个聚类中心合并为一条（按块权重加权平均）
  static ClusterBeadMapping mergeClustersByBeadCode({
    required List<ColorClusterCentroid> centroids,
    required List<String> beadCodes,
    required List<BlockColorSample> samples,
    List<int>? sampleAssignments,
  }) {
    if (centroids.isEmpty) {
      return const ClusterBeadMapping(centroids: [], beadCodes: []);
    }
    assert(centroids.length == beadCodes.length);

    final clusterWeights = List<double>.filled(centroids.length, 0);
    if (sampleAssignments != null && sampleAssignments.length == samples.length) {
      for (int i = 0; i < samples.length; i++) {
        clusterWeights[sampleAssignments[i]] += samples[i].weight;
      }
    } else {
      for (final sample in samples) {
        final idx = nearestClusterIndex(sample.lab, centroids);
        clusterWeights[idx] += sample.weight;
      }
    }

    final groups = <String, List<int>>{};
    for (int i = 0; i < beadCodes.length; i++) {
      groups.putIfAbsent(beadCodes[i], () => []).add(i);
    }

    final mergedCentroids = <ColorClusterCentroid>[];
    final mergedBeadCodes = <String>[];

    for (final entry in groups.entries) {
      final indices = entry.value;
      var totalW = 0.0;
      var sumL = 0.0;
      var sumA = 0.0;
      var sumB = 0.0;
      var sumR = 0.0;
      var sumG = 0.0;
      var sumBch = 0.0;

      for (final i in indices) {
        final w = clusterWeights[i] > 0 ? clusterWeights[i] : 1.0;
        final c = centroids[i];
        totalW += w;
        sumL += c.lab[0] * w;
        sumA += c.lab[1] * w;
        sumB += c.lab[2] * w;
        sumR += c.r * w;
        sumG += c.g * w;
        sumBch += c.b * w;
      }

      mergedCentroids.add(ColorClusterCentroid(
        lab: [sumL / totalW, sumA / totalW, sumB / totalW],
        r: sumR / totalW,
        g: sumG / totalW,
        b: sumBch / totalW,
      ));
      mergedBeadCodes.add(entry.key);
    }

    if (mergedCentroids.length < centroids.length) {
      debugPrint(
        '[聚类] 同珠色簇合并: ${centroids.length} → ${mergedCentroids.length}',
      );
    }

    return ClusterBeadMapping(
      centroids: mergedCentroids,
      beadCodes: mergedBeadCodes,
    );
  }

  /// 在已定主色号集合中，找与样本块 ΔE00 最近的珠色（禁止跳出集合）
  ///
  /// 主色较少时全量 ΔE00；较多时先用 ΔE76 筛 top-K 再精算 ΔE00，兼顾速度与观感。
  static String nearestMasterBeadCode(
    BlockColorSample sample,
    List<String> masterBeadCodes,
    List<List<double>> masterBeadLabs,
  ) {
    final ranked = _rankMasterCandidates(
      sample.lab,
      masterBeadCodes,
      masterBeadLabs,
    );
    if (ranked.isEmpty) return '';
    return masterBeadCodes[ranked.first.index];
  }

  /// 边界格映射：在 ΔE00 可接受范围内，优先选与邻接填充色对比更大的珠色
  ///
  /// 深色描边（原图近黑 + 邻居偏亮）时优先统一为最暗珠色，避免黑/深灰交织。
  static String nearestMasterBeadCodeWithContrast(
    BlockColorSample sample,
    List<String> masterBeadCodes,
    List<List<double>> masterBeadLabs,
    List<List<double>> neighborFillLabs,
  ) {
    if (neighborFillLabs.length < 2) {
      return nearestMasterBeadCode(sample, masterBeadCodes, masterBeadLabs);
    }

    final darkestOutline = nearestDarkestOutlineBead(
      sample.lab,
      masterBeadCodes,
      masterBeadLabs,
      neighborFillLabs,
    );
    if (darkestOutline != null) return darkestOutline;

    final ranked = _rankMasterCandidates(
      sample.lab,
      masterBeadCodes,
      masterBeadLabs,
    );
    if (ranked.isEmpty) return '';

    final bestDe = ranked.first.de;
    const tolerance = 4.0;

    var bestCode = masterBeadCodes[ranked.first.index];
    var bestContrast = -1.0;

    for (final item in ranked) {
      if (item.de > bestDe + tolerance) break;

      final candLab = masterBeadLabs[item.index];
      var minNeighborDe = double.infinity;
      for (final nLab in neighborFillLabs) {
        final de = ColorDelta.deltaE00FromLab(candLab, nLab);
        if (de < minNeighborDe) minNeighborDe = de;
      }

      if (minNeighborDe > bestContrast) {
        bestContrast = minNeighborDe;
        bestCode = masterBeadCodes[item.index];
      }
    }

    return bestCode;
  }

  /// 深色描边统一：在可接受 ΔE 范围内取最暗珠色，消除黑/深灰交织
  static String? nearestDarkestOutlineBead(
    List<double> sampleLab,
    List<String> masterBeadCodes,
    List<List<double>> masterBeadLabs,
    List<List<double>> neighborFillLabs, {
    double maxOutlineL = 48.0,
    double tolerance = 8.0,
  }) {
    if (neighborFillLabs.isEmpty) return null;

    final avgNeighborL =
        neighborFillLabs.map((l) => l[0]).reduce((a, b) => a + b) /
            neighborFillLabs.length;
    if (sampleLab[0] > 45 || avgNeighborL < 50) return null;

    var minDe = double.infinity;
    for (int i = 0; i < masterBeadLabs.length; i++) {
      if (masterBeadLabs[i][0] > maxOutlineL) continue;
      final de = ColorDelta.deltaE00FromLab(sampleLab, masterBeadLabs[i]);
      if (de < minDe) minDe = de;
    }
    if (minDe == double.infinity) return null;

    String? bestCode;
    var bestL = double.infinity;
    for (int i = 0; i < masterBeadCodes.length; i++) {
      final lab = masterBeadLabs[i];
      if (lab[0] > maxOutlineL) continue;
      final de = ColorDelta.deltaE00FromLab(sampleLab, lab);
      if (de > minDe + tolerance) continue;
      if (lab[0] < bestL) {
        bestL = lab[0];
        bestCode = masterBeadCodes[i];
      }
    }
    return bestCode;
  }

  static List<({int index, double de})> _rankMasterCandidates(
    List<double> sampleLab,
    List<String> masterBeadCodes,
    List<List<double>> masterBeadLabs,
  ) {
    final n = masterBeadCodes.length;
    if (n == 0) return [];
    if (n == 1) return [(index: 0, de: 0.0)];

    final indices = <int>[];

    if (n <= 5) {
      indices.addAll(List.generate(n, (i) => i));
    } else {
      const topK = 5;
      final topIndices = List<int>.filled(topK, 0);
      final topDistSq = List<double>.filled(topK, double.infinity);

      for (int i = 0; i < n; i++) {
        final d76 = ColorDelta.deltaE76SqFromLab(sampleLab, masterBeadLabs[i]);
        for (int k = 0; k < topK; k++) {
          if (d76 < topDistSq[k]) {
            for (int j = topK - 1; j > k; j--) {
              topIndices[j] = topIndices[j - 1];
              topDistSq[j] = topDistSq[j - 1];
            }
            topIndices[k] = i;
            topDistSq[k] = d76;
            break;
          }
        }
      }
      indices.addAll(topIndices);
    }

    final ranked = <({int index, double de})>[];
    for (final idx in indices) {
      ranked.add((
        index: idx,
        de: ColorDelta.deltaE00FromLab(sampleLab, masterBeadLabs[idx]),
      ));
    }
    ranked.sort((a, b) => a.de.compareTo(b.de));
    return ranked;
  }

  static List<ColorClusterCentroid> _initCentroidsKMeansPlusPlus(
    List<BlockColorSample> samples,
    int k,
  ) {
    final rng = math.Random(42);
    final centroids = <ColorClusterCentroid>[];
    var firstIdx = 0;
    var maxW = samples.first.weight;
    for (int i = 1; i < samples.length; i++) {
      if (samples[i].weight > maxW) {
        maxW = samples[i].weight;
        firstIdx = i;
      }
    }
    final first = samples[firstIdx];
    centroids.add(ColorClusterCentroid(
      lab: List<double>.from(first.lab),
      r: first.r,
      g: first.g,
      b: first.b,
    ));

    final distances = List<double>.filled(samples.length, double.infinity);

    for (int c = 1; c < k; c++) {
      var distSum = 0.0;
      for (int i = 0; i < samples.length; i++) {
        final d = ColorDelta.deltaE76SqFromLab(samples[i].lab, centroids.last.lab);
        if (d < distances[i]) distances[i] = d;
        distSum += distances[i] * samples[i].weight;
      }

      if (distSum <= 0) {
        // 退化：随机选未覆盖样本
        final idx = rng.nextInt(samples.length);
        final s = samples[idx];
        centroids.add(ColorClusterCentroid(
          lab: List<double>.from(s.lab),
          r: s.r,
          g: s.g,
          b: s.b,
        ));
        continue;
      }

      var pick = rng.nextDouble() * distSum;
      var chosen = 0;
      for (int i = 0; i < samples.length; i++) {
        pick -= distances[i] * samples[i].weight;
        if (pick <= 0) {
          chosen = i;
          break;
        }
      }
      final s = samples[chosen];
      centroids.add(ColorClusterCentroid(
        lab: List<double>.from(s.lab),
        r: s.r,
        g: s.g,
        b: s.b,
      ));
    }

    return centroids;
  }

  static int _nearestCentroidIndex(
    List<double> lab,
    List<ColorClusterCentroid> centroids,
  ) {
    return _nearestCentroidIndexSpatial(
      null,
      centroids,
      const [],
      const [],
      1,
      1,
      0,
      labOverride: lab,
    );
  }

  /// 颜色 + 空间距离联合选簇（相近色优先归入空间相邻簇，减少渐变区杂色）
  static int _nearestCentroidIndexSpatial(
    BlockColorSample? sample,
    List<ColorClusterCentroid> centroids,
    List<double> centroidRows,
    List<double> centroidCols,
    int gridW,
    int gridH,
    double spatialWeight, {
    List<double>? labOverride,
  }) {
    final lab = labOverride ?? sample!.lab;
    var best = 0;
    var minCost = double.infinity;
    for (int i = 0; i < centroids.length; i++) {
      final colorCost = ColorDelta.deltaE76SqFromLab(lab, centroids[i].lab);
      var cost = colorCost;
      if (sample != null && spatialWeight > 0 && centroidRows.length > i) {
        final dr = (sample.row - centroidRows[i]) / gridH;
        final dc = (sample.col - centroidCols[i]) / gridW;
        cost += spatialWeight * (dr * dr + dc * dc) * 120;
      }
      if (cost < minCost) {
        minCost = cost;
        best = i;
      }
    }
    return best;
  }

  static ({List<ColorClusterCentroid> centroids, List<double> rows, List<double> cols})
      _recomputeCentroids(
    List<BlockColorSample> samples,
    List<int> assignments,
    int k,
    List<ColorClusterCentroid> prevCentroids,
    List<double> prevRows,
    List<double> prevCols,
  ) {
    final sumL = List<double>.filled(k, 0);
    final sumA = List<double>.filled(k, 0);
    final sumB = List<double>.filled(k, 0);
    final sumR = List<double>.filled(k, 0);
    final sumG = List<double>.filled(k, 0);
    final sumBch = List<double>.filled(k, 0);
    final sumRow = List<double>.filled(k, 0);
    final sumCol = List<double>.filled(k, 0);
    final weights = List<double>.filled(k, 0);

    for (int i = 0; i < samples.length; i++) {
      final c = assignments[i];
      final w = samples[i].weight.toDouble();
      weights[c] += w;
      sumL[c] += samples[i].lab[0] * w;
      sumA[c] += samples[i].lab[1] * w;
      sumB[c] += samples[i].lab[2] * w;
      sumR[c] += samples[i].r * w;
      sumG[c] += samples[i].g * w;
      sumBch[c] += samples[i].b * w;
      sumRow[c] += samples[i].row * w;
      sumCol[c] += samples[i].col * w;
    }

    final result = <ColorClusterCentroid>[];
    final rows = List<double>.filled(k, 0);
    final cols = List<double>.filled(k, 0);
    for (int c = 0; c < k; c++) {
      if (weights[c] > 0) {
        result.add(ColorClusterCentroid(
          lab: [sumL[c] / weights[c], sumA[c] / weights[c], sumB[c] / weights[c]],
          r: sumR[c] / weights[c],
          g: sumG[c] / weights[c],
          b: sumBch[c] / weights[c],
        ));
        rows[c] = sumRow[c] / weights[c];
        cols[c] = sumCol[c] / weights[c];
      } else {
        result.add(prevCentroids[c]);
        rows[c] = prevRows[c];
        cols[c] = prevCols[c];
      }
    }
    return (centroids: result, rows: rows, cols: cols);
  }
}
