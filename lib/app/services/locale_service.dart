import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/local_cache_util.dart';

/// 本地化服务 - 负责语言设置的持久化存储和管理
class LocaleService {
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';
  
  /// 获取 SharedPreferences 实例（复用已初始化的实例）
  Future<SharedPreferences> _getPrefs() async {
    final prefs = LocalCacheUtil.getInstance();
    if (prefs != null) {
      return prefs;
    }
    return await SharedPreferences.getInstance();
  }
  
  /// 获取保存的语言设置
  Future<Locale?> getSavedLocale() async {
    try {
      final prefs = await _getPrefs();
      final languageCode = prefs.getString(_languageCodeKey);
      final countryCode = prefs.getString(_countryCodeKey);
      
      if (languageCode != null && languageCode.isNotEmpty) {
        return Locale(languageCode, countryCode);
      }
      
      return null;
    } catch (e) {
      debugPrint('获取语言设置失败: $e');
      return null;
    }
  }
  
  /// 保存语言设置
  Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_languageCodeKey, locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString(_countryCodeKey, locale.countryCode!);
      } else {
        await prefs.remove(_countryCodeKey);
      }
    } catch (e) {
      debugPrint('保存语言设置失败: $e');
    }
  }
  
  /// 清除语言设置（恢复系统默认）
  Future<void> clearLocale() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_languageCodeKey);
      await prefs.remove(_countryCodeKey);
    } catch (e) {
      debugPrint('清除语言设置失败: $e');
    }
  }
}
