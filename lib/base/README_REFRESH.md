# 刷新加载基类使用指南

## 概述

`BaseRefreshController` 和 `BaseRefreshPage` 提供了统一的下拉刷新和上拉加载功能，基于 `pull_to_refresh` 插件实现。

## 基类说明

### BaseRefreshController

支持刷新和加载更多的 Controller 基类，继承自 `BaseController`。

**主要功能：**
- 自动管理 `RefreshController` 生命周期
- 提供 `onRefresh()` 和 `onLoadMore()` 模板方法
- 子类只需实现 `loadData()` 和 `loadMoreData()` 方法

**使用示例：**

```dart
class MyListController extends BaseRefreshController {
  final RxList<Item> items = <Item>[].obs;
  int _currentPage = 1;
  static const int _maxPage = 10;

  @override
  Future<void> loadData() async {
    _currentPage = 1;
    // 加载第一页数据
    final data = await api.getList(page: _currentPage);
    items.assignAll(data);
    resetRefreshState(); // 重置加载更多状态
  }

  @override
  Future<bool> loadMoreData() async {
    _currentPage++;
    // 加载更多数据
    final data = await api.getList(page: _currentPage);
    items.addAll(data);
    
    // 返回是否还有更多数据
    return _currentPage < _maxPage;
  }
}
```

### BaseRefreshPage

支持下拉刷新和上拉加载的页面基类。

**可配置选项：**
- `enablePullDown`: 是否启用下拉刷新（默认 true）
- `enablePullUp`: 是否启用上拉加载（默认 true）
- `buildRefreshHeader()`: 自定义刷新头部（默认 WaterDropHeader）
- `buildLoadMoreFooter()`: 自定义加载更多底部（默认 ClassicFooter）
- `buildEmptyWidget()`: 自定义空数据状态
- `shouldShowEmptyWidget()`: 判断是否显示空数据状态

**使用示例：**

```dart
class MyListPage extends BaseRefreshListPage<MyListController, Item> {
  const MyListPage({super.key});

  @override
  String? get pageTitle => '我的列表';

  @override
  List<Item> get items => controller.items;

  @override
  Widget buildListItem(BuildContext context, Item item, int index) {
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item.description),
    );
  }

  // 可选：自定义刷新头部
  @override
  Widget? buildRefreshHeader(BuildContext context) {
    return ClassicHeader();
  }

  // 可选：自定义加载更多底部
  @override
  Widget? buildLoadMoreFooter(BuildContext context) {
    return ClassicFooter();
  }
}
```

### BaseRefreshListPage

专门用于列表的刷新页面基类，继承自 `BaseRefreshPage`。

**额外配置：**
- `listPadding`: 列表内边距
- `itemSpacing`: 列表项间距

### BaseRefreshGridPage

专门用于网格的刷新页面基类，继承自 `BaseRefreshPage`。

**额外配置：**
- `crossAxisCount`: 网格列数
- `crossAxisSpacing`: 横向间距
- `mainAxisSpacing`: 纵向间距
- `childAspectRatio`: 宽高比
- `gridPadding`: 网格内边距

## 完整示例

### Controller

```dart
class ProductListController extends BaseRefreshController {
  final RxList<Product> products = <Product>[].obs;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  Future<void> loadData() async {
    _page = 1;
    final result = await ProductService.getProducts(
      page: _page,
      pageSize: _pageSize,
    );
    products.assignAll(result.items);
    resetRefreshState();
  }

  @override
  Future<bool> loadMoreData() async {
    _page++;
    final result = await ProductService.getProducts(
      page: _page,
      pageSize: _pageSize,
    );
    products.addAll(result.items);
    return result.hasMore;
  }
}
```

### Page

```dart
class ProductListPage extends BaseRefreshListPage<ProductListController, Product> {
  const ProductListPage({super.key});

  @override
  String? get pageTitle => '商品列表';

  @override
  List<Product> get items => controller.products;

  @override
  Widget buildListItem(BuildContext context, Product product, int index) {
    return ProductCard(product: product);
  }

  // 可选：禁用上拉加载
  @override
  bool get enablePullUp => false;
}
```

## 高级用法

### 自定义刷新头部和底部

```dart
@override
Widget? buildRefreshHeader(BuildContext context) {
  return WaterDropHeader(
    complete: Text('刷新完成'),
  );
}

@override
Widget? buildLoadMoreFooter(BuildContext context) {
  return ClassicFooter(
    // 自定义文本
  );
}
```

### 自定义空数据状态

```dart
@override
Widget? buildEmptyWidget(BuildContext context) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.inbox, size: 64),
        SizedBox(height: 16),
        Text('暂无数据'),
        ElevatedButton(
          onPressed: () => controller.onRefresh(),
          child: Text('点击刷新'),
        ),
      ],
    ),
  );
}
```

### 条件控制刷新和加载

```dart
class MyPage extends BaseRefreshListPage<MyController, Item> {
  @override
  bool get enablePullDown => controller.canRefresh;
  
  @override
  bool get enablePullUp => controller.hasMore;
}
```

## 注意事项

1. Controller 必须继承 `BaseRefreshController`
2. 刷新完成后必须调用 `refreshController.refreshCompleted()` 或 `refreshController.refreshFailed()`
3. 加载更多完成后必须调用 `refreshController.loadComplete()` 或 `refreshController.loadNoData()`
4. 刷新数据时建议调用 `resetRefreshState()` 重置加载更多状态
5. `loadMoreData()` 方法需要返回 `bool` 值，表示是否还有更多数据
