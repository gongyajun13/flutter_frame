import 'dart:convert';
import 'dart:ui';

import '../widget/color_display_mode_sheet.dart';

/// 画布工具状态数据模型
/// 用于保存网格更多设置、高亮/已拼标记等画板配置数据，支持上传服务端和从服务端接收赋值
class CanvasToolsStatus {
  // ── 网格设置 ──

  /// 是否展示网格
  final bool gridShow;

  /// 网格间距（粗线间隔格子数）
  final int gridSpacing;

  /// 是否显示中虚线
  final bool centerDashShow;

  /// 网格粗细（粗线宽度）
  final double gridThickness;

  /// 网格颜色（ARGB 整数格式）
  final int gridColor;

  /// 网格起始点 X（偏移格子数）
  final double gridStartPointX;

  /// 网格起始点 Y（偏移格子数）
  final double gridStartPointY;

  /// 色号显示模式
  final ColorDisplayMode colorDisplayMode;

  // ── 高亮/标记数据 ──

  /// 高亮色号集合（支持多个色号同时高亮）
  final Set<String> highlightedCodes;

  /// 叠加高亮色号集合
  final Set<String> overlayHighlightedCodes;

  /// 区域已拼的连通区域集合（存储中心坐标 "col,row"）
  /// 恢复时用于 BFS 重算 checkedGridKeys
  final Set<String> areaPinnedRegions;

  /// 同一色号已拼好的色号集合
  /// 恢复时用于全画布遍历重算 checkedGridKeys
  final Set<String> sameColorPinnedCodes;

  CanvasToolsStatus({
    this.gridShow = false,
    this.gridSpacing = 9,
    this.centerDashShow = false,
    this.gridThickness = 3.0,
    this.gridColor = 0xFFFF4444,
    this.gridStartPointX = 1.0,
    this.gridStartPointY = 1.0,
    this.colorDisplayMode = ColorDisplayMode.normal,
    this.highlightedCodes = const {},
    this.overlayHighlightedCodes = const {},
    this.areaPinnedRegions = const {},
    this.sameColorPinnedCodes = const {},
  });

  Map<String, dynamic> toJson() => {
        'gridShow': gridShow,
        'gridSpacing': gridSpacing,
        'centerDashShow': centerDashShow,
        'gridThickness': gridThickness,
        'gridColor': gridColor,
        'gridStartPointX': gridStartPointX,
        'gridStartPointY': gridStartPointY,
        'colorDisplayMode': colorDisplayMode.name,
        'highlightedCodes': highlightedCodes.toList(),
        'overlayHighlightedCodes': overlayHighlightedCodes.toList(),
        'areaPinnedRegions': areaPinnedRegions.toList(),
        'sameColorPinnedCodes': sameColorPinnedCodes.toList(),
      };

  factory CanvasToolsStatus.fromJson(Map<String, dynamic> json) {
    return CanvasToolsStatus(
      gridShow: json['gridShow'] as bool? ?? false,
      gridSpacing: json['gridSpacing'] as int? ?? 9,
      centerDashShow: json['centerDashShow'] as bool? ?? false,
      gridThickness:
          (json['gridThickness'] as num?)?.toDouble() ?? 3.0,
      gridColor: json['gridColor'] as int? ?? 0xFFFF4444,
      gridStartPointX:
          (json['gridStartPointX'] as num?)?.toDouble() ?? 1.0,
      gridStartPointY:
          (json['gridStartPointY'] as num?)?.toDouble() ?? 1.0,
      colorDisplayMode: ColorDisplayMode.values
          .byName(json['colorDisplayMode'] as String? ?? 'normal'),
      highlightedCodes: _parseStringSet(json['highlightedCodes']),
      overlayHighlightedCodes: _parseStringSet(json['overlayHighlightedCodes']),
      areaPinnedRegions: _parseStringSet(json['areaPinnedRegions']),
      sameColorPinnedCodes: _parseStringSet(json['sameColorPinnedCodes']),
    );
  }

  /// 安全解析 List<dynamic> → Set<String>
  static Set<String> _parseStringSet(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toSet();
    }
    return {};
  }

  String toJsonString() => jsonEncode(toJson());

  factory CanvasToolsStatus.fromJsonS(String jsonStr) =>
      CanvasToolsStatus.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

  // ── 便捷属性 ─

  Color get gridColorValue => Color(gridColor);

  Offset get gridStartPoint =>
      Offset(gridStartPointX, gridStartPointY);
}
