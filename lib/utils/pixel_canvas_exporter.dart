import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import 'package:flutter_frame/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_frame/constants/app_values.dart';

/// 像素画布离屏导出器
///
/// 将像素数据渲染为高清 PNG 图片，不依赖屏幕尺寸。
/// 从 [PixelizeResultController] 中提取的纯渲染逻辑。
class PixelCanvasExporter {
  PixelCanvasExporter._();

  static const String _headerLogoAsset =
      'assets/icons/icon_export_header_logo.webp';
  static const String _statsTipsAsset =
      'assets/icons/icon_export_tips.png';
  static const String _defaultWorkTitle = '本地草稿';
  static const String _defaultUserNickname = '';
  static const String _brandAppName = '拼豆社区';
  static const String _brandSlogan = '让每一颗豆子都有灵魂';

  static const Color _frameBgColor = Color(0xFFFFFDF6);
  static const Color _frameBorderColor = Color(0xFFF9B067);
  static const Color _statsAccentColor = Color(0xFFFDB32A);

  // ── 导出图分区调参指南（改尺寸优先看这里）────────────────────────────
  //
  // 【画板区清晰度 / 整图分辨率】→ export() 内：
  //   - pixelSize 入参默认值（调用方 saveCanvasImage / 图纸预览 onTapExport）
  //   - maxImageDimension、maxCanvasPixelCount（GPU 上限，过大 Android 易崩溃）
  //   - _initialPixelSize 的 chromeReserve（品牌框占用的布局预算比例）
  //
  // 【外框整体】→ 本区常量 + _BrandFrameLayout.fromContentWidth 返回值：
  //   - _brandChromeCompactFactor：头尾整体缩放（越小画板越大）
  //   - _maxBrandUiScale / _brandUiLargeCanvasBoost：大图时品牌 UI 随画板变大的幅度
  //   - outerMargin / innerPadH / innerPadV / borderRadius（fromContentWidth 内）
  //
  // 【头部 Logo + 左右文字】→ fromContentWidth 内 headerScale 段：
  //   - _headerChromeBoost：头部总体系数（首选，只影响题头）
  //   - logoSize、workTitleFontSize、workMetaFontSize（左：作品名@用户、规格行）
  //   - brandTitleFontSize、brandSloganFontSize（右：拼豆社区、slogan）
  //   - headerGap / headerSideGap / headerBottomGap（题头内部间距）
  //   绘制逻辑：_drawBrandHeader
  //
  // 【尾部「色号统计」一行】→ fromContentWidth 内 statsScale 段：
  //   - _footerStatsBoost：统计栏总体系数（首选，不含下方 chip）
  //   - statsBarHeight、statsFontSize、statsIconWidth/Height、statsIconGap、statsPaletteGap
  //   绘制逻辑：_drawBrandFooterStatsBar
  //
  // 【尾部色号 chip 列表】→ fromContentWidth 内 scale 段（无单独 boost）：
  //   - chipHeight、chipFontSize、chipSwatchSize、chipPaddingH、chipGap、chipMinWidth
  //   绘制逻辑：_drawBrandColorChips
  //
  // 【导出标题/昵称文案】→ 调用 export 时传入 workTitle、userNickname（非本文件尺寸）
  // ────────────────────────────────────────────────────────────────────

  /// 设计稿内容区参考宽度（375 屏宽减去左右外边距与内边距）
  static const double _designContentWidth = 345.0;

  /// 品牌框 UI（题头/统计栏/色块）最大缩放
  static const double _maxBrandUiScale = 4.3;

  /// 相对设计稿宽度，大图时品牌区额外放大系数
  static const double _brandUiLargeCanvasBoost = 0.38;

  /// 头部/尾部整体紧凑系数（略缩小 chrome，把像素预算让给画板区）
  static const double _brandChromeCompactFactor = 0.86;

  /// 题头 Logo/文字相对尾部额外放大（仅头部，不影响底部色号区）
  static const double _headerChromeBoost = 1.3;

  /// 尾部「色号统计」栏文字/图标放大（不含下方色号 chip 列表）
  static const double _footerStatsBoost = 1.28;

