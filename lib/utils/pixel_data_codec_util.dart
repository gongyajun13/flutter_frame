import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

/// 像素数据压缩/解压工具类
///
/// 使用 RLE（游程编码）+ Base64 对 [pixelCodes] 进行压缩，
/// 适用于拼豆画板数据上传到服务端的场景。
///
/// 压缩格式：RLE 编码 → JSON 字符串 → Base64
///
/// 示例：
/// - 原始：["A01","A01","A01","","B03","B03"]
/// - RLE：3:A01,2:,2:B03
/// - Base64：MzpBMDEsMjoyLDI6QjAz
class PixelDataCodecUtil {
  PixelDataCodecUtil._();

  /// 压缩编码标识，用于服务端识别解码方式
  static const String encodingType = 'rle_base64';

  /// 将 [pixelCodes] 列表压缩为 Base64 字符串
  ///
  /// 算法：游程编码 (Run-Length Encoding)
  /// - 连续相同的颜色代码合并为 `数量:代码` 格式
  /// - 单个数量上限 255，超出自动分段
  ///
  /// 返回 Base64 编码的字符串，可直接用于 HTTP 请求体传输
  static String compress(List<String> pixelCodes) {
    if (pixelCodes.isEmpty) return '';

    final buffer = StringBuffer();
    String currentCode = pixelCodes[0];
    int count = 1;

    for (int i = 1; i < pixelCodes.length; i++) {
      final code = pixelCodes[i];
      if (code == currentCode && count < 255) {
        count++;
      } else {
        buffer.write('$count:$currentCode,');
        currentCode = code;
        count = 1;
      }
    }
    // 写入最后一组
    buffer.write('$count:$currentCode');

    // 转为 UTF-8 再 Base64 编码
    final bytes = utf8.encode(buffer.toString());
    return base64.encode(bytes);
  }

  /// 从 Base64 字符串解压还原 [pixelCodes] 列表
  ///
  /// [compressed] 为 [compress] 方法生成的 Base64 字符串
  /// [expectedLength] 可选，用于校验解压后的列表长度是否正确
  static List<String> decompress(String compressed, {int? expectedLength}) {
    if (compressed.isEmpty) return <String>[];

    try {
      // Base64 解码
      final bytes = base64.decode(compressed);
      final decoded = utf8.decode(bytes);

      // 按 ',' 分割 RLE 段
      final runs = decoded.split(',');
      final result = <String>[];

      for (final run in runs) {
        if (run.isEmpty) continue;
        final colonIndex = run.indexOf(':');
        if (colonIndex <= 0 || colonIndex >= run.length) continue;

        final countStr = run.substring(0, colonIndex);
        final code = run.substring(colonIndex + 1);
        final count = int.tryParse(countStr);

        if (count != null && count > 0) {
          result.addAll(List.filled(count, code));
        }
      }

      // 长度校验（可选）
      if (expectedLength != null && result.length != expectedLength) {
        debugPrint(
          '[PixelDataCodec] 长度不匹配: 期望=$expectedLength, 实际=${result.length}',
        );
      }

      return result;
    } catch (e) {
      debugPrint('[PixelDataCodec] 解压失败: $e');
      rethrow;
    }
  }

  /// 计算压缩率（用于调试/日志）
  ///
  /// 返回压缩后相对于原始数据的百分比，如 15.0 表示压缩到原大小的 15%
  static double calculateCompressionRatio(
    List<String> pixelCodes,
    String compressed,
  ) {
    if (pixelCodes.isEmpty || compressed.isEmpty) return 0;

    // 原始数据大小估算（每个 code 平均 ~4 字节 + JSON 结构开销）
    final originalSize = jsonEncode(pixelCodes).length;
    final compressedSize = compressed.length;

    if (originalSize == 0) return 0;
    return (compressedSize / originalSize * 100).toDouble();
  }
}
