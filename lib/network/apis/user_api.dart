import '../base/base_network_request.dart';
import '../models/user_model.dart';
import '../interceptors/auth_interceptor.dart';

/// 用户登录API
class UserLoginApi extends BaseNetworkRequest<LoginResponseModel> {
  final String username;
  final String password;
  final bool _showLoading;
  final bool _showError;

  UserLoginApi({
    required this.username,
    required this.password,
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/auth/login';

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  dynamic get data => LoginRequestModel(
        username: username,
        password: password,
      ).toJson();

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '登录中...';

  @override
  String? get successText => '登录成功';

  @override
  LoginResponseModel Function(dynamic)? get fromJson => (data) {
        return LoginResponseModel.fromJson(data);
      };

  @override
  void onSuccess(LoginResponseModel data) {
    // 保存token
    AuthInterceptor.saveToken(data.token, refreshToken: data.refreshToken);
    print('登录成功: ${data.user.username}');
  }

  @override
  void onError(String message, int code) {
    print('登录失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('登录异常: $error');
  }
}

/// 用户注册API
class UserRegisterApi extends BaseNetworkRequest<UserModel> {
  final String username;
  final String password;
  final String email;
  final String? name;
  final String? phone;
  final bool _showLoading;
  final bool _showError;

  UserRegisterApi({
    required this.username,
    required this.password,
    required this.email,
    this.name,
    this.phone,
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/auth/register';

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  dynamic get data => RegisterRequestModel(
        username: username,
        password: password,
        email: email,
        name: name,
        phone: phone,
      ).toJson();

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '注册中...';

  @override
  String? get successText => '注册成功';

  @override
  UserModel Function(dynamic)? get fromJson => (data) {
        return UserModel.fromJson(data);
      };

  @override
  void onSuccess(UserModel data) {
    print('注册成功: ${data.username}');
  }

  @override
  void onError(String message, int code) {
    print('注册失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('注册异常: $error');
  }
}

/// 获取用户信息API
class GetUserProfileApi extends BaseNetworkRequest<UserModel> {
  final bool _showLoading;
  final bool _showError;

  GetUserProfileApi({
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/user/profile';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '获取用户信息中...';

  @override
  String? get successText => null; // 不显示成功提示

  @override
  UserModel Function(dynamic)? get fromJson => (data) {
        return UserModel.fromJson(data);
      };

  @override
  void onSuccess(UserModel data) {
    print('获取用户信息成功: ${data.username}');
  }

  @override
  void onError(String message, int code) {
    print('获取用户信息失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('获取用户信息异常: $error');
  }
}

/// 更新用户信息API
class UpdateUserProfileApi extends BaseNetworkRequest<UserModel> {
  final Map<String, dynamic> profileData;
  final bool _showLoading;
  final bool _showError;

  UpdateUserProfileApi({
    required this.profileData,
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/user/profile';

  @override
  HttpMethod get method => HttpMethod.put;

  @override
  dynamic get data => profileData;

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '更新用户信息中...';

  @override
  String? get successText => '更新成功';

  @override
  UserModel Function(dynamic)? get fromJson => (data) {
        return UserModel.fromJson(data);
      };

  @override
  void onSuccess(UserModel data) {
    print('更新用户信息成功: ${data.username}');
  }

  @override
  void onError(String message, int code) {
    print('更新用户信息失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('更新用户信息异常: $error');
  }
}

/// 上传用户头像API
class UploadUserAvatarApi extends BaseFileUploadRequest<Map<String, dynamic>> {
  final String _filePath;
  final bool _showLoading;
  final bool _showError;

  UploadUserAvatarApi({
    required String filePath,
    bool showLoading = true,
    bool showError = true,
  }) : _filePath = filePath,
       _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/user/avatar';

  @override
  String get filePath => _filePath;

  @override
  String? get fileName => null; // 使用默认文件名

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '上传头像中...';

  @override
  String? get successText => '头像上传成功';

  @override
  Map<String, dynamic> Function(dynamic)? get fromJson => (data) {
        return Map<String, dynamic>.from(data);
      };

  @override
  void onSuccess(Map<String, dynamic> data) {
    print('头像上传成功: $data');
  }

  @override
  void onError(String message, int code) {
    print('头像上传失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('头像上传异常: $error');
  }

  @override
  void onProgress(int sent, int total) {
    print('上传进度: ${(sent / total * 100).toStringAsFixed(2)}%');
  }
}
