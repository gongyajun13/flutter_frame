import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../base/base_controller.dart';
import 'models/list_item_model.dart';

/// 列表布局类型
enum ListLayoutType {
  linear, // 线性布局
  grid, // 网格布局
  waterfall, // 瀑布流布局
}

/// 数据列表演示控制器
class ListDemoController extends BaseController {
  /// 列表数据
  final RxList<ListItemModel> items = <ListItemModel>[].obs;

  /// 当前布局类型
  final Rx<ListLayoutType> layoutType = ListLayoutType.linear.obs;

  /// 网格列数
  final RxInt gridCrossAxisCount = 2.obs;

  /// 当前页码
  int _currentPage = 1;

  /// 最大页数（模拟数据加载完毕）
  static const int _maxPage = 5;

  /// 线性布局刷新控制器
  final RefreshController linearRefreshController = RefreshController(initialRefreshStatus: RefreshStatus.idle);

  /// 网格布局刷新控制器
  final RefreshController gridRefreshController = RefreshController(initialRefreshStatus: RefreshStatus.idle);

  /// 瀑布流布局刷新控制器
  final RefreshController waterfallRefreshController = RefreshController(initialRefreshStatus: RefreshStatus.idle);

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onClose() {
    linearRefreshController.dispose();
    gridRefreshController.dispose();
    waterfallRefreshController.dispose();
    super.onClose();
  }

  /// 加载数据
  void _loadData() {
    _currentPage = 1;
    items.assignAll(ListItemModel.generateSampleData());
    // 重置所有刷新控制器的状态
    linearRefreshController.resetNoData();
    gridRefreshController.resetNoData();
    waterfallRefreshController.resetNoData();
  }

  /// 检查是否还有更多数据
  bool get hasMore => _currentPage < _maxPage;

  /// 切换布局类型
  void switchLayout(ListLayoutType type) {
    layoutType.value = type;
  }

  /// 设置网格列数
  void setGridCrossAxisCount(int count) {
    gridCrossAxisCount.value = count;
  }

  /// 刷新数据（统一方法）
  Future<void> _onRefresh(RefreshController refreshController) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _loadData();
      refreshController.refreshCompleted();
      showSuccess('刷新成功，共 ${items.length} 条数据');
    } catch (e) {
      refreshController.refreshFailed();
      showError('刷新失败：$e');
    }
  }

  /// 加载更多数据（统一方法）
  Future<void> _onLoadMore(RefreshController refreshController) async {
    if (!hasMore) {
      refreshController.loadNoData();
      return;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _currentPage++;
      final moreItems = ListItemModel.generateSampleData();
      items.addAll(moreItems);
      
      if (_currentPage >= _maxPage) {
        refreshController.loadNoData();
        showInfo('已加载全部数据');
      } else {
        refreshController.loadComplete();
        showInfo('已加载 ${moreItems.length} 条数据，共 ${items.length} 条');
      }
    } catch (e) {
      refreshController.loadFailed();
      showError('加载失败：$e');
    }
  }

  /// 刷新数据（用于线性布局）
  Future<void> onLinearRefresh() => _onRefresh(linearRefreshController);

  /// 加载更多数据（用于线性布局）
  Future<void> onLinearLoadMore() => _onLoadMore(linearRefreshController);

  /// 刷新数据（用于网格布局）
  Future<void> onGridRefresh() => _onRefresh(gridRefreshController);

  /// 加载更多数据（用于网格布局）
  Future<void> onGridLoadMore() => _onLoadMore(gridRefreshController);

  /// 刷新数据（用于瀑布流布局）
  Future<void> onWaterfallRefresh() => _onRefresh(waterfallRefreshController);

  /// 加载更多数据（用于瀑布流布局）
  Future<void> onWaterfallLoadMore() => _onLoadMore(waterfallRefreshController);
}
