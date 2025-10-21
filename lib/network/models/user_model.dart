/// 用户模型
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? name;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.name,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      name: json['name'],
      phone: json['phone'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'name': name,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, email: $email, name: $name}';
  }
}

/// 登录请求模型
class LoginRequestModel {
  final String username;
  final String password;

  LoginRequestModel({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

/// 登录响应模型
class LoginResponseModel {
  final String token;
  final String? refreshToken;
  final UserModel user;
  final DateTime expiresAt;

  LoginResponseModel({
    required this.token,
    this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'],
      user: UserModel.fromJson(json['user'] ?? {}),
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

/// 注册请求模型
class RegisterRequestModel {
  final String username;
  final String password;
  final String email;
  final String? name;
  final String? phone;

  RegisterRequestModel({
    required this.username,
    required this.password,
    required this.email,
    this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'name': name,
      'phone': phone,
    };
  }
}
