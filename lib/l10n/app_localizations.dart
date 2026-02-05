import 'package:flutter/material.dart';

/// 应用本地化类
/// 提供应用内所有文本的国际化支持
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  // 翻译映射表
  static const Map<String, Map<String, String>> _localizedValues = {
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

  String _getLocalizedValue(String key) {
    final languageCode = locale.languageCode;
    final values = _localizedValues[languageCode] ?? _localizedValues['en']!;
    return values[key] ?? key;
  }

  // 应用标题
  String get appTitle => _getLocalizedValue('appTitle');

  // 欢迎语
  String get welcome => _getLocalizedValue('welcome');

  // 问候语（带参数）
  String hello(String name) {
    final languageCode = locale.languageCode;
    if (languageCode == 'zh') {
      return '你好，$name';
    } else {
      return 'Hello, $name';
    }
  }

  // 确认
  String get confirm => _getLocalizedValue('confirm');

  // 取消
  String get cancel => _getLocalizedValue('cancel');

  // 确定
  String get ok => _getLocalizedValue('ok');

  // 保存
  String get save => _getLocalizedValue('save');

  // 删除
  String get delete => _getLocalizedValue('delete');

  // 编辑
  String get edit => _getLocalizedValue('edit');

  // 加载中
  String get loading => _getLocalizedValue('loading');

  // 暂无数据
  String get noData => _getLocalizedValue('noData');

  // 网络错误
  String get networkError => _getLocalizedValue('networkError');

  // 操作成功
  String get operationSuccess => _getLocalizedValue('operationSuccess');

  // 操作失败
  String get operationFailed => _getLocalizedValue('operationFailed');

  // 请重试
  String get pleaseRetry => _getLocalizedValue('pleaseRetry');

  // 语言
  String get language => _getLocalizedValue('language');

  // 中文
  String get chinese => _getLocalizedValue('chinese');

  // 英文
  String get english => _getLocalizedValue('english');

  // 主题
  String get theme => _getLocalizedValue('theme');

  // 设置
  String get settings => _getLocalizedValue('settings');
}

/// 本地化代理
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
