import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'color_delta.dart';
import 'merge_intensity.dart';
import 'pixel_post_processor.dart';
import 'color_merge_util.dart';
import 'color_cluster_util.dart';
import 'pixel_subject_mask.dart';

export 'merge_intensity.dart';

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
  max16(16, '16色'),
  max8(8, '8色');

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
  List<double> get lab => _lab ??= ColorDelta.rgbToLab(r, g, b);

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

  /// 合并强度（ΔE00 阈值档位）
  final MergeIntensity mergeIntensity;

  _PixelizeParams({
    required this.imageBytes,
    required this.gridWidth,
    required this.gridHeight,
    required this.beadColors,
    required this.beadColorMap,
    required this.colorLimit,
    required this.brandSuffix,
    this.aiGridFitMode = AiGridFitMode.none,
    this.mergeIntensity = MergeIntensity.medium,
  });
}

/// RGB → CIE Lab（委托 ColorDelta）
List<double> _rgbToLab(int r, int g, int b) => ColorDelta.rgbToLab(r, g, b);

/// CIEDE2000 (ΔE00) between two Lab values
double _labDistFromValues(List<double> lab1, List<double> lab2) =>
    ColorDelta.deltaE00FromLab(lab1, lab2);

/// 从珠色映射构建 RGB 查找表（供后处理使用）
Map<String, ({int r, int g, int b})> _beadRgbMap(
  Map<String, _BeadColor> beadColorMap,
) {
  return {
    for (final e in beadColorMap.entries)
      e.key: (r: e.value.r, g: e.value.g, b: e.value.b),
  };
}

/// 用矩形填充网格块（比逐像素 setPixelRgba 快得多）
void _fillGridBlock(
  img.Image image,
  int startX,
  int startY,
  int endX,
  int endY,
  _BeadColor color,
) {
  if (endX <= startX || endY <= startY) return;
  img.fillRect(
    image,
    x1: startX,
    y1: startY,
    x2: endX - 1,
    y2: endY - 1,
    color: img.ColorRgb8(color.r, color.g, color.b),
  );
}

