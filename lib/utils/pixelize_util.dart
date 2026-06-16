import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// 像素化分割枚举
enum GridSize {
  size16x16(16, 16, '16×16'),
  size32x32(32, 32, '32×32'),
  size52x52(52, 52, '52×52'),
  size52x104(52, 104, '52×104'),
  size104x52(104, 52, '104×52'),
  size104x104(104, 104, '104×104');

  final int width;
  final int height;
  final String label;

  const GridSize(this.width, this.height, this.label);
}

/// 颜色库枚举
enum BeadBrand {
  mard('assets/mard_colors.json', 'MARD拼豆', 291, 'mard'),
  artkal('assets/artkal_colors.json', 'ARTKAL拼豆', 159, 'artkal'),
  coco('assets/Coco_colors.json', 'Coco', 221, 'coco'),
  dmc('assets/DMC_colors.json', 'DMC', 436, 'dmc'),
  panpan('assets/盼盼拼豆_colors.json', '盼盼拼豆', 221, 'panpan'),
  kaka('assets/卡卡家_colors.json', '卡卡家', 283, 'kaka'),
  manman('assets/漫漫家_colors.json', '漫漫家', 219, 'manman'),
  hama('assets/hama_colors.json', 'HAMA拼豆', 53, 'hama'),
  perler('assets/perler_colors.json', 'Perler拼豆', 51, 'perler');

  final String jsonPath;
  final String displayName;
  final int totalColors;
  final String key; // 唯一标识符，用于持久化存储

  const BeadBrand(this.jsonPath, this.displayName, this.totalColors, this.key);

  /// 根据 key 查找品牌，找不到返回默认品牌
  static BeadBrand fromKey(String key) {
    return BeadBrand.values.firstWhere(
      (brand) => brand.key == key,
      orElse: () => BeadBrand.mard,
    );
  }
}

/// 颜色限制枚举（limit 为 -1 表示使用全部颜色）
enum ColorLimit {
  unlimited(-1, '全部'),
  max128(128, '最多128色'),
  max64(64, '最多64色'),
  max32(32, '最多32色'),
  max16(16, '最多16色'),
  max8(8, '最多8色');

  final int limit;
  final String label;

  const ColorLimit(this.limit, this.label);

  /// 根据 limit 值查找，找不到返回默认值
  static ColorLimit fromLimit(int limit) {
    return ColorLimit.values.firstWhere(
      (c) => c.limit == limit,
      orElse: () => ColorLimit.unlimited,
    );
  }
}

/// 颜色类（用于 isolate）
class _Color {
  final double r;
  final double g;
  final double b;

  const _Color({
    required this.r,
    required this.g,
    required this.b,
  });
}

/// 珠子颜色类（用于 isolate）
class _BeadColor {
  final int r;
  final int g;
  final int b;
  final String code;
  List<double>? _lab; // CIE Lab 值懒缓存

   _BeadColor({
    required this.r,
    required this.g,
    required this.b,
    required this.code,
  });

  /// 获取 CIE Lab 值（首次调用时计算并缓存，后续直接返回）
  List<double> get lab => _lab ??= _rgbToLab(r, g, b);

  /// 从十六进制颜色值创建珠子颜色
  factory _BeadColor.fromHex(String hex, String code) {
    // 去掉 # 号
    final hexValue = hex.replaceAll('#', '');

    // 解析 RGB
    final r = int.parse(hexValue.substring(0, 2), radix: 16);
    final g = int.parse(hexValue.substring(2, 4), radix: 16);
    final b = int.parse(hexValue.substring(4, 6), radix: 16);

    return _BeadColor(r: r, g: g, b: b, code: code);
  }
}

/// AI生图非正方形网格适配模式
enum AiGridFitMode {
  /// 不做特殊处理（默认，本地裁剪/文件上传等场景）
  none,
  /// 保持原网格尺寸，正方形内容居中放置（如52×102画板中居中显示52×52）
  center,
  /// 直接将网格改为正方形（如52×102→52×52，整个画布都是内容）
  resizeToSquare,
}

/// Isolate 参数类
class _PixelizeParams {
  final Uint8List imageBytes;
  final int gridWidth;
  final int gridHeight;
  final List<_BeadColor> beadColors;
  final Map<String, _BeadColor> beadColorMap;
  final int colorLimit;
  final String brandSuffix;

  /// AI生图非正方形网格适配模式，默认 none
  final AiGridFitMode aiGridFitMode;

  _PixelizeParams({
    required this.imageBytes,
    required this.gridWidth,
    required this.gridHeight,
    required this.beadColors,
    required this.beadColorMap,
    required this.colorLimit,
    required this.brandSuffix,
    this.aiGridFitMode = AiGridFitMode.none,
  });
}

/// 计算颜色的饱和度 (0.0 - 1.0)
double _getSaturation(int r, int g, int b) {
  final max = [r, g, b].reduce((a, b) => a > b ? a : b).toDouble();
  final min = [r, g, b].reduce((a, b) => a < b ? a : b).toDouble();
  if (max == 0) return 0;
  return (max - min) / max;
}

/// RGB → CIE Lab 色彩空间转换（用于感知相似度计算）
///
/// CIE Lab 将颜色分解为 L（亮度）、a（红-绿轴）、b（蓝-黄轴），
/// 在此空间中的欧氏距离（Delta E 76）与人眼感知高度一致。
List<double> _rgbToLab(int r, int g, int b) {
  // Step 1: sRGB → 线性 RGB（gamma 解压）
  double fn(num c) {
    final s = c / 255.0;
    return (s > 0.04045 ? pow((s + 0.055) / 1.055, 2.4) : s / 12.92).toDouble();
  }
  final rL = fn(r), gL = fn(g), bL = fn(b);

  // Step 2: 线性 RGB → XYZ（sRGB 标准 illuminant D65）
  final x = rL * 0.4124 + gL * 0.3576 + bL * 0.1805;
  final y = rL * 0.2126 + gL * 0.7152 + bL * 0.0722;
  final z = rL * 0.0193 + gL * 0.1192 + bL * 0.9505;

  // Step 3: XYZ → Lab
  double f(num t) => (t > 0.008856 ? pow(t, 1 / 3) : t * 7.787 + 16 / 116).toDouble();
  final fx = f(x / 0.95047);
  final fy = f(y / 1.00000);
  final fz = f(z / 1.08883);

  return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
}

/// 计算两个颜色的 CIE Lab Delta E 76 距离（感知色彩差异）
/// 返回值越小表示颜色越接近，与人眼感知高度一致
/// 注意：在核心流程中优先使用 _labDistFromValues + _BeadColor.lab 缓存以避免重复计算
double _labDeltaE(int r1, int g1, int b1, int r2, int g2, int b2) {
  final lab1 = _rgbToLab(r1, g1, b1);
  final lab2 = _rgbToLab(r2, g2, b2);
  return _labDistFromValues(lab1, lab2);
}

