# 🌍 国际化支持使用指南

## 📋 概述

项目已完整集成国际化（i18n）支持，支持中文和英文两种语言，可以轻松扩展更多语言。

## 🎯 功能特点

- ✅ **双语言支持** - 中文（简体）和英文
- ✅ **语言持久化** - 自动保存用户选择的语言
- ✅ **动态切换** - 运行时切换语言，无需重启应用
- ✅ **GetX 集成** - 与 GetX 状态管理完美集成
- ✅ **系统语言检测** - 自动检测并应用系统语言

## 🚀 使用方法（推荐：用 S，简单）

### 1. 用 S 取文案（无需 context，任意处可用）

```dart
import '../../l10n/s.dart';

// 在 Widget 里（需随语言更新时用 Obx 包一层）
Obx(() => Text(S.confirm));
Obx(() => Text(S.hello('张三')));

// 在 Controller 里
showSuccess(S.operationSuccess);
```

- **Widget 中**：需要随语言切换更新时，用 `Obx(() => Text(S.xxx))`。
- **Controller 中**：直接 `S.confirm`、`S.hello('名')` 等。
- **新增文案**：在 `lib/l10n/s.dart` 的 `_strings` 里为 zh/en 各加一条，再补一个 `static String get xxx => _t('xxx');` 即可。

### 2. 在 Controller 中切换语言

```dart
import 'package:get/get.dart';
import '../../app/controllers/locale_controller.dart';

class MyController extends GetxController {
  final localeController = Get.find<LocaleController>();
  
  // 切换到中文
  void switchToChinese() {
    localeController.switchToChinese();
  }
  
  // 切换到英文
  void switchToEnglish() {
    localeController.switchToEnglish();
  }
  
  // 切换到指定语言
  void switchToLocale(Locale locale) {
    localeController.switchLocale(locale);
  }
}
```

### 3. 获取当前语言（LocaleController）

```dart
final localeController = Get.find<LocaleController>();

// 获取当前语言代码
String languageCode = localeController.currentLocale.value.languageCode;

// 检查是否为中文
bool isChinese = localeController.isChinese;

// 检查是否为英文
bool isEnglish = localeController.isEnglish;

// 获取语言显示名称
String languageName = localeController.currentLanguageName;
```

### 4. 在 GetX 中使用（无需 BuildContext）

```dart
import 'package:get/get.dart';
import '../../l10n/s.dart';

class MyController extends GetxController {
  String getWelcomeText() => S.welcome;
}
```

## 📝 添加新的翻译文本

### 新增/修改文案（唯一入口：S）

编辑 `lib/l10n/s.dart`：

1. 在 `_strings` 里为 `zh`、`en` 各加一条 key；
2. 在类中加一行 getter：`static String get myNewText => _t('myNewText');`

```dart
// _strings 中
'zh': { ..., 'myNewText': '我的新文本' },
'en': { ..., 'myNewText': 'My New Text' },

// 类中
static String get myNewText => _t('myNewText');
```

## 🔧 添加新语言

### 步骤 1: 更新 LocaleController

编辑 `lib/app/controllers/locale_controller.dart`：

```dart
static const List<Locale> supportedLocales = [
  Locale('zh', 'CN'),
  Locale('en', 'US'),
  Locale('ja', 'JP'), // 添加日语
];
```

### 步骤 2: 添加翻译文本

在 `lib/l10n/s.dart` 的 `_strings` 中增加对应语言：

```dart
'ja': {
  'appTitle': 'Flutter Frame',
  'welcome': 'ようこそ',
  // ... 与 zh/en 同 key
},
```

### 步骤 3: 更新 main.dart

`main.dart` 中的 `supportedLocales` 会自动从 `LocaleController.supportedLocales` 获取，无需手动更新。

## 📁 文件结构（精简后）

```
lib/
├── l10n/
│   ├── s.dart                      # 唯一文案源：_strings + S.xxx 入口
│   └── app_localizations.dart      # 薄封装，供 MaterialApp delegate 用
├── app/
│   ├── controllers/
│   │   └── locale_controller.dart  # 语言切换与 supportedLocales
│   └── services/
│       └── locale_service.dart     # 语言持久化
└── main.dart
```

## 🎨 使用示例

### 示例 1: 语言选择器

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/locale_controller.dart';
import '../../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    // 文案用 S，无需 context
    
    return Obx(() => DropdownButton<Locale>(
      value: localeController.currentLocale.value,
      items: LocaleController.supportedLocales.map((locale) {
        return DropdownMenuItem(
          value: locale,
          child: Text(localeController.getLanguageName(locale)),
        );
      }).toList(),
      onChanged: (locale) {
        if (locale != null) {
          localeController.switchLocale(locale);
        }
      },
    ));
  }
}
```

### 示例 2: 在 Dialog 中使用

```dart
import 'package:flutter/material.dart';
import '../../l10n/s.dart';

void showConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(S.confirm),
      content: Text('确定要执行此操作吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.cancel),
        ),
        TextButton(
          onPressed: () {
            // 执行操作
            Navigator.pop(context);
          },
          child: Text(S.ok),
        ),
      ],
    ),
  );
}
```

## 🔍 可用的翻译文本

当前支持以下翻译文本：

- `appTitle` - 应用标题
- `welcome` - 欢迎语
- `hello(name)` - 问候语（带参数）
- `confirm` - 确认
- `cancel` - 取消
- `ok` - 确定
- `save` - 保存
- `delete` - 删除
- `edit` - 编辑
- `loading` - 加载中
- `noData` - 暂无数据
- `networkError` - 网络错误
- `operationSuccess` - 操作成功
- `operationFailed` - 操作失败
- `pleaseRetry` - 请重试
- `language` - 语言
- `chinese` - 中文
- `english` - 英文
- `theme` - 主题
- `settings` - 设置

## 💡 最佳实践

1. **统一用 S** - 不要硬编码文案，用 `S.confirm`、`S.hello('名')` 等
2. **在 Widget 中** - 需随语言更新时用 `Obx(() => Text(S.xxx))`
3. **在 Controller 中** - 直接 `S.xxx`，无需 context
4. **添加新文本时同步更新所有语言** - 确保所有语言都有对应的翻译
5. **使用有意义的键名** - 使用描述性的键名，便于维护

## 🐛 故障排除

### 问题：语言切换后 UI 没有更新

**解决方案**：确保在 `GetMaterialApp` 中正确配置了 `locale` 和 `localizationsDelegates`。

### 问题：某些文本没有翻译

**解决方案**：在 `lib/l10n/s.dart` 的 `_strings` 中补全对应 key 的翻译。

### 问题：语言设置没有保存

**解决方案**：确保 `LocaleService` 已正确初始化，并且 `SharedPreferences` 已初始化。

## 📚 相关文档

- [Flutter 国际化官方文档](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [GetX 文档](https://pub.dev/packages/get)
