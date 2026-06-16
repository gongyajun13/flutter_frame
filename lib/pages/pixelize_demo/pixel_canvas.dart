import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Point, sqrt, min;
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/pages/pixelize_demo/widget/color_display_mode_sheet.dart';
import 'package:get/get.dart' hide GetStringUtils;

import 'data/tool_item.dart';
import 'pixelize_result_controller.dart';

/// 颜色数据类
class _BeadColor {
  final int r;
  final int g;
  final int b;

  const _BeadColor({
    required this.r,
    required this.g,
    required this.b,
  });

  /// 从十六进制颜色值创建珠子颜色
  factory _BeadColor.fromHex(String hex) {
    final hexValue = hex.replaceAll('#', '');
    final r = int.parse(hexValue.substring(0, 2), radix: 16);
    final g = int.parse(hexValue.substring(2, 4), radix: 16);
    final b = int.parse(hexValue.substring(4, 6), radix: 16);
    return _BeadColor(r: r, g: g, b: b);
  }

  /// 转换为 Flutter Color
  Color toColor() {
    return Color.fromARGB(255, r, g, b);
  }
}

/// 防抖工具类
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// 像素回调函数类型
typedef PixelCallback = void Function(int x, int y, Color color);

/// 像素画板组件
///
/// 功能：
/// - 显示像素化图片
/// - 在每个像素块上显示颜色code
/// - 支持缩放和平移
class PixelCanvas extends StatefulWidget {
  final File? imageFile;
  /// 原始图片的网络URL（服务端加载场景，与 imageFile 二选一）
  final String? imageUrl;
  final PixelCallback onPixelTapped;
  final PixelCallback? onPixelLongPressed;

  const PixelCanvas({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onPixelTapped,
    this.onPixelLongPressed,
  });

  @override
  State<PixelCanvas> createState() => _PixelCanvasState();
}

/// 像素画板状态类（暴露缩放控制方法）
class _PixelCanvasState extends State<PixelCanvas> {
  /// 控制器
  final PixelizeResultController _controller =
      Get.find<PixelizeResultController>();

  /// TransformationController 用于控制缩放和平移（使用 controller 的）
  TransformationController get _transformationController =>
      _controller.transformationController;

  /// 图片数据（用于计算宽高比）
  ui.Image? _image;