/// 从已计算的 CIE Lab 值直接计算 Delta E（避免重复转换）
double _labDistFromValues(List<double> lab1, List<double> lab2) {
  final dL = lab1[0] - lab2[0];
  final da = lab1[1] - lab2[1];
  final db = lab1[2] - lab2[2];
  return dL * dL + da * da + db * db; // 返回平方值用于比较，避免 sqrt 开销
}

/// 计算两个颜色之间的加权欧几里得距离
/// 使用感知权重 + 饱和度惩罚，避免模糊区域映射到偏灰颜色
@Deprecated('建议使用 _labDeltaE (CIE Lab Delta E) 替代，感知一致性更好')
double _colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
  final dr = r1 - r2;
  final dg = g1 - g2;
  final db = b1 - b2;
  // 感知加权：红色*2, 绿色*4, 蓝色*3
  double distance = (2.0 * dr * dr + 4.0 * dg * dg + 3.0 * db * db);

  // 计算饱和度
  final sat1 = _getSaturation(r1, g1, b1);
  final sat2 = _getSaturation(r2, g2, b2);
  
  // 饱和度差异惩罚
  // 当原图颜色有较高饱和度时，如果候选颜色饱和度低（偏灰），增加惩罚
  if (sat1 > 0.15 && sat2 < sat1) {
    // 原图有色，候选偏灰，增加惩罚
    final satPenalty = (sat1 - sat2) * 8000; // 惩罚系数
    distance += satPenalty;
  }
  
  // 如果原图是低饱和度（灰色区域），候选也是低饱和度时，稍微降低惩罚
  // 这样可以避免灰色区域被强制匹配到有色颜色
  if (sat1 < 0.1 && sat2 < 0.1) {
    distance *= 0.8; // 减少距离，允许匹配灰色
  }

  return distance;
}

/// 计算网格格在 gridCodes 中的索引（支持居中适配偏移）
int _gridCellIndex(
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

/// 将单个网格格的颜色写回 gridCodes 并同步预览图
void _paintGridCell(
  List<String> gridCodes,
  int row,
  int col,
  String code,
  int gridWidth,
  int gridHeight,
  img.Image image,
  List<int> xGridLines,
  List<int> yGridLines,
  Map<String, _BeadColor> beadColorMap, {
  int targetGridW = 0,
  int offsetX = 0,
  int offsetY = 0,
}) {
  final index = _gridCellIndex(
    row,
    col,
    gridWidth: gridWidth,
    targetGridW: targetGridW,
    offsetX: offsetX,
    offsetY: offsetY,
  );
  gridCodes[index] = code;

  final beadColor = beadColorMap[code];
  if (beadColor == null) return;

  final startX = xGridLines[col];
  final startY = yGridLines[row];
  final endX = xGridLines[col + 1];
  final endY = yGridLines[row + 1];

  for (int y = startY; y < endY; y++) {
    for (int x = startX; x < endX; x++) {
      image.setPixelRgba(x, y, beadColor.r, beadColor.g, beadColor.b, 255);
    }
  }
}

/// 空间平滑：清除 3×3 邻域中的孤立杂色格
///
/// 当当前格色号在 8 邻居中同名出现 ≤1 次，且存在足够强的邻居主流色时，替换为主流色。
/// 边缘/角落格按有效邻居数自适应降低主流色阈值。
void _applySpatialSmoothing(
  List<String> gridCodes,
  int gridWidth,
  int gridHeight,
  img.Image image,
  List<int> xGridLines,
  List<int> yGridLines,
  Map<String, _BeadColor> beadColorMap, {
  int targetGridW = 0,
  int offsetX = 0,
  int offsetY = 0,
}) {
  String codeAt(int row, int col) {
    if (row < 0 || row >= gridHeight || col < 0 || col >= gridWidth) {
      return '';
    }
    return gridCodes[_gridCellIndex(
      row,
      col,
      gridWidth: gridWidth,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    )];
  }

  final replacements = <List<dynamic>>[];

  for (int row = 0; row < gridHeight; row++) {
    for (int col = 0; col < gridWidth; col++) {
      final current = codeAt(row, col);
      if (current.isEmpty) continue;

      final neighborCounts = <String, int>{};
      var validNeighbors = 0;

      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nc = codeAt(row + dr, col + dc);
          if (nc.isEmpty) continue;
          validNeighbors++;
          neighborCounts[nc] = (neighborCounts[nc] ?? 0) + 1;
        }
      }

      if (validNeighbors < 3) continue;

      String? majorityCode;
      var majorityCount = 0;
      for (final entry in neighborCounts.entries) {
        if (entry.value > majorityCount) {
          majorityCount = entry.value;
          majorityCode = entry.key;
        }
      }

      if (majorityCode == null || majorityCode == current) continue;

      final sameAmongNeighbors = neighborCounts[current] ?? 0;
      final requiredMajority = validNeighbors >= 6
          ? 5
          : validNeighbors >= 4
              ? 3
              : 2;

      if (sameAmongNeighbors <= 1 && majorityCount >= requiredMajority) {
        replacements.add([row, col, majorityCode]);
      }
    }
  }

  for (final item in replacements) {
    _paintGridCell(
      gridCodes,
      item[0] as int,
      item[1] as int,
      item[2] as String,
      gridWidth,
      gridHeight,
      image,
      xGridLines,
      yGridLines,
      beadColorMap,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }

  debugPrint('[空间平滑] 清除孤立杂色格: ${replacements.length}');
}

/// Isolate 返回结果类
class _PixelizeResult {
  final Uint8List pixelizedBytes;
  final String filename;
  final List<String> pixelCodes; // 每个像素的颜色code（按行优先顺序）
  final int actualGridWidth; // 实际处理的网格宽度（resizeToSquare等模式可能不同于入参）
  final int actualGridHeight; // 实际处理的网格高度

  _PixelizeResult({
    required this.pixelizedBytes,
    required this.filename,
    required this.pixelCodes,
    required this.actualGridWidth,
    required this.actualGridHeight,
  });
}

