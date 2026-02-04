import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_design_tokens.dart';
import 'debug_panel_controller.dart';
import 'debug_panel.dart';

/// 调试面板独立页面版本
/// - 与悬浮球弹出的 DebugPanel 共享同一个 DebugPanelController
/// - 方便通过路由直接进入完整调试界面
class DebugPanelPage extends StatelessWidget {
  const DebugPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保已有控制器（通常在 main.dart 中全局注册）
    final controller = Get.find<DebugPanelController>();

    // 进入独立页面时，强制显示面板，并默认选中“设置”Tab（也可以根据需要改成日志 Tab）
    controller.isPanelVisible.value = true;
    controller.currentTab.value = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('调试面板'),
      ),
      body: const _DebugPanelBody(),
    );
  }
}

/// 调试面板主体，可被页面和弹窗复用
class _DebugPanelBody extends StatelessWidget {
  const _DebugPanelBody();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DebugPanelController>();

    return Container(
      color: AppDesignTokens.surfaceColor,
      child: Column(
        children: [
          // 复用原有的 tab 与内容结构
          _DebugPanelTabs(controller: controller),
          Expanded(
            child: _DebugPanelContent(controller: controller),
          ),
        ],
      ),
    );
  }
}

/// 简化版 Tabs，复用 DebugPanel 内的构建逻辑
class _DebugPanelTabs extends StatelessWidget {
  final DebugPanelController controller;

  const _DebugPanelTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final tabs = ['日志', '网络', '性能', '设置'];
    final icons = [
      Icons.description,
      Icons.network_check,
      Icons.speed,
      Icons.settings,
    ];

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppDesignTokens.grey300,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = controller.currentTab.value == index;
            return Expanded(
              child: InkWell(
                onTap: () => controller.switchTab(index),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDesignTokens.spacing12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppDesignTokens.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[index],
                        size: 20,
                        color: isSelected
                            ? AppDesignTokens.primaryColor
                            : AppDesignTokens.textSecondary,
                      ),
                      SizedBox(height: AppDesignTokens.spacing4),
                      Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize12,
                          color: isSelected
                              ? AppDesignTokens.primaryColor
                              : AppDesignTokens.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

/// 内容区域，同样复用 DebugPanel 的 tab 内容构建
class _DebugPanelContent extends StatelessWidget {
  final DebugPanelController controller;

  const _DebugPanelContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => const DebugPanel().buildTabContent(controller));
  }
}

/// 调试面板弹窗，用于从悬浮球以弹窗形式打开
class DebugPanelDialog extends StatelessWidget {
  const DebugPanelDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 进入弹窗时，默认展示“设置”Tab，方便调环境/代理
    final controller = Get.find<DebugPanelController>();
    controller.currentTab.value = 3;

    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(AppDesignTokens.spacing16),
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.8,
        decoration: BoxDecoration(
          color: AppDesignTokens.surfaceColor,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // 顶部标题 + 关闭按钮
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spacing16,
                vertical: AppDesignTokens.spacing12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bug_report,
                    size: 20,
                  ),
                  SizedBox(width: AppDesignTokens.spacing8),
                  const Expanded(
                    child: Text(
                      '调试面板',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    splashRadius: 18,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppDesignTokens.grey300),
            // 主体内容
            const Expanded(
              child: _DebugPanelBody(),
            ),
          ],
        ),
      ),
    );
  }
}

