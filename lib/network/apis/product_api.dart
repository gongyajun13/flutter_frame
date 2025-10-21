import '../base/base_network_request.dart';
import '../models/product_model.dart';
import '../models/api_response.dart';

/// 获取产品列表API（分页）
class GetProductsApi extends BasePaginatedRequest<ProductModel> {
  final int _page;
  final int _pageSize;
  final Map<String, dynamic>? _filters;
  final bool _showLoading;
  final bool _showError;

  GetProductsApi({
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
    bool showLoading = true,
    bool showError = true,
  }) : _page = page,
       _pageSize = pageSize,
       _filters = filters,
       _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/products';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  int get page => _page;

  @override
  int get pageSize => _pageSize;

  @override
  Map<String, dynamic>? get filters => _filters;

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '获取产品列表中...';

  @override
  String? get successText => null; // 不显示成功提示

  @override
  ProductModel Function(dynamic) get itemFromJson => (item) {
        return ProductModel.fromJson(item);
      };

  @override
  void onSuccess(PaginatedResponse<ProductModel> data) {
    print('获取产品列表成功: 共${data.total}个产品，当前页${data.page}');
  }

  @override
  void onError(String message, int code) {
    print('获取产品列表失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('获取产品列表异常: $error');
  }
}

/// 获取产品详情API
class GetProductDetailApi extends BaseNetworkRequest<ProductModel> {
  final String productId;
  final bool _showLoading;
  final bool _showError;

  GetProductDetailApi({
    required this.productId,
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/products/$productId';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '获取产品详情中...';

  @override
  String? get successText => null; // 不显示成功提示

  @override
  ProductModel Function(dynamic)? get fromJson => (data) {
        return ProductModel.fromJson(data);
      };

  @override
  void onSuccess(ProductModel data) {
    print('获取产品详情成功: ${data.name}');
  }

  @override
  void onError(String message, int code) {
    print('获取产品详情失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('获取产品详情异常: $error');
  }
}

/// 创建产品API
class CreateProductApi extends BaseNetworkRequest<ProductModel> {
  final CreateProductRequestModel productData;
  final bool _showLoading;
  final bool _showError;

  CreateProductApi({
    required this.productData,
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/products';

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  dynamic get data => productData.toJson();

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '创建产品中...';

  @override
  String? get successText => '产品创建成功';

  @override
  ProductModel Function(dynamic)? get fromJson => (data) {
        return ProductModel.fromJson(data);
      };

  @override
  void onSuccess(ProductModel data) {
    print('创建产品成功: ${data.name}');
  }

  @override
  void onError(String message, int code) {
    print('创建产品失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('创建产品异常: $error');
  }
}

/// 更新产品API
class UpdateProductApi extends BaseNetworkRequest<ProductModel> {
  final String productId;
  final UpdateProductRequestModel productData;
  final bool _showLoading;
  final bool _showError;

  UpdateProductApi({
    required this.productId,
    required this.productData,
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/products/$productId';

  @override
  HttpMethod get method => HttpMethod.put;

  @override
  dynamic get data => productData.toJson();

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '更新产品中...';

  @override
  String? get successText => '产品更新成功';

  @override
  ProductModel Function(dynamic)? get fromJson => (data) {
        return ProductModel.fromJson(data);
      };

  @override
  void onSuccess(ProductModel data) {
    print('更新产品成功: ${data.name}');
  }

  @override
  void onError(String message, int code) {
    print('更新产品失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('更新产品异常: $error');
  }
}

/// 删除产品API
class DeleteProductApi extends BaseNetworkRequest<void> {
  final String productId;
  final bool _showLoading;
  final bool _showError;

  DeleteProductApi({
    required this.productId,
    bool showLoading = true,
    bool showError = true,
  }) : _showLoading = showLoading,
       _showError = showError;

  @override
  String get url => '/products/$productId';

  @override
  HttpMethod get method => HttpMethod.delete;

  @override
  bool get showLoading => _showLoading;

  @override
  bool get showError => _showError;

  @override
  String get loadingText => '删除产品中...';

  @override
  String? get successText => '产品删除成功';

  @override
  void Function(dynamic)? get fromJson => null; // 删除操作通常不返回数据

  @override
  void onSuccess(void data) {
    print('删除产品成功: $productId');
  }

  @override
  void onError(String message, int code) {
    print('删除产品失败: $message (代码: $code)');
  }

  @override
  void onException(dynamic error) {
    print('删除产品异常: $error');
  }
}
