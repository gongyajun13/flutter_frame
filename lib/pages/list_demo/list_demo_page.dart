import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import 'list_demo_controller.dart';
import 'models/list_item_model.dart';

/// 数据列表演示页面
class ListDemoPage extends BasePage<ListDemoController> {
  const ListDemoPage({super.key});

  @override
  String? get pageTitle => '数据列表演示';

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // 布局切换工具栏
        _buildLayoutToolbar(),
        // 列表内容
        Expanded(
          child: Obx(() => _buildListContent()),
        ),
      ],
    );
  }

  /// 构建布局切换工具栏
  Widget _buildLayoutToolbar() {
    return Container(
      margin: EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
        boxShadow: AppDesignTokens.shadowSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 布局切换按钮
          Padding(
            padding: EdgeInsets.all(AppDesignTokens.spacing12),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildLayoutButton(
                    ListLayoutType.linear,
                    Icons.view_list,
                    '线性',
                    controller.layoutType.value == ListLayoutType.linear,
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                Expanded(
                  child: _buildLayoutButton(
                    ListLayoutType.grid,
                    Icons.grid_view,
                    '网格',
                    controller.layoutType.value == ListLayoutType.grid,
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacing8),
                Expanded(
                  child: _buildLayoutButton(
                    ListLayoutType.waterfall,
                    Icons.view_column,
                    '瀑布流',
                    controller.layoutType.value == ListLayoutType.waterfall,
                  ),
                ),
              ],
            )),
          ),
          // 网格列数选择（仅在网格布局时显示）
          Obx(() {
            if (controller.layoutType.value == ListLayoutType.grid) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacing12,
                  vertical: AppDesignTokens.spacingV8,
                ),
                decoration: BoxDecoration(
                  color: AppDesignTokens.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppDesignTokens.radius12),
                    bottomRight: Radius.circular(AppDesignTokens.radius12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_on,
                      size: 18,
                      color: AppDesignTokens.primaryColor,
                    ),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Text(
                      '列数',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize14,
                        color: AppDesignTokens.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppDesignTokens.spacing12),
                    _buildColumnCountButton(
                      icon: Icons.remove_circle_outline,
                      onPressed: controller.gridCrossAxisCount.value > 1
                          ? () => controller.setGridCrossAxisCount(
                              controller.gridCrossAxisCount.value - 1)
                          : null,
                    ),
                    Container(
                      width: 40,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing8,
                        vertical: AppDesignTokens.spacingV4,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.primaryColor,
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                      ),
                      child: Text(
                        '${controller.gridCrossAxisCount.value}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize16,
                          fontWeight: AppDesignTokens.fontWeightBold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildColumnCountButton(
                      icon: Icons.add_circle_outline,
                      onPressed: controller.gridCrossAxisCount.value < 4
                          ? () => controller.setGridCrossAxisCount(
                              controller.gridCrossAxisCount.value + 1)
                          : null,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// 构建布局切换按钮
  Widget _buildLayoutButton(
    ListLayoutType type,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.switchLayout(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing8,
          vertical: AppDesignTokens.spacingV8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignTokens.primaryColor
              : AppDesignTokens.grey100,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppDesignTokens.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : AppDesignTokens.textSecondary,
            ),
            SizedBox(width: AppDesignTokens.spacing4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize13,
                fontWeight: isSelected
                    ? AppDesignTokens.fontWeightSemiBold
                    : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : AppDesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建列数调整按钮
  Widget _buildColumnCountButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
        child: Container(
          padding: EdgeInsets.all(AppDesignTokens.spacing4),
          child: Icon(
            icon,
            size: 24,
            color: onPressed != null
                ? AppDesignTokens.primaryColor
                : AppDesignTokens.textDisabled,
          ),
        ),
      ),
    );
  }

  /// 构建列表内容
  Widget _buildListContent() {
    if (controller.items.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
      );
    }

    switch (controller.layoutType.value) {
      case ListLayoutType.linear:
        return _buildLinearLayout();
      case ListLayoutType.grid:
        return _buildGridLayout();
      case ListLayoutType.waterfall:
        return _buildWaterfallLayout();
    }
  }

  /// 构建线性布局
  Widget _buildLinearLayout() {
    return Obx(() {
      return SmartRefresher(
        controller: controller.linearRefreshController,
        enablePullDown: true,
        enablePullUp: true, // 始终启用上拉加载，由 RefreshController 控制是否显示
        onRefresh: controller.onLinearRefresh,
        onLoading: controller.onLinearLoadMore,
        header: WaterDropHeader(
          complete: Text(
            '刷新完成',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        ),
        footer: ClassicFooter(),
        child: controller.items.isEmpty
            ? ListView(
                padding: EdgeInsets.all(AppDesignTokens.spacing16),
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        '暂无数据，下拉刷新',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize14,
                          color: AppDesignTokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: EdgeInsets.all(AppDesignTokens.spacing16),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppDesignTokens.spacingV12),
                    child: _buildLinearItem(controller.items[index]),
                  );
                },
              ),
      );
    });
  }

  /// 构建网格布局
  Widget _buildGridLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          // 根据列数动态计算 childAspectRatio
          final crossAxisCount = controller.gridCrossAxisCount.value;
          
          // 根据列数调整宽高比：列数越多，item 越窄，需要更小的宽高比
          // 增加高度比例，给文字内容更多空间
          double childAspectRatio;
          if (crossAxisCount == 1) {
            childAspectRatio = 0.75;
          } else if (crossAxisCount == 2) {
            childAspectRatio = 0.65;
          } else if (crossAxisCount == 3) {
            childAspectRatio = 0.6;
          } else {
            childAspectRatio = 0.55;
          }
          
          return SmartRefresher(
            controller: controller.gridRefreshController,
            enablePullDown: true,
            enablePullUp: true, // 始终启用上拉加载，由 RefreshController 控制是否显示
            onRefresh: controller.onGridRefresh,
            onLoading: controller.onGridLoadMore,
            header: WaterDropHeader(
              complete: Text(
                '刷新完成',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize14,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
            ),
            footer: ClassicFooter(),
            child: controller.items.isEmpty
                ? ListView(
                    padding: EdgeInsets.all(AppDesignTokens.spacing16),
                    children: [
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: Text(
                            '暂无数据，下拉刷新',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize14,
                              color: AppDesignTokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildGridViewWithLoadMore(crossAxisCount, childAspectRatio),
          );
        });
      },
    );
  }

  /// 构建带加载更多的网格布局
  Widget _buildGridViewWithLoadMore(int crossAxisCount, double childAspectRatio) {
    return GridView.builder(
      padding: EdgeInsets.all(AppDesignTokens.spacing16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDesignTokens.spacing12,
        mainAxisSpacing: AppDesignTokens.spacing12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        return _buildGridItem(controller.items[index], crossAxisCount);
      },
    );
  }

  /// 构建瀑布流布局
  Widget _buildWaterfallLayout() {
    return Obx(() {
      return SmartRefresher(
        controller: controller.waterfallRefreshController,
        enablePullDown: true,
        enablePullUp: true, // 始终启用上拉加载，由 RefreshController 控制是否显示
        onRefresh: controller.onWaterfallRefresh,
        onLoading: controller.onWaterfallLoadMore,
        header: WaterDropHeader(
          complete: Text(
            '刷新完成',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
        ),
        footer: ClassicFooter(),
        child: controller.items.isEmpty
            ? ListView(
                padding: EdgeInsets.all(AppDesignTokens.spacing16),
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        '暂无数据，下拉刷新',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize14,
                          color: AppDesignTokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(AppDesignTokens.spacing16),
                    sliver: _buildWaterfallSliver(),
                  ),
                ],
              ),
      );
    });
  }

  /// 构建瀑布流 Sliver
  Widget _buildWaterfallSliver() {
    // 简单的瀑布流实现：两列布局，根据高度分配
    return Obx(() {
      final items = controller.items;
      final leftColumn = <ListItemModel>[];
      final rightColumn = <ListItemModel>[];
      double leftHeight = 0;
      double rightHeight = 0;

      // 根据高度分配项目到左右两列
      for (var item in items) {
        if (leftHeight <= rightHeight) {
          leftColumn.add(item);
          leftHeight += item.height.toDouble();
        } else {
          rightColumn.add(item);
          rightHeight += item.height.toDouble();
        }
      }

      return SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: leftColumn
                    .map((item) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppDesignTokens.spacingV12,
                          ),
                          child: _buildWaterfallItem(item),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(width: AppDesignTokens.spacing12),
            Expanded(
              child: Column(
                children: rightColumn
                    .map((item) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppDesignTokens.spacingV12,
                          ),
                          child: _buildWaterfallItem(item),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建线性布局项
  Widget _buildLinearItem(ListItemModel item) {
    return AppCard(
      showShadow: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 120,
                height: 120,
                color: AppDesignTokens.grey300,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppDesignTokens.primaryColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 120,
                height: 120,
                color: AppDesignTokens.grey300,
                child: Icon(
                  Icons.error_outline,
                  color: AppDesignTokens.textDisabled,
                ),
              ),
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          // 文字信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize16,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    color: AppDesignTokens.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDesignTokens.spacingV8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDesignTokens.spacing8,
                        vertical: AppDesignTokens.spacingV4,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize12,
                          color: AppDesignTokens.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建网格布局项
  Widget _buildGridItem(ListItemModel item, int crossAxisCount) {
    // 根据列数调整字体大小和间距
    final titleFontSize = crossAxisCount >= 3 
        ? AppDesignTokens.fontSize12 
        : AppDesignTokens.fontSize14;
    final descFontSize = crossAxisCount >= 3 
        ? AppDesignTokens.fontSize10 
        : AppDesignTokens.fontSize12;
    final padding = crossAxisCount >= 3 
        ? AppDesignTokens.spacing4 
        : AppDesignTokens.spacing8;
    
    return AppCard(
      showShadow: true,
      padding: EdgeInsets.zero, // 移除默认 padding，手动控制
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图片（使用 AspectRatio 保持比例，但根据列数调整比例）
          AspectRatio(
            aspectRatio: crossAxisCount >= 3 ? 1.1 : 1.0, // 列数多时稍微高一点
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDesignTokens.radius8),
                topRight: Radius.circular(AppDesignTokens.radius8),
              ),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppDesignTokens.grey300,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppDesignTokens.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppDesignTokens.grey300,
                  child: Icon(
                    Icons.error_outline,
                    color: AppDesignTokens.textDisabled,
                    size: crossAxisCount >= 3 ? 20 : 24,
                  ),
                ),
              ),
            ),
          ),
          // 文字信息（减少内边距，紧凑布局）
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: crossAxisCount >= 3 ? AppDesignTokens.spacingV4 : padding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // 描述（根据列数决定是否显示）
                if (crossAxisCount <= 2) ...[
                  SizedBox(height: AppDesignTokens.spacingV4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: descFontSize,
                      color: AppDesignTokens.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // 分类标签（根据列数决定是否显示）
                if (crossAxisCount <= 3) ...[
                  SizedBox(height: AppDesignTokens.spacingV4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: crossAxisCount >= 3 
                          ? AppDesignTokens.spacing4 
                          : AppDesignTokens.spacing8,
                      vertical: crossAxisCount >= 3 
                          ? AppDesignTokens.spacingV4 
                          : AppDesignTokens.spacingV4,
                    ),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize10,
                        color: AppDesignTokens.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建瀑布流布局项
  Widget _buildWaterfallItem(ListItemModel item) {
    return AppCard(
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片（使用固定高度比例）
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDesignTokens.radius8),
              topRight: Radius.circular(AppDesignTokens.radius8),
            ),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: double.infinity,
              height: item.height.toDouble(),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: item.height.toDouble(),
                color: AppDesignTokens.grey300,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppDesignTokens.primaryColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: item.height.toDouble(),
                color: AppDesignTokens.grey300,
                child: Icon(
                  Icons.error_outline,
                  color: AppDesignTokens.textDisabled,
                ),
              ),
            ),
          ),
          // 文字信息
          Padding(
            padding: EdgeInsets.all(AppDesignTokens.spacing8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize12,
                    color: AppDesignTokens.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing8,
                    vertical: AppDesignTokens.spacingV4,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize10,
                      color: AppDesignTokens.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
