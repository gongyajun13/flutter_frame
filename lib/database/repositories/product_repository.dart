import '../database_helper.dart';
import '../models/product_table_model.dart';
import '../../utils/app_logger.dart';

/// 产品数据仓库
/// 提供产品数据的 CRUD 操作
class ProductRepository {
  static const String _tableName = 'products';

  /// 插入产品
  Future<String> insertProduct(ProductTableModel product) async {
    try {
      await DatabaseHelper.insert(_tableName, product.toMap());
      AppLogger.d('插入产品: ${product.id}');
      return product.id;
    } catch (e) {
      AppLogger.e('插入产品失败', error: e);
      rethrow;
    }
  }

  /// 批量插入产品
  Future<int> insertProducts(List<ProductTableModel> products) async {
    try {
      final maps = products.map((product) => product.toMap()).toList();
      return await DatabaseHelper.insertAll(_tableName, maps);
    } catch (e) {
      AppLogger.e('批量插入产品失败', error: e);
      rethrow;
    }
  }

  /// 根据 ID 获取产品
  Future<ProductTableModel?> getProductById(String id) async {
    try {
      final map = await DatabaseHelper.queryFirst(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return map != null ? ProductTableModel.fromMap(map) : null;
    } catch (e) {
      AppLogger.e('获取产品失败: $id', error: e);
      rethrow;
    }
  }

  /// 获取所有产品
  Future<List<ProductTableModel>> getAllProducts({
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final maps = await DatabaseHelper.query(
        _tableName,
        orderBy: orderBy ?? 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => ProductTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('获取所有产品失败', error: e);
      rethrow;
    }
  }

  /// 根据分类获取产品
  Future<List<ProductTableModel>> getProductsByCategory(
    String category, {
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final maps = await DatabaseHelper.query(
        _tableName,
        where: 'category = ?',
        whereArgs: [category],
        orderBy: orderBy ?? 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => ProductTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('根据分类获取产品失败: $category', error: e);
      rethrow;
    }
  }

  /// 获取活跃产品
  Future<List<ProductTableModel>> getActiveProducts({
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final maps = await DatabaseHelper.query(
        _tableName,
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: orderBy ?? 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => ProductTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('获取活跃产品失败', error: e);
      rethrow;
    }
  }

  /// 更新产品
  Future<int> updateProduct(ProductTableModel product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      return await DatabaseHelper.update(
        _tableName,
        updatedProduct.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      AppLogger.e('更新产品失败: ${product.id}', error: e);
      rethrow;
    }
  }

  /// 更新产品库存
  Future<int> updateProductStock(String id, int stock) async {
    try {
      return await DatabaseHelper.update(
        _tableName,
        {
          'stock': stock,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      AppLogger.e('更新产品库存失败: $id', error: e);
      rethrow;
    }
  }

  /// 删除产品
  Future<int> deleteProduct(String id) async {
    try {
      return await DatabaseHelper.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      AppLogger.e('删除产品失败: $id', error: e);
      rethrow;
    }
  }

  /// 删除所有产品
  Future<int> deleteAllProducts() async {
    try {
      return await DatabaseHelper.clearTable(_tableName);
    } catch (e) {
      AppLogger.e('删除所有产品失败', error: e);
      rethrow;
    }
  }

  /// 获取产品数量
  Future<int> getProductCount({String? category}) async {
    try {
      if (category != null) {
        return await DatabaseHelper.count(
          _tableName,
          where: 'category = ?',
          whereArgs: [category],
        );
      }
      return await DatabaseHelper.count(_tableName);
    } catch (e) {
      AppLogger.e('获取产品数量失败', error: e);
      rethrow;
    }
  }

  /// 搜索产品（根据名称、描述或分类）
  Future<List<ProductTableModel>> searchProducts(String keyword) async {
    try {
      AppLogger.d('搜索产品，关键词: $keyword');
      // 使用 COALESCE 处理 NULL 值，如果 description 为 NULL，则使用空字符串
      final maps = await DatabaseHelper.query(
        _tableName,
        where: 'name LIKE ? OR COALESCE(description, \'\') LIKE ? OR category LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
        orderBy: 'created_at DESC',
      );
      AppLogger.d('搜索产品，找到 ${maps.length} 条记录');
      return maps.map((map) => ProductTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('搜索产品失败: $keyword', error: e);
      rethrow;
    }
  }

  /// 获取价格范围的产品
  Future<List<ProductTableModel>> getProductsByPriceRange(
    double minPrice,
    double maxPrice, {
    String? orderBy,
  }) async {
    try {
      final maps = await DatabaseHelper.query(
        _tableName,
        where: 'price >= ? AND price <= ?',
        whereArgs: [minPrice, maxPrice],
        orderBy: orderBy ?? 'price ASC',
      );
      return maps.map((map) => ProductTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('根据价格范围获取产品失败', error: e);
      rethrow;
    }
  }
}
