import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_design_tokens.dart';
import '../home_controller.dart';
import 'home_demo_grid_tile.dart';

/// 单个 Tab 页的内容区元信息
class HomeTabContentMeta {
  final String title;
  final String subtitle;

  const HomeTabContentMeta({
    required this.title,
    required this.subtitle,
  });
}

/// 首页 Tab 内容 — 顶部标题 + 双列网格
class HomeTabContent extends StatelessWidget {
  final HomeTabContentMeta meta;
  final List<DemoItem> items;
  final ValueChanged<String> onItemTap;

  static const List<HomeTabContentMeta> metas = [
    HomeTabContentMeta(
      title: '视图',
      subtitle: '界面展示、布局与交互组件',
    ),
    HomeTabContentMeta(
      title: '功能',
      subtitle: '业务能力与核心功能演示',
    ),
    HomeTabContentMeta(
      title: '工具',
      subtitle: '通用工具与基础能力封装',
    ),
  ];

  const HomeTabContent({
    super.key,
    required this.meta,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _HomeTabHeader(meta: meta, count: items.length)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.02,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return HomeDemoGridTile(
                  item: item,
                  index: index,
                  onTap: () => onItemTap(item.route),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTabHeader extends StatelessWidget {
  final HomeTabContentMeta meta;
  final int count;

  const _HomeTabHeader({
    required this.meta,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: AppDesignTokens.textPrimary,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  meta.subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppDesignTokens.textTertiary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppDesignTokens.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count 项',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: AppDesignTokens.fontWeightMedium,
                color: AppDesignTokens.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
