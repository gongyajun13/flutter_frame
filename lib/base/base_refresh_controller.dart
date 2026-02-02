import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'base_controller.dart';

/// 支持下拉刷新和上拉加载的 Controller 基类
abstract class BaseRefreshController extends BaseController {
  /// 刷新控制器
  final RefreshController refreshController = RefreshController(
    initialRefreshStatus: RefreshStatus.idle,
  );

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  /// 刷新数据（子类需要实现）
  /// 刷新完成后需要调用 refreshController.refreshCompleted() 或 refreshController.refreshFailed()
  Future<void> onRefresh() async {
    try {
      await loadData();
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
      showError('刷新失败：$e');
    }
  }

  /// 加载更多数据（子类需要实现）
  /// 加载完成后需要调用 refreshController.loadComplete() 或 refreshController.loadNoData()
  Future<void> onLoadMore() async {
    try {
      final hasMore = await loadMoreData();
      if (hasMore) {
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    } catch (e) {
      refreshController.loadFailed();
      showError('加载失败：$e');
    }
  }

  /// 加载数据（子类可重写，用于刷新时调用）
  Future<void> loadData() async {
    // 子类实现具体的数据加载逻辑
  }

  /// 加载更多数据（子类可重写，用于加载更多时调用）
  /// 返回是否还有更多数据
  Future<bool> loadMoreData() async {
    // 子类实现具体的加载更多逻辑
    return false;
  }

  /// 重置刷新状态（在刷新数据时调用，重置加载更多状态）
  void resetRefreshState() {
    refreshController.resetNoData();
  }
}
