import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_refresh_controller.dart';

/// 主分类 Tab 项
class CategoryTab {
  final String id;
  final String name;
  final IconData icon;

  const CategoryTab({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// 多分类数据视图控制器
class MultiCategoryViewController extends BaseRefreshController {
  /// 当前选中的 Tab 索引，用于下拉刷新时确定刷新哪一个
  final RxInt currentTabIndex = 0.obs;
  /// 已经加载过数据的 Tab id 集合，用于控制懒加载
  final RxSet<String> loadedTabIds = <String>{}.obs;

  /// 主分类列表（顶部 Tab，可多个，顶部可横向滑动）
  /// 使用 RxList 支持动态增删 Tab
  final RxList<CategoryTab> categoryTabs = <CategoryTab>[
    const CategoryTab(id: 'all', name: '全部', icon: Icons.apps),
    const CategoryTab(id: 'recommend', name: '推荐', icon: Icons.star),
    const CategoryTab(id: 'hot', name: '热门', icon: Icons.whatshot),
    const CategoryTab(id: 'latest', name: '最新', icon: Icons.schedule),
    const CategoryTab(id: 'focus', name: '关注', icon: Icons.favorite),
    const CategoryTab(id: 'video', name: '视频', icon: Icons.video_library),
    const CategoryTab(id: 'article', name: '文章', icon: Icons.article),
  ].obs;

  /// 动态添加一个主分类 Tab
  void addCategoryTab(CategoryTab tab) {
    categoryTabs.add(tab);
  }

  /// 通过 id 删除一个主分类 Tab
  void removeCategoryTabById(String id) {
    final index = categoryTabs.indexWhere((e) => e.id == id);
    if (index != -1) {
      categoryTabs.removeAt(index);
    }
  }

  /// 通过索引删除一个主分类 Tab
  void removeCategoryTabAt(int index) {
    if (index >= 0 && index < categoryTabs.length) {
      final removed = categoryTabs.removeAt(index);
      loadedTabIds.remove(removed.id);
    }
  }

  /// 当某个 Tab 第一次变为可见时调用，只在「未加载过」时触发加载
  Future<void> onTabVisible(int index) async {
    currentTabIndex.value = index;
    if (index < 0 || index >= categoryTabs.length) return;
    final id = categoryTabs[index].id;
    if (loadedTabIds.contains(id)) return;
    await loadTabData(id);
    loadedTabIds.add(id);
  }

  /// 加载指定 Tab 的数据（可在此调用真实接口）
  Future<void> loadTabData(String id) async {
    // TODO: 在这里调用接口，按 id 加载对应分类的数据
    // 例：
    // final result = await api.fetchCategoryData(id);
    // 保存到对应的状态中，供 UI 使用
  }

  /// 下拉刷新：无论是否加载过，都重新拉取一次
  Future<void> refreshTabData(String id) async {
    await loadTabData(id);
    loadedTabIds.add(id);
  }

  /// BaseRefreshController 刷新入口：只刷新当前可见的 Tab
  @override
  Future<void> loadData() async {
    final index = currentTabIndex.value;
    if (index < 0 || index >= categoryTabs.length) return;
    final id = categoryTabs[index].id;
    await refreshTabData(id);
  }
}
