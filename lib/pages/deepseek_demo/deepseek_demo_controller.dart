import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../base/base_controller.dart';
import '../../network/services/deepseek_service.dart';
import '../../network/models/deepseek_models.dart';
import '../../network/config/deepseek_config.dart';
import '../../network/config/local_deepseek_config.dart';

/// DeepSeek 演示页面控制器
class DeepSeekDemoController extends BaseController {
  // 输入控制器
  late final TextEditingController messageController;
  late final TextEditingController codeController;
  late final TextEditingController apiKeyController;
  
  // 响应式变量
  final RxString chatResponse = ''.obs;
  final RxString codeResponse = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isApiKeySet = false.obs;
  final RxBool isApiConnected = false.obs; // 新增：API连接状态
  final RxString validationMessage = ''.obs; // 新增：验证消息状态
  final RxList<ChatMessage> conversationHistory = <ChatMessage>[].obs;
  
  // 选择的功能类型
  final RxInt selectedTabIndex = 0.obs;
  
  // 模型选择
  final RxString selectedModel = 'deepseek-chat'.obs;
  final RxList<String> availableModels = <String>[
    'deepseek-chat',
    'deepseek-coder',
  ].obs;
  
  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
    codeController = TextEditingController();
    apiKeyController = TextEditingController();
    registerTextController(messageController);
    registerTextController(codeController);
    registerTextController(apiKeyController);
    _checkApiKeyStatus();
  }
  
  /// 检查API密钥状态
  void _checkApiKeyStatus() {
    isApiKeySet.value = DeepSeekConfig.hasApiKey;
    // 如果有API密钥，自动验证连接状态
    if (isApiKeySet.value) {
      _verifyConnection();
    } else {
      isApiConnected.value = false;
    }
  }
  
  /// 验证API连接状态
  void _verifyConnection() async {
    try {
      isApiConnected.value = await DeepSeekService.checkConnection();
    } catch (e) {
      isApiConnected.value = false;
    }
  }
  
  /// 设置API密钥
  Future<void> setApiKey() async {
    if (apiKeyController.text.trim().isEmpty) {
      showError('请输入API密钥');
      return;
    }
    
    String tempApiKey = apiKeyController.text.trim();
    
    // 先验证连接再保存
    try {
      // 临时设置密钥用于验证
      DeepSeekService.initialize(tempApiKey);
      bool isConnected = await DeepSeekService.checkConnection();
      
      if (isConnected) {
        // 验证成功，保存密钥并更新状态
        isApiKeySet.value = true;
        isApiConnected.value = true;
        validationMessage.value = '✅ 验证成功！API密钥有效'; // 更新验证消息
        apiKeyController.clear(); // 保存设置时清空输入框
        
        showSuccess('API密钥有效，已保存并可开始使用');
      } else {
        // 验证失败，不保存密钥
        DeepSeekConfig.setApiKey(''); // 清除临时设置的密钥
        isApiKeySet.value = false;
        isApiConnected.value = false;
        validationMessage.value = '❌ 验证失败，请检查密钥是否正确'; // 更新验证消息
        
        showError('API密钥无效，请检查密钥是否正确');
      }
    } catch (e) {
      // 网络异常，不保存密钥
      DeepSeekConfig.setApiKey(''); // 清除临时设置的密钥
      isApiKeySet.value = false;
      isApiConnected.value = false;
      validationMessage.value = '❌ 网络连接异常，请检查网络后重试'; // 更新验证消息
      
      showError('网络连接异常，请检查网络后重试');
    }
  }
  
  /// 发送聊天消息
  void sendChatMessage() async {
    if (messageController.text.trim().isEmpty) {
      showWarning('请输入消息内容');
      return;
    }
    
    if (!isApiKeySet.value) {
      showWarning('请先设置API密钥');
      return;
    }
    
    // 防止重复发送
    if (isLoading.value) {
      return;
    }
    
    final message = messageController.text.trim();
    messageController.clear();
    
    // 添加用户消息到历史记录
    conversationHistory.add(ChatMessage.user(message));
    
    isLoading.value = true;
    chatResponse.value = '';
    
    // 生成系统提示词，包含当前真实时间
    final now = DateTime.now();
    final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final weekday = weekdays[now.weekday - 1];
    final systemPrompt = '''你是一个智能助手，具有实时网络搜索能力。当前真实时间信息：
- 日期：${now.year}年${now.month}月${now.day}日
- 星期：$weekday  
- 时间：${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}

重要指令：
1. 对于需要实时信息的询问，你必须主动进行网络搜索获取最新数据
2. 当用户询问实时信息时，不要说"无法提供实时信息"，而应该直接搜索并提供准确的实时数据
3. 搜索到信息后，请提供详细、准确的数据，包括数据来源
4. 基于搜索结果给出实用的分析和建议

请积极使用你的网络搜索功能，为用户提供准确的实时信息。''';
    
    await DeepSeekService.chatCompletion(
      message: message,
      model: selectedModel.value,
      conversationHistory: conversationHistory.take(conversationHistory.length - 1).toList(),
      systemPrompt: systemPrompt,
      temperature: 0.1, // 更低温度确保准确性和一致性
      maxTokens: 4000,   // 增加输出长度以容纳详细的搜索结果
      topP: 0.8,         // 降低topP以提高确定性
      frequencyPenalty: 0.0, // 移除频次惩罚，避免抑制重要信息重复
      presencePenalty: 0.0,  // 移除存在惩罚，确保完整信息展示
      onSuccess: (response) {
        // 添加助手回复到历史记录
        if (response.firstContent != null) {
          conversationHistory.add(ChatMessage.assistant(response.firstContent!));
        }
        // 清空临时响应，避免重复显示
        chatResponse.value = '';
      },
      onError: (error, code) {
        // 只添加错误消息到对话历史，不设置chatResponse
        conversationHistory.add(ChatMessage.assistant('抱歉，出现了错误：$error'));
        chatResponse.value = ''; // 清空临时响应
        showError(error);
      },
      onException: (exception) {
        // 只添加异常消息到对话历史，不设置chatResponse
        conversationHistory.add(ChatMessage.assistant('抱歉，网络连接异常，请稍后重试。'));
        chatResponse.value = ''; // 清空临时响应
        showError('请检查网络连接');
      },
    );
    
    isLoading.value = false;
  }
  
  /// 生成代码
  void generateCode() async {
    if (codeController.text.trim().isEmpty) {
      showWarning('请输入代码需求');
      return;
    }
    
    if (!isApiKeySet.value) {
      showWarning('请先设置API密钥');
      return;
    }
    
    final prompt = codeController.text.trim();
    
    isLoading.value = true;
    codeResponse.value = '';
    
    await DeepSeekService.generateCode(
      prompt: prompt,
      language: 'dart', // 默认使用Dart语言
      onSuccess: (response) {
        codeResponse.value = response.firstContent ?? '没有生成代码';
      },
      onError: (error, code) {
        codeResponse.value = '错误 ($code): $error';
        showError(error);
      },
      onException: (exception) {
        codeResponse.value = '请求异常: $exception';
      },
    );
    
    isLoading.value = false;
  }
  
  /// 解释代码
  void explainCode() async {
    if (codeController.text.trim().isEmpty) {
      showWarning('请输入要解释的代码');
      return;
    }
    
    if (!isApiKeySet.value) {
      showWarning('请先设置API密钥');
      return;
    }
    
    final code = codeController.text.trim();
    
    isLoading.value = true;
    codeResponse.value = '';
    
    await DeepSeekService.explainCode(
      code: code,
      language: 'dart',
      onSuccess: (response) {
        codeResponse.value = response.firstContent ?? '没有解释内容';
      },
      onError: (error, code) {
        codeResponse.value = '错误 ($code): $error';
        showError(error);
      },
      onException: (exception) {
        codeResponse.value = '请求异常: $exception';
      },
    );
    
    isLoading.value = false;
  }
  
  /// 清空聊天历史
  void clearChatHistory() {
    conversationHistory.clear();
    chatResponse.value = '';
  }
  
  /// 清空代码响应
  void clearCodeResponse() {
    codeResponse.value = '';
  }
  
  /// 切换模型
  void changeModel(String model) {
    selectedModel.value = model;
  }
  
  /// 测试连接
  void testConnection() async {
    if (!isApiKeySet.value) {
      showWarning('请先设置API密钥');
      return;
    }
    
    final isConnected = await DeepSeekService.checkConnection();
    
    if (isConnected) {
      showSuccess('DeepSeek API连接正常');
    } else {
      showError('无法连接到DeepSeek API');
    }
  }
  
  /// 测试连接并返回结果（用于弹窗）
  Future<bool> testConnectionResult() async {
    if (!isApiKeySet.value) {
      return false;
    }
    
    try {
      return await DeepSeekService.checkConnection();
    } catch (e) {
      return false;
    }
  }
  
  /// 清除API密钥
  void clearApiKey() {
    DeepSeekConfig.setApiKey('');
    isApiKeySet.value = false;
    isApiConnected.value = false;
    validationMessage.value = ''; // 清除验证消息
    apiKeyController.clear();
  }

  /// 使用默认密钥
  /// 
  /// 从本地配置中读取默认密钥并填充到输入框
  void useDefaultKey() {
    try {
      final defaultKey = LocalDeepSeekConfig.defaultApiKey;
      if (defaultKey.isNotEmpty) {
        apiKeyController.text = defaultKey;
        validationMessage.value = '✅ 已填充默认密钥，请点击"测试连接"或"保存设置"';
      } else {
        showWarning('未找到默认密钥配置');
      }
    } catch (e) {
      showError('无法加载默认密钥：$e');
    }
  }

  /// 检查是否有可用的默认密钥
  bool get hasDefaultKey {
    try {
      return LocalDeepSeekConfig.defaultApiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
