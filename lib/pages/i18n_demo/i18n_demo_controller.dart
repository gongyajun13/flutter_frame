import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../app/controllers/locale_controller.dart';

/// 国际化演示控制器
class I18nDemoController extends BaseController {
  final LocaleController localeController = Get.find<LocaleController>();

  /// 获取当前语言
  Locale get currentLocale => localeController.currentLocale.value;

  /// 获取当前语言名称
  String get currentLanguageName => localeController.currentLanguageName;

  /// 是否为中文
  bool get isChinese => localeController.isChinese;

  /// 是否为英文
  bool get isEnglish => localeController.isEnglish;

  /// 切换到中文
  Future<void> switchToChinese() async {
    await localeController.switchToChinese();
  }

  /// 切换到英文
  Future<void> switchToEnglish() async {
    await localeController.switchToEnglish();
  }
}