/// 移除噪点颜色（优化版 v2）
/// 特性：
/// 1. CIE Lab 颜色相似性：使用 Delta E 76 感知距离，与品牌切换/减色保持一致
/// 2. 中心保护：中心区域阈值更高（更宽容），保护主体细节不被误删
/// 3. 边缘激进：边缘区域阈值更低（更严格），清理背景散落噪点
/// 4. 替换色缓存：每种噪点色只做一次全局搜索，避免重复计算
/// 5. 迭代处理：处理新产生的孤立噪点
void _removeNoiseColors(
  List<String> gridCodes,
  int gridWidth,
  int gridHeight,
  Map<String, int> colorFrequency,
  img.Image image,
  List<int> xGridLines,
  List<int> yGridLines,
  Map<String, _BeadColor> beadColorMap, {
  bool isSmallGrid = false,
  int targetGridW = 0, // 完整目标网格宽（用于居中适配场景）
  int offsetX = 0,
  int offsetY = 0,
}) {
  final totalBlocks = gridWidth * gridHeight;
  final centerRow = gridHeight / 2;
  final centerCol = gridWidth / 2;
  final maxDistance = sqrt(centerRow * centerRow + centerCol * centerCol);

  // 基础噪点阈值：根据网格大小动态调整
  int baseThreshold;
  if (isSmallGrid) {
    baseThreshold = (totalBlocks * 0.001).ceil().clamp(1, 3);
  } else {
    baseThreshold = (totalBlocks * 0.003).ceil().clamp(2, 10);
  }

  int totalProcessed = 0;
  int iteration = 0;
  const maxIterations = 5;

  // 迭代处理，直到没有新噪点产生
  while (iteration < maxIterations) {
    iteration++;
    int processedThisRound = 0;

    // 重新统计颜色频率
    colorFrequency.clear();
    for (final code in gridCodes) {
      if (code.isNotEmpty) {
        colorFrequency[code] = (colorFrequency[code] ?? 0) + 1;
      }
    }

    // 找出当前迭代的噪点颜色（使用动态阈值）
    final noiseColors = <String>{};
    for (final entry in colorFrequency.entries) {
      // 基础阈值检查
      if (entry.value <= baseThreshold) {
        noiseColors.add(entry.key);
      }
    }

    if (noiseColors.isEmpty) break;

    debugPrint('[噪点过滤] 第$iteration轮，发现 ${noiseColors.length} 种噪点颜色（基础阈值: $baseThreshold）');

    // [P4] CIE Lab 预计算缓存：本轮涉及的所有颜色只转换一次，避免重复 gamma/cube-root 计算
    final labCache = <String, List<double>>{};
    for (final code in colorFrequency.keys) {
      final bc = beadColorMap[code];
      if (bc != null) {
        labCache[code] = _rgbToLab(bc.r, bc.g, bc.b);
      }
    }

    // 距离辅助函数：从预计算的 Lab 值直接算 Delta E（跳过重复的 RGB→Lab 转换）
    double labDist(String codeA, String codeB) {
      final labA = labCache[codeA];
      final labB = labCache[codeB];
      if (labA == null || labB == null) return double.infinity;
      final dL = labA[0] - labB[0];
      final da = labA[1] - labB[1];
      final db = labA[2] - labB[2];
      return dL * dL + da * da + db * db;
    }

    // [P1] 噪点色 → 最佳替换色 缓存（避免同一种噪点色的所有像素重复全局搜索）
    final noiseReplaceCache = <String, String>{};

    // 处理每个噪点块
    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        // 居中适配时，映射到完整目标网格的索引
        final effectiveW = targetGridW > 0 ? targetGridW : gridWidth;
        final index = (row + offsetY) * effectiveW + (col + offsetX);
        final currentCode = gridCodes[index];

        if (!noiseColors.contains(currentCode)) continue;

        // 计算中心距离因子（0-1，中心为1，边缘为0）
        final distanceFromCenter = sqrt(
          (row - centerRow) * (row - centerRow) +
          (col - centerCol) * (col - centerCol)
        );
        final centerFactor = 1.0 - (distanceFromCenter / maxDistance);

        // [P2 修复] 动态阈值：中心保护（阈值更高→更宽容），边缘激进（阈值更低→更严格）
        //
        //   位置     | centerFactor | localThreshold         | 效果
        //   ----------|-------------|------------------------|-------------
        //   中心(~1.0)| ~1.0        | baseThreshold × 2.0   | 需要更多出现次数才保留（保护细节）
        //   边缘(~0.0)| ~0.0        | baseThreshold × 1.0   | 少量出现即被清除（激进清理）
        final localThreshold = (baseThreshold * (1.0 + centerFactor)).ceil();

        // 检查当前块是否超过动态阈值（中心区域可能不被视为噪点）
        if (colorFrequency[currentCode]! > localThreshold) {
          continue; // 中心区域保护，跳过
        }

        // 获取当前噪点颜色对象
        final currentColor = beadColorMap[currentCode];
        if (currentColor == null) continue;

        // [P1] 先查缓存：同种噪点色已找到过最佳替换色则直接复用
        final cached = noiseReplaceCache[currentCode];
        if (cached != null) {
          final newColor = beadColorMap[cached];
          if (newColor != null) {
            gridCodes[index] = cached;
            // 更新图片
            final startX = xGridLines[col];
            final startY = yGridLines[row];
            final endX = xGridLines[col + 1];
            final endY = yGridLines[row + 1];
            for (int y = startY; y < endY; y++) {
              for (int x = startX; x < endX; x++) {
                image.setPixelRgba(x, y, newColor.r, newColor.g, newColor.b, 255);
              }
            }
            processedThisRound++;
            continue;
          }
        }

        // 未命中缓存，执行三级查找（使用 CIE Lab Delta E 距离）
        String? bestReplacement;
        double minColorDistance = double.infinity;

        // 第一优先：相邻非噪点颜色中颜色最接近的
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = row + dr;
            final nc = col + dc;
            if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;

            final neighborIndex = _gridCellIndex(
              nr,
              nc,
              gridWidth: gridWidth,
              targetGridW: targetGridW,
              offsetX: offsetX,
              offsetY: offsetY,
            );
            final neighborCode = gridCodes[neighborIndex];
            if (neighborCode.isEmpty || noiseColors.contains(neighborCode)) continue;

            final neighborColor = beadColorMap[neighborCode];
            if (neighborColor == null) continue;

            // [P0/P4] 使用预计算 CIE Lab Delta E（避免重复 RGB→Lab 转换）
            final distance = labDist(currentCode, neighborCode);

            if (distance < minColorDistance) {
              minColorDistance = distance;
              bestReplacement = neighborCode;
            }
          }
        }

        // 第二优先：如果周围全是噪点，扩大搜索范围到5x5
        if (bestReplacement == null) {
          for (int dr = -2; dr <= 2; dr++) {
            for (int dc = -2; dc <= 2; dc++) {
              if (dr == 0 && dc == 0) continue;
              if (dr.abs() == 1 && dc.abs() == 1) continue; // 已搜索过
              final nr = row + dr;
              final nc = col + dc;
              if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;

              final neighborIndex = _gridCellIndex(
                nr,
                nc,
                gridWidth: gridWidth,
                targetGridW: targetGridW,
                offsetX: offsetX,
                offsetY: offsetY,
              );
              final neighborCode = gridCodes[neighborIndex];
              if (neighborCode.isEmpty || noiseColors.contains(neighborCode)) continue;

              final neighborColor = beadColorMap[neighborCode];
              if (neighborColor == null) continue;

              final distance = labDist(currentCode, neighborCode);

              if (distance < minColorDistance) {
                minColorDistance = distance;
                bestReplacement = neighborCode;
              }
            }
          }
        }

        // 第三优先：如果仍然没找到，选择全局颜色最接近的非噪点颜色
        if (bestReplacement == null) {
          for (final entry in colorFrequency.entries) {
            if (noiseColors.contains(entry.key)) continue;
            final candidateColor = beadColorMap[entry.key];
            if (candidateColor == null) continue;

            final distance = labDist(currentCode, entry.key);

            if (distance < minColorDistance) {
              minColorDistance = distance;
              bestReplacement = entry.key;
            }
          }
        }

        if (bestReplacement == null) continue;

        // [P1] 写入缓存，供后续同种噪点色像素直接复用
        noiseReplaceCache[currentCode] = bestReplacement;

        final newColor = beadColorMap[bestReplacement];
        if (newColor == null) continue;

        // 更新 gridCodes
        gridCodes[index] = bestReplacement;

        // 更新图片
        final startX = xGridLines[col];
        final startY = yGridLines[row];
        final endX = xGridLines[col + 1];
        final endY = yGridLines[row + 1];

        for (int y = startY; y < endY; y++) {
          for (int x = startX; x < endX; x++) {
            image.setPixelRgba(x, y, newColor.r, newColor.g, newColor.b, 255);
          }
        }

        processedThisRound++;
      }
    }

    totalProcessed += processedThisRound;

    // 如果本轮没有处理任何噪点，退出迭代
    if (processedThisRound == 0) break;

    debugPrint('[噪点过滤] 第$iteration轮处理了 $processedThisRound 个噪点块');
  }

  // 最终更新颜色频率统计
  colorFrequency.clear();
  for (final code in gridCodes) {
    if (code.isNotEmpty) {
      colorFrequency[code] = (colorFrequency[code] ?? 0) + 1;
    }
  }

  debugPrint('[噪点过滤] 完成，共处理 $totalProcessed 个噪点块，迭代 $iteration 轮');
}

