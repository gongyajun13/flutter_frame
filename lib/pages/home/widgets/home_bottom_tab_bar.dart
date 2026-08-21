import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_design_tokens.dart';

/// 首页底部 Tab 数据
class HomeTabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const HomeTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// 首页底部 Tab 栏 — 纯图标 + 选中圆点
class HomeBottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<int> badgeCounts;

  static const List<HomeTabItem> tabs = [
    HomeTabItem(
      label: '视图',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
    HomeTabItem(
      label: '功能',
      icon: Icons.widgets_outlined,
      selectedIcon: Icons.widgets_rounded,
    ),
    HomeTabItem(
      label: '工具',
      icon: Icons.build_outlined,
      selectedIcon: Icons.build_circle_rounded,
    ),
  ];

  const HomeBottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.badgeCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppDesignTokens.textDisabled.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52.h,
          child: Row(
            children: List.generate(tabs.length, (index) {
              return _HomeTabButton(
                item: tabs[index],
                isSelected: currentIndex == index,
                badgeCount:
                    index < badgeCounts.length ? badgeCounts[index] : 0,
                onTap: () => onTabSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  final HomeTabItem item;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _HomeTabButton({
    required this.item,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = AppDesignTokens.primaryColor;
    final inactive = AppDesignTokens.textTertiary;

    return Expanded(
      child: Tooltip(
        message: item.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      size: 26.w,
                      color: isSelected ? active : inactive,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -6.w,
                        top: -4.h,
                        child: _TabBadge(count: badgeCount),
                      ),
                  ],
                ),
                SizedBox(height: 5.h),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: active,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  final int count;

  const _TabBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      constraints: BoxConstraints(minWidth: 16.w, minHeight: 14.h),
      decoration: BoxDecoration(
        color: AppDesignTokens.errorColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppDesignTokens.surfaceColor, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.sp,
          fontWeight: AppDesignTokens.fontWeightBold,
          height: 1.0,
        ),
      ),
    );
  }
}
