import '../core/network_manager.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/api_response.dart';

/// API服务类
/// 提供简洁的业务API调用方法
class ApiService {
  static final NetworkManager _networkManager = NetworkManager();

  /// 用户登录
  static void login({
    required String username,
    required String password,
    required void Function(LoginResponseModel) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.post<LoginResponseModel>(
      url: '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
      fromJson: (data) => LoginResponseModel.fromJson(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '登录中...',
      successText: '登录成功',
    );
  }

  /// 用户注册
  static void register({
    required String username,
    required String password,
    required String email,
    String? name,
    String? phone,
    required void Function(UserModel) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.post<UserModel>(
      url: '/auth/register',
      data: {
        'username': username,
        'password': password,
        'email': email,
        'name': name,
        'phone': phone,
      },
      fromJson: (data) => UserModel.fromJson(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '注册中...',
      successText: '注册成功',
    );
  }

  /// 获取用户信息
  static void getUserProfile({
    required void Function(UserModel) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.get<UserModel>(
      url: '/user/profile',
      fromJson: (data) => UserModel.fromJson(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '获取用户信息中...',
      successText: null, // 不显示成功提示
    );
  }

  /// 更新用户信息
  static void updateUserProfile({
    required Map<String, dynamic> profileData,
    required void Function(UserModel) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.put<UserModel>(
      url: '/user/profile',
      data: profileData,
      fromJson: (data) => UserModel.fromJson(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '更新用户信息中...',
      successText: '更新成功',
    );
  }

  /// 上传用户头像
  static void uploadAvatar({
    required String filePath,
    required void Function(Map<String, dynamic>) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    void Function(int sent, int total)? onProgress,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.upload<Map<String, dynamic>>(
      url: '/user/avatar',
      filePath: filePath,
      fromJson: (data) => Map<String, dynamic>.from(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      onProgress: onProgress,
      showLoading: showLoading,
      showError: showError,
      loadingText: '上传头像中...',
      successText: '头像上传成功',
    );
  }

  /// 获取产品列表
  static void getProducts({
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
    required void Function(PaginatedResponse<ProductModel>) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.getPaginated<ProductModel>(
      url: '/products',
      page: page,
      pageSize: pageSize,
      filters: filters,
      itemFromJson: (item) => ProductModel.fromJson(item),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '获取产品列表中...',
    );
  }

  /// 获取产品详情
  static void getProductDetail({
    required String productId,
    required void Function(ProductModel) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.get<ProductModel>(
      url: '/products/$productId',
      fromJson: (data) => ProductModel.fromJson(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '获取产品详情中...',
      successText: null, // 不显示成功提示
    );
  }

  /// 创建产品
  static void createProduct({
    required CreateProductRequestModel productData,
    required void Function(ProductModel) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.post<ProductModel>(
      url: '/products',
      data: productData.toJson(),
      fromJson: (data) => ProductModel.fromJson(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '创建产品中...',
      successText: '产品创建成功',
    );
  }

  /// 更新产品
  static void updateProduct({
    required String productId,
    required UpdateProductRequestModel productData,
    required void Function(ProductModel) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.put<ProductModel>(
      url: '/products/$productId',
      data: productData.toJson(),
      fromJson: (data) => ProductModel.fromJson(data),
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '更新产品中...',
      successText: '产品更新成功',
    );
  }

  /// 删除产品
  static void deleteProduct({
    required String productId,
    required void Function(void) onSuccess,
    void Function(String, int)? onError,
    void Function(dynamic)? onException,
    bool showLoading = true,
    bool showError = true,
  }) {
    _networkManager.delete<void>(
      url: '/products/$productId',
      onSuccess: onSuccess,
      onError: onError,
      onException: onException,
      showLoading: showLoading,
      showError: showError,
      loadingText: '删除产品中...',
      successText: '产品删除成功',
    );
  }
}