/// 计算指定区域的平均色（优化版：根据网格大小采用不同策略）
/// 大网格：使用中位数过滤异常值 + 中心加权
/// 小网格：使用高斯加权减少边缘像素影响
_Color _calculateAverageColor(
  img.Image image,
  int startX,
  int startY,
  int width,
  int height,
) {
  // 判断是否为大网格块（像素数 > 400，约 20×20 以上）
  final pixelCount = width * height;
  final isLargeBlock = pixelCount > 400;

  // 大网格策略：收集像素并计算中位数
  if (isLargeBlock) {
    return _calculateLargeBlockColor(image, startX, startY, width, height);
  }

  // 小网格策略：加权平均
  return _calculateSmallBlockColor(image, startX, startY, width, height);
}

/// 大网格块颜色计算：使用中位数 + 中心加权
_Color _calculateLargeBlockColor(
  img.Image image,
  int startX,
  int startY,
  int width,
  int height,
) {
  // 收集中心区域像素（中心 60%）
  final centerRatio = 0.6;
  final marginX = (width * (1 - centerRatio) / 2).floor();
  final marginY = (height * (1 - centerRatio) / 2).floor();

  final rValues = <int>[];
  final gValues = <int>[];
  final bValues = <int>[];

  for (int y = startY + marginY; y < startY + height - marginY; y++) {
    for (int x = startX + marginX; x < startX + width - marginX; x++) {
      if (x >= image.width || y >= image.height) continue;
      final pixel = image.getPixel(x, y);
      rValues.add(pixel.r.toInt());
      gValues.add(pixel.g.toInt());
      bValues.add(pixel.b.toInt());
    }
  }

  if (rValues.isEmpty) {
    // 降级到普通平均
    return _calculateSmallBlockColor(image, startX, startY, width, height);
  }

  // 排序并取中位数
  rValues.sort();
  gValues.sort();
  bValues.sort();

  final mid = rValues.length ~/ 2;

  return _Color(
    r: rValues[mid].toDouble(),
    g: gValues[mid].toDouble(),
    b: bValues[mid].toDouble(),
  );
}

/// 小网格块颜色计算：加权平均，中心像素权重更高
_Color _calculateSmallBlockColor(
  img.Image image,
  int startX,
  int startY,
  int width,
  int height,
) {
  double r = 0;
  double g = 0;
  double b = 0;
  double totalWeight = 0;

  // 计算网格块中心
  final centerX = startX + width / 2;
  final centerY = startY + height / 2;

  // 高斯权重参数
  final sigma = (width + height) / 6.0;
  final sigmaSquared = sigma * sigma;

  for (int y = startY; y < startY + height; y++) {
    for (int x = startX; x < startX + width; x++) {
      if (x >= image.width || y >= image.height) continue;

      final pixel = image.getPixel(x, y);

      // 计算高斯权重
      final dx = x - centerX;
      final dy = y - centerY;
      final distanceSquared = dx * dx + dy * dy;
      final weight = (distanceSquared < sigmaSquared * 4) ? 1.0 : 0.3;

      r += pixel.r.toInt() * weight;
      g += pixel.g.toInt() * weight;
      b += pixel.b.toInt() * weight;
      totalWeight += weight;
    }
  }

  return _Color(
    r: totalWeight > 0 ? r / totalWeight : 0,
    g: totalWeight > 0 ? g / totalWeight : 0,
    b: totalWeight > 0 ? b / totalWeight : 0,
  );
}

/// 在珠子色库中查找 CIE Lab 感知距离最近的珠子色（全局搜索，保证最优映射）
_BeadColor _findClosestBeadColor(int r, int g, int b, List<_BeadColor> beadColors) {
  if (beadColors.isEmpty) {
    return _BeadColor(r: r, g: g, b: b, code: 'UNK');
  }

  final labInput = _rgbToLab(r, g, b);
  _BeadColor closest = beadColors.first;
  double minDist = _labDistFromValues(labInput, closest.lab);

  for (final beadColor in beadColors) {
    final dist = _labDistFromValues(labInput, beadColor.lab);
    if (dist < minDist) {
      minDist = dist;
      closest = beadColor;
    }
  }

  return closest;
}

