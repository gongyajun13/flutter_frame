import 'dart:collection';

import 'package:flutter/scheduler.dart';

class FrameRecord {
  final DateTime timestamp;
  final Duration total;
  final Duration build;
  final Duration raster;

  const FrameRecord({
    required this.timestamp,
    required this.total,
    required this.build,
    required this.raster,
  });

  bool get isJank16 => total.inMicroseconds > 16000;
  bool get isJank33 => total.inMicroseconds > 33000;
}

class PageOpenRecord {
  final String pageName;
  final Duration duration;
  final DateTime timestamp;

  const PageOpenRecord({
    required this.pageName,
    required this.duration,
    required this.timestamp,
  });
}

/// 性能监控（帧耗时 / FPS）
///
/// - 基于 [SchedulerBinding.addTimingsCallback]，无侵入采集每帧耗时
/// - 提供简单的聚合指标与慢帧列表，供调试面板展示
class PerformanceMonitor {
  PerformanceMonitor._();
  static final PerformanceMonitor instance = PerformanceMonitor._();

  final List<VoidCallback> _listeners = [];

  bool _enabled = false;
  bool get enabled => _enabled;

  // 最近 N 帧（用于计算 FPS）
  final Queue<int> _recentFrameTimestampsMs = Queue<int>();

  // 慢帧记录（限制数量）
  static const int maxSlowFrames = 80;
  final List<FrameRecord> _slowFrames = [];
  List<FrameRecord> get slowFrames => List.unmodifiable(_slowFrames);

  // 页面打开耗时记录
  static const int maxPageOpens = 50;
  final List<PageOpenRecord> _pageOpens = [];
  List<PageOpenRecord> get pageOpens => List.unmodifiable(_pageOpens);

  String? _currentPageSession;
  String? get currentPageSession => _currentPageSession;

  // 聚合指标
  int _fps = 0;
  int get fps => _fps;

  Duration _avgFrame = Duration.zero;
  Duration get avgFrame => _avgFrame;

  Duration _worstFrame = Duration.zero;
  Duration get worstFrame => _worstFrame;

  int _jank16Count = 0;
  int get jank16Count => _jank16Count;

  int _jank33Count = 0;
  int get jank33Count => _jank33Count;

  int _frameCount = 0;
  int get frameCount => _frameCount;

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void start() {
    if (_enabled) return;
    _enabled = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _notify();
  }

  void stop() {
    if (!_enabled) return;
    _enabled = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _notify();
  }

  void clear() {
    _resetFrameStats();
    _pageOpens.clear();
    _notify();
  }

  /// 重置当前帧统计（不清空页面记录）
  void _resetFrameStats() {
    _recentFrameTimestampsMs.clear();
    _slowFrames.clear();
    _fps = 0;
    _avgFrame = Duration.zero;
    _worstFrame = Duration.zero;
    _jank16Count = 0;
    _jank33Count = 0;
    _frameCount = 0;
  }

  /// 开始新的页面会话：后续 FPS/Jank 等统计都视为此页面的数据
  void startPageSession(String pageName) {
    _currentPageSession = pageName;
    _resetFrameStats();
    _notify();
  }

  /// 记录页面首帧耗时
  void recordPageOpen(String pageName, Duration duration) {
    // 即使当前未开启帧监控，也允许记录页面耗时，方便分析启动/切换时长
    _pageOpens.add(
      PageOpenRecord(
        pageName: pageName,
        duration: duration,
        timestamp: DateTime.now(),
      ),
    );
    if (_pageOpens.length > maxPageOpens) {
      _pageOpens.removeAt(0);
    }
    _notify();
  }

  void _onTimings(List<FrameTiming> timings) {
    if (!_enabled) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // 统计 FPS：保留最近 1s 的帧时间点
    for (int i = 0; i < timings.length; i++) {
      _recentFrameTimestampsMs.addLast(nowMs);
    }
    while (_recentFrameTimestampsMs.isNotEmpty &&
        nowMs - _recentFrameTimestampsMs.first > 1000) {
      _recentFrameTimestampsMs.removeFirst();
    }
    _fps = _recentFrameTimestampsMs.length;

    // 计算平均/最差帧耗时（用本批次 + 当前已有 worst）
    int totalUsSum = 0;
    int count = 0;
    Duration localWorst = _worstFrame;

    for (final t in timings) {
      final total = t.totalSpan;
      totalUsSum += total.inMicroseconds;
      count++;
      if (total > localWorst) localWorst = total;

      if (total.inMicroseconds > 16000) _jank16Count++;
      if (total.inMicroseconds > 33000) _jank33Count++;

      // 记录慢帧（>16ms）
      if (total.inMicroseconds > 16000) {
        _slowFrames.add(
          FrameRecord(
            timestamp: DateTime.now(),
            total: total,
            build: t.buildDuration,
            raster: t.rasterDuration,
          ),
        );
      }
    }

    if (_slowFrames.length > maxSlowFrames) {
      _slowFrames.removeRange(0, _slowFrames.length - maxSlowFrames);
    }

    if (count > 0) {
      _frameCount += count;
      _avgFrame = Duration(microseconds: (totalUsSum / count).round());
      _worstFrame = localWorst;
    }

    _notify();
  }

  void _notify() {
    for (final l in List<VoidCallback>.from(_listeners)) {
      l();
    }
  }
}