  /// 防抖器，用于优化缩放性能（50ms：平衡流畅度与CPU开销）
  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 50));

  /// 重绘通知器，用于控制画板重绘
  final ValueNotifier<int> _repaintNotifier = ValueNotifier<int>(0);

  /// 珠子颜色映射（code -> _BeadColor）
  Map<String, _BeadColor>? _beadColorMap;

  /// 查看模式下记录按下的位置（用于区分点击和拖动）
  Offset? _viewModeDownPosition;

  /// 查看模式下记录按下的时间戳（配合距离判断是否为点击）
  DateTime? _viewModeDownTime;

  /// 点位线模式下记录按下的位置（用于区分点击和拖动）
  Offset? _locationLineDownPosition;

  @override
  void initState() {
    super.initState();
    _loadColors();
    _loadImage();

    // 监听变换控制器的变化，使用防抖优化性能
    _transformationController.addListener(_onTransformationChanged);

    // 监听 pixelCodes 的变化，触发重绘通知器
    ever(_controller.pixelCodes, (_) {
      _repaintNotifier.value++;
      print('[PixelCanvas] pixelCodes 变化，触发 repaintNotifier');
    });

    // 监听遮罩/标记状态的变化，触发即时重绘（查看模式操作即时生效）
    ever(_controller.maskedGridKeys, (_) {
      _repaintNotifier.value++;
      print('[PixelCanvas] maskedGridKeys 变化，触发 repaintNotifier');
    });
    ever(_controller.checkedGridKeys, (_) {
      _repaintNotifier.value++;
      print('[PixelCanvas] checkedGridKeys 变化，触发 repaintNotifier');
    });

    // 监听点位线中心集合变化，触发重绘
    ever(_controller.locationLineCenterKeys, (_) {
      _repaintNotifier.value++;
      print('[PixelCanvas] locationLineCenterKeys 变化，触发 repaintNotifier');
    });

    // 监听品牌标签的变化，重新加载颜色映射
    ever(_controller.beadBrandLabel, (_) {
      // 如果正在重新处理中，跳过（等待 pixelCodes 更新后再加载）
      if (_controller.isChangingBrandOrColorLimit) {
        print('[PixelCanvas] 正在重新处理中，跳过颜色加载');
        return;
      }
      print('[PixelCanvas] 品牌标签变化，重新加载颜色映射');
      _loadColors();
    });

    // 监听重新处理状态变化，完成后重新加载颜色
    ever(_controller.isReprocessing, (isProcessing) {
      if (!isProcessing) {
        // 重处理完成后，重新加载颜色映射
        print('[PixelCanvas] 重处理完成，重新加载颜色映射');
        _loadColors();
      }
    });

    // 监听圆形模式的变化，触发重绘
    ever(_controller.isCircleMode, (_) {
      _repaintNotifier.value++;
    });

    // 监听其他工具状态变化（如代码、网格），触发重绘
    ever(_controller.enabledOtherTools, (_) {
      _repaintNotifier.value++;
    });

    // 监听网格设置变化，触发重绘
    ever(_controller.gridThickness, (_) => _repaintNotifier.value++);
    ever(_controller.gridColor, (_) => _repaintNotifier.value++);
    ever(_controller.gridSpacing, (_) => _repaintNotifier.value++);
    ever(_controller.gridStartPoint, (_) => _repaintNotifier.value++);
    ever(_controller.centerDashShow, (_) => _repaintNotifier.value++);
    ever(_controller.gridShow, (_) => _repaintNotifier.value++);

    // 监听色号显示模式变化，触发重绘
    ever(_controller.colorDisplayMode, (_) => _repaintNotifier.value++);

    // 监听缩放状态变化（scale 模式需要在缩放开始/结束时切换显示）
    ever(_controller.isCanvasScaling, (_) => _repaintNotifier.value++);

    // 监听浮动文本位置变化，触发重绘（确保拖拽过程中实时更新）
    ever(_controller.textPosition, (_) {
      _repaintNotifier.value++;
    });
  }

  /// 加载珠子颜色数据
  Future<void> _loadColors() async {
    try {
      final jsonPath = _controller.currentBeadBrandPath;
      print('[PixelCanvas] 开始加载颜色映射: $jsonPath');

      final jsonString = await rootBundle.loadString(jsonPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final colors = json['colors'] as List;

      _beadColorMap = {};
      for (final color in colors) {
        final c = color as Map<String, dynamic>;
        final code = c['code'] as String;
        final hex = c['hex'] as String;
        _beadColorMap![code] = _BeadColor.fromHex(hex);
      }

      print('[PixelCanvas] 颜色映射加载完成，共 ${_beadColorMap!.length} 种颜色');

      // 颜色加载完成后触发重绘
      if (mounted) {
        setState(() {});
        _repaintNotifier.value++;
      }
    } catch (e) {
      print('[PixelCanvas] 加载颜色数据失败: $e');
      _beadColorMap = {};
    }
  }

  /// 变换控制器变化回调
  void _onTransformationChanged() {
    // 使用防抖延迟触发重绘
    _debouncer(() {
      _repaintNotifier.value++;
    });
  }

  /// 加载图片（用于计算宽高比 + 参考图蒙层）
  /// 支持两种来源：本地文件(imageFile) 或 网络URL(imageUrl)
  Future<void> _loadImage() async {
    ui.Image? loadedImage;

    // 优先使用本地文件
    if (widget.imageFile != null && await widget.imageFile!.exists()) {
      final bytes = await widget.imageFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      loadedImage = frame.image;
      print('[PixelCanvas] 已加载本地文件: ${widget.imageFile!.path}');
    }
    // 其次尝试网络URL（使用 cached_network_image，自带磁盘+内存缓存）
    else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      try {
        final provider = CachedNetworkImageProvider(widget.imageUrl!);
        final completer = Completer<ui.Image>();
        final stream = provider.resolve(const ImageConfiguration());
        stream.addListener(ImageStreamListener(
          (frame, _) {
            if (!completer.isCompleted) {
              completer.complete(frame.image);
            }
          },
          onError: (exception, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(exception, stackTrace);
            }
          },
        ));
        loadedImage = await completer.future;
        print('[PixelCanvas] 已加载网络图片: ${widget.imageUrl}');
      } catch (e) {
        print('[PixelCanvas] 网络图片加载异常: $e');
      }
    }

    // 无论哪种来源，最终都需要一个 ui.Image（用于宽高比计算和参考图蒙层）
    if (loadedImage != null) {
      setState(() => _image = loadedImage);
    } else {
      // 无可用来源时创建虚拟1x1图片（宽高比由 gridWidth/gridHeight 决定）
      final gw = _controller.gridWidth.value;
      final gh = _controller.gridHeight.value;
      if (gw > 0 && gh > 0) {
        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);
        canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint());
        final picture = pictureRecorder.endRecording();
        final image = await picture.toImage(1, 1);
        setState(() => _image = image);
        print('[PixelCanvas] 无本地或网络图片，使用网格尺寸 $gw x $gh 计算宽高比');
      }
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    // 注意：不在这里 dispose _transformationController，因为它属于 controller
    _debouncer.dispose();
    _repaintNotifier.dispose();
    _paintDelayTimer?.cancel();
    _image?.dispose();
    super.dispose();
  }

  /// GlobalKey 用于访问 CustomPaint 的 RenderBox
  final GlobalKey _customPaintKey = GlobalKey();
  final GlobalKey _numberBorderKey = GlobalKey();

  /// GlobalKey 用于获取控制菜单的位置，判断点击是否在菜单区域内
  final GlobalKey _textMenuKey = GlobalKey();

  /// 记录触摸开始时的指针数量
  int _pointerCount = 0;

  /// 是否正在绘画
  bool _isPainting = false;

  /// 绘画延迟定时器（用于区分单指绘画和双指缩放）
  Timer? _paintDelayTimer;

  /// 待绘制的位置（延迟绘制用）
  Offset? _pendingPaintPosition;

  /// 上一次绘制的屏幕位置（用于插值绘制）
  Offset? _lastPaintPosition;

  /// 是否正在拖拽文本
  bool _isTextDragging = false;

  /// 文本拖拽开始时的屏幕位置
  Offset? _textDragStartPointerPosition;

  /// 文本拖拽开始时的文本网格位置
  Offset? _textDragStartTextPosition;

  // ── 形状绘制状态 ──────────────────────────────────────────
  /// 形状起点（网格坐标）
  Point<int>? _shapeStartGrid;

  /// 形状终点预览（网格坐标），Move 时更新，Up 时提交并清除
  Point<int>? _shapeEndGrid;

  /// 形状预览像素缓存（避免起/终点未变时重复计算）
  Set<String>? _cachedPreviewPixels;
  Point<int>? _cachedPreviewStart;
  Point<int>? _cachedPreviewEnd;
  String _cachedPreviewShapeType = '';

  // ─────────────────────────────────────────────────────────

  /// 缓存的绘制参数（避免每次绘制时重复计算）
  double? _cachedBlockWidth;
  double? _cachedBlockHeight;
  int? _cachedGridWidth;
  int? _cachedGridHeight;

  /// 内容在全屏 canvas 中的居中偏移量（因为 SizedBox 填满 viewport，但实际内容更小）
  double? _contentOffsetX;
  double? _contentOffsetY;

  /// 处理指针按下事件
  void _handlePointerDown(PointerDownEvent event) {
    // 注意：菜单区域的触摸已被菜单自身的 Listener(opaque) 吸收，
    // 不会传到此处，无需在这里做菜单区域判断。

    setState(() {
      _pointerCount++;
    });

    // 双指按下时，取消待执行的绘画和文本拖拽操作
    if (_pointerCount == 2) {
      _paintDelayTimer?.cancel();
      _paintDelayTimer = null;
      _pendingPaintPosition = null;
      _isPainting = false;
      _lastPaintPosition = null;
      _isTextDragging = false;
      _viewModeDownPosition = null;
      _viewModeDownTime = null;
      _locationLineDownPosition = null;
      return;
    }

    // 文本模式 + 文本未浮动：放置文本到点击位置
    if (_pointerCount == 1 &&
        _controller.currentToolMode.value == ToolMode.text &&
        _controller.pendingText.value.isNotEmpty &&
        !_controller.isTextFloating.value) {
      _showFloatingTextAt(event.position);
      return;
    }

    // 文本浮动时：单指按下开始拖拽文本（双指时交给 InteractiveViewer 缩放）
    final textActive = _controller.isTextFloating.value;
    if (_pointerCount == 1 && textActive) {
      _startTextDrag(event.position);
    }

    // 单指按下时，延迟触发绘画（区分双指缩放）
    if (_pointerCount == 1 &&
        !textActive &&
        (_controller.currentToolMode.value == ToolMode.draw ||
            _controller.currentToolMode.value == ToolMode.eraser ||
            _controller.currentToolMode.value == ToolMode.sprayGun)) {
      // 记录待绘制位置，重置上一位置
      _pendingPaintPosition = event.position;
      _lastPaintPosition = null; // 新的触摸开始，重置上一位置
      // 延迟 50ms 触发绘画，如果期间有第二根手指按下则取消
      _paintDelayTimer = Timer(const Duration(milliseconds: 50), () {
        if (_pendingPaintPosition != null && _pointerCount == 1) {
          _isPainting = true;
          _paintPixel(_pendingPaintPosition!);
        }
        _pendingPaintPosition = null;
      });
    }

    // 泛填充模式：点击触发泛填充
    if (_pointerCount == 1 &&
        !textActive &&
        _controller.currentToolMode.value == ToolMode.floodFill) {
      _floodFillAt(event.position);
    }

    // 提取模式：点击提取颜色
    if (_pointerCount == 1 &&
        _controller.currentToolMode.value == ToolMode.extract) {
      _extractColorAt(event.position);
    }

    // 形状模式：立即记录起点（不需要延迟，形状绘制不存在误触问题）
    if (_pointerCount == 1 &&
        !textActive &&
        _controller.currentToolMode.value == ToolMode.shape) {
      final grid = _globalToGrid(event.position);
      if (grid != null) {
        setState(() {
          _shapeStartGrid = grid;
          _shapeEndGrid = grid;
        });
      }
    }

    // 点位线模式：记录按下位置（在 Up 事件中判断是否为点击）
    if (_pointerCount == 1 &&
        !textActive &&
        _controller.currentToolMode.value == ToolMode.locationLine) {
      _locationLineDownPosition = event.position;
    }

    // 查看模式：记录按下位置和时间（在 Up 事件中判断是点击还是拖动）
    if (_pointerCount == 1 &&
        _controller.currentToolMode.value == ToolMode.view) {
      _viewModeDownPosition = event.position;
      _viewModeDownTime = DateTime.now();
    }
  }

  /// 处理指针抬起事件
  void _handlePointerUp(PointerUpEvent event) {
    // 注意：菜单区域的触摸已被菜单自身的 Listener(opaque) 吸收，
    // Up 事件不会来自菜单区域，无需额外判断。

    // 形状模式：提交形状像素
    if (_controller.currentToolMode.value == ToolMode.shape &&
        _shapeStartGrid != null) {
      final end =
          _globalToGrid(event.position) ?? _shapeEndGrid ?? _shapeStartGrid!;
      final pixels = _controller.computeShapePixels(
        _shapeStartGrid!.x,
        _shapeStartGrid!.y,
        end.x,
        end.y,
      );
      _controller.drawShapePixels(pixels);
      setState(() {
        _shapeStartGrid = null;
        _shapeEndGrid = null;
        _cachedPreviewPixels = null;
        _cachedPreviewStart = null;
        _cachedPreviewEnd = null;
      });
    }

    // 查看模式：判断是否为点击（距离 + 时长双重保护）
    if (_controller.currentToolMode.value == ToolMode.view &&
        _viewModeDownPosition != null &&
        _viewModeDownTime != null) {
      final distance = (event.position - _viewModeDownPosition!).distance;
      final elapsed = DateTime.now().difference(_viewModeDownTime!).inMilliseconds;
      // 距离 < 18px 且 持续 < 300ms 才视为点击
      if (distance < 18 && elapsed < 300) {
        _handlePixelTap(event.position);
      }
      _viewModeDownPosition = null;
      _viewModeDownTime = null;
    }

    // 点位线模式：判断是否为点击（距离 + 时长双重保护）
    if (_controller.currentToolMode.value == ToolMode.locationLine &&
        _locationLineDownPosition != null) {
      final distance = (event.position - _locationLineDownPosition!).distance;
      if (distance < 18) {
        final gridPos = _globalToGridPosition(event.position);
        if (gridPos != null) {
          final (col, row) = gridPos;
          _controller.setLocationLineCenter(col, row);
        }
      }
      _locationLineDownPosition = null;
    }

    setState(() {
      _pointerCount--;
      // 所有手指抬起时，重置绘画状态
      if (_pointerCount == 0) {
        _isPainting = false;
        _paintDelayTimer?.cancel();
        _paintDelayTimer = null;
        _pendingPaintPosition = null;
        _lastPaintPosition = null;
        _isTextDragging = false;
        _textDragStartPointerPosition = null;
        _textDragStartTextPosition = null;
      }
    });
  }

  /// 处理像素点击（查看模式/点位线等需要区分点击与拖动的场景复用）
  void _handlePixelTap(Offset position) {
    final gridPos = _globalToGridPosition(position);
    if (gridPos == null) return;
    final (col, row) = gridPos;
    final index = row * _controller.gridWidth.value + col;
    final codes = _controller.pixelCodes;
    if (index < 0 || index >= codes.length) return;
    final code = codes[index];
    if (code.isEmpty) return;
    final beadColor = _beadColorMap?[code];
    if (beadColor != null) {
      widget.onPixelTapped(col, row, beadColor.toColor());
    }
  }

  /// 处理指针移动
  void _handlePointerMove(PointerMoveEvent event) {
    // 文本拖拽中：优先处理，不受菜单区域拦截（手指可以滑过菜单区域继续拖拽）
    if (_isTextDragging && _pointerCount == 1) {
      _dragTextTo(event.position);
      return;
    }

    // 如果移动位置在控制菜单区域内，忽略其他画板事件
    if (_isPointInTextMenu(event.position)) return;

    // 文本浮动期间，禁止绘画
    if (_controller.isTextFloating.value) return;

    // 处理绘画、橡皮擦或喷枪时的移动（单指且在相应模式下）
    if (_pointerCount == 1 &&
        (_controller.currentToolMode.value == ToolMode.draw ||
            _controller.currentToolMode.value == ToolMode.eraser ||
            _controller.currentToolMode.value == ToolMode.sprayGun)) {
      // 插值绘制：从上一位置到当前位置绘制所有经过的像素
      if (_lastPaintPosition != null) {
        _paintLine(_lastPaintPosition!, event.position);
      } else {
        _paintPixel(event.position);
      }
      _lastPaintPosition = event.position;
    }

    // 形状模式：更新终点预览
    if (_pointerCount == 1 &&
        _controller.currentToolMode.value == ToolMode.shape &&
        _shapeStartGrid != null) {
      final grid = _globalToGrid(event.position);
      if (grid != null && grid != _shapeEndGrid) {
        setState(() {
          _shapeEndGrid = grid;
        });
      }
    }
  }

  /// 在两个点之间绘制连续的像素（线性插值）
  void _paintLine(Offset start, Offset end) {
    final distance = (end - start).distance;
    // 动态计算步长：确保步长不超过像素块宽度的一半，避免遗漏
    final minBlockSize =
        (_cachedBlockWidth ?? 5.0) < (_cachedBlockHeight ?? 5.0)
            ? (_cachedBlockWidth ?? 5.0)
            : (_cachedBlockHeight ?? 5.0);
    final stepSize = (minBlockSize * 0.5).clamp(2.0, 10.0);
    final steps = (distance / stepSize).ceil().clamp(1, 100);

    // 收集所有需要绘制的点，然后去重绘制
    final points = <Offset>[];
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;
      points.add(Offset(x, y));
    }

    // 去重绘制：使用 Set 记录已绘制的网格坐标
    _paintPixelsWithDedup(points);
  }

  /// 批量绘制像素（去重）
  void _paintPixelsWithDedup(List<Offset> positions) {
    // 使用缓存的参数，避免每次绘制时重复计算
    final gridWidth = _cachedGridWidth ?? _controller.gridWidth.value;
    final gridHeight = _cachedGridHeight ?? _controller.gridHeight.value;
    if (gridWidth == 0 || gridHeight == 0) return;

    final blockWidth = _cachedBlockWidth;
    final blockHeight = _cachedBlockHeight;
    if (blockWidth == null || blockHeight == null) return;

    final customPaintContext = _customPaintKey.currentContext;
    if (customPaintContext == null) return;
    final customPaintRenderBox =
        customPaintContext.findRenderObject() as RenderBox?;
    if (customPaintRenderBox == null) return;

    // 使用 Set 去重网格坐标
    final drawnGrids = <String>{};
    final isSprayGun = _controller.currentToolMode.value == ToolMode.sprayGun;

    for (final position in positions) {
      try {
        // 手动坐标转换（与 _globalToGridPosition 保持一致）
        final cpScreenOrigin = customPaintRenderBox.localToGlobal(Offset.zero);
        final relX = position.dx - cpScreenOrigin.dx;
        final relY = position.dy - cpScreenOrigin.dy;
        final matrix = _transformationController.value;
        final scale = matrix.getMaxScaleOnAxis();
        final localX = relX / scale;
        final localY = relY / scale;
        // 基于实际 renderBox.size 动态计算居中偏移（修复矩形画板 offset 失配问题）
        final dynOffX = (customPaintRenderBox.size.width - blockWidth * gridWidth) / 2;
        final dynOffY = (customPaintRenderBox.size.height - blockHeight * gridHeight) / 2;
        final contentX = localX - dynOffX;
        final contentY = localY - dynOffY;
        final gridX = (contentX / blockWidth).floor();
        final gridY = (contentY / blockHeight).floor();

        if (gridX < 0 || gridX >= gridWidth || gridY < 0 || gridY >= gridHeight) {
          continue;
        }

        if (isSprayGun) {
          // 喷枪模式：绘制多个像素
          final range = _controller.getSprayGunRange();
          for (final (dx, dy) in range) {
            final targetX = gridX + dx;
            final targetY = gridY + dy;
            if (targetX >= 0 &&
                targetX < gridWidth &&
                targetY >= 0 &&
                targetY < gridHeight) {
              final key = '$targetX,$targetY';
              if (!drawnGrids.contains(key)) {
                drawnGrids.add(key);
                widget.onPixelTapped(
                    targetX, targetY, _controller.brushColor.value);
              }
            }
          }
        } else {
          // 普通绘画/橡皮擦
          final key = '$gridX,$gridY';
          if (!drawnGrids.contains(key)) {
            drawnGrids.add(key);
            widget.onPixelTapped(gridX, gridY, _controller.brushColor.value);
          }
        }
      } catch (e) {
        // 忽略转换错误
      }
    }
  }

  /// 在指定位置绘制像素
  void _paintPixel(Offset position) {
    // 复用批量绘制方法，自动去重
    _paintPixelsWithDedup([position]);
  }

  (int, int)? _globalToGridPosition(Offset position) {
    final customPaintContext = _customPaintKey.currentContext;
    if (customPaintContext == null) return null;
    final customPaintRenderBox =
        customPaintContext.findRenderObject() as RenderBox?;
    if (customPaintRenderBox == null) return null;

    final gw = _cachedGridWidth ?? _controller.gridWidth.value;
    final gh = _cachedGridHeight ?? _controller.gridHeight.value;
    if (gw == 0 || gh == 0) return null;

    final blockW = _cachedBlockWidth;
    final blockH = _cachedBlockHeight;
    if (blockW == null || blockH == null) return null;

    try {
      // 使用 globalToLocal 进行坐标转换（已自动处理 IV 逆变换链）
      final localPos = customPaintRenderBox.globalToLocal(position);

      // 关键修复：基于 CustomPaint 实际渲染尺寸（renderBox.size）动态计算居中偏移，
      // 而非使用 _contentOffsetX/Y（后者基于 build() 时 screenWidth/maxHeight 计算，
      // maxHeight 可能与实际 paintSize.height 不一致，导致矩形画板时 offset 失配）
      final imgDisplayW = blockW * gw;
      final imgDisplayH = blockH * gh;
      final dynOffsetX = (customPaintRenderBox.size.width - imgDisplayW) / 2;
      final dynOffsetY = (customPaintRenderBox.size.height - imgDisplayH) / 2;

      final contentX = localPos.dx - dynOffsetX;
      final contentY = localPos.dy - dynOffsetY;
      if (contentX < 0 || contentY < 0) return null;
      final gx = (contentX / blockW).floor();
      final gy = (contentY / blockH).floor();

      if (gx >= 0 && gx < gw && gy >= 0 && gy < gh) {
        return (gx, gy);
      }
      return null;
    } catch (e) {
      print('[PixelCanvas] 坐标转换出错: $e');
      return null;
    }
  }

  /// 泛填充：在指定位置执行泛填充
  void _floodFillAt(Offset position) {
    final pos = _globalToGridPosition(position);
    if (pos != null) {
      _controller.floodFill(pos.$1, pos.$2);
    }
  }

  /// 提取颜色：点击获取像素块颜色
  void _extractColorAt(Offset position) {
    final pos = _globalToGridPosition(position);
    if (pos != null) {
      _controller.extractColor(pos.$1, pos.$2);
    }
  }

  /// 拖拽文本到新位置（带边界限制）
  void _dragTextTo(Offset pointerPosition) {
    final cpContext = _customPaintKey.currentContext;
    final cpBox = cpContext?.findRenderObject() as RenderBox?;
    if (cpBox == null ||
        _cachedBlockWidth == null ||
        _cachedBlockHeight == null) return;

    // 手动坐标转换（与 _globalToGridPosition 保持一致）
    final screenOrigin = cpBox.localToGlobal(Offset.zero);
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    final startRelX = _textDragStartPointerPosition!.dx - screenOrigin.dx;
    final startRelY = _textDragStartPointerPosition!.dy - screenOrigin.dy;
    final startLocalX = startRelX / scale;
    final startLocalY = startRelY / scale;

    final currentRelX = pointerPosition.dx - screenOrigin.dx;
    final currentRelY = pointerPosition.dy - screenOrigin.dy;
    final currentLocalX = currentRelX / scale;
    final currentLocalY = currentRelY / scale;

    final dx = (currentLocalX - startLocalX) / _cachedBlockWidth!;
    final dy = (currentLocalY - startLocalY) / _cachedBlockHeight!;

    final newX = _textDragStartTextPosition!.dx + dx;
    final newY = _textDragStartTextPosition!.dy + dy;
    _controller.updateTextPositionClamped(Offset(newX, newY));
  }

  /// 全局屏幕坐标 → 网格坐标，越界或无法转换时返回 null
  Point<int>? _globalToGrid(Offset globalPosition) {
    final gridWidth = _cachedGridWidth ?? _controller.gridWidth.value;
    final gridHeight = _cachedGridHeight ?? _controller.gridHeight.value;
    if (gridWidth == 0 || gridHeight == 0) return null;
    final blockWidth = _cachedBlockWidth;
    final blockHeight = _cachedBlockHeight;
    if (blockWidth == null || blockHeight == null) return null;
    final cpContext = _customPaintKey.currentContext;
    if (cpContext == null) return null;
    final cpBox = cpContext.findRenderObject() as RenderBox?;
    if (cpBox == null) return null;
    try {
      final localPos = cpBox.globalToLocal(globalPosition);

      final imgDisplayW = blockWidth * gridWidth;
      final imgDisplayH = blockHeight * gridHeight;
      final dynOffX = (cpBox.size.width - imgDisplayW) / 2;
      final dynOffY = (cpBox.size.height - imgDisplayH) / 2;
      final contentX = localPos.dx - dynOffX;
      final contentY = localPos.dy - dynOffY;
      final gx = (contentX / blockWidth).floor();
      final gy = (contentY / blockHeight).floor();
      if (gx < 0 || gx >= gridWidth || gy < 0 || gy >= gridHeight) return null;
      return Point<int>(gx, gy);
    } catch (_) {
      return null;
    }
  }

  /// 判断全局坐标点是否在控制菜单区域内
  bool _isPointInTextMenu(Offset globalPosition) {
    final menuContext = _textMenuKey.currentContext;
    if (menuContext == null) return false;
    final renderBox = menuContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final localPos = renderBox.globalToLocal(globalPosition);
    return renderBox.paintBounds.contains(localPos);
  }

  /// 文本拖拽开始（基于指针事件，不参与手势竞技场）
  void _startTextDrag(Offset globalPosition) {
    if (_cachedBlockWidth == null || _cachedBlockHeight == null) return;
    _isTextDragging = true;
    _textDragStartPointerPosition = globalPosition;
    _textDragStartTextPosition = _controller.textPosition.value;
  }

  /// 在点击位置显示浮动文本
  void _showFloatingTextAt(Offset position) {
    final customPaintContext = _customPaintKey.currentContext;
    if (customPaintContext == null) return;
    final customPaintRenderBox =
        customPaintContext.findRenderObject() as RenderBox?;
    if (customPaintRenderBox == null) return;

    final gridWidth = _controller.gridWidth.value;
    final gridHeight = _controller.gridHeight.value;
    if (gridWidth == 0 || gridHeight == 0) return;

    try {
      // 手动坐标转换（与 _globalToGridPosition 保持一致）
      final screenOrigin = customPaintRenderBox.localToGlobal(Offset.zero);
      final relX = position.dx - screenOrigin.dx;
      final relY = position.dy - screenOrigin.dy;
      final matrix = _transformationController.value;
      final scale = matrix.getMaxScaleOnAxis();
      final localX = relX / scale;
      final localY = relY / scale;
      final blockWidth = _cachedBlockWidth!;
      final blockHeight = _cachedBlockHeight!;
      // 基于实际 renderBox.size 动态计算居中偏移
      final dynOffX = (customPaintRenderBox.size.width - blockWidth * gridWidth) / 2;
      final dynOffY = (customPaintRenderBox.size.height - blockHeight * gridHeight) / 2;
      final contentX = localX - dynOffX;
      final contentY = localY - dynOffY;
      final gridX = (contentX / blockWidth).floor();
      final gridY = (contentY / blockHeight).floor();

      if (gridX >= 0 && gridX < gridWidth && gridY >= 0 && gridY < gridHeight) {
        _controller.showFloatingTextAt(gridX.toDouble(), gridY.toDouble());
      }
    } catch (e) {
      print('[PixelCanvas] 显示浮动文本坐标转换出错: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = 375.h;

    if (_image == null) {
      return SizedBox(
        height: maxHeight,
        child: const Center(child: CircularProgressIndicator(color: AppColors.cFAC331,)),
      );
    }

    // 形状预览像素（带缓存：起点/终点/形状类型未变时跳过重算）
    Set<String>? previewShapePixels;
    if (_controller.currentToolMode.value == ToolMode.shape &&
        _shapeStartGrid != null &&
        _shapeEndGrid != null) {
      final shapeType = _controller.selectedShapeType.value;
      if (_shapeStartGrid != _cachedPreviewStart ||
          _shapeEndGrid != _cachedPreviewEnd ||
          shapeType != _cachedPreviewShapeType) {
        _cachedPreviewPixels = _controller.computeShapePixels(
          _shapeStartGrid!.x,
          _shapeStartGrid!.y,
          _shapeEndGrid!.x,
          _shapeEndGrid!.y,
        );
        _cachedPreviewStart = _shapeStartGrid;
        _cachedPreviewEnd = _shapeEndGrid;
        _cachedPreviewShapeType = shapeType;
      }
      previewShapePixels = _cachedPreviewPixels;
    } else {
      previewShapePixels = null;
    }

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // [修复] 使用 LayoutBuilder 获取实际约束宽度，而非 MediaQuery.of(context).size.width
          // 后者取设备屏幕全宽，可能因 SafeArea/Scaffold padding 等大于实际可用宽度，
          // 导致 imageDisplayWidth 按 screenWidth 计算后超出 painter 实际 size.width
          final actualWidth = constraints.maxWidth - 16.w; // 左右各 8.w 间距

          return Center(
            child: SizedBox(
              width: actualWidth,
              height: maxHeight,
          child: Listener(
            onPointerDown: _handlePointerDown,
            onPointerUp: _handlePointerUp,
            onPointerMove: _handlePointerMove,
            onPointerCancel: (event) {
              setState(() {
                _pointerCount = 0;
                _isPainting = false;
                _paintDelayTimer?.cancel();
                _paintDelayTimer = null;
                _pendingPaintPosition = null;
                _isTextDragging = false;
                _textDragStartPointerPosition = null;
                _textDragStartTextPosition = null;
                _shapeStartGrid = null;
                _shapeEndGrid = null;
                _cachedPreviewPixels = null;
                _cachedPreviewStart = null;
                _cachedPreviewEnd = null;
                _viewModeDownPosition = null;
                _viewModeDownTime = null;
                _locationLineDownPosition = null;
              });
            },
            behavior: HitTestBehavior.translucent,
            child: Obx(() {
              // 在 Obx 内读取网格尺寸，旋转/翻转后画板宽高比才能同步更新
              final gridWidth = _controller.gridWidth.value;
              final gridHeight = _controller.gridHeight.value;
              // 关键修复：在 Obx 内部读取 pixelCodes，确保响应式更新
              final pixelCodes = _controller.pixelCodes;
              // 文本模式只在浮动文本显示时禁用平移（允许用户先定位）
              final isDrawMode =
                  _controller.currentToolMode.value == ToolMode.draw ||
                      _controller.currentToolMode.value == ToolMode.eraser ||
                      _controller.currentToolMode.value == ToolMode.sprayGun ||
                      _controller.currentToolMode.value == ToolMode.shape;
              // 文本浮动时也需禁用 pan，防止 InteractiveViewer 抢占单指触摸，导致文本无法拖拽
              final isTextFloatingNow = _controller.isTextFloating.value;
              final panEnabled = !isDrawMode && !isTextFloatingNow;
              final isCircleMode = _controller.isCircleMode.value;
              final showText = _controller.isOtherToolEnabled(ToolMode.code);
              final showReference =
                  _controller.isOtherToolEnabled(ToolMode.reference);
              final showGrid = _controller.isOtherToolEnabled(ToolMode.grid)
                  && _controller.gridShow.value;
              final showNumber =
                  _controller.isOtherToolEnabled(ToolMode.number);

              // 编号边框的固定宽度
              const numberBorderWidth = 24.0;

              // 计算扣除编号边框后的可用空间
              final availW =
                  actualWidth - (showNumber ? numberBorderWidth * 2 : 0);
              final availH =
                  maxHeight - (showNumber ? numberBorderWidth * 2 : 0);

              // 按网格宽高比计算实际显示尺寸（保证像素块为正方形，不变形）
              double imageDisplayWidth, imageDisplayHeight;
              if (gridWidth > 0 && gridHeight > 0) {
                final gridRatio = gridWidth / gridHeight;
                // 先以高度为基准计算宽度
                imageDisplayHeight = availH;
                imageDisplayWidth = availH * gridRatio;
                // 若宽度超出可用空间，改为以宽度为基准
                if (imageDisplayWidth > availW) {
                  imageDisplayWidth = availW;
                  imageDisplayHeight = availW / gridRatio;
                }
              } else {
                imageDisplayWidth = availW;
                imageDisplayHeight = availH;
              }

              // 更新 controller 中的画板尺寸（用于以中心缩放）
              _controller.canvasDisplaySize.value =
                  Size(imageDisplayWidth, imageDisplayHeight);

              // 更新绘制参数缓存（用于优化绘制性能）
              _cachedGridWidth = gridWidth;
              _cachedGridHeight = gridHeight;
              _cachedBlockWidth = imageDisplayWidth / gridWidth;
              _cachedBlockHeight = imageDisplayHeight / gridHeight;

              // 缓存内容居中偏移量（用于坐标转换方法）
              // 注意：SizedBox 始终填满 viewport（actualWidth × maxHeight），
              // 不受编号边框影响，确保矩形网格缩放正常
              _contentOffsetX = (actualWidth - imageDisplayWidth) / 2;
              _contentOffsetY = (maxHeight - imageDisplayHeight) / 2;

              // 预读取文本浮动相关响应式变量，确保 Obx 重建
              final isTextFloating = isTextFloatingNow;
              final pendingText = _controller.pendingText.value;
              final textScale = _controller.textScale.value;

              return Stack(
                children: [
                  // 画板区域：InteractiveViewer 占满屏幕
                  // child 用全屏 SizedBox 填满 viewport（消除矩形网格两侧空白），
                  // 内容居中由 painter 内部通过 translate 实现
                  InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.1,
                    maxScale: 10.0,
                    constrained: true,
                    panEnabled: panEnabled,
                    onInteractionStart: (_) =>
                        _controller.isCanvasScaling.value = true,
                    onInteractionEnd: (_) {
                      _controller.isCanvasScaling.value = false;
                      _repaintNotifier.value++;
                    },
                    child: SizedBox(
                      // 始终填满 viewport，消除矩形网格两侧空白参与缩放变换的问题
                      // 编号边框由独立 overlay (Positioned.fill) 覆盖，不影响 InteractiveViewer
                      width: actualWidth,
                      height: maxHeight,
                      child: CustomPaint(
                        key: _customPaintKey,
                        painter: _PixelCanvasPainter(
                          image: _image!,
                          pixelCodes: pixelCodes,
                          gridWidth: gridWidth,
                          gridHeight: gridHeight,
                          imageDisplaySize:
                              Size(imageDisplayWidth, imageDisplayHeight),
                          transformationController:
                              _transformationController,
                          repaintNotifier: _repaintNotifier,
                          beadColorMap: _beadColorMap,
                          isCircleMode: isCircleMode,
                          showText: showText,
                          showReference: showReference,
                          showGrid: showGrid,
                          textGridPositions: _controller.textGridPositions,
                          gridThickness: _controller.gridThickness.value,
                          gridColor: _controller.gridColor.value,
                          gridSpacing: _controller.gridSpacing.value,
                          gridStartPoint: _controller.gridStartPoint.value,
                          showCenterDash: _controller.centerDashShow.value,
                          colorDisplayMode: _controller.colorDisplayMode.value,
                          isCanvasScaling: _controller.isCanvasScaling.value,
                          previewShapePixels: previewShapePixels,
                          // 编号边框开启时，SizedBox 已填满 viewport（screenWidth × maxHeight）
                          // 无需额外偏移修正，painter 内的 translate 直接处理居中即可
                          contentOffsetX: 0,
                          contentOffsetY: 0,
                          maskedGridKeys: _controller.maskedGridKeys,
                          checkedGridKeys: _controller.checkedGridKeys,
                          locationLineCenterKeys: _controller.locationLineCenterKeys,
                          isLocationLineMode: _controller.currentToolMode.value == ToolMode.locationLine,
                        ),
                      ),
                    ),
                  ),

                  // 编号边框（固定位置，不受缩放影响）
                  if (showNumber)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          key: _numberBorderKey,
                          painter: _NumberBorderPainter(
                            gridWidth: gridWidth,
                            gridHeight: gridHeight,
                            borderWidth: numberBorderWidth,
                            canvasWidth: imageDisplayWidth,
                            canvasHeight: imageDisplayHeight,
                            transformationController: _transformationController,
                            repaintNotifier: _repaintNotifier,
                            // 画布内容在 SizedBox 中的居中偏移（矩形网格时非零）
                            contentOffsetX: _contentOffsetX ?? 0,
                            contentOffsetY: _contentOffsetY ?? 0,
                            getCanvasPosition: () {
                              final canvasCtx = _customPaintKey.currentContext;
                              final borderCtx = _numberBorderKey.currentContext;
                              if (canvasCtx == null || borderCtx == null) return null;
                              final canvasRB =
                                  canvasCtx.findRenderObject() as RenderBox?;
                              final borderRB =
                                  borderCtx.findRenderObject() as RenderBox?;
                              if (canvasRB == null || borderRB == null) return null;
                              // 通过框架直接获取画布在编号边框坐标系中的真实位置
                              // 自动包含 InteractiveViewer 变换、Padding、Align 等所有偏移
                              return canvasRB.localToGlobal(
                                  Offset.zero, ancestor: borderRB);
                            },
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),

                  // 控制菜单（固定在屏幕右上角，不受 InteractiveViewer 影响）
                  // 用 Listener(opaque) + IgnorePointer 阻止菜单区域的触摸事件穿透到画板
                  if (pendingText.isNotEmpty)
                    Positioned(
                      top: showNumber ? numberBorderWidth + 8 : 8,
                      right: showNumber ? numberBorderWidth + 8 : 8,
                      child: Listener(
                        key: _textMenuKey,
                        onPointerDown: (_) {},
                        // 吸收所有触摸事件，阻止透传到画板
                        onPointerMove: (_) {},
                        onPointerUp: (_) {},
                        onPointerCancel: (_) {},
                        behavior: HitTestBehavior.opaque,
                        child: _TextControlMenu(
                          scale: textScale,
                          isFloating: isTextFloating,
                          onApply: () => _controller.applyText(),
                          onDiscard: () => _controller.discardText(),
                          onIncreaseScale: () =>
                              _controller.increaseTextScale(),
                          onDecreaseScale: () =>
                              _controller.decreaseTextScale(),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ); // Center > SizedBox > Listener > Obx > Stack
        }, // LayoutBuilder builder
      ), // LayoutBuilder
    ); // RepaintBoundary
  }
}

/// 像素画板绘制器
class _PixelCanvasPainter extends CustomPainter {
  final ui.Image image;
  final List<String> pixelCodes;
  final int gridWidth;
  final int gridHeight;
  final Size imageDisplaySize;
  final TransformationController transformationController;
  final ValueNotifier<int> repaintNotifier;
  final Map<String, _BeadColor>? beadColorMap;
  final bool isCircleMode;
  final bool showText;
  final bool showReference;
  final bool showGrid;
  final Set<String> textGridPositions;

  /// 网格粗细（粗线宽度）
  final double gridThickness;

  /// 粗网格颜色
  final Color gridColor;

  /// 粗网格间隔
  final int gridSpacing;

  /// 网格起始点偏移
  final Offset gridStartPoint;

  /// 中虚线是否显示（'显示'|'隐藏'）
  final bool showCenterDash;

  /// 色号显示模式
  final ColorDisplayMode colorDisplayMode;

  /// 画布是否正在缩放中（scale 模式用）
  final bool isCanvasScaling;

  /// 形状预览像素集合（绘制中时展示半透明预览，null 表示无预览）
  final Set<String>? previewShapePixels;

  /// 画布在 InteractiveViewer 子坐标系中的偏移（编号边框开启时为 borderWidth）
  /// 用于修正视口裁剪的坐标计算
  final double contentOffsetX;
  final double contentOffsetY;

  /// 需要遮罩显示的像素块集合（高亮功能使用）
  final Set<String> maskedGridKeys;

  /// 需要显示✅标记的像素块集合（区域已拼/同色已拼好）
  final Set<String> checkedGridKeys;

  /// 点位线中心坐标集合（"col,row"格式，点位线模式下显示十字+横向纵向蒙层）
  final Set<String> locationLineCenterKeys;

  /// 是否处于点位线模式（用于隐藏高亮等冲突 UI）
  final bool isLocationLineMode;

  _PixelCanvasPainter({
    required this.image,
    required this.pixelCodes,
    required this.gridWidth,
    required this.gridHeight,
    required this.imageDisplaySize,
    required this.transformationController,
    required this.repaintNotifier,
    this.beadColorMap,
    this.isCircleMode = false,
    this.showText = false,
    this.showReference = false,
    this.showGrid = false,
    this.textGridPositions = const {},
    this.gridThickness = 3.0,
    this.gridColor = const Color(0xFFFF4444),
    this.gridSpacing = 9,
    this.gridStartPoint = const Offset(1.0, 1.0),
    this.showCenterDash = false,
    this.colorDisplayMode = ColorDisplayMode.normal,
    this.isCanvasScaling = false,
    this.previewShapePixels,
    this.contentOffsetX = 0,
    this.contentOffsetY = 0,
    this.maskedGridKeys = const {},
    this.checkedGridKeys = const {},
    this.locationLineCenterKeys = const {},
    this.isLocationLineMode = false,
  }) : super(repaint: repaintNotifier);

  /// 绘制网格线
  void _drawGridLines(Canvas canvas, Size imageSize, Size fullSize,
      double offsetX, double offsetY) {
    // 使用浮点数均匀分配网格线（与像素化处理保持一致）
    final blockWidth = imageSize.width / gridWidth;
    final blockHeight = imageSize.height / gridHeight;

    // 普通网格线（细线）— 固定细线参数，延后到最后绘制以避免被粗线/虚线覆盖
    final thinPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.15;

    // 粗网格线（使用用户配置的粗细、颜色、间隔和起始偏移）
    final step = gridSpacing;
    final startOffsetX = gridStartPoint.dx.toInt();
    final startOffsetY = gridStartPoint.dy.toInt();

    if (showGrid) {
      final boldPaint = Paint()
        ..color = gridColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = gridThickness;

      // 纵向粗线（从起始偏移开始，每 step 格画一条）
      for (int i = startOffsetX; i < gridWidth; i += step) {
        final x = i * blockWidth;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, imageSize.height),
          boldPaint,
        );
      }

      // 横向粗线（从起始偏移开始，每 step 格画一条）
      for (int i = startOffsetY; i < gridHeight; i += step) {
        final y = i * blockHeight;
        canvas.drawLine(
          Offset(0, y),
          Offset(imageSize.width, y),
          boldPaint,
        );
      }
    }

    // 中虚线：在大网格居中位置画同色虚线（横竖方向）
    if (showCenterDash && showGrid) {
      final dashPaint = Paint()
        ..color = gridColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = gridThickness;

      // 计算居中位置：gridSpacing ~/ 2（8×8→4, 9×9→4）
      final centerStep = gridSpacing ~/ 2;

      // 虚线效果：使用 Path + dash effect
      final dashPath = Path();
      const dashLength = 6.0;
      const gapLength = 4.0;

      // 纵向中虚线（从起始偏移 + centerStep 开始，每 step 格画一条）
      for (int i = startOffsetX + centerStep; i < gridWidth; i += step) {
        final x = i * blockWidth;
        _drawDashedLine(canvas, Offset(x, 0), Offset(x, imageSize.height),
            dashPaint, dashLength, gapLength);
      }

      // 横向中虚线
      for (int i = startOffsetY + centerStep; i < gridHeight; i += step) {
        final y = i * blockHeight;
        _drawDashedLine(canvas, Offset(0, y), Offset(imageSize.width, y),
            dashPaint, dashLength, gapLength);
      }
    }

    // 【最后】绘制普通细线网格，确保不被粗线/虚线覆盖
    // 绘制纵向网格线
    for (int i = 0; i <= gridWidth; i++) {
      final x = i * blockWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, imageSize.height),
        thinPaint,
      );
    }

    // 绘制横向网格线
    for (int i = 0; i <= gridHeight; i++) {
      final y = i * blockHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(imageSize.width, y),
        thinPaint,
      );
    }
  }

  /// 绘制虚线（通过分段绘制实现）
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      double dashLength, double gapLength) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    if (distance < 0.001) return;

    final unitX = dx / distance;
    final unitY = dy / distance;
    double current = 0;
    bool drawing = true;

    while (current < distance) {
      final segLen = drawing
          ? min(dashLength, distance - current)
          : min(gapLength, distance - current);
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

  @override
  void paint(Canvas canvas, Size size) {
    if (pixelCodes.isEmpty || gridWidth == 0 || gridHeight == 0) {
      return;
    }

    // [关键修复] 内容居中：SizedBox 填满 viewport，但实际内容是 imageDisplaySize，
    // 需要平移到居中位置，消除矩形网格两侧空白参与缩放变换的问题
    final offsetX = (size.width - imageDisplaySize.width) / 2;
    final offsetY = (size.height - imageDisplaySize.height) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);

    // 获取当前的缩放比例
    final matrix = transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    // 计算网格块的最小尺寸（考虑缩放）
    final minGridWidth = (imageDisplaySize.width / gridWidth) * scale;
    final minGridHeight = (imageDisplaySize.height / gridHeight) * scale;

    // 性能优化：文字显示阈值，缩小到极小时仍显示（由 fontSize 自身 clamp 控制）
    // 不再做硬性尺寸门槛限制

    // 先计算一次网格线（供 _drawPixelBlocks 和 _drawText 共用）
    final blockWidth = imageDisplaySize.width / gridWidth;
    final blockHeight = imageDisplaySize.height / gridHeight;
    final xGridLines = List<double>.generate(gridWidth + 1,
        (i) => i == gridWidth ? imageDisplaySize.width : i * blockWidth);
    final yGridLines = List<double>.generate(gridHeight + 1,
        (i) => i == gridHeight ? imageDisplaySize.height : i * blockHeight);

    // 视口裁剪：计算当前缩放/平移状态下的可见区域
    // 现在 SizedBox 填满 viewport，size 就是完整的视口尺寸
    // painter.translate(offsetX, offsetY) 处理居中，直接减去 offsetX/Y 即可转换到内容坐标
    final translation = matrix.getTranslation();
    final tx = translation.x;
    final ty = translation.y;

    final visX0 = (0 - tx) / scale - offsetX;
    final visY0 = (0 - ty) / scale - offsetY;
    final visX1 = (size.width - tx) / scale - offsetX;
    final visY1 = (size.height - ty) / scale - offsetY;

    // 根据可见区域计算需要绘制的网格行列范围
    final startCol = (visX0 / blockWidth).floor().clamp(0, gridWidth - 1);
    final endCol = (visX1 / blockWidth).ceil().clamp(startCol + 1, gridWidth);
    final startRow = (visY0 / blockHeight).floor().clamp(0, gridHeight - 1);
    final endRow = (visY1 / blockHeight).ceil().clamp(startRow + 1, gridHeight);

    // 先绘制像素块矩形（使用预计算的网格线 + 视口裁剪范围）
    _drawPixelBlocks(canvas, xGridLines, yGridLines,
        startCol, endCol, startRow, endRow);

    // 绘制文本选中效果（黄色边框 + 半透明黑色蒙层）
    if (textGridPositions.isNotEmpty) {
      _drawTextSelection(canvas, imageDisplaySize);
    }

    // 后绘制网格线（覆盖整个屏幕，而不仅仅是像素图片区域）
    _drawGridLines(canvas, imageDisplaySize, size, 0, 0);

    // 只在空间足够时绘制文本（使用预计算的网格线 + 视口裁剪范围）
    if (showText) {
      _drawText(canvas, xGridLines, yGridLines, startCol, endCol, startRow, endRow);
    }

    // 【最后】绘制高亮蒙层：确保蒙层盖在像素块和文字的最上层
    // 点位线模式激活时不展示高亮效果（避免视觉冲突）
    if (maskedGridKeys.isNotEmpty && !isLocationLineMode) {
      _drawMergedMaskOverlay(canvas, xGridLines, yGridLines,
          imageDisplaySize.width / gridWidth,
          imageDisplaySize.height / gridHeight);
    }

    // 绘制参考图蒙层（低透明度原图覆盖，用于对比）
    if (showReference) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, imageDisplaySize.width, imageDisplaySize.height),
        Paint()..color = const Color(0x60FFFFFF),
      );
    }

    // 绘制形状预览层（手势拖动时实时显示）
    if (previewShapePixels != null && previewShapePixels!.isNotEmpty) {
      _drawShapePreview(canvas, imageDisplaySize);
    }

    // 绘制点位线（十字+横向纵向黄色半透明蒙层，最顶层）
    if (locationLineCenterKeys.isNotEmpty) {
      _drawLocationLine(canvas, xGridLines, yGridLines,
          imageDisplaySize.width / gridWidth,
          imageDisplaySize.height / gridHeight);
    }

    // 恢复画布状态（抵消居中 translate）
    canvas.restore();
  }

  /// 绘制形状实时预览（与文本选中效果一致：半透明黑色蒙层 + 黄色边框）
  void _drawShapePreview(Canvas canvas, Size imageSize) {
    if (previewShapePixels == null || previewShapePixels!.isEmpty) return;
    _drawGridSelection(canvas, imageSize, previewShapePixels!);
  }

  /// 绘制点位线效果：每个中心点的横向+纵向像素显示黄色半透明蒙层，中心点显示十字
  void _drawLocationLine(Canvas canvas, List<double> xGridLines,
      List<double> yGridLines, double blockWidth, double blockHeight) {
    if (locationLineCenterKeys.isEmpty) return;

    final overlayPaint = Paint()
      ..color = const Color(0x80FAC331); // 黄色半透明
    final crossPaint = Paint()
      ..color = const Color(0xFFFAC331) // 黄色十字
      ..style = PaintingStyle.stroke
      ..strokeWidth = min(blockWidth, blockHeight) * 0.15
      ..strokeCap = StrokeCap.round;
    final crossBgPaint = Paint()
      ..color = const Color(0xE6FFFFFF); // 白色底（遮住色号文字）

    // 第一步：收集所有需要绘制蒙层的格子（Set 去重 + 排除已蒙层格子）
    final overlayKeys = <String>{};
    for (final key in locationLineCenterKeys) {
      final parts = key.split(',');
      if (parts.length != 2) continue;
      final centerCol = int.tryParse(parts[0]);
      final centerRow = int.tryParse(parts[1]);
      if (centerCol == null || centerRow == null) continue;
      if (centerCol < 0 || centerCol >= gridWidth || centerRow < 0 || centerRow >= gridHeight) continue;

      // 收集整行
      for (int c = 0; c < gridWidth; c++) {
        overlayKeys.add('$c,$centerRow');
      }
      // 收集整列
      for (int r = 0; r < gridHeight; r++) {
        overlayKeys.add('$centerCol,$r');
      }
    }

    // 第二步：批量绘制去重后的蒙层（非点位线模式时跳过已高亮蒙层覆盖的）
    final shouldSkipMasked = !isLocationLineMode;
    for (final gk in overlayKeys) {
      if (shouldSkipMasked && maskedGridKeys.contains(gk)) continue;
      final parts = gk.split(',');
      final col = int.tryParse(parts[0]);
      final row = int.tryParse(parts[1]);
      if (col == null || row == null) continue;
      canvas.drawRect(
        Rect.fromLTWH(xGridLines[col], yGridLines[row], blockWidth, blockHeight),
        overlayPaint,
      );
    }

    // 第三步：绘制每个中心点的白色底 + 十字
    for (final key in locationLineCenterKeys) {
      final parts = key.split(',');
      if (parts.length != 2) continue;
      final centerCol = int.tryParse(parts[0]);
      final centerRow = int.tryParse(parts[1]);
      if (centerCol == null || centerRow == null) continue;
      if (centerCol < 0 || centerCol >= gridWidth || centerRow < 0 || centerRow >= gridHeight) continue;

      final cx = xGridLines[centerCol];
      final cy = yGridLines[centerRow];

      canvas.drawRect(Rect.fromLTWH(cx, cy, blockWidth, blockHeight), crossBgPaint);

      final centerX = cx + blockWidth / 2;
      final centerY = cy + blockHeight / 2;
      final armLen = min(blockWidth, blockHeight) * 0.35;

      // 横线
      canvas.drawLine(
        Offset(centerX - armLen, centerY), Offset(centerX + armLen, centerY), crossPaint);
      // 竖线
      canvas.drawLine(
        Offset(centerX, centerY - armLen), Offset(centerX, centerY + armLen), crossPaint);
    }
  }

  /// 绘制文本选中效果（黄色边框 + 半透明黑色蒙层）
  void _drawTextSelection(Canvas canvas, Size imageSize) {
    _drawGridSelection(canvas, imageSize, textGridPositions);
  }

  /// 绘制✅标记（用于区域已拼/同色已拼好功能）
  void _drawCheckMark(Canvas canvas, Offset center, double size) {
    final checkPaint = Paint()
      ..color = const Color(0xFFFAC331)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 绘制✅形状：左下到中心，再到右上
    final path = Path();
    path.moveTo(center.dx - size * 0.4, center.dy);
    path.lineTo(center.dx - size * 0.1, center.dy + size * 0.35);
    path.lineTo(center.dx + size * 0.45, center.dy - size * 0.3);

    canvas.drawPath(path, checkPaint);
  }

  /// 通用：绘制网格选中高亮（半透明黑色蒙层 + 黄色边框）
  void _drawGridSelection(Canvas canvas, Size imageSize, Set<String> gridKeys) {
    if (gridKeys.isEmpty) return;
    final blockWidth = imageSize.width / gridWidth;
    final blockHeight = imageSize.height / gridHeight;

    // 半透明黑色蒙层画笔
    final overlayPaint = Paint()..color = const Color(0xB3000000);
    // 黄色边框画笔
    final borderPaint = Paint()
      ..color = const Color(0xFFFAC331)
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          (blockWidth < blockHeight ? blockWidth : blockHeight) * 0.12;

    for (final key in gridKeys) {
      final commaIndex = key.indexOf(',');
      if (commaIndex < 0) continue;
      final col = int.tryParse(key.substring(0, commaIndex));
      final row = int.tryParse(key.substring(commaIndex + 1));
      if (col == null || row == null) continue;
      if (col < 0 || col >= gridWidth || row < 0 || row >= gridHeight) continue;
      final rect = Rect.fromLTWH(
          col * blockWidth, row * blockHeight, blockWidth, blockHeight);
      canvas.drawRect(rect, overlayPaint);
      canvas.drawRect(rect, borderPaint);
    }
  }

  /// 绘制合并边框的高亮蒙层（相邻蒙层像素共享边框，只画外轮廓）
  /// 确保蒙层盖在所有像素块和文字之上
  void _drawMergedMaskOverlay(Canvas canvas, List<double> xGridLines,
      List<double> yGridLines, double blockWidth, double blockHeight) {
    if (maskedGridKeys.isEmpty) return;

    // 半透明黑色蒙层画笔
    final overlayPaint = Paint()..color = const Color(0xB3000000);
    // 黄色边框画笔（外轮廓）
    final borderPaint = Paint()
      ..color = const Color(0xFFFAC331)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (blockWidth < blockHeight ? blockWidth : blockHeight) * 0.12;

    // 将 maskedGridKeys 解析为坐标集合，方便快速查询
    // 使用 Set<String> 直接查找即可，无需额外转换
    final maskedSet = maskedGridKeys;

    // 第一步：批量填充所有蒙层区域的底色
    for (final key in maskedSet) {
      final commaIndex = key.indexOf(',');
      if (commaIndex < 0) continue;
      final col = int.tryParse(key.substring(0, commaIndex));
      final row = int.tryParse(key.substring(commaIndex + 1));
      if (col == null || row == null) continue;
      if (col < 0 || col >= gridWidth || row < 0 || row >= gridHeight) continue;

      final rect = Rect.fromLTWH(
          col * blockWidth, row * blockHeight, blockWidth, blockHeight);
      canvas.drawRect(rect, overlayPaint);
    }

    // 第二步：只画外轮廓边框——对每个蒙层格子检查四邻，
    // 只有当邻居不在蒙层集合中时才画对应的边
    for (final key in maskedSet) {
      final commaIndex = key.indexOf(',');
      if (commaIndex < 0) continue;
      final col = int.tryParse(key.substring(0, commaIndex));
      final row = int.tryParse(key.substring(commaIndex + 1));
      if (col == null || row == null) continue;
      if (col < 0 || col >= gridWidth || row < 0 || row >= gridHeight) continue;

      final x = col * blockWidth;
      final y = row * blockHeight;

      // 上边：上方邻居不在蒙层中 或 越界
      if (!_isMaskedNeighbor(maskedSet, col, row - 1)) {
        canvas.drawLine(
            Offset(x, y), Offset(x + blockWidth, y), borderPaint);
      }
      // 下边：下方邻居不在蒙层中 或 越界
      if (!_isMaskedNeighbor(maskedSet, col, row + 1)) {
        canvas.drawLine(
            Offset(x, y + blockHeight), Offset(x + blockWidth, y + blockHeight), borderPaint);
      }
      // 左边：左方邻居不在蒙层中 或 越界
      if (!_isMaskedNeighbor(maskedSet, col - 1, row)) {
        canvas.drawLine(
            Offset(x, y), Offset(x, y + blockHeight), borderPaint);
      }
      // 右边：右方邻居不在蒙层中 或 越界
      if (!_isMaskedNeighbor(maskedSet, col + 1, row)) {
        canvas.drawLine(
            Offset(x + blockWidth, y), Offset(x + blockWidth, y + blockHeight), borderPaint);
      }
    }
  }

  /// 判断指定坐标是否为蒙层像素（含越界保护）
  bool _isMaskedNeighbor(Set<String> maskedSet, int col, int row) {
    // 越界视为非蒙层（会触发边框绘制）
    if (col < 0 || col >= gridWidth || row < 0 || row >= gridHeight) return false;
    return maskedSet.contains('$col,$row');
  }

  @override
  bool shouldRepaint(_PixelCanvasPainter oldDelegate) => true;

  /// 绘制像素块矩形（带视口裁剪：只绘制可见区域内的网格）
  void _drawPixelBlocks(Canvas canvas, List<double> xGridLines,
      List<double> yGridLines, int startCol, int endCol, int startRow, int endRow) {
    if (beadColorMap == null) return;

    // [P0-1] 预创建 Paint 对象，循环内只修改 color 属性，避免每格 new Paint()
    //   正常像素块使用 fillPaint，缺失颜色使用 warnPaint（灰色警告）
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final warnPaint = Paint()..color = const Color(0xFFB0B0B0)..style = PaintingStyle.fill;

    for (int row = startRow; row < endRow; row++) {
      for (int col = startCol; col < endCol; col++) {
        final index = row * gridWidth + col;
        if (index >= pixelCodes.length) continue;

        // 获取对应的颜色代码
        final code = pixelCodes[index];

        // 如果代码为空，跳过
        if (code.isEmpty) continue;

        // 使用预计算的网格线位置计算绘制区域
        final startX = xGridLines[col];
        final startY = yGridLines[row];
        final endX = xGridLines[col + 1];
        final endY = yGridLines[row + 1];
        final width = endX - startX;
        final height = endY - startY;

        // 跳过无效的网格（宽度或高度为0或负数）
        if (width <= 0 || height <= 0) continue;

        // 从颜色映射中获取对应的颜色
        final beadColor = beadColorMap![code];
        if (beadColor == null) {
          print('[PixelCanvas] 警告: 未找到颜色代码: $code，使用灰色替代绘制');
          canvas.drawRect(Rect.fromLTWH(startX, startY, width, height), warnPaint);
          continue;
        }

        // [P0-1] 复用 Paint，只改 color
        fillPaint.color = beadColor.toColor();

        // 检查当前像素是否需要特殊处理
        final gridKey = '$col,$row';
        final isMasked = maskedGridKeys.contains(gridKey);
        final isChecked = checkedGridKeys.contains(gridKey);

        // 已拼好的色号：显示50%透明度效果
        if (isChecked) {
          fillPaint.color = beadColor.toColor().withValues(alpha: 0.5);
        }

        if (isCircleMode) {
          // 圆形模式：以网格中心为圆心，取宽高较小值为直径
          final centerX = startX + width / 2;
          final centerY = startY + height / 2;
          final radius = width < height ? width / 2 : height / 2;
          canvas.drawCircle(Offset(centerX, centerY), radius, fillPaint);

          // 已拼好标记：显示✅
          if (isChecked) {
            _drawCheckMark(canvas, Offset(centerX, centerY), radius * 0.6);
          }
        } else {
          // 方形模式
          canvas.drawRect(Rect.fromLTWH(startX, startY, width, height), fillPaint);

          // 已拼好标记：显示✅
          if (isChecked) {
            _drawCheckMark(canvas, Offset(startX + width / 2, startY + height / 2), width * 0.35);
          }
        }

        // 遮罩效果已移到 paint() 最外层绘制，确保盖在文字之上
        // 此处只负责像素块底色和✅标记的绘制
      }
    }
  }

  /// 绘制文本（带视口裁剪：只绘制可见区域内的文本）
  void _drawText(Canvas canvas, List<double> xGridLines,
      List<double> yGridLines, int startCol, int endCol, int startRow, int endRow) {
    // 隐藏模式下不绘制色号文字
    if (colorDisplayMode == ColorDisplayMode.hidden) return;

    // scale 模式：仅在缩放过程中显示色号，缩放停止后不显示
    if (colorDisplayMode == ColorDisplayMode.scale && !isCanvasScaling) return;

    if (colorDisplayMode == ColorDisplayMode.compressRow) {
      _drawCompressRowText(canvas, xGridLines, yGridLines,
          startCol, endCol, startRow, endRow);
      return;
    }

    if (colorDisplayMode == ColorDisplayMode.compressColumn) {
      _drawCompressColumnText(canvas, xGridLines, yGridLines,
          startCol, endCol, startRow, endRow);
      return;
    }

    // [P0-2] 网格线已在 paint() 入口处预计算并传入，无需重复生成

    // 计算网格块尺寸
    final blockWidth = xGridLines[1] - xGridLines[0];
    final blockHeight = yGridLines[1] - yGridLines[0];

    // 统一字体大小：取网格宽高较小值的 40%（确保适合大多数代码）
    final baseFontSize = (blockWidth < blockHeight ? blockWidth : blockHeight) * 0.4;

    // 性能优化：创建可复用的 TextPainter
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1, // 强制单行
    );

    // 绘制每个像素块的颜色code（跳过文本选中区域）—— 仅遍历可见范围
    for (int row = startRow; row < endRow; row++) {
      for (int col = startCol; col < endCol; col++) {
        final index = row * gridWidth + col;
        if (index >= pixelCodes.length) continue;

        final code = pixelCodes[index];

        // 只在code不为空时绘制
        if (code.isEmpty) continue;

        // 文本选中区域：跳过文字绘制，只保留蒙层+边框效果
        if (textGridPositions.isNotEmpty &&
            textGridPositions.contains('$col,$row')) continue;

        // 已拼区域：只显示 ✅ 标记，不显示色号文本
        if (checkedGridKeys.contains('$col,$row')) continue;

        // 从颜色映射中获取对应的颜色
        final beadColor = beadColorMap![code];
        if (beadColor == null) {
          continue;
        }
        // 使用网格线位置计算中心
        final startX = xGridLines[col];
        final startY = yGridLines[row];
        final endX = xGridLines[col + 1];
        final endY = yGridLines[row + 1];

        final centerX = (startX + endX) / 2;
        final centerY = (startY + endY) / 2;
        final gridCellWidth = endX - startX;
        final gridCellHeight = endY - startY;

        // 计算亮度（使用相对亮度公式）
        final luminance =
            (0.299 * beadColor.r + 0.587 * beadColor.g + 0.114 * beadColor.b) /
                255;

        // 根据亮度选择文本颜色
        final textColor = luminance <= 0.5 ? Colors.white : Colors.black;

        // 目标：文本宽度不超过网格宽度的 90%，高度不超过网格高度的 75%
        final maxWidth = gridCellWidth * 0.9;
        final maxHeight = gridCellHeight * 0.75;

        // 计算字体大小：根据代码长度动态调整
        double fontSize = baseFontSize;

        // 根据代码长度缩放字体（代码越长字体越小）
        if (code.length > 2) {
          fontSize = fontSize * 2.5 / code.length;
        }

        // 字体大小不做最小限制，缩多小都显示
        if (fontSize < 0.5) {
          fontSize = 0.5;
        }

        // 设置文本并测量
        _paintSingleCode(textPainter, canvas, code, textColor, fontSize,
            maxWidth, maxHeight, centerX, centerY);
      }
    }
  }

  /// 行压缩模式（水平数量）：每行从左到右扫描，
  /// 同色连续段第一个格子显示色号，后续格子显示序号 2、3、4...
  void _drawCompressRowText(Canvas canvas, List<double> xGridLines,
      List<double> yGridLines, int startCol, int endCol, int startRow, int endRow) {

    final blockWidth = xGridLines[1] - xGridLines[0];
    final blockHeight = yGridLines[1] - yGridLines[0];
    final baseFontSize = (blockWidth < blockHeight ? blockWidth : blockHeight) * 0.4;
    final maxWidth = blockWidth * 0.9;
    final maxHeight = blockHeight * 0.75;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    );

    // 必须从 col=0 开始扫描整行，才能正确计算同色连续段的序号
    // 缩放/移动时若只用 startCol~endCol 裁剪范围，会导致连续段被截断、序号错乱
    for (int row = startRow; row < endRow; row++) {
      var col = 0;
      while (col < gridWidth) {
        final index = row * gridWidth + col;
        if (index >= pixelCodes.length || pixelCodes[index].isEmpty) { col++; continue; }

        final code = pixelCodes[index];
        final beadColor = beadColorMap![code];
        if (beadColor == null) { col++; continue; }

        // 向右扩展统计同色连续段长度
        int count = 0;
        var scanCol = col;
        while (scanCol < gridWidth) {
          final scanIdx = row * gridWidth + scanCol;
          if (scanIdx >= pixelCodes.length) break;
          if (pixelCodes[scanIdx] != code) break;
          count++;
          scanCol++;
        }
        if (count == 0) { col++; continue; }

        // 计算该段的文本颜色（基于颜色亮度）
        final luminance =
            (0.299 * beadColor.r + 0.587 * beadColor.g + 0.114 * beadColor.b) / 255;
        final textColor = luminance <= 0.5 ? Colors.white : Colors.black;

        // 只在视口可见范围内绘制文本
        for (int i = 0; i < count; i++) {
          final c = col + i;
          if (c < startCol || c >= endCol) continue;

          // 跳过文本选中区域
          if (textGridPositions.isNotEmpty &&
              textGridPositions.contains('$c,$row')) continue;

          // 已拼区域：只显示 ✅ 标记，不显示色号文本
          if (checkedGridKeys.contains('$c,$row')) continue;

          final centerX = (xGridLines[c] + xGridLines[c + 1]) / 2;
          final centerY = (yGridLines[row] + yGridLines[row + 1]) / 2;
          final displayText = (i == 0) ? code : '${i + 1}';
          double fontSize = baseFontSize;
          if (displayText.length > 2) {
            fontSize = fontSize * 2.5 / displayText.length;
          }

          _paintSingleCode(textPainter, canvas, displayText, textColor, fontSize,
              maxWidth, maxHeight, centerX, centerY);
        }
        col += count;
      }
    }
  }

  /// 列压缩模式（垂直数量）：每列从上到下扫描，
  /// 同色连续段第一个格子显示色号，后续格子显示序号 2、3、4...
  void _drawCompressColumnText(Canvas canvas, List<double> xGridLines,
      List<double> yGridLines, int startCol, int endCol, int startRow, int endRow) {

    final blockWidth = xGridLines[1] - xGridLines[0];
    final blockHeight = yGridLines[1] - yGridLines[0];
    final baseFontSize = (blockWidth < blockHeight ? blockWidth : blockHeight) * 0.4;
    final maxWidth = blockWidth * 0.9;
    final maxHeight = blockHeight * 0.75;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    );

    // 必须从 row=0 开始扫描整列，才能正确计算同色连续段的序号
    // 缩放/移动时若只用 startRow~endRow 裁剪范围，会导致连续段被截断、序号错乱
    for (int col = startCol; col < endCol; col++) {
      var row = 0;
      while (row < gridHeight) {
        final index = row * gridWidth + col;
        if (index >= pixelCodes.length || pixelCodes[index].isEmpty) { row++; continue; }

        final code = pixelCodes[index];
        final beadColor = beadColorMap![code];
        if (beadColor == null) { row++; continue; }

        // 向下扩展统计同色连续段高度
        int count = 0;
        var scanRow = row;
        while (scanRow < gridHeight) {
          final scanIdx = scanRow * gridWidth + col;
          if (scanIdx >= pixelCodes.length) break;
          if (pixelCodes[scanIdx] != code) break;
          count++;
          scanRow++;
        }
        if (count == 0) { row++; continue; }

        // 计算该段的文本颜色（基于颜色亮度）
        final luminance =
            (0.299 * beadColor.r + 0.587 * beadColor.g + 0.114 * beadColor.b) / 255;
        final textColor = luminance <= 0.5 ? Colors.white : Colors.black;

        // 只在视口可见范围内绘制文本
        for (int i = 0; i < count; i++) {
          final r = row + i;
          if (r < startRow || r >= endRow) continue;

          // 跳过文本选中区域
          if (textGridPositions.isNotEmpty &&
              textGridPositions.contains('$col,$r')) continue;

          // 已拼区域：只显示 ✅ 标记，不显示色号文本
          if (checkedGridKeys.contains('$col,$r')) continue;

          final centerX = (xGridLines[col] + xGridLines[col + 1]) / 2;
          final centerY = (yGridLines[r] + yGridLines[r + 1]) / 2;
          final displayText = (i == 0) ? code : '${i + 1}';
          double fontSize = baseFontSize;
          if (displayText.length > 2) {
            fontSize = fontSize * 2.5 / displayText.length;
          }

          _paintSingleCode(textPainter, canvas, displayText, textColor, fontSize,
              maxWidth, maxHeight, centerX, centerY);
        }
        row += count;
      }
    }
  }

  /// 绘制单条文本（复用 TextPainter，处理自适应缩放和居中）
  void _paintSingleCode(TextPainter textPainter, Canvas canvas, String text,
      Color textColor, double fontSize, double maxWidth, double maxHeight,
      double centerX, double centerY) {
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        height: 1.0,
      ),
    );
    textPainter.layout();

    if (textPainter.width > maxWidth || textPainter.height > maxHeight) {
      final scaleX = maxWidth / textPainter.width;
      final scaleY = maxHeight / textPainter.height;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      fontSize = fontSize * scale;

      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      );
      textPainter.layout();
    }

    textPainter.paint(canvas,
        Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2));
  }
}


