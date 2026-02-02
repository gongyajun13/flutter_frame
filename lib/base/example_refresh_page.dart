import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../theme/app_design_tokens.dart';
import 'base_refresh_controller.dart';
import 'base_refresh_page.dart';

/// 示例：使用 BaseRefreshController 和 BaseRefreshListPage
/// 
/// 这是一个完整的使用示例，展示如何使用刷新加载基类

// ==================== Controller 示例 ====================

class ExampleListController extends BaseRefreshController {
  final RxList<String> items = <String>[].obs;
  int _currentPage = 1;
  static const int _maxPage = 5;

  @override
  void onInit() {
    super.onInit();
    // 初始加载数据
    loadData();
  }

  @override
  Future<void> loadData() async {
    _currentPage = 1;
    // 模拟网络请求
    await Future.delayed(const Duration(milliseconds: 500));
    items.assignAll(_generatePageData(_currentPage));
    resetRefreshState(); // 重置加载更多状态
  }

  @override
  Future<bool> loadMoreData() async {
    _currentPage++;
    // 模拟网络请求
    await Future.delayed(const Duration(milliseconds: 500));
    final newItems = _generatePageData(_currentPage);
    items.addAll(newItems);
    
    // 返回是否还有更多数据
    return _currentPage < _maxPage;
  }

  List<String> _generatePageData(int page) {
    return List.generate(10, (index) => 'Item ${(page - 1) * 10 + index + 1}');
  }
}

// ==================== Page 示例 ====================

class ExampleListPage extends BaseRefreshListPage<ExampleListController, String> {
  const ExampleListPage({super.key});

  @override
  String? get pageTitle => '刷新列表示例';

  @override
  List<String> get items => controller.items;

  @override
  Widget buildListItem(BuildContext context, String item, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${index + 1}'),
      ),
      title: Text(item),
      subtitle: Text('这是 $item 的描述信息'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  // 可选：自定义空数据状态
  @override
  Widget? buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppDesignTokens.textDisabled,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV8),
          ElevatedButton(
            onPressed: () => controller.onRefresh(),
            child: Text('点击刷新'),
          ),
        ],
      ),
    );
  }
}

// ==================== 网格布局示例 ====================

class ExampleGridController extends BaseRefreshController {
  final RxList<String> items = <String>[].obs;
  int _currentPage = 1;
  static const int _maxPage = 5;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  Future<void> loadData() async {
    _currentPage = 1;
    await Future.delayed(const Duration(milliseconds: 500));
    items.assignAll(_generatePageData(_currentPage));
    resetRefreshState();
  }

  @override
  Future<bool> loadMoreData() async {
    _currentPage++;
    await Future.delayed(const Duration(milliseconds: 500));
    items.addAll(_generatePageData(_currentPage));
    return _currentPage < _maxPage;
  }

  List<String> _generatePageData(int page) {
    return List.generate(12, (index) => 'Item ${(page - 1) * 12 + index + 1}');
  }
}

class ExampleGridPage extends BaseRefreshGridPage<ExampleGridController, String> {
  const ExampleGridPage({super.key});

  @override
  String? get pageTitle => '刷新网格示例';

  @override
  List<String> get items => controller.items;

  @override
  int get crossAxisCount => 2;

  @override
  double get childAspectRatio => 0.8;

  @override
  Widget buildGridItem(BuildContext context, String item, int index) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48),
            SizedBox(height: 8),
            Text(item),
          ],
        ),
      ),
    );
  }
}

// ==================== 自定义刷新头部和底部示例 ====================

class CustomRefreshPage extends BaseRefreshListPage<ExampleListController, String> {
  const CustomRefreshPage({super.key});

  @override
  String? get pageTitle => '自定义刷新样式';

  @override
  List<String> get items => controller.items;

  @override
  Widget buildListItem(BuildContext context, String item, int index) {
    return ListTile(title: Text(item));
  }

  // 自定义刷新头部
  @override
  Widget? buildRefreshHeader(BuildContext context) {
    return ClassicHeader(
      refreshingText: '正在刷新...',
      completeText: '刷新完成',
      idleText: '下拉刷新',
      releaseText: '松开刷新',
    );
  }

  // 自定义加载更多底部
  @override
  Widget? buildLoadMoreFooter(BuildContext context) {
    return ClassicFooter(
      loadingText: '正在加载...',
      noDataText: '没有更多数据了',
      idleText: '上拉加载更多',
      canLoadingText: '松开加载更多',
    );
  }

  // 禁用上拉加载
  @override
  bool get enablePullUp => false;
}
