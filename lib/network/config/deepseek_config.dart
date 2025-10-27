/// DeepSeek API配置类
/// 管理DeepSeek相关的API配置和认证信息
class DeepSeekConfig {
  // DeepSeek API 基础配置
  static const String baseUrl = 'https://api.deepseek.com';
  static const String apiVersion = 'v1';
  
  // API密钥 - 实际使用时需要从安全存储中获取
  static String _apiKey = '';
  
  /// 设置API密钥
  static void setApiKey(String key) {
    _apiKey = key;
  }
  
  /// 获取API密钥
  static String get apiKey => _apiKey;
  
  /// 检查API密钥是否已设置
  static bool get hasApiKey => _apiKey.isNotEmpty;
  
  // 请求超时配置
  static const int connectTimeout = 60000; // 60秒
  static const int receiveTimeout = 120000; // 120秒 - AI响应可能较慢
  static const int sendTimeout = 30000; // 30秒
  
  // 模型配置
  static const String defaultChatModel = 'deepseek-chat';
  static const String defaultCoderModel = 'deepseek-coder';
  
  /// 获取请求头
  static Map<String, String> get headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };
  
  /// 获取完整的API路径
  static String getFullPath(String endpoint) {
    return '$baseUrl/$apiVersion$endpoint';
  }
}

/// DeepSeek API路由配置
class DeepSeekRoutes {
  // 聊天接口
  static const String chat = '/chat/completions';
  
  // 模型列表
  static const String models = '/models';
  
  // 获取完整路径的便捷方法
  static String get chatCompletions => DeepSeekConfig.getFullPath(chat);
  static String get modelsList => DeepSeekConfig.getFullPath(models);
}

/// DeepSeek支持的模型列表
class DeepSeekModels {
  static const String deepseekChat = 'deepseek-chat';
  static const String deepseekCoder = 'deepseek-coder';
  
  /// 获取所有可用模型
  static List<String> get allModels => [
    deepseekChat,
    deepseekCoder,
  ];
  
  /// 模型描述
  static Map<String, String> get modelDescriptions => {
    deepseekChat: '通用对话模型，适合日常聊天和问答',
    deepseekCoder: '专业代码模型，适合编程任务和代码生成',
  };
}
