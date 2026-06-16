import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_frame/utils/pixel_data_codec_util.dart';
import 'canvas_tools_status.dart';

/// 像素画项目数据模型
class PixelProject {
  final String id;
  final String title;
  final int? time;
  final int createdAt;
  final int updatedAt;
  final int gridWidth;
  final int gridHeight;
  final String beadBrandKey; // 品牌唯一标识符（替代 index）
  final int colorLimitValue; // 减色限制值（替代 index）
  final List<String> pixelCodes;
  final List<int> enabledTools;
  final String? picture;
  // 压缩数据
  final String? pixelData;
  final String? pixelDataEncoding;
  // 原始图片 URL
  final String? originalImage;
  final List<String> colorData;
  // 工具配置详情
  final CanvasToolsStatus? tools;


  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'picture' : picture,
        'originalImage': originalImage,
        'time': time,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'gridWidth': gridWidth,
        'gridHeight': gridHeight,
        'beadBrandKey': beadBrandKey,
        'colorLimitValue': colorLimitValue,
        'pixelCodes': pixelCodes,
        'enabledTools': enabledTools,
        'pixelData': pixelData,
        'pixelDataEncoding': pixelDataEncoding,
        'colorData': colorData,
        'tools': tools,
      };

  PixelProject({
    required this.id,
    required this.title,

    required this.createdAt,
    required this.updatedAt,
    required this.gridWidth,
    required this.gridHeight,
    required this.beadBrandKey,
    required this.colorLimitValue,
    required this.pixelCodes,
    required this.colorData,
    this.enabledTools = const [],
    this.picture,
    this.pixelData,
    this.pixelDataEncoding,
    this.originalImage,
    this.time,
    this.tools,

  });

  factory PixelProject.fromJson(Map<String, dynamic> json) {
    // 兼容旧版本：优先使用新字段，没有则使用旧索引字段
    String beadBrandKey = json['beadBrandKey'] as String? ?? '';
    int colorLimitValue = json['colorLimitValue'] as int? ?? -1;

    // 处理像素数据：优先从压缩数据解压，否则直接读取 pixelCodes
    List<String> pixelCodes = <String>[];
    if (json['pixelData'] != null && (json['pixelData'] as String).isNotEmpty) {
      pixelCodes = PixelDataCodecUtil.decompress(
        json['pixelData'] as String,
        expectedLength: json['gridWidth'] != null && json['gridHeight'] != null
            ? (json['gridWidth'] as int) * (json['gridHeight'] as int)
            : null,
      );
    } else if (json['pixelCodes'] != null) {
      pixelCodes = List<String>.from(json['pixelCodes'] as List);
    }

    return PixelProject(
      id: json['id'] as String,
      title: json['title'] as String,
      picture: json['picture'] as String?,
      originalImage: json['originalImage'] as String?,
      time: json['time'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
      gridWidth: json['gridWidth'] as int,
      gridHeight: json['gridHeight'] as int,
      beadBrandKey: beadBrandKey,
      colorLimitValue: colorLimitValue,
      pixelCodes: pixelCodes,
      enabledTools: json['enabledTools'] != null
          ? List<int>.from(json['enabledTools'] as List)
          : [],
      pixelData: json['pixelData'] as String?,
      pixelDataEncoding: json['pixelDataEncoding'] as String?,
      colorData: json["colorData"] == null
          ? <String>[]
          : List<String>.from((json["colorData"] as List).map((e) => '$e')),
      tools: () {
        final raw = json['tools'];
        if (raw == null || raw == '0' || raw is! String || (raw).isEmpty) return null;
        try {
          return CanvasToolsStatus.fromJsonS(raw);
        } catch (e) {
          debugPrint('[PixelProject] 解析 tools 失败，使用默认值: $e');
          return null;
        }
      }(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory PixelProject.fromJsonString(String json) =>
      PixelProject.fromJson(jsonDecode(json) as Map<String, dynamic>);
}
