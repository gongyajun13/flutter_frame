/// 像素画布形状计算工具类
///
/// 提供各种几何形状的网格坐标计算（纯数学逻辑，无状态依赖）。
/// 从 pixelize_img_result_controller.dart 提取，减少主控制器文件体积。
class ShapeComputer {
  ShapeComputer._();

  /// 计算矩形轮廓
  static void rectOutline(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final minX = x0 < x1 ? x0 : x1;
    final maxX = x0 > x1 ? x0 : x1;
    final minY = y0 < y1 ? y0 : y1;
    final maxY = y0 > y1 ? y0 : y1;
    for (int x = minX; x <= maxX; x++) {
      add(x, minY);
      add(x, maxY);
    }
    for (int y = minY + 1; y < maxY; y++) {
      add(minX, y);
      add(maxX, y);
    }
  }

  /// 计算矩形填充
  static void rectFill(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final minX = x0 < x1 ? x0 : x1;
    final maxX = x0 > x1 ? x0 : x1;
    final minY = y0 < y1 ? y0 : y1;
    final maxY = y0 > y1 ? y0 : y1;
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        add(x, y);
      }
    }
  }

  /// Bresenham 中点椭圆算法（轮廓）
  static void ellipseOutline(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final cx = (x0 + x1) ~/ 2;
    final cy = (y0 + y1) ~/ 2;
    final a = ((x1 - x0).abs() / 2).round();
    final b = ((y1 - y0).abs() / 2).round();
    if (a == 0 && b == 0) { add(cx, cy); return; }
    if (a == 0) { for (int y = cy - b; y <= cy + b; y++) add(cx, y); return; }
    if (b == 0) { for (int x = cx - a; x <= cx + a; x++) add(x, cy); return; }

    final a2 = a * a;
    final b2 = b * b;

    void plot4(int dx, int dy) {
      add(cx + dx, cy + dy);
      add(cx - dx, cy + dy);
      add(cx + dx, cy - dy);
      add(cx - dx, cy - dy);
    }

    int px = 0, py = b;
    double d = b2 - a2 * b + 0.25 * a2;
    while (b2 * px <= a2 * py) {
      plot4(px, py);
      px++;
      if (d < 0) {
        d += b2 * (2 * px + 1);
      } else {
        py--;
        d += b2 * (2 * px + 1) - 2 * a2 * py;
      }
    }
    d = b2 * (px + 0.5) * (px + 0.5) + a2 * (py - 1) * (py - 1) - a2.toDouble() * b2;
    while (py >= 0) {
      plot4(px, py);
      py--;
      if (d > 0) {
        d += a2 * (1 - 2 * py);
      } else {
        px++;
        d += b2 * (2 * px + 1) + a2 * (1 - 2 * py);
      }
    }
  }

  /// 椭圆填充
  static void ellipseFill(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final cx = (x0 + x1) / 2.0;
    final cy = (y0 + y1) / 2.0;
    final a = (x1 - x0).abs() / 2.0;
    final b = (y1 - y0).abs() / 2.0;
    if (a == 0 && b == 0) { add(cx.round(), cy.round()); return; }

    final minX = (cx - a).ceil();
    final maxX = (cx + a).floor();
    final minY = (cy - b).ceil();
    final maxY = (cy + b).floor();

    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        final dx = (x - cx) / (a == 0 ? 1 : a);
        final dy = (y - cy) / (b == 0 ? 1 : b);
        if (dx * dx + dy * dy <= 1.0 + 1e-9) {
          add(x, y);
        }
      }
    }
  }

  /// Bresenham 直线算法
  static void line(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    int dx = (x1 - x0).abs();
    int dy = (y1 - y0).abs();
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx - dy;
    int x = x0, y = y0;
    while (true) {
      add(x, y);
      if (x == x1 && y == y1) break;
      final e2 = 2 * err;
      if (e2 > -dy) { err -= dy; x += sx; }
      if (e2 < dx)  { err += dx; y += sy; }
    }
  }

  /// 等腰三角形轮廓（底边在下，顶点在上方中间）
  static void triangleOutline(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final minX = x0 < x1 ? x0 : x1;
    final maxX = x0 > x1 ? x0 : x1;
    final minY = y0 < y1 ? y0 : y1;
    final maxY = y0 > y1 ? y0 : y1;
    final topX = (minX + maxX) ~/ 2;
    // 三条边：顶点→左下，顶点→右下，左下→右下
    line(topX, minY, minX, maxY, add);
    line(topX, minY, maxX, maxY, add);
    line(minX, maxY, maxX, maxY, add);
  }

  /// 等腰三角形填充
  static void triangleFill(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final minX = x0 < x1 ? x0 : x1;
    final maxX = x0 > x1 ? x0 : x1;
    final minY = y0 < y1 ? y0 : y1;
    final maxY = y0 > y1 ? y0 : y1;
    final topX = (minX + maxX) / 2.0;
    final height = maxY - minY;
    if (height == 0) {
      for (int x = minX; x <= maxX; x++) add(x, minY);
      return;
    }
    for (int y = minY; y <= maxY; y++) {
      final t = (y - minY) / height;
      final halfW = t * (maxX - minX) / 2.0;
      final rowMinX = (topX - halfW).round();
      final rowMaxX = (topX + halfW).round();
      for (int x = rowMinX; x <= rowMaxX; x++) add(x, y);
    }
  }

  /// 菱形轮廓
  static void diamondOutline(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final cx = (x0 + x1) ~/ 2;
    final cy = (y0 + y1) ~/ 2;
    final hw = ((x1 - x0).abs() / 2).round();
    final hh = ((y1 - y0).abs() / 2).round();
    // 四条边：上→右，右→下，下→左，左→上
    line(cx, cy - hh, cx + hw, cy, add);
    line(cx + hw, cy, cx, cy + hh, add);
    line(cx, cy + hh, cx - hw, cy, add);
    line(cx - hw, cy, cx, cy - hh, add);
  }

  /// 菱形填充
  static void diamondFill(int x0, int y0, int x1, int y1, void Function(int, int) add) {
    final cx = (x0 + x1) / 2.0;
    final cy = (y0 + y1) / 2.0;
    final hw = (x1 - x0).abs() / 2.0;
    final hh = (y1 - y0).abs() / 2.0;
    if (hw == 0 && hh == 0) { add(cx.round(), cy.round()); return; }

    final minY = (cy - hh).ceil();
    final maxY = (cy + hh).floor();
    for (int y = minY; y <= maxY; y++) {
      final t = (y - cy).abs() / (hh == 0 ? 1 : hh);
      final rowHW = hw * (1 - t);
      final rowMinX = (cx - rowHW).round();
      final rowMaxX = (cx + rowHW).round();
      for (int x = rowMinX; x <= rowMaxX; x++) add(x, y);
    }
  }

  /// 根据形状类型分发计算（返回网格坐标集合 Set<'x,y'>）
  static Set<String> computeShape(
    String shapeType,
    int x0, int y0, int x1, int y1, {
    required int gridWidth,
    required int gridHeight,
  }) {
    final result = <String>{};

    void addSafe(int x, int y) {
      if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
        result.add('$x,$y');
      }
    }

    switch (shapeType) {
      case 'rect':
        rectOutline(x0, y0, x1, y1, addSafe);
        break;
      case 'rect_fill':
        rectFill(x0, y0, x1, y1, addSafe);
        break;
      case 'circle':
        ellipseOutline(x0, y0, x1, y1, addSafe);
        break;
      case 'circle_fill':
        ellipseFill(x0, y0, x1, y1, addSafe);
        break;
      case 'line':
        line(x0, y0, x1, y1, addSafe);
        break;
      case 'triangle':
        triangleOutline(x0, y0, x1, y1, addSafe);
        break;
      case 'triangle_fill':
        triangleFill(x0, y0, x1, y1, addSafe);
        break;
      case 'diamond':
        diamondOutline(x0, y0, x1, y1, addSafe);
        break;
      case 'diamond_fill':
        diamondFill(x0, y0, x1, y1, addSafe);
        break;
      default:
        addSafe(x1, y1);
    }
    return result;
  }
}