  /// 导出像素画布为 PNG 字节数据
  ///
  /// [codes] 像素颜色代码列表
  /// [gridWidth] / [gridHeight] 网格尺寸
  /// [beadColorMap] 颜色代码→Color 映射
  /// [pixelSize] 每个像素块的输出像素大小，默认80
  /// [circleMode] 是否使用圆形像素块
  /// [showText] 是否在像素块上绘制颜色代码文字
  /// [showGrid] 是否绘制网格线
  /// [showBoldGrid] 是否绘制粗分割线（启用后使用下方网格参数）
  /// [showNumberBorder] 是否绘制四周编号边框
  /// [showColorLegend] 是否在底部绘制颜色图例
  /// [gridSpacing] 粗线间隔格子数，默认9
  /// [gridThickness] 粗线宽度，默认3.0
  /// [gridColor] 粗线颜色，默认黑色
  /// [gridStartPoint] 网格起始偏移（格子数），默认(1,1)
  /// [centerDashShow] 是否显示中心虚线
  static Future<Uint8List?> export({
    required List<String> codes,
    required int gridWidth,
    required int gridHeight,
    required Map<String, Color> beadColorMap,
    int pixelSize = 108,
    bool circleMode = false,
    bool showText = true,
    bool showGrid = true,
    bool showBoldGrid = false,
    bool showNumberBorder = false,
    bool showColorLegend = false,
    // 网格配置（showBoldGrid 为 true 时生效）
    int gridSpacing = 10,
    double gridThickness = 3.0,
    Color gridColor = const Color(0xFF000000),
    Offset gridStartPoint = const Offset(1, 1),
    bool centerDashShow = false,
    bool showBrandFrame = false,
    String? beadBrandName,
    int? beadBrandPaletteSize,
    String? workTitle,
    String? userNickname,
  }) async {
    try {
      final w = gridWidth;
      final h = gridHeight;

      if (codes.isEmpty || w == 0 || h == 0) return null;

      ui.Image? headerLogo;
      ui.Image? statsTipsIcon;
      if (showBrandFrame) {
        headerLogo = await _loadAssetImage(_headerLogoAsset);
        statsTipsIcon = await _loadAssetImage(_statsTipsAsset);
        if (headerLogo == null) {
          debugPrint('[CanvasExporter] 题头 Logo 加载失败，跳过品牌外框');
        }
      }

      final useBrandFrame = showBrandFrame && headerLogo != null;

      final resolvedWorkTitle = workTitle?.trim().isNotEmpty == true
          ? workTitle!.trim()
          : _defaultWorkTitle;
      final resolvedNickname = userNickname?.trim().isNotEmpty == true
          ? userNickname!.trim()
          : _defaultUserNickname;
      final workTitleLine = '$resolvedWorkTitle@$resolvedNickname';
      final colorCount =
          codes.where((code) => code.isNotEmpty).toSet().length;

      // 限制导出总像素与最长边，避免 Android Impeller/Vulkan GPU OOM（ErrorDeviceLost）
      // 32MP/120px 在部分 Adreno 设备会崩溃；26MP 约为实测稳定上限（~4600×5400）
      const int maxImageDimension = 8080;
      const int maxCanvasPixelCount = 29 * 1000 * 1000; // ~28MP
      const int absoluteMinCellSize = 8;
      final int maxGridSide = w > h ? w : h;

      int effectivePixelSize = _initialPixelSize(
        maxGridSide: maxGridSide,
        pixelSize: pixelSize,
        maxImageDimension: maxImageDimension,
        showNumberBorder: showNumberBorder,
        useBrandFrame: useBrandFrame,
      );

      late _ExportMetrics metrics;
      for (var i = 0; i < 48; i++) {
        metrics = _computeMetrics(
          gridWidth: w,
          gridHeight: h,
          effectivePixelSize: effectivePixelSize,
          codes: codes,
          showNumberBorder: showNumberBorder,
          showColorLegend: showColorLegend,
          useBrandFrame: useBrandFrame,
        );
        if (_fitsExportGpuBudget(
          metrics,
          maxImageDimension: maxImageDimension,
          maxCanvasPixelCount: maxCanvasPixelCount,
        )) {
          break;
        }
        final nextSize = math.max(
          absoluteMinCellSize,
          (effectivePixelSize * 0.9).floor(),
        );
        if (nextSize >= effectivePixelSize) break;
        effectivePixelSize = nextSize;
      }

      if (!_fitsExportGpuBudget(
        metrics,
        maxImageDimension: maxImageDimension,
        maxCanvasPixelCount: maxCanvasPixelCount,
      )) {
        debugPrint(
          '[CanvasExporter] 导出尺寸仍偏大: '
          '${metrics.canvasWidth}x${metrics.canvasHeight}',
        );
      }

      final totalWidth = metrics.contentWidth;
      final imgWidth = metrics.imgWidth;
      final imgHeight = metrics.imgHeight;
      final numberBorder = metrics.numberBorder;
      final gridAreaHeight = imgHeight + numberBorder * 2;
      final totalBeadCount =
          codes.where((code) => code.isNotEmpty).length;
      final legendHeight = metrics.legendHeight;
      final legendPadding = metrics.legendPadding;
      final legendItemHeight = metrics.legendItemHeight;
      final legendFontSize = metrics.legendFontSize;
      final legendSwatchSize = metrics.legendSwatchSize;
      final legendTitleHeight = metrics.legendTitleHeight;
      final frameLayout = metrics.frameLayout;

      // 创建离屏 Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(
          0,
          0,
          metrics.canvasWidth.toDouble(),
          metrics.canvasHeight.toDouble(),
        ),
      );

      if (useBrandFrame && frameLayout != null && headerLogo != null) {
        _drawBrandFrame(
          canvas,
          metrics.canvasWidth.toDouble(),
          metrics.canvasHeight.toDouble(),
          frameLayout,
        );
        canvas.save();
        canvas.translate(
          frameLayout.contentOriginX,
          frameLayout.contentOriginY,
        );
        _drawBrandHeader(
          canvas: canvas,
          headerRect: Rect.fromLTWH(
            0,
            0,
            totalWidth.toDouble(),
            frameLayout.headerContentHeight,
          ),
          logo: headerLogo,
          layout: frameLayout,
          workTitleLine: workTitleLine,
          workMetaLine: '[${w}x$h/$colorCount色/共$totalBeadCount颗]',
        );
        canvas.save();
        canvas.translate(0, frameLayout.headerHeight);
      }

      // 编号边框背景
      if (showNumberBorder) {
        final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
        canvas.drawRect(
            Rect.fromLTWH(0, 0, totalWidth.toDouble(), numberBorder.toDouble()),
            bgPaint);
        canvas.drawRect(
            Rect.fromLTWH(0, (numberBorder + imgHeight).toDouble(),
                totalWidth.toDouble(), numberBorder.toDouble()),
            bgPaint);
        canvas.drawRect(
            Rect.fromLTWH(0, numberBorder.toDouble(), numberBorder.toDouble(),
                imgHeight.toDouble()),
            bgPaint);
        canvas.drawRect(
            Rect.fromLTWH(
                (numberBorder + imgWidth).toDouble(),
                numberBorder.toDouble(),
                numberBorder.toDouble(),
                imgHeight.toDouble()),
            bgPaint);
      }

      // 偏移画布到编号边框内部区域
      canvas.save();
      if (showNumberBorder) {
        canvas.translate(numberBorder.toDouble(), numberBorder.toDouble());
      }

      // 绘制像素块
      _drawPixelBlocks(canvas, codes, w, h, effectivePixelSize, circleMode, beadColorMap);



      // 绘制粗分割线（使用完整网格配置）
      if (showBoldGrid) {
        _drawBoldGridLines(
          canvas, w, h, effectivePixelSize, imgWidth, imgHeight,
          gridSpacing: gridSpacing,
          gridThickness: gridThickness,
          gridColor: gridColor,
          gridStartPoint: gridStartPoint,
          centerDashShow: centerDashShow,
        );
      }
      // 绘制网格线
      if (showGrid) {
        _drawGridLines(canvas, w, h, effectivePixelSize, imgWidth, imgHeight);
      }

      // 绘制颜色代码文本
      if (showText) {
        _drawColorCodes(canvas, codes, w, h, effectivePixelSize, beadColorMap);
      }

      // 绘制编号边框和图例
      canvas.restore();

