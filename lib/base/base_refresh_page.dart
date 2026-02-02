import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../theme/app_design_tokens.dart';
import 'base_page.dart';
import 'base_refresh_controller.dart';

/// 支持下拉刷新和上拉加载的页面基类
abstract class BaseRefreshPage<T extends BaseRefreshController> extends BasePage<T> {
  const BaseRefreshPage({super.key});

  /// 是否启用下拉刷新（默认 true）
  bool get enablePullDown => true;

  /// 是否启用上拉加载（默认 true）
  bool get enablePullUp => true;

  /// 刷新头部组件（默认使用 WaterDropHeader）
  Widget? buildRefreshHeader(BuildContext context) {
    return WaterDropHeader(
      complete: Text(
        '刷新完成',
        style: TextStyle(
          fontSize: AppDesignTokens.fontSize14,
          color: AppDesignTokens.textSecondary,
        ),
      ),
    );
  }

  /// 加载更多底部组件（默认使用 ClassicFooter）
  Widget? buildLoadMoreFooter(BuildContext context) {
    return ClassicFooter();
  }

  /// 构建可滚动内容（子类需要实现）
  /// 返回需要包裹在 SmartRefresher 中的滚动组件
  Widget buildRefreshContent(BuildContext context);

  /// 构建空数据状态（可选，子类可重写）
  Widget? buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: AppDesignTokens.iconSizeXLarge,
            color: AppDesignTokens.textDisabled,
          ),
          SizedBox(height: AppDesignTokens.spacingV16),
          Text(
            '暂无数据，下拉刷新',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 是否显示空数据状态（默认当数据为空时显示）
  bool shouldShowEmptyWidget(BuildContext context) {
    return false; // 子类可重写，根据实际数据判断
  }

  @override
  Widget buildContent(BuildContext context) {
    // 如果显示空数据状态，直接返回空状态组件
    if (shouldShowEmptyWidget(context)) {
      final emptyWidget = buildEmptyWidget(context);
      if (emptyWidget != null) {
        return SmartRefresher(
          controller: controller.refreshController,
          enablePullDown: enablePullDown,
          enablePullUp: false, // 空数据时不启用上拉加载
          onRefresh: controller.onRefresh,
          header: buildRefreshHeader(context),
          child: ListView(
            padding: EdgeInsets.all(AppDesignTokens.spacing16),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: emptyWidget,
              ),
            ],
          ),
        );
      }
    }

    // 正常显示刷新内容
    return SmartRefresher(
      controller: controller.refreshController,
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      onRefresh: controller.onRefresh,
      onLoading: controller.onLoadMore,
      header: buildRefreshHeader(context),
      footer: buildLoadMoreFooter(context),
      child: buildRefreshContent(context),
    );
  }
}

/// 支持下拉刷新和上拉加载的列表页面基类
abstract class BaseRefreshListPage<T extends BaseRefreshController, I> extends BaseRefreshPage<T> {
  const BaseRefreshListPage({super.key});

  /// 列表数据（子类需要实现）
  List<I> get items;

  /// 构建列表项（子类需要实现）
  Widget buildListItem(BuildContext context, I item, int index);

  /// 列表内边距
  EdgeInsets get listPadding => EdgeInsets.all(AppDesignTokens.spacing16);

  /// 列表项间距
  double get itemSpacing => AppDesignTokens.spacingV12;

  @override
  bool shouldShowEmptyWidget(BuildContext context) {
    return items.isEmpty;
  }

  @override
  Widget buildRefreshContent(BuildContext context) {
    return ListView.separated(
      padding: listPadding,
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        return buildListItem(context, items[index], index);
      },
    );
  }
}

/// 支持下拉刷新和上拉加载的网格页面基类
abstract class BaseRefreshGridPage<T extends BaseRefreshController, I> extends BaseRefreshPage<T> {
  const BaseRefreshGridPage({super.key});

  /// 列表数据（子类需要实现）
  List<I> get items;

  /// 构建网格项（子类需要实现）
  Widget buildGridItem(BuildContext context, I item, int index);

  /// 网格列数（默认 2）
  int get crossAxisCount => 2;

  /// 网格横向间距
  double get crossAxisSpacing => AppDesignTokens.spacing12;

  /// 网格纵向间距
  double get mainAxisSpacing => AppDesignTokens.spacing12;

  /// 网格项宽高比（默认 0.75）
  double get childAspectRatio => 0.75;

  /// 网格内边距
  EdgeInsets get gridPadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  bool shouldShowEmptyWidget(BuildContext context) {
    return items.isEmpty;
  }

  @override
  Widget buildRefreshContent(BuildContext context) {
    return GridView.builder(
      padding: gridPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return buildGridItem(context, items[index], index);
      },
    );
  }
}