/// 应用颜色筛选（优化版：考虑颜色多样性 + 全局 Lab 映射）
void _applyColorFilter(
  img.Image image,
  Map<String, int> colorFrequency,
  int maxColors,
  int gridWidth,
  int gridHeight,
  List<int> xGridLines,
  List<int> yGridLines,
  Map<String, _BeadColor> beadColorMap,
  List<String> gridCodes, {
  int targetGridW = 0, // 完整目标网格宽（=0时等同gridWidth，用于居中适配场景）
  int offsetX = 0,
  int offsetY = 0,
}) {
  debugPrint('[珠子颜色] ===== 开始应用颜色筛选 =====');
  debugPrint('[珠子颜色] 当前颜色数: ${colorFrequency.length}');
  debugPrint('[珠子颜色] 目标颜色数: $maxColors');

  // 如果当前颜色数已经小于等于目标，无需处理
  if (colorFrequency.length <= maxColors) {
    debugPrint('[珠子颜色] 当前颜色数已满足要求，跳过筛选');
    return;
  }

  // 按使用频率排序
  final sortedEntries = colorFrequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // 使用"频率+多样性"策略选择颜色
  final selectedColors = _selectColorsWithDiversity(
    sortedEntries,
    beadColorMap,
    maxColors,
  );
  final topColors = selectedColors.map((e) => e.code).toSet();
  debugPrint('[珠子颜色] 选中颜色代码 (${topColors.length}): ${topColors.toList().take(10)}${topColors.length > 10 ? '...' : ''}');

  final topColorList = selectedColors.toList();

  // 将其他颜色映射到最接近的高频颜色（全局 Lab 搜索）
  final colorRemapCache = <String, _BeadColor>{};

  for (int row = 0; row < gridHeight; row++) {
    for (int col = 0; col < gridWidth; col++) {
      // 居中适配时，映射到完整目标网格的索引
      final effectiveW = targetGridW > 0 ? targetGridW : gridWidth;
      final gridIndex = (row + offsetY) * effectiveW + (col + offsetX);
      final currentColorCode = gridCodes[gridIndex];

      // 如果当前颜色已经是高频颜色，跳过
      if (topColors.contains(currentColorCode)) {
        continue;
      }

      // 获取当前珠子颜色对象
      final currentColor = beadColorMap[currentColorCode];
      if (currentColor == null) continue;

      // 查找缓存
      if (!colorRemapCache.containsKey(currentColorCode)) {
        final closestTopColor = _findClosestBeadColor(
          currentColor.r,
          currentColor.g,
          currentColor.b,
          topColorList,
        );
        colorRemapCache[currentColorCode] = closestTopColor;
      }

      // 使用映射后的高频颜色
      final remappedColor = colorRemapCache[currentColorCode]!;

      // 更新 gridCodes
      gridCodes[gridIndex] = remappedColor.code;

      // 使用预计算的网格线位置
      final startX = xGridLines[col];
      final startY = yGridLines[row];
      final endX = xGridLines[col + 1];
      final endY = yGridLines[row + 1];

      // 计算当前块的实际宽高
      final actualWidth = endX - startX;
      final actualHeight = endY - startY;

      // 用映射后的高频颜色替换整个块
      for (int y = startY; y < startY + actualHeight; y++) {
        for (int x = startX; x < startX + actualWidth; x++) {
          image.setPixelRgba(x, y, remappedColor.r, remappedColor.g, remappedColor.b, 255);
        }
      }
    }
  }

  // 统计筛选后的颜色数
  final finalColorCount = gridCodes.toSet().length;
  debugPrint('[珠子颜色] ===== 颜色筛选完成 =====');
  debugPrint('[珠子颜色] 筛选后颜色数: $finalColorCount');
}

/// 使用"频率+多样性"策略选择颜色
/// 确保选中的颜色在色彩空间中分布均匀，同时保留高频颜色
List<_BeadColor> _selectColorsWithDiversity(
  List<MapEntry<String, int>> sortedEntries,
  Map<String, _BeadColor> beadColorMap,
  int maxColors,
) {
  if (sortedEntries.length <= maxColors) {
    return sortedEntries.map((e) => beadColorMap[e.key]!).toList();
  }

  final selected = <_BeadColor>[];
  final remaining = <MapEntry<String, int>>[...sortedEntries];

  // 动态计算最小颜色距离阈值：颜色限制越大，阈值越小
  // 基准：8色时约8000，128色时约2000
  final minDistanceThreshold = 8000.0 / (maxColors / 8).clamp(1, 16);
  debugPrint('[颜色选择] 目标颜色数: $maxColors, 动态阈值: ${minDistanceThreshold.toStringAsFixed(0)}');

  // 前 30% 的名额直接按频率选择，不受多样性限制（保护高频颜色）
  final guaranteedCount = (maxColors * 0.3).ceil().clamp(1, maxColors ~/ 2);
  int guaranteedSelected = 0;

  // 第一轮：按频率选择，前 guaranteedCount 个不受多样性限制
  for (final entry in remaining) {
    if (selected.length >= maxColors) break;

    final color = beadColorMap[entry.key];
    if (color == null) continue;
    if (selected.any((c) => c.code == color.code)) continue;

    // 前 guaranteedCount 个颜色直接选中（保护高频颜色）
    if (guaranteedSelected < guaranteedCount) {
      selected.add(color);
      guaranteedSelected++;
      continue;
    }

    // 后续颜色需要通过多样性检查（使用 CIE Lab Delta E 感知距离）
    bool isDiverse = true;
    for (final selectedColor in selected) {
      final dist = _labDistFromValues(color.lab, selectedColor.lab);
      if (dist < minDistanceThreshold) {
        isDiverse = false;
        break;
      }
    }

    if (isDiverse) {
      selected.add(color);
    }
  }

  // 第二轮：如果还没选够，放宽多样性要求，优先填充频率高的颜色
  if (selected.length < maxColors) {
    for (final entry in remaining) {
      if (selected.length >= maxColors) break;

      final color = beadColorMap[entry.key];
      if (color == null) continue;
      if (selected.any((c) => c.code == color.code)) continue;

      selected.add(color);
    }
  }

  debugPrint('[颜色选择] 选中颜色数: ${selected.length}');
  return selected;
}

