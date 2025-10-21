import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 认证拦截器
/// 负责添加token、处理认证相关的请求头
class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 添加认证token
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 添加通用请求头
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    options.headers['X-Requested-With'] = 'XMLHttpRequest';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理401未授权错误，尝试刷新token
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // 重新发送请求
        final options = err.requestOptions;
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          try {
            final response = await Dio().fetch(options);
            handler.resolve(response);
            return;
          } catch (e) {
            // 刷新失败，清除token
            await _clearTokens();
          }
        }
      }
    }
    handler.next(err);
  }

  /// 获取存储的token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// 刷新token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) return false;

      // 这里应该调用刷新token的API
      // 示例实现，实际使用时需要替换为真实的API调用
      final dio = Dio();
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await prefs.setString(_tokenKey, data['access_token']);
        if (data['refresh_token'] != null) {
          await prefs.setString(_refreshTokenKey, data['refresh_token']);
        }
        return true;
      }
    } catch (e) {
      print('Token刷新失败: $e');
    }
    return false;
  }

  /// 清除所有token
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  /// 保存token
  static Future<void> saveToken(String token, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// 清除token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
