// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Frame';

  @override
  String get welcome => 'Welcome';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No Data';

  @override
  String get networkError => 'Network error, please check your connection';

  @override
  String get operationSuccess => 'Operation successful';

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get pleaseRetry => 'Please retry';

  @override
  String get language => 'Language';

  @override
  String get chinese => 'Chinese';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get settings => 'Settings';
}
