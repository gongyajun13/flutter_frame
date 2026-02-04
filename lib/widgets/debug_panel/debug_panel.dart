import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_design_tokens.dart';
import '../../utils/debug_logger.dart';
import '../../utils/network_logger.dart';
import 'debug_panel_controller.dart';
import '../../app/config/environment_config.dart';

/// 调试面板
/// 点击调试球后弹出的调试面板
class DebugPanel extends StatelessWidget {
  const DebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DebugPanelController>();

    return Obx(() {
      if (!controller.isPanelVisible.value) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () => controller.hidePanel(),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 阻止点击事件冒泡
              behavior: HitTestBehavior.deferToChild,
              child: Material(
                color: Colors.transparent,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            color: AppDesignTokens.surfaceColor,
                            borderRadius: BorderRadius.circular(AppDesignTokens.radius16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  // 标题栏
                                  _buildHeader(controller),
                                  // 标签页
                                  _buildTabs(controller),
                                  // 内容区域
                                  Expanded(
                                    child: _buildContent(controller),
                                  ),
                                ],
                              ),
                              // 过滤器下拉列表（显示在内容之上）
                              _buildFilterDropdownList(controller),
                              // cURL 预览弹窗（显示在最上层）
                              _buildCurlPreview(controller),
                              // 面板内 Toast（最上层）
                              _buildPanelToast(controller),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 构建标题栏
  Widget _buildHeader(DebugPanelController controller) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacing16),
      decoration: BoxDecoration(
        color: AppDesignTokens.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDesignTokens.radius16),
          topRight: Radius.circular(AppDesignTokens.radius16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bug_report,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          const Expanded(
            child: Text(
              '调试面板',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => controller.hidePanel(),
          ),
        ],
      ),
    );
  }

  /// 构建标签页
  Widget _buildTabs(DebugPanelController controller) {
    final tabs = ['日志', '网络', '性能', '设置'];
    final icons = [
      Icons.description,
      Icons.network_check,
      Icons.speed,
      Icons.settings,
    ];

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
  }

  /// 构建内容区域
  Widget _buildContent(DebugPanelController controller) {
    return Obx(() => buildTabContent(controller));
  }

  /// 根据当前 Tab 构建对应内容（对外也可复用）
  Widget buildTabContent(DebugPanelController controller) {
    switch (controller.currentTab.value) {
      case 0:
        return buildLogsTab(controller);
      case 1:
        return _buildNetworkTab(controller);
      case 2:
        return _buildPerformanceTab(controller);
      case 3:
        return _buildSettingsTab(controller);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建日志标签页
  Widget buildLogsTab(DebugPanelController controller) {
    return Column(
      children: [
        // 搜索框（自定义实现，不依赖 Overlay）
        Container(
          padding: EdgeInsets.all(AppDesignTokens.spacing12),
          child: _buildCustomSearchField(controller),
        ),
        // 过滤器
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
          child: Row(
            children: [
              // 级别过滤
              Expanded(
                child: Obx(() => _buildFilterButton(
                  label: '级别',
                  value: controller.logLevelFilter.value,
                  items: ['ALL', 'D', 'I', 'W', 'E'],
                  filterType: 'level',
                  controller: controller,
                  onChanged: (value) => controller.setLogLevelFilter(value),
                )),
              ),
              // 标签过滤（仅在有多于一个标签时显示）
              Obx(() {
                final tags = controller.allLogTags;
                // 如果只有 'ALL' 和默认的 'App' 标签，则不显示标签过滤器
                if (tags.length <= 2) {
                  return const SizedBox.shrink();
                }
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppDesignTokens.spacing8),
                    child: _buildFilterButton(
                      label: '标签',
                      value: controller.logTagFilter.value,
                      items: tags,
                      filterType: 'tag',
                      controller: controller,
                      onChanged: (value) => controller.setLogTagFilter(value),
                    ),
                  ),
                );
              }),
              SizedBox(width: AppDesignTokens.spacing8),
              // 清空按钮
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () => controller.clearLogs(),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDesignTokens.spacing8),
        // 日志列表
        Expanded(
          child: Obx(() {
            final logs = controller.filteredLogs;
            if (logs.isEmpty) {
              return Center(
                child: Text(
                  '暂无日志',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return _buildLogItem(logs[index], controller);
              },
            );
          }),
        ),
      ],
    );
  }

  /// 构建自定义搜索框（使用 StatefulWidget 管理 TextEditingController）
  Widget _buildCustomSearchField(DebugPanelController controller) {
    return _CustomSearchField(controller: controller);
  }

  /// 构建过滤器按钮（自定义实现，不依赖 Overlay）
  Widget _buildFilterButton({
    required String label,
    required String value,
    required List<String> items,
    required String filterType,
    required DebugPanelController controller,
    required Function(String) onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        if (controller.showingFilterDropdown.value == filterType) {
          controller.hideFilterDropdown();
        } else {
          controller.showFilterDropdown(filterType);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spacing8,
          vertical: AppDesignTokens.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppDesignTokens.grey100,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
          border: Border.all(color: AppDesignTokens.grey300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              controller.showingFilterDropdown.value == filterType
                  ? Icons.arrow_drop_up
                  : Icons.arrow_drop_down,
              size: 16,
              color: AppDesignTokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建过滤器下拉列表（在 Stack 中显示）
  Widget _buildFilterDropdownList(DebugPanelController controller) {
    return Obx(() {
      final showingType = controller.showingFilterDropdown.value;
      if (showingType == null) return const SizedBox.shrink();

      List<String> items;
      String currentValue;
      Function(String) onItemSelected;

      if (showingType == 'level') {
        items = ['ALL', 'D', 'I', 'W', 'E'];
        currentValue = controller.logLevelFilter.value;
        onItemSelected = (value) {
          controller.setLogLevelFilter(value);
          controller.hideFilterDropdown();
        };
      } else if (showingType == 'tag') {
        items = controller.allLogTags;
        currentValue = controller.logTagFilter.value;
        onItemSelected = (value) {
          controller.setLogTagFilter(value);
          controller.hideFilterDropdown();
        };
      } else {
        return const SizedBox.shrink();
      }

      // 计算下拉列表的位置（在过滤器按钮下方）
      return GestureDetector(
        onTap: () => controller.hideFilterDropdown(),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 阻止点击事件冒泡
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(Get.context!).size.height * 0.3,
                ),
                decoration: BoxDecoration(
                  color: AppDesignTokens.surfaceColor,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                  border: Border.all(color: AppDesignTokens.grey300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == currentValue;
                    return InkWell(
                      onTap: () => onItemSelected(item),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignTokens.spacing16,
                          vertical: AppDesignTokens.spacing12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppDesignTokens.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            if (isSelected)
                              Icon(
                                Icons.check,
                                size: 16,
                                color: AppDesignTokens.primaryColor,
                              )
                            else
                              SizedBox(width: 16),
                            SizedBox(width: AppDesignTokens.spacing8),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: AppDesignTokens.fontSize13,
                                  color: isSelected
                                      ? AppDesignTokens.primaryColor
                                      : AppDesignTokens.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 构建日志条目
  Widget _buildLogItem(DebugLogEntry log, DebugPanelController controller) {
    final levelColor = _getLogLevelColor(log.level);
    
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacing8),
      padding: EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
        border: Border.all(
          color: levelColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：时间、级别、标签
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacing8,
                  vertical: AppDesignTokens.spacing4,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                ),
                child: Text(
                  log.level,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize10,
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              Expanded(
                child: Text(
                  log.tag,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize12,
                    color: AppDesignTokens.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                log.formattedTime,
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize10,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacing8),
          // 日志内容
          Text(
            log.message,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize13,
              color: AppDesignTokens.textPrimary,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          // 如果有错误信息，显示简要信息
          if (log.error != null) ...[
            SizedBox(height: AppDesignTokens.spacing8),
            Container(
              padding: EdgeInsets.all(AppDesignTokens.spacing8),
              decoration: BoxDecoration(
                color: AppDesignTokens.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
              ),
              child: Text(
                '错误: ${log.error.toString()}',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                  color: AppDesignTokens.errorColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 获取日志级别颜色
  Color _getLogLevelColor(String level) {
    switch (level) {
      case 'D':
        return AppDesignTokens.infoColor;
      case 'I':
        return AppDesignTokens.successColor;
      case 'W':
        return AppDesignTokens.warningColor;
      case 'E':
        return AppDesignTokens.errorColor;
      default:
        return AppDesignTokens.textSecondary;
    }
  }


  /// 构建网络标签页
  Widget _buildNetworkTab(DebugPanelController controller) {
    return Column(
      children: [
        // 过滤器
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
          child: Row(
            children: [
              // 状态过滤
              Expanded(
                child: Obx(() => _buildFilterButton(
                  label: '状态',
                  value: controller.networkStatusFilter.value,
                  items: ['ALL', 'SUCCESS', 'ERROR'],
                  filterType: 'network_status',
                  controller: controller,
                  onChanged: (value) => controller.setNetworkStatusFilter(value),
                )),
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              // 清空按钮
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () => controller.clearNetworkLogs(),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDesignTokens.spacing8),
        // 网络请求列表
        Expanded(
          child: Obx(() {
            final requests = controller.filteredNetworkLogs;
            if (requests.isEmpty) {
              return Center(
                child: Text(
                  '暂无网络请求',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildNetworkItem(requests[index], controller);
              },
            );
          }),
        ),
      ],
    );
  }

  /// 构建网络请求条目
  Widget _buildNetworkItem(NetworkLogEntry entry, DebugPanelController controller) {
    final statusColor = _getNetworkStatusColor(entry);
    final methodColor = _getMethodColor(entry.method);
    
    return InkWell(
      onTap: () => controller.openCurlPreview(entry),
      borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
      child: Container(
        margin: EdgeInsets.only(bottom: AppDesignTokens.spacing8),
        padding: EdgeInsets.all(AppDesignTokens.spacing12),
        decoration: BoxDecoration(
          color: AppDesignTokens.surfaceColor,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 头部：方法、URL、时间
          Row(
            children: [
              // 请求方法
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacing8,
                  vertical: AppDesignTokens.spacing4,
                ),
                decoration: BoxDecoration(
                  color: methodColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                ),
                child: Text(
                  entry.method,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize10,
                    color: methodColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              // 状态码
              if (entry.statusCode != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing8,
                    vertical: AppDesignTokens.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                  ),
                  child: Text(
                    '${entry.statusCode}',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignTokens.spacing8,
                    vertical: AppDesignTokens.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.warningColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
                  ),
                  child: Text(
                    '进行中',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize10,
                      color: AppDesignTokens.warningColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              // 时间
              Text(
                entry.formattedTime,
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize10,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacing8),
          // URL
          Text(
            entry.shortUrl,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize13,
              color: AppDesignTokens.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // 耗时
          if (entry.duration != null) ...[
            SizedBox(height: AppDesignTokens.spacing4),
            Text(
              '耗时: ${entry.duration!.inMilliseconds}ms',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize12,
                color: AppDesignTokens.textSecondary,
              ),
            ),
          ],
          // 错误信息
          if (entry.error != null) ...[
            SizedBox(height: AppDesignTokens.spacing8),
            Container(
              padding: EdgeInsets.all(AppDesignTokens.spacing8),
              decoration: BoxDecoration(
                color: AppDesignTokens.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesignTokens.radius4),
              ),
              child: Text(
                '错误: ${entry.error}',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                  color: AppDesignTokens.errorColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurlPreview(DebugPanelController controller) {
    return Obx(() {
      if (!controller.showCurlPreview.value) {
        return const SizedBox.shrink();
      }

      return Positioned.fill(
        child: Material(
          color: Colors.black.withOpacity(0.55),
          child: GestureDetector(
            onTap: controller.closeCurlPreview,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 560,
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.9,
                    maxHeight: Get.height * 0.7,
                  ),
                  padding: EdgeInsets.all(AppDesignTokens.spacing16),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.surfaceColor,
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'cURL（可复制执行）',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: controller.copyCurlToClipboard,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('复制'),
                          ),
                          IconButton(
                            onPressed: controller.closeCurlPreview,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDesignTokens.spacing12),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(AppDesignTokens.spacing12),
                          decoration: BoxDecoration(
                            color: AppDesignTokens.backgroundColor,
                            borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                            border: Border.all(
                              color: AppDesignTokens.grey300,
                              width: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              controller.curlPreviewText.value,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPanelToast(DebugPanelController controller) {
    return Obx(() {
      if (!controller.showPanelToast.value) return const SizedBox.shrink();

      return Positioned(
        top: AppDesignTokens.spacing12,
        left: AppDesignTokens.spacing12,
        right: AppDesignTokens.spacing12,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignTokens.spacing12,
              vertical: AppDesignTokens.spacing8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
            ),
            child: Text(
              controller.panelToastMessage.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 获取网络请求状态颜色
  Color _getNetworkStatusColor(NetworkLogEntry entry) {
    if (entry.isError) {
      return AppDesignTokens.errorColor;
    } else if (entry.isSuccess) {
      return AppDesignTokens.successColor;
    } else {
      return AppDesignTokens.warningColor;
    }
  }

  /// 获取请求方法颜色
  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return AppDesignTokens.infoColor;
      case 'POST':
        return AppDesignTokens.successColor;
      case 'PUT':
        return AppDesignTokens.warningColor;
      case 'DELETE':
        return AppDesignTokens.errorColor;
      case 'PATCH':
        return AppDesignTokens.secondaryColor;
      default:
        return AppDesignTokens.textSecondary;
    }
  }

  /// 构建性能标签页
  Widget _buildPerformanceTab(DebugPanelController controller) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignTokens.spacing12,
            vertical: AppDesignTokens.spacing8,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '性能监控',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Obx(() => Switch(
                    value: controller.performanceMonitoringEnabled.value,
                    onChanged: controller.setPerformanceMonitoringEnabled,
                  )),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: controller.clearPerformance,
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            // 触发刷新
            final fps = controller.currentFps;
            final avg = controller.avgFrameTime;
            final worst = controller.worstFrameTime;
            final j16 = controller.jank16Count;
            final j33 = controller.jank33Count;
            final frames = controller.frameCount;
            final pageOpens = controller.pageOpens;

            final scrollLabel = _smoothnessLabel(fps, j16, j33, frames);
            final scrollColor = _smoothnessColor(scrollLabel);
            final scrollDesc = _smoothnessDescription(scrollLabel);
            final currentPage = controller.currentPerfPageName ?? '未识别页面';

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacing12),
              children: [
                if (controller.currentPerfPageName != null) ...[
                  Text(
                    '当前页面：$currentPage（以下 FPS / Jank 为进入该页面后的统计）',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize12,
                      color: AppDesignTokens.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppDesignTokens.spacing8),
                ],
                Row(
                  children: [
                    Expanded(child: _perfStatCard('FPS', '$fps', AppDesignTokens.infoColor)),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Expanded(
                        child: _perfStatCard(
                      'Avg',
                      '${avg.inMilliseconds}ms',
                      AppDesignTokens.successColor,
                    )),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Expanded(
                        child: _perfStatCard(
                      'Worst',
                      '${worst.inMilliseconds}ms',
                      AppDesignTokens.warningColor,
                    )),
                  ],
                ),
                SizedBox(height: AppDesignTokens.spacing12),
                Row(
                  children: [
                    Expanded(
                        child: _perfStatCard(
                      'Jank >16ms',
                      '$j16',
                      AppDesignTokens.warningColor,
                    )),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Expanded(
                        child: _perfStatCard(
                      'Jank >33ms',
                      '$j33',
                      AppDesignTokens.errorColor,
                    )),
                  ],
                ),
                SizedBox(height: AppDesignTokens.spacing16),
                // 列表滑动 & 动画流畅度解释
                Text(
                  '列表滑动 / 动画流畅度',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacing8),
                Container(
                  padding: EdgeInsets.all(AppDesignTokens.spacing12),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.surfaceColor,
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                    border: Border.all(color: scrollColor.withOpacity(0.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.only(
                          top: AppDesignTokens.spacing4,
                          right: AppDesignTokens.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: scrollColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scrollLabel,
                              style: TextStyle(
                                fontSize: AppDesignTokens.fontSize13,
                                fontWeight: FontWeight.w600,
                                color: scrollColor,
                              ),
                            ),
                            SizedBox(height: AppDesignTokens.spacing4),
                            Text(
                              scrollDesc,
                              style: TextStyle(
                                fontSize: AppDesignTokens.fontSize12,
                                color: AppDesignTokens.textSecondary,
                              ),
                            ),
                            SizedBox(height: AppDesignTokens.spacing4),
                            Text(
                              '参考：FPS≈$fps，平均帧 ${avg.inMilliseconds}ms，最慢帧 ${worst.inMilliseconds}ms，'
                              '轻微卡顿 $j16 次，严重卡顿 $j33 次',
                              style: TextStyle(
                                fontSize: AppDesignTokens.fontSize10,
                                color: AppDesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacing16),
                Text(
                  '页面打开速度',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacing8),
                if (pageOpens.isEmpty)
                  Text(
                    '最近暂无页面打开记录。\n'
                    '提示：从其它页面跳转到某个 Demo 页面时，会自动记录首帧耗时。',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize12,
                      color: AppDesignTokens.textSecondary,
                    ),
                  )
                else ...[
                  ...pageOpens.take(10).map((p) {
                    final color = _pageOpenColor(p.duration);
                    return Container(
                      margin: EdgeInsets.only(bottom: AppDesignTokens.spacing8),
                      padding: EdgeInsets.all(AppDesignTokens.spacing12),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.surfaceColor,
                        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
                        border: Border.all(color: color.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          SizedBox(width: AppDesignTokens.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.pageName,
                                  style: TextStyle(
                                    fontSize: AppDesignTokens.fontSize13,
                                    fontWeight: FontWeight.w600,
                                    color: AppDesignTokens.textPrimary,
                                  ),
                                ),
                                SizedBox(height: AppDesignTokens.spacing4),
                                Text(
                                  '首帧耗时: ${p.duration.inMilliseconds}ms',
                                  style: TextStyle(
                                    fontSize: AppDesignTokens.fontSize12,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: AppDesignTokens.spacing8),
                  Text(
                    '建议：首帧 <300ms 体验较好，300–800ms 可接受，>800ms 建议优化（懒加载数据、骨架屏等）。',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize12,
                      color: AppDesignTokens.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: AppDesignTokens.spacing16),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _perfStatCard(String title, String value, Color accent) {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize10,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacing4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  String _smoothnessLabel(int fps, int j16, int j33, int frames) {
    if (frames < 30) {
      return '数据不足（请在当前页面多滑动几秒）';
    }
    final j33Rate = frames > 0 ? j33 / frames : 0.0;
    if (fps >= 55 && j33Rate < 0.02) {
      return '流畅（推荐标准）';
    }
    if (fps >= 45 && j33Rate < 0.08) {
      return '可接受（存在轻微卡顿）';
    }
    return '明显卡顿（建议优化）';
  }

  Color _smoothnessColor(String label) {
    if (label.startsWith('流畅')) {
      return AppDesignTokens.successColor;
    }
    if (label.startsWith('可接受')) {
      return AppDesignTokens.warningColor;
    }
    return AppDesignTokens.errorColor;
  }

  String _smoothnessDescription(String label) {
    if (label.startsWith('数据不足')) {
      return '请在当前页面进行实际操作（例如连续滑动列表 3–5 秒），再回来看数据。';
    }
    if (label.startsWith('流畅')) {
      return 'FPS 基本维持在 55 以上，且几乎没有 >33ms 的严重卡顿，列表滑动和动画整体顺滑。';
    }
    if (label.startsWith('可接受')) {
      return '偶尔出现轻微掉帧，日常使用基本 OK，如是核心页面建议继续优化到“流畅”区间。';
    }
    return '存在较多 >33ms 的严重卡顿，用户在滑动列表或动画时会明显感到卡顿，建议重点排查。';
  }

  Color _pageOpenColor(Duration d) {
    final ms = d.inMilliseconds;
    if (ms <= 300) return AppDesignTokens.successColor;
    if (ms <= 800) return AppDesignTokens.warningColor;
    return AppDesignTokens.errorColor;
  }

  /// 构建设置标签页
  Widget _buildSettingsTab(DebugPanelController controller) {
    final env = controller.envConfig;
    final envName = env?.env.value.toString().split('.').last ?? 'unknown';
    final baseUrl = env?.apiBaseUrl ?? '-';

    return ListView(
      padding: EdgeInsets.all(AppDesignTokens.spacing16),
      children: [
        Text(
          '环境信息',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            fontWeight: FontWeight.w600,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacing8),
        Container(
          padding: EdgeInsets.all(AppDesignTokens.spacing12),
          decoration: BoxDecoration(
            color: AppDesignTokens.surfaceColor,
            borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前环境：$envName',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize13,
                  color: AppDesignTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacing4),
              Text(
                'Base URL：$baseUrl',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacing4),
              Text(
                '说明：环境需通过构建参数 APP_ENV 切换，运行中修改需要重启应用。',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDesignTokens.spacing16),
        Text(
          '网络代理（仅调试）',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            fontWeight: FontWeight.w600,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacing8),
        Obx(() {
          final enabled = controller.proxyEnabled.value;
          final proxyText = controller.proxyInput.value;
          return Container(
            padding: EdgeInsets.all(AppDesignTokens.spacing12),
            decoration: BoxDecoration(
              color: AppDesignTokens.surfaceColor,
              borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: proxyText,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDesignTokens.radius8),
                            borderSide:
                                BorderSide(color: AppDesignTokens.grey300),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppDesignTokens.spacing12,
                            vertical: AppDesignTokens.spacing8,
                          ),
                          hintText: '示例：127.0.0.1:8888',
                          hintStyle: TextStyle(
                            fontSize: AppDesignTokens.fontSize12,
                            color: AppDesignTokens.textSecondary,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize13,
                          color: AppDesignTokens.textPrimary,
                        ),
                        onChanged: controller.setProxyText,
                      ),
                    ),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Column(
                      children: [
                        Switch(
                          value: enabled,
                          onChanged: (v) => controller.setProxyEnabled(v),
                        ),
                        Text(
                          enabled ? '已开启' : '已关闭',
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSize12,
                            color: AppDesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppDesignTokens.spacing8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: controller.applyProxyConfig,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignTokens.spacing16,
                          vertical: AppDesignTokens.spacing8,
                        ),
                      ),
                      child: const Text('应用'),
                    ),
                    SizedBox(width: AppDesignTokens.spacing8),
                    Expanded(
                      child: Text(
                        '说明：仅影响 Dio HTTP 请求，建议配合 Charles / Fiddler 等抓包工具使用。',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSize12,
                          color: AppDesignTokens.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        SizedBox(height: AppDesignTokens.spacing16),
        Text(
          '切换环境',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            fontWeight: FontWeight.w600,
            color: AppDesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacing8),
        Wrap(
          spacing: AppDesignTokens.spacing8,
          children: [
            ChoiceChip(
              label: const Text('dev'),
              selected: env?.isDev ?? false,
              onSelected: (_) => controller.switchEnvironment(AppEnvironment.development),
            ),
            ChoiceChip(
              label: const Text('test'),
              selected: env?.isTest ?? false,
              onSelected: (_) => controller.switchEnvironment(AppEnvironment.test),
            ),
            ChoiceChip(
              label: const Text('prod'),
              selected: env?.isProd ?? false,
              onSelected: (_) => controller.switchEnvironment(AppEnvironment.production),
            ),
          ],
        ),
        Text(
          '说明：这里的环境切换主要用于本地调试接口地址、日志等行为，部分底层 SDK 或构建相关配置仍以启动参数为准，必要时需重启应用。',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize12,
            color: AppDesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 自定义搜索框组件（使用 StatefulWidget 管理状态，不依赖 Overlay）
class _CustomSearchField extends StatefulWidget {
  final DebugPanelController controller;

  const _CustomSearchField({required this.controller});

  @override
  State<_CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<_CustomSearchField> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.logSearchKeyword.value,
    );
    _focusNode = FocusNode();
    
    // 监听控制器变化
    ever(widget.controller.logSearchKeyword, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasText = widget.controller.logSearchKeyword.value.isNotEmpty;
      
      return Container(
        decoration: BoxDecoration(
          color: AppDesignTokens.grey100,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius8),
          border: Border.all(color: AppDesignTokens.grey300),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: AppDesignTokens.spacing12),
              child: Icon(
                Icons.search,
                size: 20,
                color: AppDesignTokens.textSecondary,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // 提示文本
                  if (!_focusNode.hasFocus && _textController.text.isEmpty)
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignTokens.spacing12,
                          vertical: AppDesignTokens.spacing12,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '搜索日志...',
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSize14,
                              color: AppDesignTokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 输入框
                  EditableText(
                    controller: _textController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize14,
                      color: AppDesignTokens.textPrimary,
                    ),
                    cursorColor: AppDesignTokens.primaryColor,
                    backgroundCursorColor: AppDesignTokens.primaryColor.withOpacity(0.3),
                    onChanged: (value) {
                      widget.controller.setLogSearchKeyword(value);
                    },
                  ),
                ],
              ),
            ),
            if (hasText)
              GestureDetector(
                onTap: () {
                  _textController.clear();
                  widget.controller.setLogSearchKeyword('');
                  _focusNode.unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.all(AppDesignTokens.spacing8),
                  child: Icon(
                    Icons.clear,
                    size: 20,
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
