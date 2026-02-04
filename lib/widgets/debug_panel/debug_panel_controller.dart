import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/config/environment_config.dart';
import '../../utils/debug_logger.dart';
import '../../utils/network_logger.dart';
import '../../utils/performance_monitor.dart';

/// 调试面板控制器
class DebugPanelController extends GetxController {
  /// 是否显示调试面板
  final RxBool isPanelVisible = false.obs;

  /// 当前选中的标签页（0: 日志, 1: 网络, 2: 性能, 3: 设置）
  final RxInt currentTab = 0.obs;

  /// 日志过滤器（级别）
  final RxString logLevelFilter = 'ALL'.obs;

  /// 日志过滤器（标签）
  final RxString logTagFilter = 'ALL'.obs;

  /// 日志搜索关键词
  final RxString logSearchKeyword = ''.obs;

  /// 网络请求过滤器（状态）
  final RxString networkStatusFilter = 'ALL'.obs;

  /// 性能监控开关
  final RxBool performanceMonitoringEnabled = false.obs;

  /// 性能刷新触发器
  final RxInt performanceRefreshTrigger = 0.obs;


  /// 日志刷新触发器（用于强制刷新日志列表）
  final RxInt logRefreshTrigger = 0.obs;

  /// 网络请求刷新触发器（用于强制刷新网络请求列表）
  final RxInt networkRefreshTrigger = 0.obs;

  /// 当前显示的下拉选择器类型（null 表示不显示）
  final Rx<String?> showingFilterDropdown = Rx<String?>(null);

  /// 是否显示 cURL 预览弹窗（面板内弹层，不依赖 Overlay）
  final RxBool showCurlPreview = false.obs;

  /// 当前 cURL 文本
  final RxString curlPreviewText = ''.obs;

  /// 面板内提示（不依赖 Overlay）
  final RxString panelToastMessage = ''.obs;
  final RxBool showPanelToast = false.obs;

  /// 网络代理输入与开关
  final RxString proxyInput = ''.obs;
  final RxBool proxyEnabled = false.obs;

  /// 显示过滤器下拉选择器
  void showFilterDropdown(String type) {
    showingFilterDropdown.value = type;
  }

  /// 隐藏过滤器下拉选择器
  void hideFilterDropdown() {
    showingFilterDropdown.value = null;
  }

