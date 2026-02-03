import '../base/base_repository.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/product_model.dart';

/// 产品相关接口仓库（基于 HTTP API）
class ProductApiRepository extends BaseRepository {
  ProductApiRepository();

  /// 获取产品列表（分页）
  Future<PaginatedResponse<ProductModel>> fetchProducts({
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
  }) async {
    final path = ApiRoutes.getProducts;
    return getPaginated<ProductModel>(
      path: path,
      page: page,
      pageSize: pageSize,
      filters: filters,
      itemFromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取产品详情
  Future<ProductModel> fetchProductDetail(String id) async {
    final route = ApiRoutes.replacePathParams(ApiRoutes.getProductDetail, {'id': id});
    return getJson<ProductModel>(
      path: route,
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 创建产品
  Future<ProductModel> createProduct(CreateProductRequestModel req) async {
    final path = ApiRoutes.createProduct;
    return postJson<ProductModel>(
      path: path,
      data: req.toJson(),
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 更新产品
  Future<ProductModel> updateProduct(
    String id,
    UpdateProductRequestModel req,
  ) async {
    final route = ApiRoutes.replacePathParams(ApiRoutes.updateProduct, {'id': id});
    return putJson<ProductModel>(
      path: route,
      data: req.toJson(),
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 删除产品（返回是否成功）
  Future<bool> deleteProduct(String id) async {
    final route = ApiRoutes.replacePathParams(ApiRoutes.deleteProduct, {'id': id});
    // 某些接口 delete 返回空 body，这里用 Map 接收再判定
    await deleteJson<Map<String, dynamic>>(
      path: route,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return true;
  }
}

