import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

/// 实时主题预览组件
/// 在主题设置界面提供实时预览功能
class LiveThemePreview extends StatefulWidget {
  final Widget child;
  final bool showPreview;
  
  const LiveThemePreview({
    super.key,
    required this.child,
    this.showPreview = true,
  });

  @override
  State<LiveThemePreview> createState() => _LiveThemePreviewState();
}

class _LiveThemePreviewState extends State<LiveThemePreview>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        // 监听主题变化，播放预览动画
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.showPreview) {
            _animationController.forward().then((_) {
              Future.delayed(const Duration(milliseconds: 200), () {
                _animationController.reverse();
              });
            });
          }
        });
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: widget.child,
              ),
            );
          },
        );
      },
    );
  }
}

/// 主题切换指示器
/// 显示当前正在切换主题的状态
class ThemeChangeIndicator extends StatelessWidget {
  const ThemeChangeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        if (!controller.isChangingTheme.value) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  controller.currentTheme.value.primaryColor,
                  controller.currentTheme.value.secondaryColor,
                ],
              ),
            ),
            child: const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          ),
        );
      },
    );
  }
}

/// 主题切换成功提示
class ThemeChangeSuccessToast extends StatelessWidget {
  final String themeName;
  
  const ThemeChangeSuccessToast({
    super.key,
    required this.themeName,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: controller.currentTheme.value.primaryColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '已切换到 $themeName',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 实时主题预览卡片
/// 在主题设置界面显示当前主题的实时预览
class RealTimeThemePreview extends StatelessWidget {
  const RealTimeThemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: controller.currentTheme.value.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.currentTheme.value.primaryColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: controller.currentTheme.value.primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 预览标题
              Row(
                children: [
                  Icon(
                    Icons.preview,
                    color: controller.currentTheme.value.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '实时预览',
                    style: TextStyle(
                      color: controller.currentTheme.value.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.currentTheme.value.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.currentTheme.value.name,
                        style: TextStyle(
                          color: controller.currentTheme.value.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 预览内容
              _buildPreviewContent(controller),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPreviewContent(ThemeController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 模拟AppBar
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: controller.currentTheme.value.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.currentTheme.value.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Text(
              '预览标题',
              style: TextStyle(
                color: controller.currentTheme.value.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 模拟按钮组
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.currentTheme.value.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('主要按钮', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: controller.currentTheme.value.primaryColor,
                  side: BorderSide(color: controller.currentTheme.value.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('次要按钮', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 模拟卡片
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: controller.currentTheme.value.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.currentTheme.value.primaryColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '预览卡片',
                style: TextStyle(
                  color: controller.currentTheme.value.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '这是当前主题的实时预览效果，您可以立即看到主题切换的结果。',
                style: TextStyle(
                  color: controller.currentTheme.value.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 主题切换动画包装器
/// 为整个应用提供主题切换时的动画效果
class ThemeTransitionWrapper extends StatelessWidget {
  final Widget child;
  
  const ThemeTransitionWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}
