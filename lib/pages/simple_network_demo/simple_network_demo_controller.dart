import 'package:get/get.dart';
import '../../network/services/api_service.dart';
import '../../network/models/user_model.dart';
import '../../network/models/product_model.dart';
import '../../base/base_controller.dart';

/// 简化网络请求演示控制器
class SimpleNetworkDemoController extends BaseController {
  // 结果显示文本
  final result = '点击按钮测试简洁的网络请求'.obs;

  // 当前用户
  final currentUser = Rxn<UserModel>();

  // 产品列表
  final products = <ProductModel>[].obs;

  /// 测试用户登录
  void testLogin() {
    result.value = '正在执行用户登录...';

    ApiService.login(
      username: 'test@example.com',
      password: 'password123',
      onSuccess: (data) {
        currentUser.value = data.user;
        result.value = '登录成功!\n\n用户信息:\n${data.user.toString()}\n\nToken: ${data.token}';
        showSuccess('登录成功');
      },
      onError: (message, code) {
        result.value = '登录失败!\n\n错误信息: $message\n错误代码: $code';
        showError('登录失败: $message');
      },
      onException: (error) {
        result.value = '登录异常!\n\n异常信息: $error';
        showError('登录异常: $error');
      },
    );
  }

  /// 获取用户信息
  void getUserProfile() {
    result.value = '正在获取用户信息...';

    ApiService.getUserProfile(
      onSuccess: (data) {
        currentUser.value = data;
        result.value = '获取用户信息成功!\n\n用户信息:\n${data.toString()}';
        showSuccess('获取用户信息成功');
      },
      onError: (message, code) {
        result.value = '获取用户信息失败!\n\n错误信息: $message\n错误代码: $code';
        showError('获取用户信息失败: $message');
      },
      onException: (error) {
        result.value = '获取用户信息异常!\n\n异常信息: $error';
        showError('获取用户信息异常: $error');
      },
    );
  }

  /// 获取产品列表
  void getProducts() {
    result.value = '正在获取产品列表...';

    ApiService.getProducts(
      page: 1,
      pageSize: 5,
      filters: {
        'category': 'electronics',
        'isActive': true,
      },
      onSuccess: (data) {
        products.value = data.items;
        result.value = '获取产品列表成功!\n\n'
            '总数: ${data.total}\n'
            '当前页: ${data.page}\n'
            '每页大小: ${data.pageSize}\n'
            '是否有更多: ${data.hasMore}\n\n'
            '产品列表:\n${data.items.map((p) => p.toString()).join('\n')}';
        showSuccess('获取产品列表成功');
      },
      onError: (message, code) {
        result.value = '获取产品列表失败!\n\n错误信息: $message\n错误代码: $code';
        showError('获取产品列表失败: $message');
      },
      onException: (error) {
        result.value = '获取产品列表异常!\n\n异常信息: $error';
        showError('获取产品列表异常: $error');
      },
    );
  }

  /// 创建产品
  void createProduct() {
    result.value = '正在创建产品...';

    ApiService.createProduct(
      productData: CreateProductRequestModel(
        name: '测试产品 ${DateTime.now().millisecondsSinceEpoch}',
        description: '这是一个测试产品',
        price: 99.99,
        category: 'electronics',
        stock: 100,
      ),
      onSuccess: (data) {
        result.value = '创建产品成功!\n\n产品信息:\n${data.toString()}';
        showSuccess('创建产品成功');
      },
      onError: (message, code) {
        result.value = '创建产品失败!\n\n错误信息: $message\n错误代码: $code';
        showError('创建产品失败: $message');
      },
      onException: (error) {
        result.value = '创建产品异常!\n\n异常信息: $error';
        showError('创建产品异常: $error');
      },
    );
  }

  /// 静默请求（不显示loading和错误提示）
  void silentRequest() {
    result.value = '正在执行静默请求...';

    ApiService.getUserProfile(
      showLoading: false, // 不显示loading
      showError: false, // 不显示错误提示
      onSuccess: (data) {
        currentUser.value = data;
        result.value = '静默请求成功!\n\n用户信息:\n${data.toString()}\n\n注意: 此请求没有显示loading和错误提示';
      },
      onError: (message, code) {
        result.value = '静默请求失败!\n\n错误信息: $message\n错误代码: $code\n\n注意: 此请求没有显示loading和错误提示';
      },
      onException: (error) {
        result.value = '静默请求异常!\n\n异常信息: $error\n\n注意: 此请求没有显示loading和错误提示';
      },
    );
  }
}
