import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 权限说明配置
class PermissionExplanation {
  /// 权限标题
  final String title;
  
  /// 权限说明
  final String description;
  
  /// 权限图标
  final IconData icon;
  
  /// 图标颜色
  final Color iconColor;
  
  /// 应用名称（用于显示在说明中）
  final String? appName;

  const PermissionExplanation({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor = Colors.blue,
    this.appName,
  });
}

/// 权限说明展示组件
/// 
/// 用于在请求权限时向用户展示权限使用说明
/// 符合 Android 应用市场审核要求
/// 
/// 注意：此组件仅用于展示，不包含操作按钮
/// 系统权限请求弹窗会同时显示
class PermissionExplanationDialog extends StatelessWidget {
  /// 权限说明配置
  final PermissionExplanation explanation;

  const PermissionExplanationDialog({
    super.key,
    required this.explanation,
  });

  /// 显示权限说明并立即拉起系统权限请求
  /// 
  /// [context] 上下文
  /// [explanation] 权限说明配置
  /// [onRequestPermission] 权限请求回调（在显示说明后立即调用）
  /// 
  /// 返回权限请求结果
  static Future<bool> showAndRequest(
    BuildContext context, {
    required PermissionExplanation explanation,
    required Future<bool> Function() onRequestPermission,
  }) async {
    // 显示权限说明弹窗（顶部位置，仅展示，不可交互，无动画）
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // 透明背景，不遮挡
      transitionDuration: Duration.zero, // 去除动画
      pageBuilder: (context, animation, secondaryAnimation) => PermissionExplanationDialog(
        explanation: explanation,
      ),
    );

    // 立即拉起系统权限请求（不延迟，同时显示）
    final result = await onRequestPermission();

    // 权限请求完成后，关闭说明弹窗
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧图标
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: explanation.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  explanation.icon,
                  size: 22.sp,
                  color: explanation.iconColor,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              // 右侧文字内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      explanation.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                        decoration: TextDecoration.none,
                        decorationColor: Colors.transparent,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // 说明文字
                    Text(
                      explanation.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.4,
                        decoration: TextDecoration.none,
                        decorationColor: Colors.transparent,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
