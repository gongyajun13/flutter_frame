/// 用户表模型
/// 对应数据库 users 表
class UserTableModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? name;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserTableModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.name,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从数据库 Map 创建
  factory UserTableModel.fromMap(Map<String, dynamic> map) {
    return UserTableModel(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      avatar: map['avatar'] as String?,
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'name': name,
      'phone': phone,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 从 JSON 创建（用于网络数据）
  factory UserTableModel.fromJson(Map<String, dynamic> json) {
    return UserTableModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'name': name,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并更新
  UserTableModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? name,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserTableModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserTableModel{id: $id, username: $username, email: $email, name: $name}';
  }
}
