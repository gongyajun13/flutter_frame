/// DeepSeek API相关数据模型

/// 聊天请求模型
class ChatCompletionRequest {
  final String model;
  final List<ChatMessage> messages;
  final double? temperature;
  final int? maxTokens;
  final bool? stream;
  final List<String>? stop;
  final double? topP;
  final double? frequencyPenalty;
  final double? presencePenalty;

  ChatCompletionRequest({
    required this.model,
    required this.messages,
    this.temperature,
    this.maxTokens,
    this.stream,
    this.stop,
    this.topP,
    this.frequencyPenalty,
    this.presencePenalty,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'model': model,
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };

    if (temperature != null) json['temperature'] = temperature;
    if (maxTokens != null) json['max_tokens'] = maxTokens;
    if (stream != null) json['stream'] = stream;
    if (stop != null) json['stop'] = stop;
    if (topP != null) json['top_p'] = topP;
    if (frequencyPenalty != null) json['frequency_penalty'] = frequencyPenalty;
    if (presencePenalty != null) json['presence_penalty'] = presencePenalty;
    json["web_search"] = true;      // 启用网络搜索功能
    json["search_query_optimization"] = true; // 优化搜索查询（如果支持）
    return json;
  }
}

/// 聊天消息模型
class ChatMessage {
  final String role;
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  /// 创建用户消息
  factory ChatMessage.user(String content) {
    return ChatMessage(role: 'user', content: content);
  }

  /// 创建助手消息
  factory ChatMessage.assistant(String content) {
    return ChatMessage(role: 'assistant', content: content);
  }

  /// 创建系统消息
  factory ChatMessage.system(String content) {
    return ChatMessage(role: 'system', content: content);
  }
}

/// 聊天响应模型
class ChatCompletionResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatChoice> choices;
  final Usage usage;

  ChatCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices: (json['choices'] as List)
          .map((choice) => ChatChoice.fromJson(choice))
          .toList(),
      usage: Usage.fromJson(json['usage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'model': model,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'usage': usage.toJson(),
    };
  }

  /// 获取第一个选择的内容
  String? get firstContent {
    if (choices.isNotEmpty) {
      return choices.first.message?.content;
    }
    return null;
  }
}

/// 聊天选择模型
class ChatChoice {
  final int index;
  final ChatMessage? message;
  final String? finishReason;

  ChatChoice({
    required this.index,
    this.message,
    this.finishReason,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'] as int,
      message: json['message'] != null 
          ? ChatMessage.fromJson(json['message'])
          : null,
      finishReason: json['finish_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'message': message?.toJson(),
      'finish_reason': finishReason,
    };
  }
}

/// 使用量统计模型
class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }
}

/// 模型信息
class ModelInfo {
  final String id;
  final String object;
  final int created;
  final String ownedBy;

  ModelInfo({
    required this.id,
    required this.object,
    required this.created,
    required this.ownedBy,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      ownedBy: json['owned_by'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'owned_by': ownedBy,
    };
  }
}

/// 模型列表响应
class ModelsResponse {
  final String object;
  final List<ModelInfo> data;

  ModelsResponse({
    required this.object,
    required this.data,
  });

  factory ModelsResponse.fromJson(Map<String, dynamic> json) {
    return ModelsResponse(
      object: json['object'] as String,
      data: (json['data'] as List)
          .map((model) => ModelInfo.fromJson(model))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'data': data.map((model) => model.toJson()).toList(),
    };
  }
}

/// DeepSeek API错误响应
class DeepSeekError {
  final String type;
  final String message;
  final String? code;

  DeepSeekError({
    required this.type,
    required this.message,
    this.code,
  });

  factory DeepSeekError.fromJson(Map<String, dynamic> json) {
    return DeepSeekError(
      type: json['type'] as String,
      message: json['message'] as String,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'code': code,
    };
  }

  @override
  String toString() {
    return 'DeepSeekError(type: $type, message: $message, code: $code)';
  }
}
