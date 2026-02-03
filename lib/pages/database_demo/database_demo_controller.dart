import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../database/repositories/user_repository.dart';
import '../../database/repositories/product_repository.dart';
import '../../database/models/user_table_model.dart';
import '../../database/models/product_table_model.dart';
import '../../utils/app_logger.dart';

/// 数据库演示控制器
class DatabaseDemoController extends BaseController {
  final UserRepository _userRepository = UserRepository();
  final ProductRepository _productRepository = ProductRepository();

  /// 用户列表
  final RxList<UserTableModel> users = <UserTableModel>[].obs;

  /// 产品列表
  final RxList<ProductTableModel> products = <ProductTableModel>[].obs;

  /// 当前选中的表（users 或 products）
  final RxString selectedTable = 'users'.obs;

  /// 用户数量
  final RxInt userCount = 0.obs;

  /// 产品数量
  final RxInt productCount = 0.obs;

  /// 搜索关键词
  final RxString searchKeyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    await _loadUsers();
    await _loadProducts();
    await _loadCounts();
  }

  /// 加载用户列表
  Future<void> _loadUsers() async {
    try {
      final userList = await _userRepository.getAllUsers();
      users.assignAll(userList);
    } catch (e) {
      showError('加载用户失败：$e');
    }
  }

  /// 加载产品列表
  Future<void> _loadProducts() async {
    try {
      final productList = await _productRepository.getAllProducts();
      products.assignAll(productList);
    } catch (e) {
      showError('加载产品失败：$e');
    }
  }

  /// 加载数量统计
  Future<void> _loadCounts() async {
    try {
      userCount.value = await _userRepository.getUserCount();
      productCount.value = await _productRepository.getProductCount();
    } catch (e) {
      showError('加载统计失败：$e');
    }
  }

  /// 切换表
  void switchTable(String table) {
    selectedTable.value = table;
    // 切换表时清除搜索关键词
    searchKeyword.value = '';
  }

  /// 添加示例用户
  Future<void> addSampleUser() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final user = UserTableModel(
        id: 'user_${now.millisecondsSinceEpoch}',
        username: 'user_${users.length + 1}',
        email: 'user${users.length + 1}@example.com',
        name: '用户 ${users.length + 1}',
        phone: '1380000${users.length.toString().padLeft(4, '0')}',
        createdAt: now,
        updatedAt: now,
      );
      await _userRepository.insertUser(user);
      await _loadUsers();
      await _loadCounts();
      showSuccess('添加用户成功');
    } catch (e) {
      showError('添加用户失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 添加示例产品
  Future<void> addSampleProduct() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final product = ProductTableModel(
        id: 'product_${now.millisecondsSinceEpoch}',
        name: '产品 ${products.length + 1}',
        description: '这是产品 ${products.length + 1} 的描述',
        price: (products.length + 1) * 10.0,
        category: ['电子产品', '服装', '食品', '图书'][products.length % 4],
        stock: (products.length + 1) * 10,
        createdAt: now,
        updatedAt: now,
      );
      await _productRepository.insertProduct(product);
      await _loadProducts();
      await _loadCounts();
      showSuccess('添加产品成功');
    } catch (e) {
      showError('添加产品失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 批量添加用户
  Future<void> batchAddUsers(int count) async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final userList = List.generate(count, (index) {
        return UserTableModel(
          id: 'user_batch_${now.millisecondsSinceEpoch}_$index',
          username: 'batch_user_${users.length + index + 1}',
          email: 'batch${users.length + index + 1}@example.com',
          name: '批量用户 ${users.length + index + 1}',
          phone: '1390000${(users.length + index).toString().padLeft(4, '0')}',
          createdAt: now,
          updatedAt: now,
        );
      });
      await _userRepository.insertUsers(userList);
      await _loadUsers();
      await _loadCounts();
      showSuccess('批量添加 $count 个用户成功');
    } catch (e) {
      showError('批量添加用户失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 批量添加产品
  Future<void> batchAddProducts(int count) async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final categories = ['电子产品', '服装', '食品', '图书', '家居'];
      final productList = List.generate(count, (index) {
        return ProductTableModel(
          id: 'product_batch_${now.millisecondsSinceEpoch}_$index',
          name: '批量产品 ${products.length + index + 1}',
          description: '这是批量产品 ${products.length + index + 1} 的描述',
          price: (products.length + index + 1) * 10.0,
          category: categories[(products.length + index) % categories.length],
          stock: (products.length + index + 1) * 10,
          createdAt: now,
          updatedAt: now,
        );
      });
      await _productRepository.insertProducts(productList);
      await _loadProducts();
      await _loadCounts();
      showSuccess('批量添加 $count 个产品成功');
    } catch (e) {
      showError('批量添加产品失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 删除用户
  Future<void> deleteUser(String id) async {
    try {
      await _userRepository.deleteUser(id);
      await _loadUsers();
      await _loadCounts();
      showSuccess('删除用户成功');
    } catch (e) {
      showError('删除用户失败：$e');
    }
  }

  /// 删除产品
  Future<void> deleteProduct(String id) async {
    try {
      await _productRepository.deleteProduct(id);
      await _loadProducts();
      await _loadCounts();
      showSuccess('删除产品成功');
    } catch (e) {
      showError('删除产品失败：$e');
    }
  }

  /// 清空用户表
  Future<void> clearUsers() async {
    try {
      isLoading.value = true;
      await _userRepository.deleteAllUsers();
      await _loadUsers();
      await _loadCounts();
      showSuccess('清空用户表成功');
    } catch (e) {
      showError('清空用户表失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 清空产品表
  Future<void> clearProducts() async {
    try {
      isLoading.value = true;
      await _productRepository.deleteAllProducts();
      await _loadProducts();
      await _loadCounts();
      showSuccess('清空产品表成功');
    } catch (e) {
      showError('清空产品表失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 搜索用户
  Future<void> searchUsers(String keyword) async {
    try {
      searchKeyword.value = keyword;
      if (keyword.isEmpty) {
        await _loadUsers();
        return;
      }
      AppLogger.d('搜索用户，关键词: $keyword');
      final userList = await _userRepository.searchUsers(keyword);
      AppLogger.d('搜索用户结果: ${userList.length} 条');
      users.assignAll(userList);
    } catch (e) {
      AppLogger.e('搜索用户失败', error: e);
      showError('搜索用户失败：$e');
    }
  }

  /// 搜索产品
  Future<void> searchProducts(String keyword) async {
    try {
      searchKeyword.value = keyword;
      if (keyword.isEmpty) {
        await _loadProducts();
        return;
      }
      AppLogger.d('搜索产品，关键词: $keyword');
      final productList = await _productRepository.searchProducts(keyword);
      AppLogger.d('搜索产品结果: ${productList.length} 条');
      products.assignAll(productList);
    } catch (e) {
      AppLogger.e('搜索产品失败', error: e);
      showError('搜索产品失败：$e');
    }
  }

  /// 清除搜索
  void clearSearch() {
    searchKeyword.value = '';
    if (selectedTable.value == 'users') {
      _loadUsers();
    } else {
      _loadProducts();
    }
  }

  /// 更新用户
  Future<void> updateUser(UserTableModel user) async {
    try {
      isLoading.value = true;
      await _userRepository.updateUser(user);
      await _loadUsers();
      await _loadCounts();
      showSuccess('更新用户成功');
    } catch (e) {
      showError('更新用户失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 更新产品
  Future<void> updateProduct(ProductTableModel product) async {
    try {
      isLoading.value = true;
      await _productRepository.updateProduct(product);
      await _loadProducts();
      await _loadCounts();
      showSuccess('更新产品成功');
    } catch (e) {
      showError('更新产品失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 根据 ID 获取用户详情
  Future<UserTableModel?> getUserById(String id) async {
    try {
      return await _userRepository.getUserById(id);
    } catch (e) {
      showError('获取用户详情失败：$e');
      return null;
    }
  }

  /// 根据 ID 获取产品详情
  Future<ProductTableModel?> getProductById(String id) async {
    try {
      return await _productRepository.getProductById(id);
    } catch (e) {
      showError('获取产品详情失败：$e');
      return null;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await _loadData();
    showSuccess('刷新成功');
  }
}
