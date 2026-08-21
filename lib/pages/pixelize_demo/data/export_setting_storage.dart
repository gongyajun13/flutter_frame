import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 导出选项本地缓存（画板 / 图纸预览共用）
class ExportSettingStorage {
  ExportSettingStorage._();

  static const String _prefsKey = 'pixelize_export_settings';
  static const int optionCount = 5;

  static const List<bool> defaultValues = [
    true,
    true,
    true,
    true,
    true,
  ];

  static Future<List<bool>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return List<bool>.from(defaultValues);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.length != optionCount) {
        return List<bool>.from(defaultValues);
      }
      return decoded.map((e) => e == true).toList();
    } catch (_) {
      return List<bool>.from(defaultValues);
    }
  }

  static Future<void> save(List<bool> values) async {
    if (values.length != optionCount) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(values));
  }
}
