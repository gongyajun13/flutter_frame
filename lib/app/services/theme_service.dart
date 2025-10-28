import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/theme_model.dart';

/// 主题服务 - 负责主题数据的持久化存储和管理
class ThemeService {
  static const String _themeModeKey = 'theme_mode';
  static const String _currentThemeKey = 'current_theme';
  static const String _customThemesKey = 'custom_themes';
  static const String _themeHistoryKey = 'theme_history';
  
  /// 获取当前主题模式
  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_themeModeKey) ?? 0;
      return ThemeMode.values[modeIndex];
    } catch (e) {
      debugPrint('获取主题模式失败: $e');
      return ThemeMode.system;
    }
  }
  
  /// 保存主题模式
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      debugPrint('保存主题模式失败: $e');
    }
  }
  
  /// 获取当前主题
  Future<AppTheme> getCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = prefs.getString(_currentThemeKey);
      
      if (themeJson != null) {
        final themeMap = jsonDecode(themeJson) as Map<String, dynamic>;
        return AppTheme.fromJson(themeMap);
      }
      
      // 如果没有保存的主题，返回默认浅色主题
      return AppTheme.light;
    } catch (e) {
      debugPrint('获取当前主题失败: $e');
      return AppTheme.light;
    }
  }
  
  /// 保存当前主题
  Future<void> saveCurrentTheme(AppTheme theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = jsonEncode(theme.toJson());
      await prefs.setString(_currentThemeKey, themeJson);
      
      // 添加到主题历史记录
      await _addToThemeHistory(theme);
    } catch (e) {
      debugPrint('保存当前主题失败: $e');
    }
  }
  
  /// 获取所有自定义主题
  Future<List<AppTheme>> getCustomThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themesJson = prefs.getString(_customThemesKey);
      
      if (themesJson != null) {
        final themesList = jsonDecode(themesJson) as List<dynamic>;
        return themesList
            .map((themeMap) => AppTheme.fromJson(themeMap as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('获取自定义主题失败: $e');
      return [];
    }
  }
  
  /// 保存自定义主题
  Future<void> saveCustomTheme(AppTheme theme) async {
    try {
      final customThemes = await getCustomThemes();
      
      // 检查是否已存在相同ID的主题
      final existingIndex = customThemes.indexWhere((t) => t.id == theme.id);
      if (existingIndex != -1) {
        customThemes[existingIndex] = theme;
      } else {
        customThemes.add(theme);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final themesJson = jsonEncode(customThemes.map((t) => t.toJson()).toList());
      await prefs.setString(_customThemesKey, themesJson);
    } catch (e) {
      debugPrint('保存自定义主题失败: $e');
    }
  }
  
  /// 删除自定义主题
  Future<void> deleteCustomTheme(String themeId) async {
    try {
      final customThemes = await getCustomThemes();
      customThemes.removeWhere((theme) => theme.id == themeId);
      
      final prefs = await SharedPreferences.getInstance();
      final themesJson = jsonEncode(customThemes.map((t) => t.toJson()).toList());
      await prefs.setString(_customThemesKey, themesJson);
    } catch (e) {
      debugPrint('删除自定义主题失败: $e');
    }
  }
  
  /// 获取主题使用历史记录
  Future<List<AppTheme>> getThemeHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_themeHistoryKey);
      
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        return historyList
            .map((themeMap) => AppTheme.fromJson(themeMap as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('获取主题历史记录失败: $e');
      return [];
    }
  }
  
  /// 添加到主题历史记录
  Future<void> _addToThemeHistory(AppTheme theme) async {
    try {
      final history = await getThemeHistory();
      
      // 移除已存在的相同主题
      history.removeWhere((t) => t.id == theme.id);
      
      // 添加到列表开头
      history.insert(0, theme);
      
      // 限制历史记录数量（最多保存20个）
      if (history.length > 20) {
        history.removeRange(20, history.length);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(history.map((t) => t.toJson()).toList());
      await prefs.setString(_themeHistoryKey, historyJson);
    } catch (e) {
      debugPrint('添加到主题历史记录失败: $e');
    }
  }
  
  /// 清除所有主题设置
  Future<void> clearAllThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeModeKey);
      await prefs.remove(_currentThemeKey);
      await prefs.remove(_customThemesKey);
      await prefs.remove(_themeHistoryKey);
    } catch (e) {
      debugPrint('清除主题设置失败: $e');
    }
  }
  
  /// 导出主题设置
  Future<Map<String, dynamic>> exportThemeSettings() async {
    try {
      final themeMode = await getThemeMode();
      final currentTheme = await getCurrentTheme();
      final customThemes = await getCustomThemes();
      final themeHistory = await getThemeHistory();
      
      return {
        'themeMode': themeMode.index,
        'currentTheme': currentTheme.toJson(),
        'customThemes': customThemes.map((t) => t.toJson()).toList(),
        'themeHistory': themeHistory.map((t) => t.toJson()).toList(),
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      debugPrint('导出主题设置失败: $e');
      return {};
    }
  }
  
  /// 导入主题设置
  Future<bool> importThemeSettings(Map<String, dynamic> settings) async {
    try {
      // 验证导入数据的格式
      if (!settings.containsKey('version') || 
          !settings.containsKey('currentTheme') ||
          !settings.containsKey('themeMode')) {
        return false;
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // 导入主题模式
      if (settings['themeMode'] is int) {
        await prefs.setInt(_themeModeKey, settings['themeMode']);
      }
      
      // 导入当前主题
      if (settings['currentTheme'] is Map<String, dynamic>) {
        final themeJson = jsonEncode(settings['currentTheme']);
        await prefs.setString(_currentThemeKey, themeJson);
      }
      
      // 导入自定义主题
      if (settings['customThemes'] is List) {
        final customThemesJson = jsonEncode(settings['customThemes']);
        await prefs.setString(_customThemesKey, customThemesJson);
      }
      
      // 导入主题历史记录
      if (settings['themeHistory'] is List) {
        final historyJson = jsonEncode(settings['themeHistory']);
        await prefs.setString(_themeHistoryKey, historyJson);
      }
      
      return true;
    } catch (e) {
      debugPrint('导入主题设置失败: $e');
      return false;
    }
  }
  
  /// 获取主题使用统计
  Future<Map<String, int>> getThemeUsageStats() async {
    try {
      final history = await getThemeHistory();
      final stats = <String, int>{};
      
      for (final theme in history) {
        stats[theme.id] = (stats[theme.id] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      debugPrint('获取主题使用统计失败: $e');
      return {};
    }
  }
  
  /// 获取最受欢迎的主题
  Future<AppTheme?> getMostPopularTheme() async {
    try {
      final stats = await getThemeUsageStats();
      if (stats.isEmpty) return null;
      
      final mostUsedId = stats.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      final history = await getThemeHistory();
      return history.firstWhere(
        (theme) => theme.id == mostUsedId,
        orElse: () => AppTheme.light,
      );
    } catch (e) {
      debugPrint('获取最受欢迎主题失败: $e');
      return null;
    }
  }
  
  /// 重置为默认主题
  Future<void> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, ThemeMode.system.index);
      
      final defaultThemeJson = jsonEncode(AppTheme.light.toJson());
      await prefs.setString(_currentThemeKey, defaultThemeJson);
    } catch (e) {
      debugPrint('重置为默认主题失败: $e');
    }
  }
}

