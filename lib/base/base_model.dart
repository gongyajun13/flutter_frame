/// 模型基类
/// 提供通用的 JSON 序列化/反序列化、数据验证等功能
abstract class BaseModel {
  /// 从 JSON 创建模型
  BaseModel.fromJson(Map<String, dynamic> json);

  /// 转换为 JSON
  Map<String, dynamic> toJson();

  /// 从 JSON 列表创建模型列表
  static List<T> fromJsonList<T extends BaseModel>(
    List<dynamic> jsonList,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  /// 验证数据
  bool validate() {
    return true;
  }

  /// 获取验证错误信息
  String? getValidationError() {
    return null;
  }

  /// 复制模型
  BaseModel copy();

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.toJson() == toJson();
  }

  @override
  int get hashCode => toJson().hashCode;
}
