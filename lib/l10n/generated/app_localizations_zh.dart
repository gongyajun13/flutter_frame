// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter Frame';

  @override
  String get welcome => '欢迎';

  @override
  String hello(String name) {
    return '你好，$name';
  }

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get loading => '加载中...';

  @override
  String get noData => '暂无数据';

  @override
  String get networkError => '网络错误，请检查网络连接';

  @override
  String get operationSuccess => '操作成功';

  @override
  String get operationFailed => '操作失败';

  @override
  String get pleaseRetry => '请重试';

  @override
  String get language => '语言';

  @override
  String get chinese => '中文';

  @override
  String get english => '英文';

  @override
  String get theme => '主题';

  @override
  String get settings => '设置';
}
