# DeepSeek API 集成指南

本指南将帮助你在Flutter项目中集成DeepSeek API，实现AI聊天对话和代码生成功能。

## 📋 目录

1. [项目概述](#项目概述)
2. [获取API密钥](#获取api密钥)
3. [项目结构](#项目结构)
4. [快速开始](#快速开始)
5. [功能说明](#功能说明)
6. [API使用示例](#api使用示例)
7. [注意事项](#注意事项)
8. [故障排除](#故障排除)

## 📖 项目概述

本项目提供了完整的DeepSeek API集成方案，包括：

- **配置管理** - 统一的API配置和认证管理
- **数据模型** - 完整的请求和响应数据模型
- **服务封装** - 易用的API调用服务
- **演示界面** - 直观的功能演示页面

## 🔑 获取API密钥

1. 访问 [DeepSeek官网](https://platform.deepseek.com/)
2. 注册账号并登录
3. 进入API管理页面
4. 创建新的API密钥
5. 复制密钥备用

## 📁 项目结构

```
lib/
├── network/
│   ├── config/
│   │   └── deepseek_config.dart          # DeepSeek API配置
│   ├── models/
│   │   └── deepseek_models.dart          # 数据模型定义
│   └── services/
│       └── deepseek_service.dart         # API服务封装
└── pages/
    ├── deepseek_demo/
    │   ├── deepseek_demo_controller.dart  # 页面控制器
    │   ├── deepseek_demo_view.dart        # 页面视图
    │   └── deepseek_demo_binding.dart     # 依赖注入绑定
    └── deepseek_demo_page.dart           # 主页面导出
```

## 🚀 快速开始

### 1. 初始化服务

```dart
import 'package:your_app/network/services/deepseek_service.dart';

// 在应用启动时初始化
void main() {
  // 设置API密钥
  DeepSeekService.initialize('your-api-key-here');
  
  runApp(MyApp());
}
```

### 2. 访问演示页面

在应用中导航到 `/deepseek-demo` 路由即可看到完整的功能演示。

```dart
Get.toNamed(Routes.DEEPSEEK_DEMO);
```

## ⚡ 功能说明

### 聊天对话功能

- **智能对话** - 支持上下文理解的多轮对话
- **历史记录** - 自动维护对话历史
- **模型选择** - 支持切换不同的AI模型

### 代码助手功能

- **代码生成** - 根据需求描述生成代码
- **代码解释** - 详细解释代码功能和逻辑
- **代码优化** - 提供性能优化建议
- **一键复制** - 快速复制生成的代码

## 💻 API使用示例

### 基础聊天对话

```dart
await DeepSeekService.chatCompletion(
  message: '你好，请介绍一下Flutter',
  model: 'deepseek-chat',
  onSuccess: (response) {
    print('AI回复: ${response.firstContent}');
  },
  onError: (error, code) {
    print('错误: $error');
  },
);
```

### 代码生成

```dart
await DeepSeekService.generateCode(
  prompt: '创建一个Flutter按钮点击计数器',
  language: 'dart',
  onSuccess: (response) {
    String code = response.firstContent ?? '';
    print('生成的代码:\n$code');
  },
  onError: (error, code) {
    print('代码生成失败: $error');
  },
);
```

### 代码解释

```dart
String codeToExplain = '''
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Counter')),
    body: Center(child: Text('Count: \$_counter')),
  );
}
''';

await DeepSeekService.explainCode(
  code: codeToExplain,
  language: 'dart',
  onSuccess: (response) {
    print('代码解释: ${response.firstContent}');
  },
  onError: (error, code) {
    print('解释失败: $error');
  },
);
```

### 带对话历史的聊天

```dart
List<ChatMessage> history = [
  ChatMessage.user('Flutter是什么?'),
  ChatMessage.assistant('Flutter是Google开发的UI框架...'),
];

await DeepSeekService.chatCompletion(
  message: '请详细说明它的优势',
  conversationHistory: history,
  onSuccess: (response) {
    // 处理响应
    history.add(ChatMessage.assistant(response.firstContent!));
  },
  onError: (error, code) {
    print('请求失败: $error');
  },
);
```

## ⚠️ 注意事项

### API密钥安全

- **不要硬编码** - 永远不要将API密钥硬编码在源代码中
- **环境变量** - 使用环境变量或安全存储来管理密钥
- **权限控制** - 定期轮换API密钥以确保安全

```dart
// 推荐做法：从安全存储获取密钥
String apiKey = await SecureStorage.getApiKey();
DeepSeekService.initialize(apiKey);
```

### 请求限制

- **频率限制** - 注意API的调用频率限制
- **Token限制** - 控制单次请求的token数量
- **错误处理** - 实现适当的错误处理和重试机制

### 网络配置

```dart
// 自定义网络超时配置
static const int connectTimeout = 60000;  // 连接超时
static const int receiveTimeout = 120000; // 接收超时（AI响应较慢）
static const int sendTimeout = 30000;     // 发送超时
```

## 🔧 故障排除

### 常见问题

#### 1. API密钥无效 (401)
```
错误信息: API密钥无效或已过期，请重新设置
解决方案: 检查API密钥是否正确设置，确保密钥有效
```

#### 2. 账户余额不足 (402) ⚠️
```
错误信息: 账户余额不足，请前往DeepSeek官网充值
解决方案: 登录DeepSeek官网，进入账户页面进行充值
```

#### 3. 请求格式错误 (400)
```
错误信息: 请求格式错误，请检查输入内容
解决方案: 检查发送的消息格式是否正确
```

#### 4. 请求参数错误 (422)
```
错误信息: 请求参数错误，请检查输入内容
解决方案: 检查model、temperature等参数是否在允许范围内
```

#### 5. 请求速率过高 (429)
```
错误信息: 请求速率过高，请稍后再试
解决方案: 控制请求频率，添加适当的延时
```

#### 6. 服务器错误 (500/503)
```
错误信息: DeepSeek服务器内部故障/繁忙
解决方案: 稍等片刻后重试，或联系DeepSeek技术支持
```

#### 7. 网络超时
```
错误信息: DioException: Connection timeout
解决方案: 增加超时时间或检查网络连接
```

### 调试技巧

#### 启用详细日志

```dart
// 在DeepSeekService中已包含请求日志
// 查看控制台输出获取详细的请求信息
```

#### 检查连接状态

```dart
bool isConnected = await DeepSeekService.checkConnection();
if (!isConnected) {
  print('无法连接到DeepSeek API');
}
```

#### 测试API可用性

```dart
await DeepSeekService.getModels(
  onSuccess: (models) {
    print('可用模型: ${models.data.map((m) => m.id).join(', ')}');
  },
  onError: (error, code) {
    print('获取模型列表失败: $error');
  },
);
```

## 📱 演示页面功能

演示页面提供了以下功能：

1. **API密钥设置** - 安全的密钥输入界面
2. **连接测试** - 一键测试API连接状态
3. **聊天对话** - 完整的对话界面，支持历史记录
4. **代码助手** - 代码生成、解释和优化功能
5. **模型切换** - 动态切换不同的AI模型
6. **响应复制** - 一键复制AI生成的内容

## 🎯 最佳实践

1. **错误处理** - 始终实现完整的错误处理逻辑
2. **用户体验** - 显示加载状态和进度提示
3. **性能优化** - 合理控制请求频率和内容长度
4. **安全考虑** - 妥善保管API密钥，避免泄露
5. **测试验证** - 在不同网络环境下测试功能稳定性

## 📞 技术支持

如果在使用过程中遇到问题，可以：

1. 查看DeepSeek官方文档
2. 检查API状态页面
3. 查看项目的错误日志
4. 联系技术支持团队

---

**注意**: 本集成方案基于DeepSeek官方API文档开发，如API发生变更，请及时更新相关配置。
