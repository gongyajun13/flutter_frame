import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../overlay/overlay.dart';
import '../controllers/theme_controller.dart';

/// 主题切换动画包装器
/// 为整个应用提供主题切换时的动画效果
class ThemeTransitionWrapper extends StatefulWidget {
  final Widget child;
  
  const ThemeTransitionWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ThemeTransitionWrapper> createState() => _ThemeTransitionWrapperState();
}

class _ThemeTransitionWrapperState extends State<ThemeTransitionWrapper>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 初始化动画
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // 监听主题切换
    _listenToThemeChanges();
  }
  
  void _listenToThemeChanges() {
    final themeController = Get.find<ThemeController>();
    
    // 监听主题切换状态
    ever(themeController.isChangingTheme, (bool isChanging) {
      if (isChanging) {
        _startTransition();
      } else {
        _endTransition();
      }
    });
  }
  
  void _startTransition() {
    _fadeController.forward();
    _scaleController.forward();
  }
  
  void _endTransition() {
    _fadeController.reverse();
    _scaleController.reverse();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
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
  }
}

/// 主题切换按钮
/// 提供快速切换主题的浮动按钮
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return FloatingActionButton(
          onPressed: () => _toggleTheme(controller),
          tooltip: '切换主题',
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              controller.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(controller.isDarkTheme),
            ),
          ),
        );
      },
    );
  }
  
  void _toggleTheme(ThemeController controller) {
    if (controller.isDarkTheme) {
      controller.switchThemeMode(ThemeMode.light);
    } else {
      controller.switchThemeMode(ThemeMode.dark);
    }
  }
}

/// 主题切换指示器
/// 显示当前主题状态的小组件
class ThemeIndicator extends StatelessWidget {
  const ThemeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: controller.currentTheme.value.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.currentTheme.value.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                size: 16,
                color: controller.currentTheme.value.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                controller.currentTheme.value.name,
                style: TextStyle(
                  fontSize: 12,
                  color: controller.currentTheme.value.primaryColor,
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

/// 主题切换动画页面
/// 专门用于主题切换时的过渡动画
class ThemeTransitionPage extends StatefulWidget {
  final Widget child;
  
  const ThemeTransitionPage({
    super.key,
    required this.child,
  });

  @override
  State<ThemeTransitionPage> createState() => _ThemeTransitionPageState();
}

class _ThemeTransitionPageState extends State<ThemeTransitionPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        )),
        child: widget.child,
      ),
    );
  }
}

/// 主题颜色动画组件
/// 为颜色变化提供平滑的过渡动画
class AnimatedThemeColor extends StatelessWidget {
  final Color color;
  final Duration duration;
  final Widget child;
  
  const AnimatedThemeColor({
    super.key,
    required this.color,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      color: color,
      child: child,
    );
  }
}

/// 主题切换时的加载指示器
class ThemeLoadingIndicator extends StatelessWidget {
  const ThemeLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        if (!controller.isChangingTheme.value) {
          return const SizedBox.shrink();
        }
        
        return Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      controller.currentTheme.value.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在切换主题...',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 主题切换成功提示
class ThemeChangeSuccessSnackBar {
  static void show(String themeName) {
    AppOverlay.snack.success(
      title: '主题切换成功',
      message: '已切换到 $themeName',
    );
  }
}

/// 主题切换错误提示
class ThemeChangeErrorSnackBar {
  static void show(String error) {
    AppOverlay.snack.error(
      title: '主题切换失败',
      message: error,
    );
  }
}