/// 编号边框绘制器（固定位置，不受 InteractiveViewer 缩放影响，但编号对齐网格位置）
class _NumberBorderPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final double borderWidth;
  final double canvasWidth;
  final double canvasHeight;
  final TransformationController transformationController;
  final ValueNotifier<int> repaintNotifier;

  /// 通过 RenderBox 获取画布在编号边框坐标系中的真实位置
  /// 自动包含 InteractiveViewer 变换、Padding、Align 等所有偏移，无需手动推算
  final Offset? Function() getCanvasPosition;

  /// 画布内容在 SizedBox 中的居中偏移（矩形网格时非零）
  /// SizedBox 填满 viewport，但内容更小且居中，需要补偿此偏移使编号对齐网格
  final double contentOffsetX;
  final double contentOffsetY;

  _NumberBorderPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.borderWidth,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.transformationController,
    required this.repaintNotifier,
    required this.getCanvasPosition,
    this.contentOffsetX = 0,
    this.contentOffsetY = 0,
  }) : super(
            // 与 _PixelCanvasPainter 共享 repaintNotifier（经 debounce），
            // 避免 transformationController 变化导致每帧重绘
            repaint: repaintNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    final border = borderWidth;
    final viewportW = size.width;
    final viewportH = size.height;

    // 获取当前变换矩阵（用于计算缩放后的网格间距）
    final matrix = transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    // 通过 RenderBox 直接获取画布左上角的真实位置
    // 框架自动计算了所有布局偏移 + InteractiveViewer 变换，零误差
    final canvasPos = getCanvasPosition();
    if (canvasPos == null) return; // 布局未完成时跳过

    final tlX = canvasPos.dx;
    final tlY = canvasPos.dy;

    // [修复] 与 _PixelCanvasPainter.paint() 中的居中偏移计算完全一致：
    //   final offsetX = (size.width - imageDisplaySize.width) / 2;
    //   final offsetY = (size.height - imageDisplaySize.height) / 2;
    // 不再依赖 build() 中传入的 contentOffsetX/Y（其基于 screenWidth/maxHeight 计算，
    // 与实际 painter.size.width/height 可能因布局约束链路不同而存在偏差，导致约一个格子的错位）
    final selfOffsetX = (viewportW - canvasWidth) / 2;
    final selfOffsetY = (viewportH - canvasHeight) / 2;

    // InteractiveViewer 缩放后偏移量等比放大
    final contentScreenOffsetX = selfOffsetX * scale;
    final contentScreenOffsetY = selfOffsetY * scale;

    // [DEBUG] 编号框对齐诊断
    print('[NumberBorder] 对齐诊断: scale=$scale, '
        'tlX=$tlX, tlY=$tlY, '
        'selfOffsetX=$selfOffsetX($contentScreenOffsetX), selfOffsetY=$selfOffsetY($contentScreenOffsetY), '
        '传入contentOffsetX=$contentOffsetX, contentOffsetY=$contentOffsetY, '
        'canvasW=$canvasWidth, canvasH=$canvasHeight, '
        'gridW=$gridWidth, gridH=$gridHeight, '
        'viewportW=$viewportW, viewportH=$viewportH');

    // 每个网格单元在屏幕上的尺寸
    final colStepScreen = (canvasWidth / gridWidth) * scale;
    final rowStepScreen = (canvasHeight / gridHeight) * scale;
    final minStep =
        colStepScreen < rowStepScreen ? colStepScreen : rowStepScreen;

    // 背景色（填充固定边框条区域）
    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, viewportW, border), bgPaint); // 顶部
    canvas.drawRect(
        Rect.fromLTWH(0, viewportH - border, viewportW, border), bgPaint); // 底部
    canvas.drawRect(Rect.fromLTWH(0, border, border, viewportH - 2 * border),
        bgPaint); // 左侧
    canvas.drawRect(
        Rect.fromLTWH(
            viewportW - border, border, border, viewportH - 2 * border),
        bgPaint); // 右侧
    // 分割线刻度（浅灰色）
    final tickPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 可见的列范围
    // 内容实际从 tlX + contentScreenOffsetX 开始，边框有效区域为 [border, viewportW - border]
    final effectiveTlX = tlX + contentScreenOffsetX;
    final startCol =
        ((border - effectiveTlX) / colStepScreen).floor().clamp(0, gridWidth);
    final endCol = (((viewportW - border) - effectiveTlX) / colStepScreen)
        .ceil()
        .clamp(0, gridWidth);

    // 列分割线刻度（顶部和底部）
    for (int col = startCol; col <= endCol; col++) {
      final x = tlX + contentScreenOffsetX + col * colStepScreen;
      if (x < border || x > viewportW - border) continue;
      canvas.drawLine(Offset(x, 0), Offset(x, border), tickPaint); // 顶部
      canvas.drawLine(
          Offset(x, viewportH - border), Offset(x, viewportH), tickPaint); // 底部
    }

    // 可见的行范围
    // 内容实际从 tlY + contentScreenOffsetY 开始，边框有效区域为 [border, viewportH - border]
    final effectiveTlY = tlY + contentScreenOffsetY;
    final startRow =
        ((border - effectiveTlY) / rowStepScreen).floor().clamp(0, gridHeight);
    final endRow = (((viewportH - border) - effectiveTlY) / rowStepScreen)
        .ceil()
        .clamp(0, gridHeight);

    // 行分割线刻度（左侧和右侧）
    for (int row = startRow; row <= endRow; row++) {
      final y = tlY + contentScreenOffsetY + row * rowStepScreen;
      if (y < border || y > viewportH - border) continue;
      canvas.drawLine(Offset(0, y), Offset(border, y), tickPaint); // 左侧
      canvas.drawLine(
          Offset(viewportW - border, y), Offset(viewportW, y), tickPaint); // 右侧
    }

    // 字体大小：跟随网格间距缩放
    final fontSize = (minStep * 0.35).clamp(0.5, border * 0.7);
    final textStyle = TextStyle(
      fontSize: fontSize,
      color: const Color(0xFF999999),
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      textWidthBasis: TextWidthBasis.longestLine,
    );

    // 列号（顶部和底部，编号居中在固定边框条内，x 对齐网格）
    // 注意：编号对应网格单元，索引范围 [0, gridWidth-1]，与刻度线的 [0, gridWidth] 不同
    for (int col = startCol; col <= endCol && col < gridWidth; col++) {
      final cellCenterX = tlX + contentScreenOffsetX + (col + 0.5) * colStepScreen;
      if (cellCenterX < border || cellCenterX > viewportW - border) continue;

      final text = (col + 1).toString();
      textPainter.text = TextSpan(text: text, style: textStyle);
      textPainter.layout();

      // 顶部
      textPainter.paint(
          canvas,
          Offset(cellCenterX - textPainter.width / 2,
              (border - textPainter.height) / 2));
      // 底部
      textPainter.paint(
          canvas,
          Offset(cellCenterX - textPainter.width / 2,
              viewportH - border + (border - textPainter.height) / 2));
    }

    // 行号（左侧和右侧，编号居中在固定边框条内，y 对齐网格）
    // 注意：编号对应网格单元，索引范围 [0, gridHeight-1]，与刻度线的 [0, gridHeight] 不同
    for (int row = startRow; row <= endRow && row < gridHeight; row++) {
      final cellCenterY = tlY + contentScreenOffsetY + (row + 0.5) * rowStepScreen;
      if (cellCenterY < border || cellCenterY > viewportH - border) continue;

      final text = (row + 1).toString();
      textPainter.text = TextSpan(text: text, style: textStyle);
      textPainter.layout();

      // 左侧
      textPainter.paint(
          canvas,
          Offset((border - textPainter.width) / 2,
              cellCenterY - textPainter.height / 2));
      // 右侧
      textPainter.paint(
          canvas,
          Offset(viewportW - border + (border - textPainter.width) / 2,
              cellCenterY - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(_NumberBorderPainter oldDelegate) => true;
}

/// 文本控制菜单（固定在右上角）
class _TextControlMenu extends StatelessWidget {
  final double scale;
  final bool isFloating;
  final VoidCallback onApply;
  final VoidCallback onDiscard;
  final VoidCallback onIncreaseScale;
  final VoidCallback onDecreaseScale;

  const _TextControlMenu({
    required this.scale,
    required this.isFloating,
    required this.onApply,
    required this.onDiscard,
    required this.onIncreaseScale,
    required this.onDecreaseScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 缩放相关按钮：仅在浮动状态下显示
              if (isFloating) ...[
                // 缩小按钮
                GestureDetector(
                  onTap: scale <= 1.0 ? null : onDecreaseScale,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: scale <= 1.0 ? Colors.grey[400] : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // 缩放显示
                Text(
                  '${scale.toStringAsFixed(0)}x',
                  style:
                      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8.w),
                // 放大按钮
                GestureDetector(
                  onTap: scale >= 4.0 ? null : onIncreaseScale,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: scale >= 4.0 ? Colors.grey[400] : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              if (!isFloating) ...[
                Text(
                  "触碰画布放置内容",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:  Colors.grey[900],
                  ),
                ),
                10.horizontalSpace
              ],
              // 应用按钮：浮动前不可点击，使用 disenable 图片
              GestureDetector(
                onTap: isFloating ? onApply : null,
                child: SvgPicture.asset(
                  isFloating
                      ? 'assets/icons/icon_text_use.svg'
                      : 'assets/icons/icon_text_use_disenable.svg',
                  width: 18.w,
                  height: 18.w,
                ),
              ),
              SizedBox(width: 8.w),
              // 遗弃按钮
              GestureDetector(
                onTap: onDiscard,
                child: SvgPicture.asset(
                  'assets/icons/icon_text_nouse.svg',
                  width: 18.w,
                  height: 18.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