  /// 环境配置
  EnvironmentConfig? get envConfig {
    try {
      return Get.find<EnvironmentConfig>();
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // 监听日志变化
    DebugLogger.instance.addListener(_onLogsChanged);
    NetworkLogger.instance.addListener(_onNetworkLogsChanged);

    // 监听性能变化
    PerformanceMonitor.instance.addListener(_onPerformanceChanged);

    // 默认开启（由 InitServices 决定是否 start，这里只同步 UI 开关）
    performanceMonitoringEnabled.value = PerformanceMonitor.instance.enabled;

    // 初始化代理配置显示
    final cfg = envConfig;
    if (cfg != null) {
      proxyInput.value = cfg.proxy ?? '';
      proxyEnabled.value = cfg.enableProxy;
    }
  }

  @override
  void onClose() {
    DebugLogger.instance.removeListener(_onLogsChanged);
    NetworkLogger.instance.removeListener(_onNetworkLogsChanged);
    PerformanceMonitor.instance.removeListener(_onPerformanceChanged);
    super.onClose();
  }

  /// 切换面板显示状态
  void togglePanel() {
    isPanelVisible.value = !isPanelVisible.value;
  }

  void setProxyText(String value) {
    proxyInput.value = value;
  }

  void setProxyEnabled(bool value) {
    proxyEnabled.value = value;
  }

  /// 应用网络代理设置
  Future<void> applyProxyConfig() async {
    final cfg = envConfig;
    if (cfg == null) return;

    final text = proxyInput.value.trim();
    final enabled = proxyEnabled.value && text.isNotEmpty;

    await cfg.setProxyConfig(enabled ? text : null, enabled: enabled);

    if (enabled) {
      _showPanelToast('已启用网络代理: $text');
    } else {
      _showPanelToast('已关闭网络代理');
    }
  }

  /// 显示面板
  void showPanel() {
    isPanelVisible.value = true;
  }

  /// 隐藏面板
  void hidePanel() {
    isPanelVisible.value = false;
  }

  /// 切换标签页
  void switchTab(int index) {
    currentTab.value = index;
    // 当切换到对应标签页时，强制刷新一次，避免在面板关闭期间产生的日志无法立即显示
    if (index == 0) {
      logRefreshTrigger.value++;
    } else if (index == 1) {
      networkRefreshTrigger.value++;
    } else if (index == 2) {
      performanceRefreshTrigger.value++;
    }
  }

  void setPerformanceMonitoringEnabled(bool enabled) {
    performanceMonitoringEnabled.value = enabled;
    if (enabled) {
      PerformanceMonitor.instance.start();
    } else {
      PerformanceMonitor.instance.stop();
    }
    performanceRefreshTrigger.value++;
  }

  void clearPerformance() {
    PerformanceMonitor.instance.clear();
    performanceRefreshTrigger.value++;
  }

  int get currentFps {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.fps;
  }

  Duration get avgFrameTime {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.avgFrame;
  }

  Duration get worstFrameTime {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.worstFrame;
  }

  int get jank16Count {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.jank16Count;
  }

  int get jank33Count {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.jank33Count;
  }

  int get frameCount {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.frameCount;
  }

  List<FrameRecord> get slowFrames {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.slowFrames.reversed.toList();
  }

  List<PageOpenRecord> get pageOpens {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.pageOpens.reversed.toList();
  }

  String? get currentPerfPageName {
    final _ = performanceRefreshTrigger.value;
    return PerformanceMonitor.instance.currentPageSession;
  }

  void openCurlPreview(NetworkLogEntry entry) {
    curlPreviewText.value = _buildCurl(entry);
    showCurlPreview.value = true;
  }

  void closeCurlPreview() {
    showCurlPreview.value = false;
  }

  Future<void> copyCurlToClipboard() async {
    final text = curlPreviewText.value;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    // 复制成功后关闭弹窗，并给出提示
    closeCurlPreview();
    _showPanelToast('已复制 cURL');
  }

  void _showPanelToast(String message) {
    panelToastMessage.value = message;
    showPanelToast.value = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      // 避免组件销毁后触发
      if (isClosed) return;
      showPanelToast.value = false;
    });
  }

  String _buildCurl(NetworkLogEntry entry) {
    final method = entry.method.toUpperCase();

    Uri? uri;
    try {
      uri = Uri.parse(entry.url);
    } catch (_) {}

    // 合并 queryParameters（若 url 已有 query，这里会覆盖同名 key）
    final qp = <String, dynamic>{};
    if (uri != null) {
      qp.addAll(uri.queryParameters);
    }
    if (entry.queryParameters != null) {
      entry.queryParameters!.forEach((k, v) {
        if (v != null) qp[k] = v;
      });
    }

    final finalUrl = uri != null
        ? uri.replace(
            queryParameters: qp.isEmpty
                ? null
                : qp.map((k, v) => MapEntry(k, v.toString())),
          ).toString()
        : entry.url;

    final parts = <String>['curl', '-X', method];

    // headers
    final headers = entry.headers ?? const {};
    headers.forEach((key, value) {
      if (value == null) return;
      final k = key.toString();
      if (k.toLowerCase() == 'content-length') return;
      parts.add('-H');
      parts.add(_shellQuote('$k: $value'));
    });

    // body
    if (method != 'GET' && method != 'HEAD') {
      final body = entry.requestData;
      if (body != null) {
        String bodyStr;
        if (body is String) {
          bodyStr = body;
        } else {
          try {
            bodyStr = jsonEncode(body);
          } catch (_) {
            bodyStr = body.toString();
          }
        }
        if (bodyStr.isNotEmpty) {
          parts.add('--data-raw');
          parts.add(_shellQuote(bodyStr));
        }
      }
    }

    parts.add(_shellQuote(finalUrl));

    // 多行展示（更可读）
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      buf.write(parts[i]);
      if (i != parts.length - 1) {
        buf.write(' \\\n  ');
      }
    }
    return buf.toString();
  }

  String _shellQuote(String s) {
    // POSIX shell single-quote safe quoting
    if (s.isEmpty) return "''";
    return "'${s.replaceAll("'", "'\"'\"'")}'";
  }

  /// 获取过滤后的日志
  /// 注意：访问 logRefreshTrigger 确保 Obx 能监听到日志列表的变化
  List<DebugLogEntry> get filteredLogs {
    // 访问响应式变量，确保 Obx 能监听到变化
    final _ = logRefreshTrigger.value;
    
    var logs = DebugLogger.instance.logs;
    
    // 按级别过滤
    if (logLevelFilter.value != 'ALL') {
      logs = logs.where((log) => log.level == logLevelFilter.value).toList();
    }
    
    // 按标签过滤
    if (logTagFilter.value != 'ALL') {
      logs = logs.where((log) => log.tag == logTagFilter.value).toList();
    }
    
    // 按关键词搜索
    if (logSearchKeyword.value.isNotEmpty) {
      final keyword = logSearchKeyword.value.toLowerCase();
      logs = logs.where((log) {
        return log.message.toLowerCase().contains(keyword) ||
               log.tag.toLowerCase().contains(keyword) ||
               (log.error != null && log.error.toString().toLowerCase().contains(keyword));
      }).toList();
    }
    
    return logs.reversed.toList(); // 最新的在前
  }

  /// 获取所有日志标签
  List<String> get allLogTags {
    final tags = DebugLogger.instance.logs
        .map((log) => log.tag)
        .toSet()
        .toList();
    tags.sort();
    return ['ALL', ...tags];
  }

  /// 获取过滤后的网络请求
  /// 注意：访问 networkRefreshTrigger 确保 Obx 能监听到网络请求列表的变化
  List<NetworkLogEntry> get filteredNetworkLogs {
    // 访问响应式变量，确保 Obx 能监听到变化
    final _ = networkRefreshTrigger.value;
    
    var logs = NetworkLogger.instance.logs;
    
    if (networkStatusFilter.value == 'SUCCESS') {
      logs = logs.where((log) => log.isSuccess).toList();
    } else if (networkStatusFilter.value == 'ERROR') {
      logs = logs.where((log) => log.isError).toList();
    }
    
    return logs.reversed.toList(); // 最新的在前
  }

  /// 清空日志
  void clearLogs() {
    DebugLogger.instance.clear();
    // 触发响应式变量变化，强制 Obx 重新计算 filteredLogs
    logRefreshTrigger.value++;
    // 不使用 Get.snackbar，因为需要 Overlay
    // 可以通过其他方式提示，比如在 UI 中显示提示文本
  }

  /// 设置日志级别过滤
  void setLogLevelFilter(String level) {
    logLevelFilter.value = level;
  }

  /// 设置日志标签过滤
  void setLogTagFilter(String tag) {
    logTagFilter.value = tag;
  }

  /// 设置日志搜索关键词
  void setLogSearchKeyword(String keyword) {
    logSearchKeyword.value = keyword;
  }

  /// 清空网络请求
  void clearNetworkLogs() {
    NetworkLogger.instance.clear();
    // 触发响应式变量变化，强制 Obx 重新计算 filteredNetworkLogs
    networkRefreshTrigger.value++;
  }

  /// 设置网络请求状态过滤
  void setNetworkStatusFilter(String status) {
    networkStatusFilter.value = status;
  }

  /// 导出日志
  Future<void> exportLogs() async {
    final text = DebugLogger.instance.exportLogs();
    if (text.isEmpty) {
      _showPanelToast('当前没有可导出的日志');
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    _showPanelToast('应用日志已复制到剪贴板');
  }

  /// 导出网络请求
  Future<void> exportNetworkLogs() async {
    final text = NetworkLogger.instance.exportLogs();
    if (text.isEmpty) {
      _showPanelToast('当前没有可导出的网络请求');
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    _showPanelToast('网络请求已复制到剪贴板');
  }

  /// 切换环境（仅开发模式）
  Future<void> switchEnvironment(AppEnvironment env) async {
    if (!kDebugMode) return;
    
    final config = envConfig;
    if (config == null) return;

    config.setRuntimeEnvironment(env);
    _showPanelToast('已切换到 $env 环境，应用即将重启以生效');
    await Future.delayed(const Duration(milliseconds: 600));
    await restartOrExitApp();
  }

  /// 重启或退出应用（用于在切换环境后手动重启）
  Future<void> restartOrExitApp() async {
    try {
      await SystemNavigator.pop();
    } catch (_) {
      // Fallback：直接退出进程，仅供调试使用
      exit(0);
    }
  }

  /// 日志变化回调
  void _onLogsChanged() {
    if (isPanelVisible.value && currentTab.value == 0) {
      // 触发响应式变量变化，强制 Obx 重新计算 filteredLogs
      logRefreshTrigger.value++;
    }
  }

  /// 网络日志变化回调
  void _onNetworkLogsChanged() {
    if (isPanelVisible.value && currentTab.value == 1) {
      // 触发响应式变量变化，强制 Obx 重新计算 filteredNetworkLogs
      networkRefreshTrigger.value++;
    }
  }

  void _onPerformanceChanged() {
    if (isPanelVisible.value && currentTab.value == 2) {
      performanceRefreshTrigger.value++;
    }
  }
}