/// 在 Isolate 中执行的像素化函数
Future<_PixelizeResult> _pixelizeInIsolate(_PixelizeParams params) async {
  try {
    // 解码图片
    final sourceImage = img.decodeImage(params.imageBytes);
    if (sourceImage == null) {
      throw Exception('解码图片失败');
    }

    var gridWidth = params.gridWidth;
    var gridHeight = params.gridHeight;

    // [AI非正方形网格适配]
    // AI接口通常返回正方形图片，当用户选择非正方形网格时需要特殊处理
    int offsetX = 0;
    int offsetY = 0;
    bool needsCentering = false;

    if (params.aiGridFitMode != AiGridFitMode.none && gridWidth != gridHeight) {
      final imgRatio = sourceImage.width / sourceImage.height;
      // 图片接近正方形(比例0.75~1.33)，且网格不是正方形
      if (imgRatio > 0.75 && imgRatio < 1.333) {
        final size = math.min(gridWidth, gridHeight);

        switch (params.aiGridFitMode) {
          case AiGridFitMode.center:
            // 保持原网格尺寸，内容居中（如52×102画板中居中显示52×52）
            offsetX = ((gridWidth - size) / 2).floor();
            offsetY = ((gridHeight - size) / 2).floor();
            gridWidth = size;
            gridHeight = size;
            needsCentering = true;
            debugPrint('[像素化] AI居中模式: 原始网格 ${params.gridWidth}x${params.gridHeight}'
                ', 图片 ${sourceImage.width}x${sourceImage.height}(ratio=${imgRatio.toStringAsFixed(2)})'
                ' → 实际处理 $gridWidth x $gridHeight, 偏移($offsetX,$offsetY)');
          case AiGridFitMode.resizeToSquare:
            // 取用户自定义尺寸中宽高的最大值作为正方形尺寸（如52×102→102×102，80×40→80×80）
            final squareSize = math.max(params.gridWidth, params.gridHeight);
            gridWidth = squareSize;
            gridHeight = squareSize;
            // 同步修改目标数组尺寸，确保 gridCodes 大小匹配
            // （targetGridW/H 在后面定义，此处用局部变量暂存，后续会重新赋值）
            debugPrint('[像素化] AI强制正方形模式: 原始网格 ${params.gridWidth}x${params.gridHeight}'
                ', 图片 ${sourceImage.width}x${sourceImage.height}(ratio=${imgRatio.toStringAsFixed(2)})'
                ' → 网格改为 $gridWidth x $gridHeight');
          case AiGridFitMode.none:
            break;
        }
      }
    }

    // [性能优化] 预缩小大图，大幅减少均值计算量
    final targetMaxDim = math.max(math.max(gridWidth, gridHeight) * 10, 500);
    img.Image imageToProcess;
    if (sourceImage.width > targetMaxDim || sourceImage.height > targetMaxDim) {
      final scale =
          math.min(targetMaxDim / sourceImage.width, targetMaxDim / sourceImage.height);
      imageToProcess = img.copyResize(
        sourceImage,
        width: (sourceImage.width * scale).round(),
        height: (sourceImage.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
      debugPrint('[像素化] 原图 ${sourceImage.width}x${sourceImage.height} → '
          '缩放至 ${imageToProcess.width}x${imageToProcess.height} (${scale.toStringAsFixed(2)}x)');
    } else {
      imageToProcess = sourceImage;
    }

    final width = imageToProcess.width;
    final height = imageToProcess.height;

    // 计算基础大小和余数（整数除法法）
    final baseWidth = width ~/ gridWidth;
    final remainderX = width % gridWidth;
    final baseHeight = height ~/ gridHeight;
    final remainderY = height % gridHeight;

    debugPrint('[像素化] 处理图片尺寸: ${width}x${height}');
    debugPrint('[像素化] 网格大小: ${gridWidth}x${gridHeight}');
    debugPrint('[像素化] 基础块大小: ${baseWidth}x${baseHeight}, 余数: ${remainderX}x${remainderY}');

    // 创建新图片（输出与处理后图像同尺寸）
    final pixelizedImage = img.Image(width: width, height: height);

    // 记录每个网格块的颜色code
    // resizeToSquare 模式下使用修改后的网格尺寸，其他模式使用原始目标尺寸
    final targetGridW = (params.aiGridFitMode == AiGridFitMode.resizeToSquare) ? gridWidth : params.gridWidth;
    final targetGridH = (params.aiGridFitMode == AiGridFitMode.resizeToSquare) ? gridHeight : params.gridHeight;
    final gridCodes = List<String>.filled(targetGridW * targetGridH, '');
    final colorFrequency = <String, int>{};

    // 预先计算所有网格线的位置（整数，确保对齐）
    final xGridLines = <int>[0];
    final yGridLines = <int>[0];
    int xPosition = 0;
    int yPosition = 0;

    // 生成X网格线：前 remainderX 个网格是 baseWidth+1，其余是 baseWidth
    for (int i = 0; i < gridWidth; i++) {
      xPosition += baseWidth + (i < remainderX ? 1 : 0);
      xGridLines.add(xPosition);
    }
    // 确保最后一条线在边界
    xGridLines[gridWidth] = width;

    // 生成Y网格线：前 remainderY 个网格是 baseHeight+1，其余是 baseHeight
    for (int i = 0; i < gridHeight; i++) {
      yPosition += baseHeight + (i < remainderY ? 1 : 0);
      yGridLines.add(yPosition);
    }
    // 确保最后一条线在边界
    yGridLines[gridHeight] = height;

    // 遍历网格
    for (int row = 0; row < gridHeight; row++) {
      final startY = yGridLines[row];
      final endY = yGridLines[row + 1];
      final actualHeight = endY - startY;

      for (int col = 0; col < gridWidth; col++) {
        // 计算网格索引（居中适配时映射到完整网格的目标位置）
        final gridIndex = (row + offsetY) * targetGridW + (col + offsetX);

        // 使用预计算的网格线位置
        final startX = xGridLines[col];
        final endX = xGridLines[col + 1];
        final actualWidth = endX - startX;

        // 计算该块的平均色（使用处理后的图片像素）
        final avgColor = _calculateAverageColor(
          imageToProcess,
          startX,
          startY,
          actualWidth,
          actualHeight,
        );

        // 找到最接近的珠子颜色（全局 Lab 搜索）
        final beadColor = _findClosestBeadColor(
          avgColor.r.toInt(),
          avgColor.g.toInt(),
          avgColor.b.toInt(),
          params.beadColors,
        );

        // 统计使用频率
        colorFrequency[beadColor.code] = (colorFrequency[beadColor.code] ?? 0) + 1;

        // 记录网格块的颜色code
        gridCodes[gridIndex] = beadColor.code;

        // 用珠子颜色填充整个块
        for (int y = startY; y < startY + actualHeight; y++) {
          for (int x = startX; x < startX + actualWidth; x++) {
            pixelizedImage.setPixelRgba(x, y, beadColor.r, beadColor.g, beadColor.b, 255);
          }
        }
      }
    }

    debugPrint('[珠子颜色] 映射后实际使用的珠子颜色数: ${colorFrequency.length}');

    // 空间平滑：清除映射阶段产生的孤立杂色格（在减色之前，避免稀有色被错误合并）
    _applySpatialSmoothing(
      gridCodes,
      gridWidth,
      gridHeight,
      pixelizedImage,
      xGridLines,
      yGridLines,
      params.beadColorMap,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    // 平滑后重新统计颜色频率
    colorFrequency.clear();
    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final code = gridCodes[_gridCellIndex(
          row,
          col,
          gridWidth: gridWidth,
          targetGridW: targetGridW,
          offsetX: offsetX,
          offsetY: offsetY,
        )];
        if (code.isNotEmpty) {
          colorFrequency[code] = (colorFrequency[code] ?? 0) + 1;
        }
      }
    }
    debugPrint('[珠子颜色] 空间平滑后颜色数: ${colorFrequency.length}');
    debugPrint('[珠子颜色] params.colorLimit: ${params.colorLimit}');

    // 应用颜色筛选（只要设置了颜色限制，总是执行筛选逻辑）
    if (params.colorLimit > 0) {
      // 调用筛选函数，内部会根据实际情况决定是否需要映射
      debugPrint('[珠子颜色] ✅ 执行颜色筛选逻辑，限制: ${params.colorLimit}');
      _applyColorFilter(
        pixelizedImage,
        colorFrequency,
        params.colorLimit,
        gridWidth,
        gridHeight,
        xGridLines,
        yGridLines,
        params.beadColorMap,
        gridCodes,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
    } else {
      debugPrint('[珠子颜色] ℹ️ 无颜色限制，不进行筛选');
    }

    // 噪点过滤（移到颜色筛选之后，避免误删重要颜色）
    // 使用平均像素数判断：每个网格块的平均像素数 < 100 时启用更严格的过滤
    final avgPixelsPerBlock = (width * height) / (gridWidth * gridHeight);
    final isSmallGrid = avgPixelsPerBlock < 100;

    if (isSmallGrid || gridWidth > 40 || gridHeight > 40) {
      _removeNoiseColors(
        gridCodes,
        gridWidth,
        gridHeight,
        colorFrequency,
        pixelizedImage,
        xGridLines,
        yGridLines,
        params.beadColorMap,
        isSmallGrid: isSmallGrid,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
      debugPrint('[珠子颜色] 噪点过滤后颜色数: ${gridCodes.toSet().length}');
    }

    debugPrint('[珠子颜色] 最终显示的颜色数: ${gridCodes.toSet().length}');
    debugPrint('[珠子颜色] 使用的珠子颜色代码: ${gridCodes.toSet().toList().take(10)}${gridCodes.toSet().length > 10 ? '...' : ''}');

    // 验证所有像素都被填充
    int unfilledPixels = 0;
    for (int y = 0; y < pixelizedImage.height; y++) {
      for (int x = 0; x < pixelizedImage.width; x++) {
        final pixel = pixelizedImage.getPixel(x, y);
        if (pixel.a == 0) {
          unfilledPixels++;
        }
      }
    }
    if (unfilledPixels > 0) {
      debugPrint('[像素化] 警告：有$unfilledPixels个像素未被填充！');
    }

    // 编码为 PNG
    final pixelizedBytes = img.encodePng(pixelizedImage);

    // 生成文件名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final limitSuffix = params.colorLimit > 0 ? '_${params.colorLimit}colors' : '_allcolors';
    final filename = 'pixelized_${timestamp}_${gridWidth}x${gridHeight}${params.brandSuffix}$limitSuffix.png';

    return _PixelizeResult(
      pixelizedBytes: pixelizedBytes,
      filename: filename,
      pixelCodes: gridCodes,
      actualGridWidth: targetGridW,
      actualGridHeight: targetGridH,
    );
  } catch (e) {
    rethrow;
  }
}

/// 使用的颜色数据模型（含 code、count、hex、name）
class ColorModel {
  final String code;
  final int count;
  final String hex;
  final String? name;

  const ColorModel({
    required this.code,
    required this.count,
    required this.hex,
    this.name,
  });
}

/// 像素化结果类
class PixelizeResult {
  final File imageFile;
  final List<String> pixelCodes;
  final int gridWidth;
  final int gridHeight;

  PixelizeResult({
    required this.imageFile,
    required this.pixelCodes,
    required this.gridWidth,
    required this.gridHeight,
  });
}

/// 像素化工具类
///
/// 功能：将图片分割成 N×N 网格，每个网格用平均色填充，生成像素风格图片
class PixelizeUtil {
  PixelizeUtil._();

  /// 项目根目录名称
  static const String projectDirName = 'pixel_projects';

  /// 清除所有像素画板缓存数据（用户注销时调用）
  static Future<void> clearAllCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory(p.join(appDir.path, projectDirName));
      
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
        debugPrint('[像素画板] 已清除所有缓存数据');
      }
    } catch (e) {
      debugPrint('[像素画板] 清除缓存失败: $e');
    }
  }

  /// 珠子颜色缓存
  static List<_BeadColor>? _beadColors;

  /// 珠子颜色按代码索引的Map（用于快速查找）
  static Map<String, _BeadColor>? _beadColorMap;

  /// 当前使用的颜色库
  static BeadBrand _currentBrand = BeadBrand.mard;

  /// 设置颜色库
  static void setBeadBrand(BeadBrand brand) {
    if (_currentBrand != brand) {
      _currentBrand = brand;
      _beadColors = null;
      _beadColorMap = null;
    }
  }

  /// 获取当前颜色库的总颜色数
  static int getCurrentBeadBrandColorCount() {
    return _currentBrand.totalColors;
  }

  /// 获取当前颜色库的显示名称
  static String getCurrentBeadBrandName() {
    return _currentBrand.displayName;
  }

  /// 加载珠子颜色数据
  static Future<void> _loadBeadColors() async {
    if (_beadColors != null) return;

    try {
      debugPrint('[珠子颜色] 开始加载颜色库: ${_currentBrand.jsonPath}');
      final jsonString = await rootBundle.loadString(_currentBrand.jsonPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final colors = json['colors'] as List;
      debugPrint('[珠子颜色] 颜色库JSON解析成功，共 ${colors.length} 个颜色');
      _beadColors = colors.map((color) {
        final c = color as Map<String, dynamic>;
        final hex = c['hex'] as String;
        final code = c['code'] as String;
        return _BeadColor.fromHex(hex, code);
      }).toList();

      // 创建快速查找索引
      _beadColorMap = {};
      for (final color in _beadColors!) {
        _beadColorMap![color.code] = color;
      }

      debugPrint('[珠子颜色] 成功加载 ${_currentBrand.displayName} ${_beadColors!.length} 种标准色');
    } catch (e) {
      debugPrint('[珠子颜色] 加载失败: $e');
      debugPrint('[珠子颜色] 错误堆栈: ${StackTrace.current}');
      // 加载失败时清空缓存，下次会重新尝试
      _beadColors = null;
      _beadColorMap = null;
      throw Exception('颜色库加载失败: $e');
    }
  }

  /// 像素化图片
  ///
  /// [imageFile] 原始图片文件
  /// [gridSize] 分割网格大小
  /// [colorLimit] 颜色限制（不限制时为 null）
  /// [brand] 颜色库（默认为 MARD）
  ///
  /// 返回像素化结果，包含图片文件和像素颜色code，失败返回 null
  static Future<PixelizeResult?> pixelizeImage(
    File imageFile,
    GridSize gridSize,
    ColorLimit? colorLimit,
    BeadBrand brand,
  ) async {
    return pixelizeImageWithCustomSize(
      imageFile,
      gridSize.width,
      gridSize.height,
      colorLimit,
      brand,
    );
  }

  /// 像素化图片（支持自定义尺寸）
  ///
  /// [imageFile] 原始图片文件
  /// [gridWidth] 网格宽度
  /// [gridHeight] 网格高度
  /// [colorLimit] 颜色限制（不限制时为 null）
  /// [brand] 颜色库（默认为 MARD）
  ///
  /// 返回像素化结果，包含图片文件和像素颜色code，失败返回 null
  ///
  /// [imageBytes] 图片原始字节数据（支持来自网络下载或本地文件）
  ///
  /// [aiGridFitMode] AI生图场景专用：当AI返回正方形图片但用户选择非正方形网格时，
  /// - center: 保持原网格，内容居中
  /// - resizeToSquare: 直接改网格为正方形
  /// 默认 none（不做特殊处理）。
  static Future<PixelizeResult?> pixelizeImageFromBytes(
    Uint8List imageBytes,
    int gridWidth,
    int gridHeight,
    ColorLimit? colorLimit,
    BeadBrand brand, {
    AiGridFitMode aiGridFitMode = AiGridFitMode.none,
  }) async {
    try {
      debugPrint('[像素化] ===== 开始处理 (bytes模式) =====');
      debugPrint('[像素化] 图片大小: ${imageBytes.length} bytes');
      debugPrint('[像素化] 网格大小: ${gridWidth}x${gridHeight}');
      debugPrint('[像素化] 颜色库: ${brand.displayName}');
      debugPrint('[像素化] 颜色库路径: ${brand.jsonPath}');
      debugPrint('[像素化] 颜色限制: ${colorLimit?.label ?? '无限制'}');

      // 设置颜色库
      setBeadBrand(brand);

      // 加载珠子颜色数据
      await _loadBeadColors();

      if (_beadColors == null || _beadColors!.isEmpty) {
        debugPrint('[像素化] 颜色数据未加载');
        throw Exception('颜色数据未加载');
      }

      debugPrint('[像素化] 颜色库大小: ${_beadColors!.length}');

      // 准备参数（直接使用传入的字节，无需文件读取）
      final params = _PixelizeParams(
        imageBytes: imageBytes,
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        beadColors: _beadColors!,
        beadColorMap: _beadColorMap!,
        colorLimit: colorLimit?.limit ?? -1,
        brandSuffix: '_${_currentBrand.displayName.toLowerCase()}',
        aiGridFitMode: aiGridFitMode,
      );

      debugPrint('[像素化] 在后台线程中处理...');

      // 在 isolate 中执行像素化（不阻塞主线程）
      final result = await compute<_PixelizeParams, _PixelizeResult>(
        _pixelizeInIsolate,
        params,
      );

      debugPrint('[像素化] 后台处理完成，保存文件...');

      // 保存到临时文件
      final tempDir = Directory.systemTemp;
      final outputFile = File('${tempDir.path}/${result.filename}');
      await outputFile.writeAsBytes(result.pixelizedBytes);

      debugPrint('[像素化] ===== 处理完成 =====');
      debugPrint('[像素化] 文件大小: ${result.pixelizedBytes.length} bytes');
      debugPrint('[像素化] 像素codes数量: ${result.pixelCodes.length}');
      debugPrint('[像素化] 输出文件: ${outputFile.path}');

      return PixelizeResult(
        imageFile: outputFile,
        pixelCodes: result.pixelCodes,
        gridWidth: result.actualGridWidth,
        gridHeight: result.actualGridHeight,
      );
    } catch (e) {
      debugPrint('[像素化] 失败: $e');
      debugPrint('[像素化] 错误堆栈: ${StackTrace.current}');
      return null;
    }
  }

  /// 像素化图片（File版本，向后兼容的便捷入口）
  ///
  /// 内部委托给 [pixelizeImageFromBytes]，保持原有 API 不变
  ///
  /// 返回像素化结果，包含图片文件和像素颜色code，失败返回 null
  static Future<PixelizeResult?> pixelizeImageWithCustomSize(
    File imageFile,
    int gridWidth,
    int gridHeight,
    ColorLimit? colorLimit,
    BeadBrand brand,
  ) async {
    // 读取文件字节后委托给 bytes 版本
    final imageBytes = await imageFile.readAsBytes();
    return pixelizeImageFromBytes(
      imageBytes, gridWidth, gridHeight, colorLimit, brand,
    );
  }

  /// 获取图片信息
  static Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return {
          'width': 0,
          'height': 0,
          'sizeKB': (imageFile.lengthSync() / 1024).toStringAsFixed(2),
          'format': 'Unknown',
        };
      }

      return {
        'width': image.width,
        'height': image.height,
        'sizeKB': (imageFile.lengthSync() / 1024).toStringAsFixed(2),
        'format': image.format.name,
      };
    } catch (e) {
      debugPrint('获取图片信息失败: $e');
      return {};
    }
  }

  /// 解析使用的颜色数据（code:count 字符串列表）为 ColorModel 列表
  ///
  /// [colorDataList] 格式如 ["F21:1841", "E18:122", ...]
  /// [beadBrandKey] 品牌标识，用于查找对应颜色库获取 hex 和 name
  ///
  /// 返回 [ColorModel] 列表，包含 code、count、hex、name
  static Future<List<ColorModel>> parseColorData(
    List<String> colorDataList,
    String beadBrandKey,
  ) async {
    // 根据 beadBrandKey 获取对应的颜色库路径
    final brand = BeadBrand.fromKey(beadBrandKey);

    // 加载品牌颜色库
    setBeadBrand(brand);
    await _loadBeadColors();

    if (_beadColors == null || _beadColorMap == null) {
      debugParse('[颜色解析] 颜色库加载失败');
      return [];
    }

    // 构建一个从 code 到 {hex, name} 的映射（快速查找）
    final codeInfoMap = <String, Map<String, String>>{};
    for (final bc in _beadColors!) {
      codeInfoMap[bc.code] = {'hex': '', 'name': ''};
    }
    // 从原始 JSON 数据中补充 hex 和 name 信息

    try {
      final jsonString = await rootBundle.loadString(brand.jsonPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final colors = json['colors'] as List;
      for (final c in colors) {
        final item = c as Map<String, dynamic>;
        final code = item['code'] as String;
        if (codeInfoMap.containsKey(code)) {
          codeInfoMap[code]!['hex'] = item['hex'] as String? ?? '';
          codeInfoMap[code]!['name'] = item['name'] as String? ?? '';
        }
      }
    } catch (e) {
      debugParse('[颜色解析] 解析颜色库JSON失败: $e');
    }

    // 解析每个 "code:count" 条目
    final result = <ColorModel>[];
    for (final item in colorDataList) {
      final colonIndex = item.indexOf(':');
      if (colonIndex <= 0 || colonIndex >= item.length - 1) continue;

      final code = item.substring(0, colonIndex);
      final count = int.tryParse(item.substring(colonIndex + 1));
      if (count == null) continue;

      final info = codeInfoMap[code];
      result.add(ColorModel(
        code: code,
        count: count,
        hex: info?['hex'] ?? '',
        name: info?['name'],
      ));
    }

    debugParse('[颜色解析] 完成，共解析 ${result.length} 个颜色');
    return result;
  }

  static void debugParse(String message) => debugPrint(message);
}
