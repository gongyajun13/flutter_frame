/// API配置类
/// 管理所有API的基础配置和路由
class ApiConfig {
  // 基础URL配置（对 EnvironmentConfig 暴露）
  static const String baseUrl = 'https://api.example.com';
  static const String devBaseUrl = 'https://dev-api.example.com';
  static const String testBaseUrl = 'https://test-api.example.com';

  /// 默认基础URL（不考虑环境，供 EnvironmentConfig 使用）

  // 请求超时配置
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒
  static const int sendTimeout = 30000; // 30秒

  // 重试配置
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1秒

  // API版本
  static const String apiVersion = 'v1';
}

/// 环境枚举
enum Environment {
  development,
  test,
  production,
}

/// API路由配置
class ApiRoutes {
  // 认证相关API
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // 用户相关API
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String uploadAvatar = '/user/avatar';

  // 文件上传API
  static const String uploadFile = '/upload/file';
  static const String uploadImage = '/upload/image';
  static const String uploadVideo = '/upload/video';

  // 通用数据API
  static const String getConfig = '/config';
  static const String getVersion = '/version';
  static const String healthCheck = '/health';

  // 业务相关API示例
  static const String getProducts = '/products';
  static const String getProductDetail = '/products/{id}';
  static const String createProduct = '/products';
  static const String updateProduct = '/products/{id}';
  static const String deleteProduct = '/products/{id}';

  static const String getOrders = '/orders';
  static const String getOrderDetail = '/orders/{id}';
  static const String createOrder = '/orders';
  static const String updateOrder = '/orders/{id}';
  static const String cancelOrder = '/orders/{id}/cancel';

  // 获取完整的API路径
  static String getFullPath(String route) {
    return '${ApiConfig.baseUrl}/api/${ApiConfig.apiVersion}$route';
  }

  // 替换路径中的参数
  static String replacePathParams(String route, Map<String, dynamic> params) {
    String result = route;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}
