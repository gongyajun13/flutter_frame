import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../services/locale_service.dart';

/// 本地化控制器 - 管理应用语言切换
class LocaleController extends BaseController {
  // 当前语言
  final Rx<Locale> currentLocale = const Locale('zh', 'CN').obs;
  
  // 本地化服务
  final LocaleService _localeService = LocaleService();
  
  // 是否正在切换语言
  final RxBool isChangingLocale = false.obs;
  
  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 简体中文
    Locale('en', 'US'), // 英文
  ];
  
  @override
  void onInit() {
    super.onInit();
    _loadLocaleFromStorage();
  }
  
  /// 从存储加载语言设置
  Future<void> _loadLocaleFromStorage() async {
    try {
      final savedLocale = await _localeService.getSavedLocale();
      if (savedLocale != null) {
        currentLocale.value = savedLocale;
      } else {
        // 如果没有保存的语言，使用系统语言或默认中文
        final systemLocale = Get.deviceLocale;
        if (systemLocale != null && _isLocaleSupported(systemLocale)) {
          currentLocale.value = systemLocale;
        } else {
          currentLocale.value = const Locale('zh', 'CN');
        }
      }
    } catch (e) {
      debugPrint('加载语言设置失败: $e');
      currentLocale.value = const Locale('zh', 'CN');
    }
  }
  
  /// 检查语言是否支持
  bool _isLocaleSupported(Locale locale) {
    return supportedLocales.any((supported) => 
      supported.languageCode == locale.languageCode
    );
  }
  
  /// 切换语言
  Future<void> switchLocale(Locale locale) async {
    if (currentLocale.value == locale) return;
    
    if (!_isLocaleSupported(locale)) {
      showError('不支持的语言: ${locale.languageCode}');
      return;
    }
    
    isChangingLocale.value = true;
    
    try {
      currentLocale.value = locale;
      await _localeService.saveLocale(locale);
      
      // 更新 GetX 的 locale
      Get.updateLocale(locale);
      
      showSuccess('语言已切换');
    } catch (e) {
      debugPrint('切换语言失败: $e');
      showError('语言切换失败，请重试');
    } finally {
      isChangingLocale.value = false;
    }
  }
  
  /// 切换到中文
  Future<void> switchToChinese() async {
    await switchLocale(const Locale('zh', 'CN'));
  }
  
  /// 切换到英文
  Future<void> switchToEnglish() async {
    await switchLocale(const Locale('en', 'US'));
  }
  
  /// 获取语言显示名称
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }
  
  /// 获取当前语言显示名称
  String get currentLanguageName => getLanguageName(currentLocale.value);
  
  /// 检查是否为中文
  bool get isChinese => currentLocale.value.languageCode == 'zh';
  
  /// 检查是否为英文
  bool get isEnglish => currentLocale.value.languageCode == 'en';
  
  /// 重置为系统默认语言
  Future<void> resetToSystemDefault() async {
    try {
      await _localeService.clearLocale();
      final systemLocale = Get.deviceLocale;
      if (systemLocale != null && _isLocaleSupported(systemLocale)) {
        await switchLocale(systemLocale);
      } else {
        await switchLocale(const Locale('zh', 'CN'));
      }
      showSuccess('已重置为系统默认语言');
    } catch (e) {
      debugPrint('重置语言失败: $e');
      showError('重置语言失败');
    }
  }
}
