import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_design_tokens.dart';
import '../home_controller.dart';

/// 首页演示项网格卡片
class HomeDemoGridTile extends StatelessWidget {
  final DemoItem item;
  final int index;
  final VoidCallback onTap;

  const HomeDemoGridTile({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
  });

  Color get _accentColor {
    switch (index % 3) {
      case 1:
        return AppDesignTokens.secondaryColor;
      case 2:
        return AppDesignTokens.infoColor;
      default:
        return AppDesignTokens.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Material(
      color: AppDesignTokens.surfaceColor,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                color: accent.withValues(alpha: 0.08),
                alignment: Alignment.center,
                child: Text(
                  item.icon,
                  style: TextStyle(fontSize: 34.sp, height: 1.0),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: AppDesignTokens.fontWeightSemiBold,
                        color: AppDesignTokens.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Expanded(
                      child: Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppDesignTokens.textTertiary,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 14.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14.w,
                          color: AppDesignTokens.textDisabled,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
