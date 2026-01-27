# 本地配置文件说明

## 📁 文件位置

`lib/network/config/local_deepseek_config.dart`

## ⚠️ 重要提示

**此文件包含敏感信息（API 密钥），不应提交到版本控制系统！**

此文件已在 `.gitignore` 中，确保不会被意外提交。

## 🔧 使用方法

### 方法 1：在应用启动时自动初始化（可选）

如果你想在应用启动时自动使用本地配置的 API 密钥，可以在 `main.dart` 或 `InitServices` 中添加：

```dart
import 'package:your_app/network/config/local_deepseek_config.dart';
import 'package:your_app/network/services/deepseek_service.dart';

// 在应用启动时
if (LocalDeepSeekConfig.enableDefaultKey && LocalDeepSeekConfig.apiKey.isNotEmpty) {
  DeepSeekService.initialize(LocalDeepSeekConfig.apiKey);
}
```

### 方法 2：在 DeepSeek 演示页面中手动设置

1. 打开应用，进入 "DeepSeek AI 演示" 页面
2. 点击 AppBar 中的 API 密钥设置按钮
3. 在对话框中输入 API 密钥（或使用本地配置的密钥）
4. 点击 "保存设置"

### 方法 3：在代码中直接使用

```dart
import 'package:your_app/network/config/local_deepseek_config.dart';
import 'package:your_app/network/services/deepseek_service.dart';

// 使用本地配置的 API 密钥
if (LocalDeepSeekConfig.apiKey.isNotEmpty) {
  DeepSeekService.initialize(LocalDeepSeekConfig.apiKey);
}
```

## 🔒 安全建议

1. **不要提交到 Git**：确保 `local_deepseek_config.dart` 在 `.gitignore` 中
2. **生产环境**：生产环境应使用环境变量或安全存储来管理 API 密钥
3. **密钥轮换**：定期更换 API 密钥以确保安全
4. **权限控制**：限制 API 密钥的访问权限和使用范围

## 📝 配置说明

- `defaultApiKey`: 默认的 API 密钥（本地开发使用）
- `enableDefaultKey`: 是否启用自动使用默认密钥（默认 `false`，需要用户手动设置）

## 🔄 更新密钥

如果需要更新 API 密钥，直接编辑 `local_deepseek_config.dart` 文件中的 `defaultApiKey` 值即可。