      if (showNumberBorder) {
        final nb = numberBorder.toDouble();
        final eps = effectivePixelSize.toDouble();

        // 边框线
        final borderLinePaint = Paint()
          ..color = const Color(0xFFCCCCCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRect(
            Rect.fromLTWH(nb, nb, imgWidth.toDouble(), imgHeight.toDouble()),
            borderLinePaint);

        // 分割线刻度
        final tickPaint = Paint()
          ..color = const Color(0xFFCCCCCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        for (int col = 0; col <= w; col++) {
          final x = nb + col * eps;
          canvas.drawLine(Offset(x, 0), Offset(x, nb), tickPaint);
          canvas.drawLine(Offset(x, nb + imgHeight.toDouble()),
              Offset(x, gridAreaHeight.toDouble()), tickPaint);
        }

        for (int row = 0; row <= h; row++) {
          final y = nb + row * eps;
          canvas.drawLine(Offset(0, y), Offset(nb, y), tickPaint);
          canvas.drawLine(Offset(nb + imgWidth.toDouble(), y),
              Offset(totalWidth.toDouble(), y), tickPaint);
        }

        // 编号字体
        final fontSize = (eps * 0.4).clamp(6.0, nb * 0.7);
        final textStyle =
            TextStyle(fontSize: fontSize, color: const Color(0xFF999999));
        final textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            textWidthBasis: TextWidthBasis.longestLine);

        // 列号
        for (int col = 0; col < w; col++) {
          final text = (col + 1).toString();
          textPainter.text = TextSpan(text: text, style: textStyle);
          textPainter.layout();
          final centerX = nb + (col + 0.5) * eps;
          textPainter.paint(
              canvas,
              Offset(centerX - textPainter.width / 2,
                  (nb - textPainter.height) / 2));
          textPainter.paint(
              canvas,
              Offset(centerX - textPainter.width / 2,
                  nb + imgHeight + (nb - textPainter.height) / 2));
        }

        // 行号
        for (int row = 0; row < h; row++) {
          final text = (row + 1).toString();
          textPainter.text = TextSpan(text: text, style: textStyle);
          textPainter.layout();
          final centerY = nb + (row + 0.5) * eps;
          textPainter.paint(
              canvas,
              Offset((nb - textPainter.width) / 2,
                  centerY - textPainter.height / 2));
          textPainter.paint(
              canvas,
              Offset(nb + imgWidth + (nb - textPainter.width) / 2,
                  centerY - textPainter.height / 2));
        }
      }

      if (useBrandFrame && frameLayout != null) {
        canvas.restore();
        final footerTop = frameLayout.headerHeight + gridAreaHeight.toDouble();
        _drawBrandFooterStatsBar(
          canvas: canvas,
          top: footerTop,
          width: totalWidth.toDouble(),
          layout: frameLayout,
          tipsIcon: statsTipsIcon,
          beadBrandName: beadBrandName ?? 'MARD',
          beadBrandPaletteSize: beadBrandPaletteSize ?? 0,
          totalBeadCount: totalBeadCount,
        );
        if (showColorLegend && metrics.chipsHeight > 0) {
          _drawBrandColorChips(
            canvas: canvas,
            codes: codes,
            beadColorMap: beadColorMap,
            top: footerTop + frameLayout.statsBarHeight,
            width: totalWidth.toDouble(),
            layout: frameLayout,
            chipsPerRow: metrics.brandChipsPerRow,
          );
        }
        canvas.restore();
      } else if (showColorLegend && legendHeight > 0) {
        _drawColorLegend(
          canvas,
          codes,
          beadColorMap,
          totalWidth,
          imgHeight,
          numberBorder,
          legendPadding,
          legendItemHeight,
          legendFontSize,
          legendSwatchSize,
          legendTitleHeight,
          legendHeight,
        );
      }

      headerLogo?.dispose();
      statsTipsIcon?.dispose();

      // 生成图片
      final picture = recorder.endRecording();
      ui.Image? image;
      try {
        image = await picture.toImage(
          metrics.canvasWidth,
          metrics.canvasHeight,
        );
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return null;
        return byteData.buffer.asUint8List();
      } finally {
        picture.dispose();
        image?.dispose();
      }
    } catch (e) {
      debugPrint('[CanvasExporter] 导出失败: $e');
      return null;
    }
  }

  /// 生成图片 → 轻量 Loading → 展示预览 → 保存相册 → 系统分享（分享后保留预览）
  static Future<void> presentSaveAndShare({
    required Future<Uint8List?> Function() generateBytes,
    String shareText = '像素画作品',
    String savedToastMessage = '已保存到相册',
  }) async {
    AppOverlay.dialog.showLoading(message: '正在生成图片...');
    Uint8List? bytes;
    try {
      bytes = await generateBytes();
    } finally {
      AppOverlay.dialog.hideLoading();
    }

    if (bytes == null) {
      showToast('保存失败：无法生成图片');
      return;
    }

    final filePath =
        '${Directory.systemTemp.path}/pixel_export_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(filePath).writeAsBytes(bytes);

    try {
      await AppOverlay.dialog.customAsync<void>(
        child: _ExportPreviewDialog(
          imageBytes: bytes,
          filePath: filePath,
          shareText: shareText,
          savedToastMessage: savedToastMessage,
        ),
      );
    } finally {
      if (await File(filePath).exists()) {
        await File(filePath).delete();
      }
    }
  }

  /// 草稿列表缩略图：仅绘制色块，不套用导出可读性下限，避免 104×104 被放大到数千像素
  ///
  /// [maxOutputDimension] 为输出图最长边上限（列表展示足够即可）
  static Future<Uint8List?> exportThumbnail({
    required List<String> codes,
    required int gridWidth,
    required int gridHeight,
    required Map<String, Color> beadColorMap,
    bool circleMode = false,
    int maxOutputDimension = 400,
  }) async {
    try {
      final w = gridWidth;
      final h = gridHeight;
      if (codes.isEmpty || w <= 0 || h <= 0) return null;

      final maxSide = w > h ? w : h;
      final cellSize = math.max(1, maxOutputDimension ~/ maxSide);
      final imgWidth = w * cellSize;
      final imgHeight = h * cellSize;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, imgWidth.toDouble(), imgHeight.toDouble()),
        Paint()..color = Colors.white,
      );
      _drawPixelBlocks(
        canvas,
        codes,
        w,
        h,
        cellSize,
        circleMode,
        beadColorMap,
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(imgWidth, imgHeight);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('[CanvasExporter] 缩略图导出失败: $e');
      return null;
    }
  }

  /// 导出画布是否落在移动端 GPU 可承受范围内
  static bool _fitsExportGpuBudget(
    _ExportMetrics metrics, {
    required int maxImageDimension,
    required int maxCanvasPixelCount,
  }) {
    final cw = metrics.canvasWidth;
    final ch = metrics.canvasHeight;
    if (cw <= 0 || ch <= 0) return true;
    return math.max(cw, ch) <= maxImageDimension &&
        cw * ch <= maxCanvasPixelCount;
  }

  /// 按网格边长保证单元格最低可读像素，避免 104×104 等大图色号看不清
  static int _minReadableCellSize(int maxGridSide) {
    if (maxGridSide <= 48) return 80;
    if (maxGridSide <= 64) return 64;
    if (maxGridSide <= 80) return 56;
    if (maxGridSide <= 104) return 48;
    if (maxGridSide <= 128) return 40;
    return 32;
  }

  static int _initialPixelSize({
    required int maxGridSide,
    required int pixelSize,
    required int maxImageDimension,
    required bool showNumberBorder,
    required bool useBrandFrame,
  }) {
    final minCell = _minReadableCellSize(maxGridSide);
    final chromeReserve = useBrandFrame ? (maxImageDimension * 0.13).toInt() : 0;
    final gridBudget = maxImageDimension - chromeReserve;
    final gridCap = gridBudget ~/ maxGridSide;

    int eps;
    if (showNumberBorder) {
      final capped = gridBudget ~/ (maxGridSide + 3);
      if (maxGridSide * pixelSize <= gridBudget - 3 * pixelSize) {
        eps = pixelSize;
      } else {
        eps = capped;
      }
    } else {
      eps = maxGridSide * pixelSize > gridBudget
          ? gridCap
          : pixelSize;
    }

    return math.max(minCell, math.min(eps, gridCap));
  }

  static _ExportMetrics _computeMetrics({
    required int gridWidth,
    required int gridHeight,
    required int effectivePixelSize,
    required List<String> codes,
    required bool showNumberBorder,
    required bool showColorLegend,
    required bool useBrandFrame,
  }) {
    final imgWidth = gridWidth * effectivePixelSize;
    final imgHeight = gridHeight * effectivePixelSize;
    final numberBorder =
        showNumberBorder ? (effectivePixelSize * 1.5).toInt() : 0;
    final contentWidth = imgWidth + numberBorder * 2;
    final gridAreaHeight = imgHeight + numberBorder * 2;

    final legendPadding = effectivePixelSize * 0.5;
    final legendItemHeight = effectivePixelSize * 1.2;
    final legendFontSize = (effectivePixelSize * 0.28).clamp(8.0, 16.0);
    final legendSwatchSize = legendFontSize * 1.8;
    final legendTitleHeight = effectivePixelSize * 1.5;

    final uniqueCodes = codes.toSet().where((c) => c.isNotEmpty).toList();
    final codeUsageMap = <String, int>{};
    for (final code in codes) {
      if (code.isNotEmpty) {
        codeUsageMap[code] = (codeUsageMap[code] ?? 0) + 1;
      }
    }

    final frameLayout = useBrandFrame
        ? _BrandFrameLayout.fromContentWidth(contentWidth.toDouble())
        : null;

    var legendHeight = 0;
    var chipsHeight = 0.0;
    var brandChipsPerRow = 0;
    if (useBrandFrame && frameLayout != null) {
      if (showColorLegend && uniqueCodes.isNotEmpty) {
        brandChipsPerRow =
            frameLayout.resolveChipsPerRow(uniqueCodes, codeUsageMap);
        chipsHeight =
            frameLayout.chipsAreaHeight(uniqueCodes.length, brandChipsPerRow);
        legendHeight = chipsHeight.round();
      }
    } else if (showColorLegend) {
      final colorsPerRow =
          (contentWidth / (legendSwatchSize * 4)).floor().clamp(4, 12);
      final colorRows = (uniqueCodes.length / colorsPerRow).ceil();
      legendHeight = (legendTitleHeight +
              legendPadding +
              colorRows * legendItemHeight +
              legendPadding)
          .toInt();
    }

    final footerHeight = useBrandFrame && frameLayout != null
        ? frameLayout.statsBarHeight + chipsHeight
        : legendHeight.toDouble();
    final contentHeight = useBrandFrame && frameLayout != null
        ? (frameLayout.headerHeight + gridAreaHeight + footerHeight).round()
        : gridAreaHeight + legendHeight;

    final canvasWidth = useBrandFrame && frameLayout != null
        ? (contentWidth +
                2 * frameLayout.outerMargin +
                2 * frameLayout.innerPadH)
            .round()
        : contentWidth;
    final canvasHeight = useBrandFrame && frameLayout != null
        ? (contentHeight +
                2 * frameLayout.outerMargin +
                2 * frameLayout.innerPadV)
            .round()
        : contentHeight;

    return _ExportMetrics(
      effectivePixelSize: effectivePixelSize,
      imgWidth: imgWidth,
      imgHeight: imgHeight,
      numberBorder: numberBorder,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      legendHeight: legendHeight,
      chipsHeight: chipsHeight,
      brandChipsPerRow: brandChipsPerRow,
      legendPadding: legendPadding,
      legendItemHeight: legendItemHeight,
      legendFontSize: legendFontSize,
      legendSwatchSize: legendSwatchSize,
      legendTitleHeight: legendTitleHeight,
      frameLayout: frameLayout,
    );
  }

  static Future<ui.Image?> _loadAssetImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('[CanvasExporter] 加载资源失败 $assetPath: $e');
      return null;
    }
  }

  static void _drawBrandFrame(
    Canvas canvas,
    double width,
    double height,
    _BrandFrameLayout layout,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = _frameBgColor,
    );

    final borderRect = Rect.fromLTWH(
      layout.outerMargin,
      layout.outerMargin,
      width - layout.outerMargin * 2,
      height - layout.outerMargin * 2,
    );
    final rrect = RRect.fromRectAndRadius(
      borderRect,
      Radius.circular(layout.borderRadius),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _frameBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = layout.borderWidth,
    );
  }

  static TextPainter _layoutHeaderText(
    String text, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    double? maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: const Color(0xFF333333),
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );
    if (maxWidth != null) {
      painter.layout(maxWidth: maxWidth);
    } else {
      painter.layout();
    }
    return painter;
  }

  /// 题头：左侧作品信息，右侧品牌文案 + Logo（与设计稿一致）
  static void _drawBrandHeader({
    required Canvas canvas,
    required Rect headerRect,
    required ui.Image logo,
    required _BrandFrameLayout layout,
    required String workTitleLine,
    required String workMetaLine,
  }) {
    final logoSize = layout.logoSize;
    final logoLeft = headerRect.right - logoSize;
    final logoTop = headerRect.top + (headerRect.height - logoSize) / 2;

    final brandTitlePainter = _layoutHeaderText(
      _brandAppName,
      fontSize: layout.brandTitleFontSize,
      fontWeight: FontWeight.bold,
    );
    final brandSloganPainter = _layoutHeaderText(
      _brandSlogan,
      fontSize: layout.brandSloganFontSize,
    );
    final brandTextRight = logoLeft - layout.headerGap;
    final brandTextLeft = brandTextRight -
        math.max(brandTitlePainter.width, brandSloganPainter.width);
    final brandTextHeight = brandTitlePainter.height +
        layout.brandSloganGap +
        brandSloganPainter.height;
    final brandTextTop =
        headerRect.top + (headerRect.height - brandTextHeight) / 2;

    final leftMaxWidth = math.max(
      0.0,
      brandTextLeft - layout.headerSideGap - headerRect.left,
    );
    final workTitlePainter = _layoutHeaderText(
      workTitleLine,
      fontSize: layout.workTitleFontSize,
      fontWeight: FontWeight.bold,
      maxWidth: leftMaxWidth > 0 ? leftMaxWidth : null,
    );
    final workMetaPainter = _layoutHeaderText(
      workMetaLine,
      fontSize: layout.workMetaFontSize,
      maxWidth: leftMaxWidth > 0 ? leftMaxWidth : null,
    );
    final leftBlockHeight =
        workTitlePainter.height + layout.workMetaGap + workMetaPainter.height;
    final leftBlockTop =
        headerRect.top + (headerRect.height - leftBlockHeight) / 2;

    workTitlePainter.paint(
      canvas,
      Offset(headerRect.left, leftBlockTop),
    );
    workMetaPainter.paint(
      canvas,
      Offset(
        headerRect.left,
        leftBlockTop + workTitlePainter.height + layout.workMetaGap,
      ),
    );

    brandTitlePainter.paint(
      canvas,
      Offset(brandTextRight - brandTitlePainter.width, brandTextTop),
    );
    brandSloganPainter.paint(
      canvas,
      Offset(
        brandTextRight - brandSloganPainter.width,
        brandTextTop + brandTitlePainter.height + layout.brandSloganGap,
      ),
    );

    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      Rect.fromLTWH(logoLeft, logoTop, logoSize, logoSize),
      Paint(),
    );
  }

  static void _drawBrandFooterStatsBar({
    required Canvas canvas,
    required double top,
    required double width,
    required _BrandFrameLayout layout,
    required ui.Image? tipsIcon,
    required String beadBrandName,
    required int beadBrandPaletteSize,
    required int totalBeadCount,
  }) {
    final barHeight = layout.statsBarHeight;
    final centerY = top + barHeight / 2;

    var leftX = 0.0;
    if (tipsIcon != null) {
      final iconWidth = layout.statsIconWidth;
      final iconHeight = layout.statsIconHeight;
      final iconTop = centerY - iconHeight / 2;
      canvas.drawImageRect(
        tipsIcon,
        Rect.fromLTWH(
          0,
          0,
          tipsIcon.width.toDouble(),
          tipsIcon.height.toDouble(),
        ),
        Rect.fromLTWH(leftX, iconTop, iconWidth, iconHeight),
        Paint(),
      );
      leftX += iconWidth + layout.statsIconGap;
    }

    final leftTitlePainter = TextPainter(
      text: TextSpan(
        text: '色号统计',
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: layout.statsFontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    leftTitlePainter.layout();
    leftTitlePainter.paint(
      canvas,
      Offset(leftX, centerY - leftTitlePainter.height / 2),
    );
    leftX += leftTitlePainter.width + layout.statsPaletteGap;

    final paletteLabel = beadBrandPaletteSize > 0
        ? '当前色系: $beadBrandName $beadBrandPaletteSize'
        : '当前色系: $beadBrandName';
    final palettePainter = TextPainter(
      text: TextSpan(
        text: paletteLabel,
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: layout.statsFontSize,
          fontWeight: FontWeight.bold,
          color: _statsAccentColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    palettePainter.layout();
    palettePainter.paint(
      canvas,
      Offset(leftX, centerY - palettePainter.height / 2),
    );

    final totalPainter = TextPainter(
      text: TextSpan(
        text: '总计: $totalBeadCount颗',
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: layout.statsFontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    totalPainter.layout();
    totalPainter.paint(
      canvas,
      Offset(
        width - totalPainter.width,
        centerY - totalPainter.height / 2,
      ),
    );
  }

  static void _drawFooterDivider(
    Canvas canvas,
    double top,
    double width,
    _BrandFrameLayout layout,
  ) {
    final paint = Paint()
      ..color = _frameBorderColor
      ..strokeWidth = layout.footerDividerHeight;
    canvas.drawLine(
      Offset(0, top + layout.footerDividerHeight / 2),
      Offset(width, top + layout.footerDividerHeight / 2),
      paint,
    );
  }

  static void _drawBrandColorChips({
    required Canvas canvas,
    required List<String> codes,
    required Map<String, Color> beadColorMap,
    required double top,
    required double width,
    required _BrandFrameLayout layout,
    required int chipsPerRow,
  }) {
    if (chipsPerRow <= 0) return;

    _drawFooterDivider(canvas, top, width, layout);
    final chipsContentTop = top + layout.footerDividerHeight;

    final uniqueCodes = codes.toSet().where((c) => c.isNotEmpty).toList();
    final codeUsageMap = <String, int>{};
    for (final code in codes) {
      if (code.isNotEmpty) {
        codeUsageMap[code] = (codeUsageMap[code] ?? 0) + 1;
      }
    }
    uniqueCodes.sort(
      (a, b) => (codeUsageMap[b] ?? 0).compareTo(codeUsageMap[a] ?? 0),
    );

    final chipHeight = layout.chipHeight;
    final chipWidth =
        (width - (chipsPerRow - 1) * layout.chipGap) / chipsPerRow;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );

    for (int i = 0; i < uniqueCodes.length; i++) {
      final code = uniqueCodes[i];
      final row = i ~/ chipsPerRow;
      final col = i % chipsPerRow;
      final x = col * (chipWidth + layout.chipGap);
      final y = chipsContentTop +
          layout.chipTopPadding +
          row * (chipHeight + layout.chipGap);

      final chipRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, chipWidth, chipHeight),
        Radius.circular(layout.chipBorderRadius),
      );
      canvas.drawRRect(chipRect, Paint()..color = Colors.white);
      canvas.drawRRect(
        chipRect,
        Paint()
          ..color = _frameBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = layout.chipBorderWidth,
      );

      final swatchSize = layout.chipSwatchSize;
      final swatchLeft = x + layout.chipPaddingH;
      final swatchTop = y + (chipHeight - swatchSize) / 2;
      final color = beadColorMap[code] ?? const Color(0xFFB0B0B0);
      canvas.drawCircle(
        Offset(swatchLeft + swatchSize / 2, swatchTop + swatchSize / 2),
        swatchSize / 2,
        Paint()..color = color,
      );

      final count = codeUsageMap[code] ?? 0;
      final textLeft = swatchLeft + swatchSize + layout.chipTextGap;
      final textMaxWidth =
          chipWidth - (textLeft - x) - layout.chipPaddingH;
      textPainter.text = TextSpan(
        children: [
          TextSpan(
            text: code,
            style: TextStyle(
              fontFamily: kPFFont,
              fontSize: layout.chipFontSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          TextSpan(
            text: ' ${count}颗',
            style: TextStyle(
              fontFamily: kPFFont,
              fontSize: layout.chipFontSize,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      );
      textPainter.layout(maxWidth: math.max(0, textMaxWidth));
      textPainter.paint(
        canvas,
        Offset(
          textLeft,
          y + (chipHeight - textPainter.height) / 2,
        ),
      );
    }
  }

  /// 绘制像素块
  static void _drawPixelBlocks(Canvas canvas, List<String> codes, int w, int h,
      int effectivePixelSize, bool circleMode, Map<String, Color> beadColorMap) {
    final imgWidth = w * effectivePixelSize;
    final imgHeight = h * effectivePixelSize;
    for (int row = 0; row < h; row++) {
      for (int col = 0; col < w; col++) {
        final index = row * w + col;
        if (index >= codes.length) continue;

        final code = codes[index];
        if (code.isEmpty) continue;

        final color = beadColorMap[code];
        if (color == null) {
          // 颜色代码缺失时使用灰色
          canvas.drawRect(
            Rect.fromLTWH(
              col * effectivePixelSize.toDouble(),
              row * effectivePixelSize.toDouble(),
              effectivePixelSize.toDouble(),
              effectivePixelSize.toDouble(),
            ),
            Paint()..color = const Color(0xFFB0B0B0),
          );
          continue;
        }

        final paint = Paint()..color = color;

        if (circleMode) {
          final centerX =
              (col * effectivePixelSize + effectivePixelSize / 2).toDouble();
          final centerY =
              (row * effectivePixelSize + effectivePixelSize / 2).toDouble();
          final radius = effectivePixelSize / 2.0;
          canvas.drawCircle(Offset(centerX, centerY), radius, paint);
        } else {
          canvas.drawRect(
            Rect.fromLTWH(
              col * effectivePixelSize.toDouble(),
              row * effectivePixelSize.toDouble(),
              effectivePixelSize.toDouble(),
              effectivePixelSize.toDouble(),
            ),
            paint,
          );
        }
      }
    }
  }

  /// 绘制网格线
  static void _drawGridLines(Canvas canvas, int w, int h, int eps, int imgWidth, int imgHeight) {
    final gridPaint = Paint()
      ..color = const Color(0x4D000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= w; i++) {
      final x = i * eps.toDouble();
      canvas.drawLine(Offset(x, 0), Offset(x, imgHeight.toDouble()), gridPaint);
    }
    for (int i = 0; i <= h; i++) {
      final y = i * eps.toDouble();
      canvas.drawLine(Offset(0, y), Offset(imgWidth.toDouble(), y), gridPaint);
    }
  }

  /// 绘制粗分割线（支持完整网格配置）
  static void _drawBoldGridLines(
    Canvas canvas, int w, int h, int eps, int imgWidth, int imgHeight, {
    required int gridSpacing,
    required double gridThickness,
    required Color gridColor,
    required Offset gridStartPoint,
    required bool centerDashShow,
  }) {
    debugPrint('[CanvasExporter] 绘制粗分割线 gridSpacing= $gridSpacing, gridThickness=  $gridThickness');
    
    // 以画布上标准格子宽度(约45px)为基准，等比缩放线宽和虚线段长
    const double referenceBlockSize = 10.0;
    final scale = eps.toDouble() / referenceBlockSize;
    final scaledThickness = (gridThickness * scale).clamp(2.0, gridThickness * 6);
    
    final boldPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledThickness;

    // 起始偏移（格子数）
    final startX = gridStartPoint.dx.toInt();
    final startY = gridStartPoint.dy.toInt();

    // 绘制粗分割线
    for (int i = startX; i < w; i += gridSpacing) {
      final x = i * eps.toDouble();
      canvas.drawLine(Offset(x, 0), Offset(x, imgHeight.toDouble()), boldPaint);
    }
    for (int i = startY; i < h; i += gridSpacing) {
      final y = i * eps.toDouble();
      canvas.drawLine(Offset(0, y), Offset(imgWidth.toDouble(), y), boldPaint);
    }

    // 中虚线：粗线之间的中线位置画同色虚线（横竖方向）
    if (centerDashShow && w > 1 && h > 1) {
      final dashPaint = Paint()
        ..color = gridColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = scaledThickness;

      final dashLength = (6.0 * scale).clamp(5.0, 24.0);
      final gapLength = (4.0 * scale).clamp(4.0, 14.0);

      // centerStep: 粗线间隔的一半，即中虚线的偏移量
      final centerStep = gridSpacing ~/ 2;

      // 纵向中虚线（从起始偏移 + centerStep 开始，每 step 格画一条）
      for (int i = startX + centerStep; i < w; i += gridSpacing) {
        final x = i * eps.toDouble();
        _drawDashedLine(canvas, Offset(x, 0), Offset(x, imgHeight.toDouble()),
            dashPaint, dashLength, gapLength);
      }

      // 横向中虚线
      for (int i = startY + centerStep; i < h; i += gridSpacing) {
        final y = i * eps.toDouble();
        _drawDashedLine(canvas, Offset(0, y), Offset(imgWidth.toDouble(), y),
            dashPaint, dashLength, gapLength);
      }
    }
  }

  /// 绘制虚线（向量方式，与 pixel_canvas.dart 逻辑一致）
  static void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      double dashLength, double gapLength) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance < 0.001) return;

    final unitX = dx / distance;
    final unitY = dy / distance;
    double current = 0;
    bool drawing = true;

    while (current < distance) {
      final segLen = drawing
          ? math.min(dashLength, distance - current)
          : math.min(gapLength, distance - current);
      final segStart = Offset(start.dx + unitX * current,
          start.dy + unitY * current);
      final segEnd = Offset(start.dx + unitX * (current + segLen),
          start.dy + unitY * (current + segLen));

      if (drawing && segLen > 0) {
        canvas.drawLine(segStart, segEnd, paint);
      }
      current += segLen;
      drawing = !drawing;
    }
  }

  /// 绘制颜色代码文本
  static void _drawColorCodes(Canvas canvas, List<String> codes, int w, int h,
      int effectivePixelSize, Map<String, Color> beadColorMap) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int row = 0; row < h; row++) {
      for (int col = 0; col < w; col++) {
        final index = row * w + col;
        if (index >= codes.length) continue;

        final code = codes[index];
        if (code.isEmpty) continue;

        final color = beadColorMap[code];
        if (color == null) continue;

        final luminance =
            (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue);
        final textColor = luminance > 128 ? Colors.black : Colors.white;

        final fontSize = (effectivePixelSize * 0.32).clamp(4.0, 28.0);
        textPainter.text = TextSpan(
          text: code,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            height: 1.0,
          ),
        );
        textPainter.layout();

        final centerX =
            (col * effectivePixelSize + effectivePixelSize / 2).toDouble();
        final centerY =
            (row * effectivePixelSize + effectivePixelSize / 2).toDouble();
        textPainter.paint(
          canvas,
          Offset(centerX - textPainter.width / 2,
              centerY - textPainter.height / 2),
        );
      }
    }
  }

  /// 绘制颜色图例
  static void _drawColorLegend(
      Canvas canvas,
      List<String> codes,
      Map<String, Color> beadColorMap,
      int totalWidth,
      int imgHeight,
      int numberBorder,
      double legendPadding,
      double legendItemHeight,
      double legendFontSize,
      double legendSwatchSize,
      double legendTitleHeight,
      int legendHeight,
      ) {
    final legendTop = (imgHeight + numberBorder * 2).toDouble();

    // 背景
    canvas.drawRect(
      Rect.fromLTWH(
          0, legendTop, totalWidth.toDouble(), legendHeight.toDouble()),
      Paint()..color = Colors.white,
    );

    // 标题
    final uniqueCodes = codes.toSet().where((c) => c.isNotEmpty).toList();
    final titlePainter = TextPainter(
      text: TextSpan(
        text: '颜色列表 (${uniqueCodes.length}色)',
        style: TextStyle(
            fontSize: legendFontSize * 1.2,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333)),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
        canvas,
        Offset(legendPadding,
            legendTop + (legendTitleHeight - titlePainter.height) / 2));

    // 颜色条目
    final colorsPerRow =
        (totalWidth / (legendSwatchSize * 4)).floor().clamp(4, 12);
    final codeUsageMap = <String, int>{};
    for (final code in codes) {
      if (code.isNotEmpty) {
        codeUsageMap[code] = (codeUsageMap[code] ?? 0) + 1;
      }
    }
    uniqueCodes.sort(
        (a, b) => (codeUsageMap[b] ?? 0).compareTo(codeUsageMap[a] ?? 0));

    final itemPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    final itemTextStyle =
        TextStyle(fontSize: legendFontSize, color: const Color(0xFF666666));

    for (int i = 0; i < uniqueCodes.length; i++) {
      final code = uniqueCodes[i];
      final row = i ~/ colorsPerRow;
      final col = i % colorsPerRow;
      final x = legendPadding +
          col * ((totalWidth - legendPadding * 2) / colorsPerRow);
      final y = legendTop +
          legendTitleHeight +
          legendPadding +
          row * legendItemHeight;

      // 色块
      final color = beadColorMap[code] ?? const Color(0xFFB0B0B0);
      canvas.drawRect(
        Rect.fromLTWH(x, y + (legendItemHeight - legendSwatchSize) / 2,
            legendSwatchSize, legendSwatchSize),
        Paint()..color = color,
      );
      canvas.drawRect(
        Rect.fromLTWH(x, y + (legendItemHeight - legendSwatchSize) / 2,
            legendSwatchSize, legendSwatchSize),
        Paint()
          ..color = const Color(0xFFDDDDDD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // 代码 + 数量
      final count = codeUsageMap[code] ?? 0;
      final label = '$code x$count';
      itemPainter.text = TextSpan(text: label, style: itemTextStyle);
      itemPainter.layout();
      itemPainter.paint(
          canvas,
          Offset(x + legendSwatchSize + 6,
              y + (legendItemHeight - itemPainter.height) / 2));
    }

    // 分隔线
    canvas.drawLine(
      Offset(0, legendTop),
      Offset(totalWidth.toDouble(), legendTop),
      Paint()
        ..color = const Color(0xFFEEEEEE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }
}

class _BrandFrameLayout {
  final double scale;
  final double outerMargin;
  final double borderRadius;
  final double borderWidth;
  final double innerPadH;
  final double innerPadV;
  final double headerContentHeight;
  final double headerHeight;
  final double logoSize;
  final double headerGap;
  final double headerSideGap;
  final double workTitleFontSize;
  final double workMetaFontSize;
  final double workMetaGap;
  final double brandTitleFontSize;
  final double brandSloganFontSize;
  final double brandSloganGap;
  final double headerBottomGap;
  final double statsBarHeight;
  final double statsFontSize;
  final double statsIconWidth;
  final double statsIconHeight;
  final double statsIconGap;
  final double statsPaletteGap;
  final double chipHeight;
  final double chipGap;
  final double chipTopPadding;
  final double chipBottomPadding;
  final double chipPaddingH;
  final double chipTextGap;
  final double chipSwatchSize;
  final double chipFontSize;
  final double chipBorderWidth;
  final double chipBorderRadius;
  final double footerDividerHeight;
  final double chipMinWidth;
  final double contentWidth;

  const _BrandFrameLayout({
    required this.scale,
    required this.outerMargin,
    required this.borderRadius,
    required this.borderWidth,
    required this.innerPadH,
    required this.innerPadV,
    required this.headerContentHeight,
    required this.headerHeight,
    required this.logoSize,
    required this.headerGap,
    required this.headerSideGap,
    required this.workTitleFontSize,
    required this.workMetaFontSize,
    required this.workMetaGap,
    required this.brandTitleFontSize,
    required this.brandSloganFontSize,
    required this.brandSloganGap,
    required this.headerBottomGap,
    required this.statsBarHeight,
    required this.statsFontSize,
    required this.statsIconWidth,
    required this.statsIconHeight,
    required this.statsIconGap,
    required this.statsPaletteGap,
    required this.chipHeight,
    required this.chipGap,
    required this.chipTopPadding,
    required this.chipBottomPadding,
    required this.chipPaddingH,
    required this.chipTextGap,
    required this.chipSwatchSize,
    required this.chipFontSize,
    required this.chipBorderWidth,
    required this.chipBorderRadius,
    required this.footerDividerHeight,
    required this.chipMinWidth,
    required this.contentWidth,
  });

  double get contentOriginX => outerMargin + innerPadH;

  double get contentOriginY => outerMargin + innerPadV;

  double measureChipWidth(String code, int count) {
    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: code,
            style: TextStyle(
              fontFamily: kPFFont,
              fontSize: chipFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: ' ${count}颗',
            style: TextStyle(
              fontFamily: kPFFont,
              fontSize: chipFontSize,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    painter.layout();
    return chipPaddingH * 2 + chipSwatchSize + chipTextGap + painter.width;
  }

  int resolveChipsPerRow(
    List<String> uniqueCodes,
    Map<String, int> codeUsageMap,
  ) {
    if (uniqueCodes.isEmpty) return 1;

    var maxRequired = chipMinWidth;
    for (final code in uniqueCodes) {
      maxRequired = math.max(
        maxRequired,
        measureChipWidth(code, codeUsageMap[code] ?? 0),
      );
    }
    return math.max(
      1,
      ((contentWidth + chipGap) / (maxRequired + chipGap)).floor(),
    );
  }

  /// 按画板内容宽度计算品牌框各区域尺寸（分区字段见文件顶部「导出图分区调参指南」）
  factory _BrandFrameLayout.fromContentWidth(double contentWidth) {
    final ratio = contentWidth / PixelCanvasExporter._designContentWidth;
    final scale = math.min(
      ratio <= 1.0
          ? math.max(ratio, 0.85)
          : 1.0 + (ratio - 1.0) * PixelCanvasExporter._brandUiLargeCanvasBoost,
      PixelCanvasExporter._maxBrandUiScale,
    ) *
        PixelCanvasExporter._brandChromeCompactFactor;
    final headerScale = scale * PixelCanvasExporter._headerChromeBoost;
    final logoSize = 80.0 * headerScale;
    final workTitleFontSize = 26.0 * headerScale;
    final workMetaFontSize = 16.0 * headerScale;
    final workMetaGap = 8.0 * headerScale;
    final brandTitleFontSize = 32.0 * headerScale;
    final brandSloganFontSize = 18.0 * headerScale;
    final brandSloganGap = 7.0 * headerScale;

    final workTitlePainter = TextPainter(
      text: TextSpan(
        text: '${PixelCanvasExporter._defaultWorkTitle}@${PixelCanvasExporter._defaultUserNickname}',
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: workTitleFontSize,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final workMetaPainter = TextPainter(
      text: TextSpan(
        text: '[99×99/99色/共99999颗]',
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: workMetaFontSize,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final brandTitlePainter = TextPainter(
      text: TextSpan(
        text: PixelCanvasExporter._brandAppName,
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: brandTitleFontSize,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final brandSloganPainter = TextPainter(
      text: TextSpan(
        text: PixelCanvasExporter._brandSlogan,
        style: TextStyle(
          fontFamily: kPFFont,
          fontSize: brandSloganFontSize,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final leftBlockHeight =
        workTitlePainter.height + workMetaGap + workMetaPainter.height;
    final brandTextHeight =
        brandTitlePainter.height + brandSloganGap + brandSloganPainter.height;
    final rightBlockHeight = math.max(logoSize, brandTextHeight);
    final headerContentHeight = math.max(leftBlockHeight, rightBlockHeight);
    final headerBottomGap = 18.0 * headerScale;
    final headerHeight = headerContentHeight + headerBottomGap;

    final chipMinWidth = 72.0 * scale;
    final chipGap = 8.0 * scale;
    final statsScale = scale * PixelCanvasExporter._footerStatsBoost;

    return _BrandFrameLayout(
      scale: scale,
      outerMargin: 6.0 * scale,
      borderRadius: 12.0 * scale,
      borderWidth: math.max(1.0, 1.0 * scale),
      innerPadH: 6.0 * scale,
      innerPadV: 10.0 * scale,
      headerContentHeight: headerContentHeight,
      headerHeight: headerHeight,
      logoSize: logoSize,
      headerGap: 18.0 * headerScale,
      headerSideGap: 20.0 * headerScale,
      workTitleFontSize: workTitleFontSize,
      workMetaFontSize: workMetaFontSize,
      workMetaGap: workMetaGap,
      brandTitleFontSize: brandTitleFontSize,
      brandSloganFontSize: brandSloganFontSize,
      brandSloganGap: brandSloganGap,
      headerBottomGap: headerBottomGap,
      statsBarHeight: 50.0 * statsScale,
      statsFontSize: 18.0 * statsScale,
      statsIconWidth: 17.0 * statsScale,
      statsIconHeight: 12.0 * statsScale,
      statsIconGap: 8.0 * statsScale,
      statsPaletteGap: 12.0 * statsScale,
      chipHeight: 34.0 * scale,
      chipGap: chipGap,
      chipTopPadding: 8.0 * scale,
      chipBottomPadding: 6.0 * scale,
      chipPaddingH: 8.0 * scale,
      chipTextGap: 5.0 * scale,
      chipSwatchSize: 18.0 * scale,
      chipFontSize: 14.0 * scale,
      chipBorderWidth: math.max(0.5, 0.5 * scale),
      chipBorderRadius: 6.0 * scale,
      footerDividerHeight: math.max(1.0, 1.2 * scale),
      chipMinWidth: chipMinWidth,
      contentWidth: contentWidth,
    );
  }

  double chipsAreaHeight(int colorCount, int chipsPerRow) {
    if (colorCount <= 0 || chipsPerRow <= 0) return 0;
    final rows = (colorCount / chipsPerRow).ceil();
    return footerDividerHeight +
        chipTopPadding +
        rows * chipHeight +
        math.max(0, rows - 1) * chipGap +
        chipBottomPadding;
  }
}

class _ExportMetrics {
  final int effectivePixelSize;
  final int imgWidth;
  final int imgHeight;
  final int numberBorder;
  final int contentWidth;
  final int contentHeight;
  final int canvasWidth;
  final int canvasHeight;
  final int legendHeight;
  final double chipsHeight;
  final int brandChipsPerRow;
  final double legendPadding;
  final double legendItemHeight;
  final double legendFontSize;
  final double legendSwatchSize;
  final double legendTitleHeight;
  final _BrandFrameLayout? frameLayout;

  const _ExportMetrics({
    required this.effectivePixelSize,
    required this.imgWidth,
    required this.imgHeight,
    required this.numberBorder,
    required this.contentWidth,
    required this.contentHeight,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.legendHeight,
    required this.chipsHeight,
    required this.brandChipsPerRow,
    required this.legendPadding,
    required this.legendItemHeight,
    required this.legendFontSize,
    required this.legendSwatchSize,
    required this.legendTitleHeight,
    required this.frameLayout,
  });
}

/// 导出结果预览：展示已生成的图片 → 保存相册 → Toast → 调起系统分享
class _ExportPreviewDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String filePath;
  final String shareText;
  final String savedToastMessage;

  const _ExportPreviewDialog({
    required this.imageBytes,
    required this.filePath,
    required this.shareText,
    required this.savedToastMessage,
  });

  @override
  State<_ExportPreviewDialog> createState() => _ExportPreviewDialogState();
}

class _ExportPreviewDialogState extends State<_ExportPreviewDialog> {
  bool _saving = true;
  String _statusMessage = '正在保存到相册...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveAndShare());
  }

  Future<void> _saveAndShare() async {
    try {
      final result = await ImageGallerySaverPlus.saveFile(widget.filePath);
      if (!mounted) return;

      if (result['isSuccess'] == true) {
        setState(() {
          _saving = false;
          _statusMessage = '已保存到相册，正在打开分享...';
        });
        showToast(widget.savedToastMessage);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(widget.filePath)],
            text: widget.shareText,
          ),
        );
        if (mounted) {
          setState(() {
            _statusMessage = '分享完成，点击空白处关闭';
          });
        }
        return;
      }

      setState(() {
        _saving = false;
        _statusMessage = '保存失败，请检查相册权限';
      });
      showToast('保存失败，请检查相册权限');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _statusMessage = '导出失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.92,
            maxHeight: size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        '导出预览',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                          fontFamily: kPFFont,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF808695),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InteractiveViewer(
                      minScale: 0.6,
                      maxScale: 3,
                      child: Image.memory(
                        widget.imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_saving) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF808695),
                          fontFamily: kPFFont,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