/// 执行连通块后处理（孤立杂色 + 微小色块 + 细节保护）
void _runPostProcess(
  List<String> gridCodes,
  int gridWidth,
  int gridHeight,
  Map<String, _BeadColor> beadColorMap,
  MergeIntensity intensity,
  img.Image image,
  List<int> xGridLines,
  List<int> yGridLines, {
  int targetGridW = 0,
  int offsetX = 0,
  int offsetY = 0,
}) {
  PixelPostProcessor.apply(
    gridCodes: gridCodes,
    gridWidth: gridWidth,
    gridHeight: gridHeight,
    colorRgbByCode: _beadRgbMap(beadColorMap),
    intensity: intensity,
    image: image,
    xGridLines: xGridLines,
    yGridLines: yGridLines,
    targetGridW: targetGridW,
    offsetX: offsetX,
    offsetY: offsetY,
  );
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


/// 计算指定区域的代表色（边界格用主色，内部格用中位数/加权平均）
_Color _calculateAverageColor(
  img.Image image,
  int startX,
  int startY,
  int width,
  int height, {
  bool? isBoundary,
}) {
  // 跨色边界格：主色采样，避免均值/中位数把描边与填充混在一起
  if (isBoundary ?? _isBoundaryBlock(image, startX, startY, width, height)) {
    return _calculateDominantBlockColor(image, startX, startY, width, height);
  }

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

/// 块内是否存在两个占比显著且对比明显的主色（跨色边界）
bool _isBoundaryBlock(
  img.Image image,
  int startX,
  int startY,
  int width,
  int height,
) {
  final counts = <int, int>{};
  var total = 0;

  for (int y = startY; y < startY + height; y++) {
    for (int x = startX; x < startX + width; x++) {
      if (x >= image.width || y >= image.height) continue;
      final pixel = image.getPixel(x, y);
      final key = _quantizeRgbKey(
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
      );
      counts[key] = (counts[key] ?? 0) + 1;
      total++;
    }
  }

  if (total < 4 || counts.length < 2) return false;

  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final top1Share = sorted[0].value / total;
  final top2Share = sorted[1].value / total;
  if (top1Share < 0.28 || top2Share < 0.18) return false;

  final lab1 = _labFromQuantizedKey(sorted[0].key);
  final lab2 = _labFromQuantizedKey(sorted[1].key);
  // ΔE76 > 12：两种主色有足够对比，视为轮廓/边界格
  return ColorDelta.deltaE76SqFromLab(lab1, lab2) > 144;
}

/// 5-bit 量化 RGB → 单一 int key
int _quantizeRgbKey(int r, int g, int b) =>
    ((r >> 3) << 10) | ((g >> 3) << 5) | (b >> 3);

List<double> _labFromQuantizedKey(int key) {
  final r = ((key >> 10) & 0x1F) << 3;
  final g = ((key >> 5) & 0x1F) << 3;
  final b = (key & 0x1F) << 3;
  return ColorDelta.rgbToLab(r | 4, g | 4, b | 4);
}

/// 边界格主色：取块内占比最高的量化色桶，再对该桶内像素求均值
_Color _calculateDominantBlockColor(
  img.Image image,
  int startX,
  int startY,
  int width,
  int height,
) {
  final counts = <int, int>{};

  for (int y = startY; y < startY + height; y++) {
    for (int x = startX; x < startX + width; x++) {
      if (x >= image.width || y >= image.height) continue;
      final pixel = image.getPixel(x, y);
      final key = _quantizeRgbKey(
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
      );
      counts[key] = (counts[key] ?? 0) + 1;
    }
  }

  if (counts.isEmpty) {
    return const _Color(r: 0, g: 0, b: 0);
  }

  final total = counts.values.fold<int>(0, (a, b) => a + b);
  var dominantKey = counts.keys.first;
  var maxCount = 0;
  for (final entry in counts.entries) {
    if (entry.value > maxCount) {
      maxCount = entry.value;
      dominantKey = entry.key;
    }
  }

  // 黑线描边：抗锯齿会让灰色像素占多数，优先取占比足够的最深色桶
  final strokeKey = _resolveDarkStrokeBucket(counts, total);
  if (strokeKey != null) {
    dominantKey = strokeKey;
  }

  double r = 0;
  double g = 0;
  double b = 0;
  var n = 0;

  for (int y = startY; y < startY + height; y++) {
    for (int x = startX; x < startX + width; x++) {
      if (x >= image.width || y >= image.height) continue;
      final pixel = image.getPixel(x, y);
      final pr = pixel.r.toInt();
      final pg = pixel.g.toInt();
      final pb = pixel.b.toInt();
      if (_quantizeRgbKey(pr, pg, pb) != dominantKey) continue;
      r += pr;
      g += pg;
      b += pb;
      n++;
    }
  }

  if (n == 0) {
    final qr = ((dominantKey >> 10) & 0x1F) << 3;
    final qg = ((dominantKey >> 5) & 0x1F) << 3;
    final qb = (dominantKey & 0x1F) << 3;
    return _Color(r: (qr | 4).toDouble(), g: (qg | 4).toDouble(), b: (qb | 4).toDouble());
  }

  return _Color(r: r / n, g: g / n, b: b / n);
}

/// 深色描边桶：深/浅双峰时取深色侧；或取占比足够的极深色桶
int? _resolveDarkStrokeBucket(Map<int, int> counts, int total) {
  if (counts.length < 2 || total == 0) return null;

  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final top = sorted.take(4).toList();
  for (int i = 0; i < top.length; i++) {
    for (int j = i + 1; j < top.length; j++) {
      final labA = _labFromQuantizedKey(top[i].key);
      final labB = _labFromQuantizedKey(top[j].key);

      final darkEntry = labA[0] <= labB[0] ? top[i] : top[j];
      final lightEntry = labA[0] <= labB[0] ? top[j] : top[i];
      final darkLab = labA[0] <= labB[0] ? labA : labB;
      final lightLab = labA[0] <= labB[0] ? labB : labA;

      if (darkLab[0] > 42 || lightLab[0] < 48) continue;
      if (ColorDelta.deltaE76SqFromLab(darkLab, lightLab) < 144) continue;
      if (darkEntry.value / total < 0.10) continue;

      return darkEntry.key;
    }
  }

  int? darkestKey;
  var darkestL = double.infinity;
  for (final entry in counts.entries) {
    if (entry.value / total < 0.08) continue;
    final lab = _labFromQuantizedKey(entry.key);
    if (lab[0] < 32 && lab[0] < darkestL) {
      darkestL = lab[0];
      darkestKey = entry.key;
    }
  }
  return darkestKey;
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

/// 3×3 中值滤波（轻量去 JPEG/毛发噪点，保留大结构）
img.Image _medianFilter3x3(img.Image source) {
  final out = img.Image.from(source);
  if (source.width < 3 || source.height < 3) return out;

  for (int y = 1; y < source.height - 1; y++) {
    for (int x = 1; x < source.width - 1; x++) {
      final rs = <int>[];
      final gs = <int>[];
      final bs = <int>[];
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          final p = source.getPixel(x + dx, y + dy);
          rs.add(p.r.toInt());
          gs.add(p.g.toInt());
          bs.add(p.b.toInt());
        }
      }
      rs.sort();
      gs.sort();
      bs.sort();
      out.setPixelRgb(x, y, rs[4], gs[4], bs[4]);
    }
  }
  return out;
}

/// 内部格四邻域多数票：映射后第一时间消除渐变区跳色
int _applyInteriorSpatialVote({
  required List<String> gridCodes,
  required int gridWidth,
  required int gridHeight,
  required Map<String, _BeadColor> beadColorMap,
  required Set<int> boundaryGridIndices,
  required img.Image pixelizedImage,
  required List<int> xGridLines,
  required List<int> yGridLines,
  int targetGridW = 0,
  int offsetX = 0,
  int offsetY = 0,
  double mergeThreshold = 6.0,
}) {
  final labCache = <String, List<double>>{
    for (final e in beadColorMap.entries) e.key: e.value.lab,
  };
  final roles = PixelSubjectMask.compute(
    gridCodes: gridCodes,
    gridWidth: gridWidth,
    gridHeight: gridHeight,
    labCache: labCache,
    targetGridW: targetGridW,
    offsetX: offsetX,
    offsetY: offsetY,
  );
  final effectiveW = targetGridW > 0 ? targetGridW : gridWidth;
  var changed = 0;

  for (int row = 0; row < gridHeight; row++) {
    for (int col = 0; col < gridWidth; col++) {
      final gridIndex = (row + offsetY) * effectiveW + (col + offsetX);
      if (boundaryGridIndices.contains(gridIndex)) continue;

      final local = row * gridWidth + col;
      final role = roles[local];
      if (role == BeadCellRole.transition) continue;

      final isBackground = role == BeadCellRole.background;
      final minVotes = isBackground ? 3 : 4;
      final threshold =
          isBackground ? mergeThreshold + 2 : mergeThreshold - 1;

      final current = gridCodes[gridIndex];
      if (current.isEmpty) continue;

      final neighborCounts = <String, int>{};
      for (final dir in const [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ]) {
        final nr = row + dir[0];
        final nc = col + dir[1];
        if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;
        final nIdx = (nr + offsetY) * effectiveW + (nc + offsetX);
        if (boundaryGridIndices.contains(nIdx)) continue;
        final nCode = gridCodes[nIdx];
        if (nCode.isEmpty || nCode == current) continue;
        neighborCounts[nCode] = (neighborCounts[nCode] ?? 0) + 1;
      }

      if (neighborCounts.isEmpty) continue;

      final sorted = neighborCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      if (top.value < minVotes) continue;

      final de = ColorDelta.deltaE00BetweenCodes(current, top.key, labCache);
      if (de > threshold) continue;

      gridCodes[gridIndex] = top.key;
      changed++;

      final bead = beadColorMap[top.key];
      if (bead == null) continue;
      _fillGridBlock(
        pixelizedImage,
        xGridLines[col],
        yGridLines[row],
        xGridLines[col + 1],
        yGridLines[row + 1],
        bead,
      );
    }
  }

  if (changed > 0) {
    debugPrint('[空间投票] 内部格统一: $changed 格');
  }
  return changed;
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

/// 四邻已映射格子的填充色 Lab（用于边界对比度映射）
List<List<double>> _neighborFillLabs(
  int row,
  int col,
  List<String> gridCodes, {
  required int gridWidth,
  required int gridHeight,
  required Map<String, _BeadColor> beadColorMap,
  int targetGridW = 0,
  int offsetX = 0,
  int offsetY = 0,
}) {
  final selfIndex = _gridCellIndex(
    row,
    col,
    gridWidth: gridWidth,
    targetGridW: targetGridW,
    offsetX: offsetX,
    offsetY: offsetY,
  );
  final selfCode = gridCodes[selfIndex];

  final neighborCodes = <String>{};
  for (final dir in const [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0],
  ]) {
    final nr = row + dir[0];
    final nc = col + dir[1];
    if (nr < 0 || nr >= gridHeight || nc < 0 || nc >= gridWidth) continue;

    final code = gridCodes[_gridCellIndex(
      nr,
      nc,
      gridWidth: gridWidth,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    )];
    if (code.isEmpty || code == selfCode) continue;
    neighborCodes.add(code);
  }

  final labs = <List<double>>[];
  for (final code in neighborCodes) {
    final bead = beadColorMap[code];
    if (bead != null) labs.add(bead.lab);
  }
  return labs;
}

/// 在珠子色库中查找 CIE Lab 感知距离最近的珠子色（ΔE76 粗筛 + ΔE00 精算）
_BeadColor _findClosestBeadColor(int r, int g, int b, List<_BeadColor> beadColors) {
  if (beadColors.isEmpty) {
    return _BeadColor(r: r, g: g, b: b, code: 'UNK');
  }

  final labInput = _rgbToLab(r, g, b);
  final topK = math.min(5, beadColors.length);
  final topIndices = List<int>.filled(topK, 0);
  final topDistSq = List<double>.filled(topK, double.infinity);

  for (int i = 0; i < beadColors.length; i++) {
    final d76 = ColorDelta.deltaE76SqFromLab(labInput, beadColors[i].lab);
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

  var closest = beadColors[topIndices[0]];
  var minDist = _labDistFromValues(labInput, closest.lab);
  for (final idx in topIndices) {
    final dist = _labDistFromValues(labInput, beadColors[idx].lab);
    if (dist < minDist) {
      minDist = dist;
      closest = beadColors[idx];
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
  int targetGridW = 0,
  int offsetX = 0,
  int offsetY = 0,
  MergeIntensity mergeIntensity = MergeIntensity.medium,
}) {
  debugPrint('[珠子颜色] ===== 开始应用颜色筛选 =====');
  debugPrint('[珠子颜色] 当前颜色数: ${colorFrequency.length}');
  debugPrint('[珠子颜色] 目标颜色数: $maxColors');

  // 如果当前颜色数已经小于等于目标，无需处理
  if (colorFrequency.length <= maxColors) {
    debugPrint('[珠子颜色] 当前颜色数已满足要求，跳过筛选');
    return;
  }

  final labByCode = {
    for (final entry in beadColorMap.entries) entry.key: entry.value.lab,
  };

  final mergeMapping = ColorMergeUtil.buildMergeMapping(
    colorCount: colorFrequency,
    labByCode: labByCode,
    maxColors: maxColors,
    diversityThreshold: mergeIntensity.mergeThreshold,
  );

  if (mergeMapping.isEmpty) {
    debugPrint('[珠子颜色] 无需合并');
    return;
  }

  debugPrint('[珠子颜色] 合并映射 ${mergeMapping.length} 种色号');

  for (int row = 0; row < gridHeight; row++) {
    for (int col = 0; col < gridWidth; col++) {
      final effectiveW = targetGridW > 0 ? targetGridW : gridWidth;
      final gridIndex = (row + offsetY) * effectiveW + (col + offsetX);
      final currentColorCode = gridCodes[gridIndex];
      if (currentColorCode.isEmpty) continue;

      final remappedCode =
          ColorMergeUtil.resolveCode(currentColorCode, mergeMapping);
      if (remappedCode == currentColorCode) continue;

      gridCodes[gridIndex] = remappedCode;

      final remappedColor = beadColorMap[remappedCode];
      if (remappedColor == null) continue;

      final startX = xGridLines[col];
      final startY = yGridLines[row];
      final endX = xGridLines[col + 1];
      final endY = yGridLines[row + 1];

      _fillGridBlock(
        image,
        startX,
        startY,
        endX,
        endY,
        remappedColor,
      );
    }
  }

  final finalColorCount =
      gridCodes.where((c) => c.isNotEmpty).toSet().length;
  debugPrint('[珠子颜色] ===== 颜色筛选完成 =====');
  debugPrint('[珠子颜色] 筛选后颜色数: $finalColorCount');
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

    // 内部区域采样用中值滤波图，边界格仍用原图（保留轮廓）
    final smoothedImage = _medianFilter3x3(imageToProcess);

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

    // 阶段一：收集每格块均色样本
    final blockSamples = <BlockColorSample>[];

    for (int row = 0; row < gridHeight; row++) {
      final startY = yGridLines[row];
      final endY = yGridLines[row + 1];
      final actualHeight = endY - startY;

      for (int col = 0; col < gridWidth; col++) {
        final gridIndex = (row + offsetY) * targetGridW + (col + offsetX);
        final startX = xGridLines[col];
        final endX = xGridLines[col + 1];
        final actualWidth = endX - startX;
        final isBoundary = _isBoundaryBlock(
          imageToProcess,
          startX,
          startY,
          actualWidth,
          actualHeight,
        );

        final avgColor = _calculateAverageColor(
          isBoundary ? imageToProcess : smoothedImage,
          startX,
          startY,
          actualWidth,
          actualHeight,
          isBoundary: isBoundary,
        );

        blockSamples.add(BlockColorSample(
          gridIndex: gridIndex,
          row: row,
          col: col,
          r: avgColor.r,
          g: avgColor.g,
          b: avgColor.b,
          weight: actualWidth * actualHeight,
          isBoundary: isBoundary,
        ));
      }
    }

    // 阶段二：密度聚类 → 主色集合
    final clusterK = ColorClusterUtil.resolveClusterCount(
      colorLimit: params.colorLimit,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      blockCount: blockSamples.length,
    );
    final kMeansResult = ColorClusterUtil.kMeansWeighted(blockSamples, clusterK);
    final centroids = kMeansResult.centroids;

    // 阶段三：聚类中心 → 珠色，合并映射到同一珠色的簇
    final rawBeadCodes = <String>[];
    for (final centroid in centroids) {
      final bead = _findClosestBeadColor(
        centroid.r.round(),
        centroid.g.round(),
        centroid.b.round(),
        params.beadColors,
      );
      rawBeadCodes.add(bead.code);
    }

    final merged = ColorClusterUtil.mergeClustersByBeadCode(
      centroids: centroids,
      beadCodes: rawBeadCodes,
      samples: blockSamples,
      sampleAssignments: kMeansResult.assignments,
    );
    final masterBeadCodes = merged.beadCodes;

    final masterBeadCodesResolved = <String>[];
    final masterBeadLabs = <List<double>>[];
    for (final code in masterBeadCodes) {
      final bead = params.beadColorMap[code];
      if (bead != null) {
        masterBeadCodesResolved.add(code);
        masterBeadLabs.add(bead.lab);
      }
    }

    debugPrint(
      '[聚类映射] K=$clusterK → ${merged.centroids.length}簇 / '
      '${masterBeadCodes.length}种主色珠色: '
      '${masterBeadCodes.take(8)}${masterBeadCodes.length > 8 ? '...' : ''}',
    );

    // 阶段四：每格在已定主色号集合内做 ΔE00 最近映射（不经过簇中心中转）
    for (final sample in blockSamples) {
      final beadCode = ColorClusterUtil.nearestMasterBeadCode(
        sample,
        masterBeadCodesResolved,
        masterBeadLabs,
      );
      if (beadCode.isEmpty) continue;

      final beadColor = params.beadColorMap[beadCode];
      if (beadColor == null) continue;

      gridCodes[sample.gridIndex] = beadCode;
      colorFrequency[beadCode] = (colorFrequency[beadCode] ?? 0) + 1;

      final startX = xGridLines[sample.col];
      final startY = yGridLines[sample.row];
      final endX = xGridLines[sample.col + 1];
      final endY = yGridLines[sample.row + 1];

      _fillGridBlock(
        pixelizedImage,
        startX,
        startY,
        endX,
        endY,
        beadColor,
      );
    }

    final boundaryGridIndices = {
      for (final s in blockSamples)
        if (s.isBoundary) s.gridIndex,
    };
    _applyInteriorSpatialVote(
      gridCodes: gridCodes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      beadColorMap: params.beadColorMap,
      boundaryGridIndices: boundaryGridIndices,
      pixelizedImage: pixelizedImage,
      xGridLines: xGridLines,
      yGridLines: yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
      mergeThreshold: params.mergeIntensity.mergeThreshold,
    );

    // 阶段四 B：边界格精修（深色描边统一 + 对比度优化）
    var boundaryRefined = 0;
    for (final sample in blockSamples) {
      if (!sample.isBoundary) continue;

      final neighborLabs = _neighborFillLabs(
        sample.row,
        sample.col,
        gridCodes,
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        beadColorMap: params.beadColorMap,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
      if (neighborLabs.length < 2) continue;

      final refinedCode = ColorClusterUtil.nearestMasterBeadCodeWithContrast(
        sample,
        masterBeadCodesResolved,
        masterBeadLabs,
        neighborLabs,
      );
      if (refinedCode.isEmpty) continue;

      final currentCode = gridCodes[sample.gridIndex];
      if (refinedCode == currentCode) continue;

      gridCodes[sample.gridIndex] = refinedCode;
      colorFrequency[currentCode] = (colorFrequency[currentCode] ?? 1) - 1;
      if (colorFrequency[currentCode]! <= 0) colorFrequency.remove(currentCode);
      colorFrequency[refinedCode] = (colorFrequency[refinedCode] ?? 0) + 1;
      boundaryRefined++;

      final beadColor = params.beadColorMap[refinedCode];
      if (beadColor == null) continue;

      _fillGridBlock(
        pixelizedImage,
        xGridLines[sample.col],
        yGridLines[sample.row],
        xGridLines[sample.col + 1],
        yGridLines[sample.row + 1],
        beadColor,
      );
    }
    if (boundaryRefined > 0) {
      debugPrint('[轮廓映射] 边界格精修: $boundaryRefined 格');
    }

    // 阶段四 C：深色描边统一（消除黑/深灰珠色交织）
    var outlineUnified = 0;
    for (final sample in blockSamples) {
      final currentCode = gridCodes[sample.gridIndex];
      if (currentCode.isEmpty) continue;

      final currentBead = params.beadColorMap[currentCode];
      if (currentBead == null) continue;

      final neighborLabs = _neighborFillLabs(
        sample.row,
        sample.col,
        gridCodes,
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        beadColorMap: params.beadColorMap,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
      if (neighborLabs.isEmpty) continue;

      final avgNeighborL =
          neighborLabs.map((l) => l[0]).reduce((a, b) => a + b) /
              neighborLabs.length;
      if (avgNeighborL < 50) continue;

      final isDarkContext =
          sample.lab[0] < 48 || currentBead.lab[0] < 52;
      if (!isDarkContext) continue;

      final unifiedCode = ColorClusterUtil.nearestDarkestOutlineBead(
        sample.lab,
        masterBeadCodesResolved,
        masterBeadLabs,
        neighborLabs,
      );
      if (unifiedCode == null || unifiedCode == currentCode) continue;

      gridCodes[sample.gridIndex] = unifiedCode;
      colorFrequency[currentCode] = (colorFrequency[currentCode] ?? 1) - 1;
      if (colorFrequency[currentCode]! <= 0) colorFrequency.remove(currentCode);
      colorFrequency[unifiedCode] = (colorFrequency[unifiedCode] ?? 0) + 1;
      outlineUnified++;

      final beadColor = params.beadColorMap[unifiedCode];
      if (beadColor == null) continue;

      _fillGridBlock(
        pixelizedImage,
        xGridLines[sample.col],
        yGridLines[sample.row],
        xGridLines[sample.col + 1],
        yGridLines[sample.row + 1],
        beadColor,
      );
    }
    if (outlineUnified > 0) {
      debugPrint('[轮廓映射] 深色描边统一: $outlineUnified 格');
    }

    debugPrint('[珠子颜色] 聚类映射后珠子颜色数: ${colorFrequency.length}');

    // 连通块后处理：孤立杂色 + 微小色块（减色之前，避免稀有色被错误合并）
    _runPostProcess(
      gridCodes,
      gridWidth,
      gridHeight,
      params.beadColorMap,
      params.mergeIntensity,
      pixelizedImage,
      xGridLines,
      yGridLines,
      targetGridW: targetGridW,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    // 后处理后重新统计颜色频率
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
    debugPrint('[珠子颜色] 后处理后颜色数: ${colorFrequency.length}');
    debugPrint('[珠子颜色] params.colorLimit: ${params.colorLimit}');

    // 聚类阶段已按 colorLimit 控色时，跳过二次减色，避免过度合并
    final skipSecondaryColorMerge = params.colorLimit > 0 &&
        colorFrequency.length <= params.colorLimit;

    if (params.colorLimit > 0 && !skipSecondaryColorMerge) {
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
        mergeIntensity: params.mergeIntensity,
      );
    } else if (params.colorLimit > 0) {
      debugPrint('[珠子颜色] 聚类已满足色号上限(${colorFrequency.length}/${params.colorLimit})，跳过二次减色');
    } else {
      debugPrint('[珠子颜色] ℹ️ 无颜色限制，不进行筛选');
    }

    // 减色后再次后处理（中/高档合并强度）
    if (params.mergeIntensity != MergeIntensity.low) {
      _runPostProcess(
        gridCodes,
        gridWidth,
        gridHeight,
        params.beadColorMap,
        params.mergeIntensity,
        pixelizedImage,
        xGridLines,
        yGridLines,
        targetGridW: targetGridW,
        offsetX: offsetX,
        offsetY: offsetY,
      );
      debugPrint('[珠子颜色] 二次后处理完成，颜色数: ${gridCodes.where((c) => c.isNotEmpty).toSet().length}');
    }

    debugPrint('[珠子颜色] 最终显示的颜色数: ${gridCodes.toSet().length}');
    debugPrint('[珠子颜色] 使用的珠子颜色代码: ${gridCodes.toSet().toList().take(10)}${gridCodes.toSet().length > 10 ? '...' : ''}');

    // 验证所有像素都被填充（仅 debug）
    if (kDebugMode) {
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
    MergeIntensity mergeIntensity = MergeIntensity.medium,
  }) async {
    try {
      debugPrint('[像素化] ===== 开始处理 (bytes模式) =====');
      debugPrint('[像素化] 图片大小: ${imageBytes.length} bytes');
      debugPrint('[像素化] 网格大小: ${gridWidth}x${gridHeight}');
      debugPrint('[像素化] 颜色库: ${brand.displayName}');
      debugPrint('[像素化] 颜色库路径: ${brand.jsonPath}');
      debugPrint('[像素化] 颜色限制: ${colorLimit?.label ?? '无限制'}');
      debugPrint('[像素化] 合并强度: ${mergeIntensity.label} (ΔE00≤${mergeIntensity.mergeThreshold})');

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
        mergeIntensity: mergeIntensity,
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
    BeadBrand brand, {
    MergeIntensity mergeIntensity = MergeIntensity.medium,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    return pixelizeImageFromBytes(
      imageBytes,
      gridWidth,
      gridHeight,
      colorLimit,
      brand,
      mergeIntensity: mergeIntensity,
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
