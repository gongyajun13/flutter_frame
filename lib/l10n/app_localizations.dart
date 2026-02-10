import 'package:flutter/material.dart';
import '../app/controllers/locale_controller.dart';
import 's.dart';

/// 供 MaterialApp localizationsDelegates 使用，内部文案统一走 [S]。
/// 业务里直接用 [S.confirm]、[S.hello('名')] 等即可。
class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => LocaleController.supportedLocales;

  String get appTitle => S.t(locale, 'appTitle');
  String get welcome => S.t(locale, 'welcome');
  String hello(String name) => locale.languageCode == 'zh' ? '你好，$name' : 'Hello, $name';
  String get confirm => S.t(locale, 'confirm');
  String get cancel => S.t(locale, 'cancel');
  String get ok => S.t(locale, 'ok');
  String get save => S.t(locale, 'save');
  String get delete => S.t(locale, 'delete');
  String get edit => S.t(locale, 'edit');
  String get loading => S.t(locale, 'loading');
  String get noData => S.t(locale, 'noData');
  String get networkError => S.t(locale, 'networkError');
  String get operationSuccess => S.t(locale, 'operationSuccess');
  String get operationFailed => S.t(locale, 'operationFailed');
  String get pleaseRetry => S.t(locale, 'pleaseRetry');
  String get language => S.t(locale, 'language');
  String get chinese => S.t(locale, 'chinese');
  String get english => S.t(locale, 'english');
  String get theme => S.t(locale, 'theme');
  String get settings => S.t(locale, 'settings');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      LocaleController.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
