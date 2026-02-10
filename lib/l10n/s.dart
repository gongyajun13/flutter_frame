import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/locale_controller.dart';

/// 国际化简易入口，无需 context，任意处可用。
///
/// 使用方式：
/// - 在 Widget 中需要随语言更新时：Obx(() => Text(S.confirm))
/// - 在 Controller 中：showSuccess(S.operationSuccess)
/// - 带参数：S.hello('张三')
///
/// 新增文案：在 _strings 里为 zh/en 各加一条，再在下方加一个 get 或方法即可。
class S {
  S._();

  static const _strings = {
    'zh': {
      'appTitle': 'Flutter Frame',
      'welcome': '欢迎',
      'confirm': '确认',
      'cancel': '取消',
      'ok': '确定',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'loading': '加载中...',
      'noData': '暂无数据',
      'networkError': '网络错误，请检查网络连接',
      'operationSuccess': '操作成功',
      'operationFailed': '操作失败',
      'pleaseRetry': '请重试',
      'language': '语言',
      'chinese': '中文',
      'english': '英文',
      'theme': '主题',
      'settings': '设置',
    },
    'en': {
      'appTitle': 'Flutter Frame',
      'welcome': 'Welcome',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'loading': 'Loading...',
      'noData': 'No Data',
      'networkError': 'Network error, please check your connection',
      'operationSuccess': 'Operation successful',
      'operationFailed': 'Operation failed',
      'pleaseRetry': 'Please retry',
      'language': 'Language',
      'chinese': 'Chinese',
      'english': 'English',
      'theme': 'Theme',
      'settings': 'Settings',
    },
  };

  /// 按 locale 取文案（供 AppLocalizations 等复用，避免重复维护）
  static String t(Locale locale, String key) {
    final lang = locale.languageCode;
    final map = _strings[lang] ?? _strings['en']!;
    return map[key] ?? key;
  }

  static String _t(String key) {
    try {
      final locale = Get.find<LocaleController>().currentLocale.value;
      return t(locale, key);
    } catch (_) {
      return _strings['en']?[key] ?? key;
    }
  }

  static String get appTitle => _t('appTitle');
  static String get welcome => _t('welcome');
  static String get confirm => _t('confirm');
  static String get cancel => _t('cancel');
  static String get ok => _t('ok');
  static String get save => _t('save');
  static String get delete => _t('delete');
  static String get edit => _t('edit');
  static String get loading => _t('loading');
  static String get noData => _t('noData');
  static String get networkError => _t('networkError');
  static String get operationSuccess => _t('operationSuccess');
  static String get operationFailed => _t('operationFailed');
  static String get pleaseRetry => _t('pleaseRetry');
  static String get language => _t('language');
  static String get chinese => _t('chinese');
  static String get english => _t('english');
  static String get theme => _t('theme');
  static String get settings => _t('settings');

  /// 带参数的文案，如：S.hello('张三')
  static String hello(String name) {
    try {
      final isZh = Get.find<LocaleController>().currentLocale.value.languageCode == 'zh';
      return isZh ? '你好，$name' : 'Hello, $name';
    } catch (_) {
      return 'Hello, $name';
    }
  }
}
