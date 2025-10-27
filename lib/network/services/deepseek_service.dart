import 'package:dio/dio.dart';
import '../config/deepseek_config.dart';
import '../models/deepseek_models.dart';

/// DeepSeek API服务类
/// 提供与DeepSeek API交互的功能
class DeepSeekService {
  static final Dio _dio = Dio();
  
  /// 初始化DeepSeek服务
  static void initialize(String apiKey) {
    DeepSeekConfig.setApiKey(apiKey);
    _setupDio();
  }
  
  /// 配置Dio实例
  static void _setupDio() {
    // 清除旧的拦截器
    _dio.interceptors.clear();
    
    _dio.options = BaseOptions(
      baseUrl: DeepSeekConfig.baseUrl,
      connectTimeout: Duration(milliseconds: DeepSeekConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: DeepSeekConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: DeepSeekConfig.sendTimeout),
      headers: DeepSeekConfig.headers,
    );
    
    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 确保每次请求都使用最新的API密钥
        options.headers.addAll(DeepSeekConfig.headers);

        // 生成curl命令
        String curl = _generateCurlCommand(options);
        print('Curl Command:\n$curl');
        print('=============================\n');
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        // 打印详细的响应日志
        print('\n=== DeepSeek API Response ===');
        print('Response Data: ${response.data}');
        print('==============================\n');
        
        handler.next(response);
      },
      onError: (error, handler) {
        // 打印详细的错误日志
        print('\n=== DeepSeek API Error ===');
        print('Error Response Data: ${error.response?.data}');
        print('===========================\n');
        
        handler.next(error);
      },
    ));
  }
  
  /// 生成curl命令
  static String _generateCurlCommand(RequestOptions options) {
    StringBuffer curl = StringBuffer();
    curl.write('curl -X ${options.method.toUpperCase()}');
    
    // 添加headers
    options.headers.forEach((key, value) {
      curl.write(' \\\n  -H "$key: $value"');
    });
    
    // 添加请求体
    if (options.data != null) {
      String dataStr;
      if (options.data is Map || options.data is List) {
        dataStr = options.data.toString().replaceAll("'", '"');
      } else {
        dataStr = options.data.toString();
      }
      curl.write(' \\\n  -d \'$dataStr\'');
    }
    
    // 添加URL
    curl.write(' \\\n  "${options.uri}"');
    
    return curl.toString();
  }
  
  /// 统一的错误处理方法
  static String _getErrorMessage(int statusCode, dynamic responseData, String? defaultMessage) {
    switch (statusCode) {
      case 400:
        return '请求格式错误，请检查输入内容';
      case 401:
        return 'API密钥无效或已过期，请重新设置';
      case 402:
        return '账户余额不足，请前往DeepSeek官网充值';
      case 422:
        return '请求参数错误，请检查输入内容';
      case 429:
        return '请求速率过高，请稍后再试';
      case 500:
        return 'DeepSeek服务器内部故障，请稍后重试';
      case 503:
        return 'DeepSeek服务器繁忙，请稍后重试';
      default:
        // 尝试解析服务器返回的错误信息
        if (responseData != null) {
          try {
            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('error')) {
                final error = DeepSeekError.fromJson(responseData['error']);
                return error.message;
              } else if (responseData.containsKey('message')) {
                return responseData['message'];
              }
            }
          } catch (_) {
            // 解析失败，使用状态码
          }
        }
        return defaultMessage ?? '服务器错误 ($statusCode)';
    }
  }
  
  /// 发送聊天请求
  static Future<ChatCompletionResponse?> chatCompletion({
    required String message,
    String model = DeepSeekConfig.defaultChatModel,
    List<ChatMessage>? conversationHistory,
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    String? systemPrompt,
    required Function(ChatCompletionResponse) onSuccess,
    Function(String, int)? onError,
    Function(dynamic)? onException,
  }) async {
    if (!DeepSeekConfig.hasApiKey) {
      onError?.call('API密钥未设置', 401);
      return null;
    }
    
    try {
      // 构建消息列表
      List<ChatMessage> messages = [];
      
      // 添加系统提示词
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add(ChatMessage.system(systemPrompt));
      }
      
      // 添加对话历史
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // 添加当前消息
      messages.add(ChatMessage.user(message));
      
      // 构建请求
      final request = ChatCompletionRequest(
        model: model,
        messages: messages,
        temperature: temperature ?? 0.1, // 更低温度确保实时信息准确性
        maxTokens: maxTokens ?? 4000,    // 增加输出长度以容纳搜索结果
        topP: topP ?? 0.8,              // 降低topP提高确定性
        frequencyPenalty: frequencyPenalty ?? 0.0, // 避免抑制重要信息
        presencePenalty: presencePenalty ?? 0.0,   // 确保完整信息展示
        stream: false,
      );
      
      // 发送请求
      final response = await _dio.post(
        DeepSeekRoutes.chatCompletions,
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final chatResponse = ChatCompletionResponse.fromJson(response.data);
        onSuccess(chatResponse);
        return chatResponse;
      } else {
        onError?.call('请求失败', response.statusCode ?? 500);
        return null;
      }
      
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      final errorMessage = _getErrorMessage(statusCode, e.response?.data, e.message ?? '网络连接失败');
      
      onError?.call(errorMessage, statusCode);
      onException?.call(e);
      return null;
    } catch (e) {
      onError?.call('未知错误: $e', 500);
      onException?.call(e);
      return null;
    }
  }
  
  /// 代码生成请求
  static Future<ChatCompletionResponse?> generateCode({
    required String prompt,
    String? language,
    String? context,
    required Function(ChatCompletionResponse) onSuccess,
    Function(String, int)? onError,
    Function(dynamic)? onException,
  }) async {
    // 构建代码生成的系统提示词
    String systemPrompt = '你是一个专业的代码助手，专门帮助用户生成高质量的代码。';
    
    if (context != null && context.isNotEmpty) {
      systemPrompt += '上下文信息：$context';
    }
    
    systemPrompt += '请直接输出代码，并在必要时添加注释。';
    
    return await chatCompletion(
      message: prompt,
      model: DeepSeekConfig.defaultCoderModel,
      systemPrompt: systemPrompt,
      temperature: 0.2, // 代码生成使用较低的temperature
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
    );
  }
  
  /// 代码解释请求
  static Future<ChatCompletionResponse?> explainCode({
    required String code,
    String? language,
    required Function(ChatCompletionResponse) onSuccess,
    Function(String, int)? onError,
    Function(dynamic)? onException,
  }) async {
    String systemPrompt = '你是一个专业的代码助手，专门帮助用户理解代码。请详细解释代码的功能、逻辑和实现方式。';
    
    String prompt = '请解释以下代码：\n\n';
    if (language != null && language.isNotEmpty) {
      prompt += '```$language\n';
    } else {
      prompt += '```\n';
    }
    prompt += '$code\n```';
    
    return await chatCompletion(
      message: prompt,
      model: DeepSeekConfig.defaultCoderModel,
      systemPrompt: systemPrompt,
      temperature: 0.3,
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
    );
  }
  
  /// 代码优化请求
  static Future<ChatCompletionResponse?> optimizeCode({
    required String code,
    String? language,
    String? requirements,
    required Function(ChatCompletionResponse) onSuccess,
    Function(String, int)? onError,
    Function(dynamic)? onException,
  }) async {
    String systemPrompt = '你是一个专业的代码助手，专门帮助用户优化代码。请提供性能更好、更简洁或更易维护的代码版本。';
    
    String prompt = '请优化以下代码：\n\n';
    if (language != null && language.isNotEmpty) {
      prompt += '```$language\n';
    } else {
      prompt += '```\n';
    }
    prompt += '$code\n```\n\n';
    
    if (requirements != null && requirements.isNotEmpty) {
      prompt += '优化要求：$requirements';
    }
    
    return await chatCompletion(
      message: prompt,
      model: DeepSeekConfig.defaultCoderModel,
      systemPrompt: systemPrompt,
      temperature: 0.2,
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
    );
  }
  
  /// 获取可用模型列表
  static Future<ModelsResponse?> getModels({
    required Function(ModelsResponse) onSuccess,
    Function(String, int)? onError,
    Function(dynamic)? onException,
  }) async {
    if (!DeepSeekConfig.hasApiKey) {
      onError?.call('API密钥未设置', 401);
      return null;
    }
    
    try {
      final response = await _dio.get(DeepSeekRoutes.modelsList);
      
      if (response.statusCode == 200) {
        final modelsResponse = ModelsResponse.fromJson(response.data);
        onSuccess(modelsResponse);
        return modelsResponse;
      } else {
        onError?.call('获取模型列表失败', response.statusCode ?? 500);
        return null;
      }
      
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      final errorMessage = _getErrorMessage(statusCode, e.response?.data, e.message ?? '网络连接失败');
      
      onError?.call(errorMessage, statusCode);
      onException?.call(e);
      return null;
    } catch (e) {
      onError?.call('未知错误: $e', 500);
      onException?.call(e);
      return null;
    }
  }
  
  /// 检查API连接状态
  static Future<bool> checkConnection() async {
    if (!DeepSeekConfig.hasApiKey) {
      return false;
    }
    
    try {
      // 重新设置Dio配置，确保使用最新的API密钥
      _setupDio();
      
      // 使用相对路径而不是完整URL
      final response = await _dio.get(
        '/v1/models',
        options: Options(
          headers: DeepSeekConfig.headers,
        ),
      );
      
      print('连接检测响应: ${response.statusCode}');
      print('响应数据: ${response.data}');
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('连接检测DioException: ${e.message}');
      print('状态码: ${e.response?.statusCode}');
      print('响应数据: ${e.response?.data}');
      return false;
    } catch (e) {
      print('连接检测异常: $e');
      return false;
    }
  }
  
  /// 清理资源
  static void dispose() {
    _dio.close();
  }
}