import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_frame/utils/toast_util.dart';
import 'package:flutter_frame/widgets/pixelize/bc_gradient_text_button.dart';
import 'package:flutter_frame/widgets/pixelize/bc_ok_cancel_content.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:flutter_frame/utils/get_extension.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_frame/base/base_controller.dart';
import 'package:flutter_frame/widgets/pixelize/bc_custom_bottom_sheet.dart';
import 'package:flutter_frame/app/routes/app_pages.dart';
import 'package:flutter_frame/utils/pixelize_util.dart';
import 'package:flutter_frame/utils/color_delta.dart';
import 'package:flutter_frame/utils/color_merge_util.dart';
import 'package:flutter_frame/utils/pixel_data_codec_util.dart';
import 'package:flutter_frame/utils/pixel_font_data.dart';
import 'package:flutter_frame/utils/pixel_shape_computer.dart';
import 'package:flutter_frame/utils/pixel_canvas_exporter.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import 'widget/color_switch_dialog.dart';
import 'widget/create_share_setting_dialog.dart';
import 'data/local_draft_store.dart';
import 'data/pixel_project.dart';
import 'data/tool_item.dart';
import 'repository/request.dart';
import 'widget/save_title_dialog.dart';
import 'widget/more_settings_sheet.dart';
import 'widget/color_display_mode_sheet.dart';
import 'widget/color_action_sheet.dart';
import 'data/canvas_tools_status.dart';

/// Isolate 内压缩 pixelCodes（大画板时避免阻塞 UI 线程）
String _compressPixelCodesInIsolate(List<String> codes) {
  return PixelDataCodecUtil.compress(codes);
}

/// 画布界面控制器
class PixelizeResultController extends BaseController
    with WidgetsBindingObserver {
  /// 当前会话绑定的本地草稿 ID（全局仅一份）
  String? _currentLocalDraftId;

  /// 作品保存后已删除草稿时，跳过 onClose 再次落盘
  bool _suppressDraftOnClose = false;

  /// goBack 已处理落盘与作品列表刷新时，onClose 不再重复
  bool _exitRefreshHandled = false;

  /// 实时自动保存防抖间隔（连续绘制时合并为一次落盘）
  static const int _autoSaveDebounceMs = 1200;

  /// 大画板阈值：超过则在 Isolate 中压缩（104×104=10816 留在主线程，避免序列化开销）
  static const int _compressInIsolateThreshold = 20000;

  /// 是否正在写入本地草稿
  bool _isSavingLocalDraft = false;

  /// 当前保存完成后是否需要再保存一次（合并最新编辑）
  bool _pendingAutoSaveAfterCurrent = false;

  /// 画布编辑版本号（每次用户操作递增，用于跳过重复落盘）
  int _canvasEditVersion = 0;

  /// 上次成功落盘时的编辑版本号
  int _lastSavedEditVersion = -1;

  /// 本会话是否已创建初始草稿（从磁盘恢复时跳过）
  bool _initialDraftCreated = false;

  /// 老作品进入时绑定的作品名（草稿展示/导出用，不被草稿时间标题覆盖）
  String? _sessionWorkTitle;

  Timer? _autoSaveDebounce;
  /// 是否已加载完数据（本地参数 or 服务端加载）
  /// 用于页面判断是否显示 PixelCanvas（服务端加载时 originalImage 可能为 null）
  final RxBool isDataLoaded = false.obs;

  /// 原始裁剪图片（用于显示）
  final Rx<File?> originalImage = Rx<File?>(null);

  /// 像素化图片（用于保存）
  final Rx<File?> pixelizedImage = Rx<File?>(null);

  /// 像素化图片信息
  final RxMap<String, dynamic> pixelizedImageInfo = <String, dynamic>{}.obs;

  /// 网格大小标签
  final RxString gridSizeLabel = ''.obs;

  /// 颜色库标签
  final RxString beadBrandLabel = ''.obs;

  /// 使用的颜色列表
  final RxList<Color> usedColors = <Color>[].obs;

  /// 颜色使用统计列表（包含颜色代码、颜色和使用数量）- 主界面显示前20个
  final RxList<Map<String, dynamic>> colorUsageStats =
      <Map<String, dynamic>>[].obs;

  /// 所有使用的颜色列表（用于颜色切换弹窗）
  final RxList<Map<String, dynamic>> allUsedColors =
      <Map<String, dynamic>>[].obs;

  /// 快速访问色列表（从颜色库中选取4个未使用的颜色）
  final RxList<Map<String, dynamic>> quickAccessColors =
      <Map<String, dynamic>>[].obs;

  /// 全部颜色列表（颜色库中的所有颜色）
  final RxList<Map<String, dynamic>> allColors = <Map<String, dynamic>>[].obs;

  /// 颜色选择弹窗选中的颜色列表（最多4个）
  final RxList<Map<String, dynamic>> selectedColors =
      <Map<String, dynamic>>[].obs;

  /// 是否正在加载颜色
  final RxBool isLoadingColors = false.obs;

  /// 像素codes列表
  final RxList<String> pixelCodes = <String>[].obs;

  /// 网格宽度
  final RxInt gridWidth = 0.obs;

  /// 网格高度
  final RxInt gridHeight = 0.obs;

  /// 颜色限制标签
  final RxString colorLimitLabel = ''.obs;

  /// 当前选择的颜色限制索引
  final RxInt selectedColorLimitIndex = (-1).obs;

  /// 当前选择的品牌色索引
  final RxInt selectedBeadBrandIndex = (-1).obs;

  /// 当前使用的颜色限制枚举（用于重新处理）
  ColorLimit? _currentColorLimit;

  /// 当前使用的品牌色枚举（用于重新处理）
  BeadBrand? _currentBeadBrand;

  /// 当前品牌颜色库的 JSON 路径（供 PixelCanvas 使用）
  String get currentBeadBrandPath =>
      _currentBeadBrand?.jsonPath ?? 'assets/mard_colors.json';

  /// 是否正在重新处理中
  final RxBool isReprocessing = false.obs;

  /// 是否为空白画布模式（从新画布创作进入，无原图）
  bool _isBlankCanvasModeFlag = false;

  bool get isBlankCanvasMode => _isBlankCanvasModeFlag;

  /// 原始像素颜色快照（首次切换品牌时捕获，之后永不更新）
  /// 每个元素为 0xRRGGBB 格式的 int，null 表示空白像素
  /// 品牌切换时以此为基准做相似色映射，确保 A→B→A 完全还原
  List<int?> _originalPixelRGBs = [];

  /// 是否已捕获原始快照（仅在首次品牌切换时为 false）
  bool _originalSnapshotReady = false;

  /// 是否正在切换品牌/减色选项（用于 PixelCanvas 判断是否跳过颜色加载）
  bool get isChangingBrandOrColorLimit => isReprocessing.value;

  /// 是否正在显示loading窗
  bool _isShowingLoadingDialog = false;

  /// 品牌色颜色映射（code -> Color）
  final RxMap<String, Color> _beadColorMap = <String, Color>{}.obs;

  Map<String, Color> get beadColorMap => _beadColorMap;

  /// 品牌色颜色映射（Color -> code）
  final RxMap<Color, String> _colorToCodeMap = <Color, String>{}.obs;

  /// 当前工具模式：0-绘画，1-橡皮擦，2-查看
  final Rx<ToolMode> currentToolMode = Rx<ToolMode>(ToolMode.view);

  /// 点位线中心坐标集合（"col,row"格式，支持多个中心点）
  final RxSet<String> _locationLineCenterKeys = <String>{}.obs;

  /// 点位线中心坐标集合（公开只读）
  RxSet<String> get locationLineCenterKeys => _locationLineCenterKeys;

  /// 其他工具状态（多选，可同时启用多个）：方形(13)、网格(14)、代码(15)、编号(16)、参考(17)
  final RxSet<ToolMode> enabledOtherTools =
      <ToolMode>{ToolMode.square, ToolMode.code}.obs;

  /// 是否为圆形像素块模式
  final RxBool isCircleMode = false.obs;

  /// 喷枪大小：1-小，2-中，3-大
  final RxInt sprayGunSize = 1.obs;

  /// 当前选中的形状类型（空字符串表示未选中）
  final RxString selectedShapeType = ''.obs;

  /// 网格粗细（0.5-10.0）
  final RxDouble gridThickness = 3.0.obs;

  /// 粗网格颜色
  final Rx<Color> gridColor = const Color(0xFFFF4444).obs;

  /// 网格起始点偏移
  final Rx<Offset> gridStartPoint = const Offset(1.0, 1.0).obs;

  /// 粗网格间隔
  final RxInt gridSpacing = 10.obs;

  /// 是否显示中虚线
  final RxBool centerDashShow = false.obs;

  /// 是否展示网格
  final RxBool gridShow = false.obs;

  /// 色号显示模式
  final Rx<ColorDisplayMode> colorDisplayMode = ColorDisplayMode.normal.obs;

  /// 画布是否正在缩放中（用于 scale 模式判断）
  final RxBool isCanvasScaling = false.obs;

  /// 当前选中的旋转选项：'left90' | 'right90' | '180'
  final RxString lastRotateOption = ''.obs;

  /// 当前选中的翻转选项：'horizontal' | 'vertical'
  final RxString lastFlipOption = ''.obs;

  /// 待绘制的文本（文本工具用）
  final RxString pendingText = ''.obs;

  /// 浮动文本的位置（像素坐标）
  final Rx<Offset> textPosition = Offset.zero.obs;

  /// 浮动文本的缩放（1.0 = 原始大小）
  final RxDouble textScale = 1.0.obs;

  /// 浮动文本是否正在显示
  final RxBool isTextFloating = false.obs;

  /// 文本选中的网格坐标集合（文本预览时，被文本占用的像素块坐标）
  final RxSet<String> textGridPositions = <String>{}.obs;

  /// 当前画笔颜色代码
  final RxString brushColorCode = ''.obs;

  /// 当前画笔颜色
  final Rx<Color> brushColor = Colors.black.obs;

  /// 颜色切换弹窗中多选的颜色代码列表
  final RxList<String> multiSelectedColorCodes = <String>[].obs;

  /// 颜色切换弹窗中快速访问色选中的颜色代码（"clear"表示清空，null表示未选择）
  final RxnString quickAccessSelectedCode = RxnString();

  /// 颜色切换弹窗专用的快速访问色列表
  final RxList<Map<String, dynamic>> _dialogQuickAccessColors =
      <Map<String, dynamic>>[].obs;

  /// 获取弹窗专用的快速访问色列表（只读）
  RxList<Map<String, dynamic>> get dialogQuickAccessColors =>
      _dialogQuickAccessColors;

  /// 是否有上一步
  final RxBool hasPreStep = false.obs;

  /// 是否有下一步
  final RxBool hasNextStep = false.obs;

  /// 操作历史栈（存储 pixelCodes 的快照）
  final List<List<String>> _historyStack = [];

  /// 历史指针（指向当前状态在 _historyStack 中的位置）
  int _historyIndex = -1;

  /// 最大历史记录数
  static const int _maxHistory = 50;

  /// 防抖器：合并连续绘制操作为一个历史记录
  Timer? _historyDebounce;

  /// 防抖器：合并连续绘制操作的颜色统计
  Timer? _colorStatsDebounce;

  /// 防抖器：合并连续高亮切换的遮罩重算
  Timer? _maskedGridDebounce;

  // ===== 高亮/标记功能相关 =====

  /// 高亮色号集合（支持多个色号同时高亮）
  final RxSet<String> _highlightedCodes = <String>{}.obs;

  /// 获取高亮色号集合的副本
  Set<String> get highlightedCodes => Set.from(_highlightedCodes);

  /// 叠加高亮色号集合
  final RxSet<String> _overlayHighlightedCodes = <String>{}.obs;

  /// 获取叠加高亮色号集合的副本
  Set<String> get overlayHighlightedCodes => Set.from(_overlayHighlightedCodes);

  /// 区域已拼的连通区域集合（存储中心坐标 "col,row"）
  final RxSet<String> _areaPinnedRegions = <String>{}.obs;

  /// 同一色号已拼好的色号集合
  final RxSet<String> _sameColorPinnedCodes = <String>{}.obs;

  /// 需要遮罩显示的像素块集合（非高亮色号的像素）
  final RxSet<String> _maskedGridKeys = <String>{}.obs;

  /// 需要显示✅标记的像素块集合（区域已拼/同色已拼好）
  final RxSet<String> _checkedGridKeys = <String>{}.obs;

  /// 获取遮罩像素集合（供 PixelCanvas 读取）
  RxSet<String> get maskedGridKeys => _maskedGridKeys;

  /// 获取✅标记像素集合（供 PixelCanvas 读取）
  RxSet<String> get checkedGridKeys => _checkedGridKeys;

  /// 获取区域已拼集合（供 ColorActionSheet 读取）
  RxSet<String> get areaPinnedRegions => _areaPinnedRegions;

  /// 获取同色已拼好色号集合（供 ColorActionSheet 读取）
  RxSet<String> get sameColorPinnedCodes => _sameColorPinnedCodes;

  /// 画板变换控制器（用于缩放和平移控制）
  final TransformationController transformationController =
      TransformationController();

  /// 画板显示尺寸（由 PixelCanvas 更新，用于以中心缩放）
  final Rx<Size> canvasDisplaySize = Size.zero.obs;

  // 其他工具相关
  /// 像素块item是否为方形，false为圆形
  final RxBool isItemShape = true.obs;

  bool isSelfPost = true;
  bool isFromPostDetail = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadArguments();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_exitRefreshHandled) {
      if (!_suppressDraftOnClose) {
        _scheduleDraftFlushOnExit();
      }
    }
    _maskedGridDebounce?.cancel();
    _historyDebounce?.cancel();
    _colorStatsDebounce?.cancel();
    // 清理从网络下载的临时原始图片文件（服务端加载场景）
    _cleanupTempOriginalImage();
    super.onClose();
  }

  /// 离开画板前异步冲刷未落盘草稿（不阻塞返回动画）
  void _scheduleDraftFlushOnExit() {
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = null;
    unawaited(_flushPendingDebounces());
  }

  /// 直接离开画板：立即返回，后台补齐最后一次草稿与缩略图
  void _leaveCanvasImmediately() {
    _exitRefreshHandled = true;
    if (!_suppressDraftOnClose) {
      _scheduleDraftFlushOnExit();
    }
    if (Get.currentRoute == Routes.PIXELIZE_RESULT) {
      Get.back();
    }
  }

  /// 是否为已发布/已保存的老作品（有服务端 projectId）
  bool _isExistingProjectSession() {
    final id = currentProjectId?.trim();
    return id != null && id.isNotEmpty;
  }

  /// 绑定老作品会话：固定 projectId 与作品名，供草稿命名与更新保存使用
  void _bindExistingWorkSession({String? projectId, String? workTitle}) {
    final id = projectId?.trim();
    if (id != null && id.isNotEmpty) {
      currentProjectId = id;
    }
    final title = workTitle?.trim();
    if (title != null &&
        title.isNotEmpty &&
        !isAutoLocalDraftTitle(title)) {
      _sessionWorkTitle = title;
      currentProjectTitle = title;
    }
  }

  /// 老作品会话作品名（保存/更新作品、导出用；草稿展示名固定为「本地草稿 HH:mm」）
  String? _sessionWorkTitleForSave(Map<String, dynamic>? existingRaw) {
    final session = _sessionWorkTitle?.trim();
    if (session != null &&
        session.isNotEmpty &&
        !isAutoLocalDraftTitle(session)) {
      return session;
    }
    final stored = (existingRaw?['workTitle'] as String?)?.trim();
    if (stored != null &&
        stored.isNotEmpty &&
        !isAutoLocalDraftTitle(stored)) {
      return stored;
    }
    final current = currentProjectTitle?.trim();
    if (current != null &&
        current.isNotEmpty &&
        !isAutoLocalDraftTitle(current)) {
      return current;
    }
    return null;
  }

  /// 草稿目录是否已有画布渲染的缩略图（仅认 thumbnail.png，不含原图占位）
  Future<bool> _hasDraftCanvasThumbnail(String draftDir) async {
    final thumbPath = p.join(draftDir, 'thumbnail.png');
    return File(thumbPath).exists();
  }

  /// 是否应在本次保存中渲染/刷新画布缩略图
  Future<bool> _shouldRenderDraftThumbnail({
    required bool updateThumbnail,
    required String draftDir,
  }) async {
    if (updateThumbnail) return true;
    return !await _hasDraftCanvasThumbnail(draftDir);
  }

  /// 仅查看会话：对齐编辑版本基线，避免初始化/退出时误判为有未保存编辑
  void _baselineDraftVersionForViewOnlySession() {
    if (!_initialDraftCreated) {
      _lastSavedEditVersion = _canvasEditVersion;
    }
  }

  /// 老作品仅查看：对齐编辑版本基线，避免退出/冲刷时误判为有未保存编辑
  void _baselineDraftVersionForViewOnlyExistingProject() {
    if (_isExistingProjectSession()) {
      _baselineDraftVersionForViewOnlySession();
    }
  }

  /// 进入画板且数据就绪后创建初始草稿（从磁盘恢复时跳过）
  Future<void> _onCanvasSessionReady() async {
    if (_suppressDraftOnClose || _currentLocalDraftId == null) return;
    if (_initialDraftCreated) return;
    // 老作品 / 空白画板：进入时不落盘，待绘制或其它编辑后再保存草稿
    if (_isExistingProjectSession() || isBlankCanvasMode) return;
    if (!_canPersistDraft(allowEmptyCanvas: true)) return;

    _initialDraftCreated = true;
    await _saveLocalDraft(
      reason: 'init',
      force: true,
      updateThumbnail: true,
      allowEmptyCanvas: true,
    );
    _lastSavedEditVersion = _canvasEditVersion;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _onAppBackgrounded(state);
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.resumed:
        debugPrint('[结果页面] App 回到前台');
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// App 退到后台（paused / hidden）
  void _onAppBackgrounded(AppLifecycleState state) {
    debugPrint('[结果页面] App 进入后台: $state');
    _flushPendingDebounces();
    _flushDraftForLifecycle(reason: state.name, copyOriginalImage: true);
  }

  /// App 进程即将被系统回收（Android 低内存 / 部分平台退出前）
  void _onAppDetached() {
    debugPrint('[结果页面] App 进程即将结束 (detached)');
    _flushPendingDebounces();
    _flushDraftForLifecycle(reason: 'detached', copyOriginalImage: true);
  }

  /// 取消防抖定时器；若有未落盘编辑则冲刷草稿
  Future<void> _flushPendingDebounces() async {
    _historyDebounce?.cancel();
    _historyDebounce = null;
    _colorStatsDebounce?.cancel();
    _colorStatsDebounce = null;
    _maskedGridDebounce?.cancel();
    _maskedGridDebounce = null;
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = null;

    if (!_hasUnsavedDraftEdits()) return;

    await _saveLocalDraft(
      reason: 'flush',
      syncWrite: false,
      copyOriginalImage: false,
      force: true,
      updateThumbnail: true,
    );
  }

  /// 本会话是否存在需要落盘的草稿编辑
  bool _hasUnsavedDraftEdits() {
    return _canvasEditVersion > _lastSavedEditVersion;
  }

  /// 草稿生命周期落盘（退后台 / 页面销毁等界面不可见时），与作品保存无关
  void _flushDraftForLifecycle({
    required String reason,
    bool copyOriginalImage = false,
    bool updateThumbnail = true,
  }) {
    if (_suppressDraftOnClose) return;
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = null;
    if (!_hasUnsavedDraftEdits()) return;
    _saveLocalDraft(
      reason: reason,
      syncWrite: true,
      copyOriginalImage: copyOriginalImage,
      force: true,
      updateThumbnail: updateThumbnail,
    );
  }

  /// 标记画布已编辑，触发防抖实时保存
  void _markCanvasDirty() {
    if (_suppressDraftOnClose) return;
    if (!isDataLoaded.value || isReprocessing.value) return;
    if (!_canPersistDraft(allowEmptyCanvas: _initialDraftCreated)) return;
    _canvasEditVersion++;
    _scheduleAutoSaveDraft();
  }

  /// 防抖调度实时保存（连续绘制合并为一次异步落盘）
  void _scheduleAutoSaveDraft() {
    if (_suppressDraftOnClose) return;
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(
      const Duration(milliseconds: _autoSaveDebounceMs),
      () {
        _saveLocalDraft(
          reason: 'auto',
          syncWrite: false,
          copyOriginalImage: false,
          updateThumbnail: true,
        );
      },
    );
  }

  /// 清理临时下载的原始图片
  Future<void> _cleanupTempOriginalImage() async {
    final img = originalImage.value;
    if (img != null && await img.exists()) {
      // 只清理 reprocess_original 开头的临时文件，不删除本地传入的真实文件
      final path = img.path;
      if (path.contains('/reprocess_original_')) {
        try {
          await img.delete();
          debugPrint('[结果页面] 已清理临时原始图片: $path');
        } catch (_) {}
      }
    }
  }

  /// 加载传递的参数
  Future<void> _loadArguments() async {
    debugPrint('[结果页面] 开始加载参数');

    // 每次加载前先重置所有状态，防止复用旧 controller 实例时数据残留
    pixelCodes.value = [];
    pendingText.value = '';
    isTextFloating.value = false;
    _historyStack.clear();
    _historyIndex = -1;
    currentProjectId = null;
    currentProjectTitle = null;
    _sessionWorkTitle = null;
    _currentLocalDraftId = null;
    // 重置为默认启用的工具（方形+代码），后续会被 args['enabledTools'] 覆盖（如果有）
    enabledOtherTools.assignAll({ToolMode.square, ToolMode.code});

    final args = Get.arguments as Map<String, dynamic>?;

    final openDraft = args?['restoreLocalDraft'] == true ||
        args?['localDraftId'] != null ||
        args?['draftId'] != null;
    if (openDraft) {
      final draftId = args?['draftId'] as String? ??
          args?['localDraftId'] as String? ??
          LocalDraftStore.singleDraftId;
      final restored = await _restoreLocalDraft(draftId);
      if (!restored) {
        showToast('草稿恢复失败或已损坏');
        Get.back();
      }
      return;
    }

    if (args == null) return;

    // 空白画布模式
    final isBlankCanvas = args['isBlankCanvas'] as bool? ?? false;
    if (isBlankCanvas) {
      _currentLocalDraftId = LocalDraftStore.singleDraftId;
      _initBlankCanvas(args);
      if (pixelCodes.isNotEmpty && gridWidth.value > 0 && gridHeight.value > 0) {
        await _loadUsedColors(updateDefaultBrushColor: true);
      }
      _baselineDraftVersionForViewOnlySession();
      return;
    }

    // 图片像素化模式（本地参数）
    _currentLocalDraftId = LocalDraftStore.singleDraftId;
    await _initWithLocalArgs(args);
    _baselineDraftVersionForViewOnlySession();
  }

  /// 使用本地参数初始化（新建作品或带完整数据的场景）
  Future<void> _initWithLocalArgs(Map<String, dynamic> args) async {
    // 标记数据已加载（用于页面显示 PixelCanvas）
    isDataLoaded.value = true;

    // 接收原始裁剪图片（用于显示）
    originalImage.value = args['originalImage'] as File?;
    debugPrint('[结果页面] 原始图片: ${originalImage.value?.path}');
    // 接收像素化图片（用于保存）
    pixelizedImage.value = args['pixelizedImage'] as File?;
    debugPrint('[结果页面] 像素化图片: ${pixelizedImage.value?.path}');
    final info = args['pixelizedImageInfo'] as Map<String, dynamic>?;
    if (info != null) {
      pixelizedImageInfo.assignAll(info);
      debugPrint('[结果页面] 图片信息: $info');
    }
    gridSizeLabel.value = args['gridSize'] as String? ?? '';
    colorLimitLabel.value = args['colorLimit'] as String? ?? '';
    beadBrandLabel.value = args['beadBrand'] as String? ?? '';

    // 保存原始枚举值（用于重新处理）
    _currentColorLimit = args['colorLimitEnum'] as ColorLimit?;
    _currentBeadBrand = args['beadBrandEnum'] as BeadBrand?;
    debugPrint('[结果页面] 接收到的枚举:');
    debugPrint('[结果页面] _currentColorLimit: ${_currentColorLimit?.label}');
    debugPrint('[结果页面] _currentBeadBrand: ${_currentBeadBrand?.displayName}');

    // 根据枚举设置初始索引
    if (_currentColorLimit != null) {
      selectedColorLimitIndex.value = _currentColorLimit!.index;
    }

    if (_currentBeadBrand != null) {
      selectedBeadBrandIndex.value = _currentBeadBrand!.index;
    }

    // 接收像素codes和网格信息（必须深拷贝，防止修改时污染源数据）
    final codes = args['pixelCodes'] as List<String>?;
    if (codes != null) {
      pixelCodes.value = List<String>.from(codes);
      debugPrint('[结果页面] 像素codes数量: ${pixelCodes.length}');
      // 保存初始状态到历史栈（初始化不计入实时保存）
      _pushHistory(pixelCodes.toList(), scheduleAutoSave: false);
    }
    final width = args['gridWidth'] as int?;
    if (width != null) {
      gridWidth.value = width;
    }
    final height = args['gridHeight'] as int?;
    if (height != null) {
      gridHeight.value = height;
    }

    // 接收项目 ID（从作品列表恢复编辑时传入）
    currentProjectId = args['projectId'] as String?;

    // 恢复已启用的工具状态
    final tools = args['enabledTools'] as List<int>?;
    if (tools != null && tools.isNotEmpty) {
      enabledOtherTools.assignAll(
        tools
            .map((v) => ToolMode.fromValue(v))
            .whereType<ToolMode>()
            .where((m) => m != ToolMode.reference && m != ToolMode.number),
      );
    }

    // 加载颜色映射表（必须先加载，画布才能正确渲染）
    await _loadUsedColors(updateDefaultBrushColor: true);
    await _onCanvasSessionReady();
  }

  /// 初始化空白画布（新画布创作模式，无像素数据、无图片）
  void _initBlankCanvas(Map<String, dynamic> args) {
    debugPrint('[结果页面] 初始化空白画布');

    isDataLoaded.value = true;
    _isBlankCanvasModeFlag = true; // 标记空白画布模式

    // 接收网格尺寸
    final w = args['gridWidth'] as int? ?? 32;
    final h = args['gridHeight'] as int? ?? 32;
    gridWidth.value = w;
    gridHeight.value = h;

    // 初始化全空 pixelCodes（每个格子都是空字符串，表示无颜色）
    final total = w * h;
    pixelCodes.value = List.filled(total, '');

    // 设置默认品牌为 MARD（用于加载颜色库供用户选色绘画）
    _currentBeadBrand = BeadBrand.mard;
    selectedBeadBrandIndex.value = BeadBrand.mard.index;

    // 设置默认颜色限制
    _currentColorLimit = ColorLimit.unlimited;
    selectedColorLimitIndex.value = ColorLimit.unlimited.index;

    // 保存初始状态到历史栈（初始化不计入实时保存）
    _pushHistory(pixelCodes.toList(), scheduleAutoSave: false);

    gridSizeLabel.value = '${w}×$h';
    beadBrandLabel.value = BeadBrand.mard.displayName;

    debugPrint('[结果页面] 空白画布尺寸: $w × $h, 像素总数: $total');
  }

  /// 使用 PixelProject 对象初始化（从其他界面直接传递 project 对象的场景）
  ///
  /// 与 [_loadFromServer] 的区别：无需网络请求，数据已就绪
  Future<void> _initWithProject(PixelProject project) async {
    debugPrint('[结果页面] 使用 Project 对象初始化: ${project.title}');

    final loadedId = project.id.trim();
    final loadedTitle = project.title.trim();
    if (loadedId.isNotEmpty) {
      currentProjectId = loadedId;
    }
    if (loadedTitle.isNotEmpty && !isAutoLocalDraftTitle(loadedTitle)) {
      _sessionWorkTitle ??= loadedTitle;
      currentProjectTitle = _sessionWorkTitle;
    } else if (_sessionWorkTitle != null) {
      currentProjectTitle = _sessionWorkTitle;
    } else {
      currentProjectTitle = loadedTitle.isNotEmpty ? loadedTitle : null;
    }

    // 标记数据已加载
    isDataLoaded.value = true;

    // 填充网格尺寸
    gridWidth.value = project.gridWidth;
    gridHeight.value = project.gridHeight;
    gridSizeLabel.value = '${project.gridWidth}x${project.gridHeight}';

    // 填充像素数据（深拷贝，防止修改时污染源数据）
    if (project.pixelCodes.isNotEmpty) {
      pixelCodes.value = List<String>.from(project.pixelCodes);
      debugPrint('[结果页面] 像素codes数量: ${pixelCodes.length}');
      _pushHistory(pixelCodes.toList(), scheduleAutoSave: false);
    }

    // 解析品牌和减色选项
    _currentBeadBrand = BeadBrand.fromKey(project.beadBrandKey);
    _currentColorLimit = ColorLimit.fromLimit(project.colorLimitValue);
    beadBrandLabel.value = _currentBeadBrand?.displayName ?? '';
    colorLimitLabel.value = _currentColorLimit?.label ?? '';
    selectedBeadBrandIndex.value = _currentBeadBrand?.index ?? 0;
    selectedColorLimitIndex.value = _currentColorLimit?.index ?? 0;

    debugPrint(
        '[结果页面] 品牌: ${_currentBeadBrand?.displayName}, 减色: ${_currentColorLimit?.label}');

    // 缩略图 URL
    if (project.picture != null) {
      pixelizedImageInfo['picture'] = project.picture;
    }

    // 原始图片 URL（用于重新处理）
    if (project.originalImage != null) {
      originalImageUrl = project.originalImage;
      debugPrint('[结果页面] 原始图 URL: $originalImageUrl');
    }

    // 恢复已启用的工具状态
    if (project.enabledTools.isNotEmpty) {
      enabledOtherTools.assignAll(
        project.enabledTools
            .map((v) => ToolMode.fromValue(v))
            .whereType<ToolMode>()
            .where((m) => m != ToolMode.reference && m != ToolMode.number),
      );
    }

    // 恢复画布工具配置（网格、色号显示模式等）
    if (project.tools != null && !isFromPostDetail) {
      final t = project.tools!;
      gridShow.value = t.gridShow;
      gridSpacing.value = t.gridSpacing;
      centerDashShow.value = t.centerDashShow;
      gridThickness.value = t.gridThickness;
      gridColor.value = t.gridColorValue;
      gridStartPoint.value = t.gridStartPoint;
      colorDisplayMode.value = t.colorDisplayMode;

      // 恢复高亮/已拼标记数据
      if (t.highlightedCodes.isNotEmpty) {
        _highlightedCodes.assignAll(t.highlightedCodes);
      }
      if (t.overlayHighlightedCodes.isNotEmpty) {
        _overlayHighlightedCodes.assignAll(t.overlayHighlightedCodes);
      }

      // 恢复区域已拼 + 重算 checkedGridKeys（BFS 从每个中心点扩展连通区域）
      if (t.areaPinnedRegions.isNotEmpty) {
        _areaPinnedRegions.assignAll(t.areaPinnedRegions);
        for (final regionKey in t.areaPinnedRegions) {
          final parts = regionKey.split(',');
          if (parts.length == 2) {
            final col = int.tryParse(parts[0]);
            final row = int.tryParse(parts[1]);
            if (col != null && row != null) {
              final index = row * gridWidth.value + col;
              if (index >= 0 && index < pixelCodes.length) {
                final code = pixelCodes[index];
                if (code.isNotEmpty) {
                  _checkedGridKeys.addAll(_findConnectedRegion(col, row, code));
                }
              }
            }
          }
        }
      }

      // 恢复同色已拼好 + 重算 checkedGridKeys（全画布遍历该色号）
      if (t.sameColorPinnedCodes.isNotEmpty) {
        _sameColorPinnedCodes.assignAll(t.sameColorPinnedCodes);
        for (int i = 0; i < pixelCodes.length; i++) {
          final code = pixelCodes[i];
          if (code.isNotEmpty && t.sameColorPinnedCodes.contains(code)) {
            final row = i ~/ gridWidth.value;
            final col = i % gridWidth.value;
            _checkedGridKeys.add('$col,$row');
          }
        }
      }

      // 高亮/叠加高亮色号恢复后，重新计算遮罩像素集合
      if (_highlightedCodes.isNotEmpty || _overlayHighlightedCodes.isNotEmpty) {
        _updateMaskedGridKeys();
      }

      // gridShow 为 true 时，同步选中工具栏网格 item
      if (t.gridShow && !enabledOtherTools.contains(ToolMode.grid)) {
        enabledOtherTools.add(ToolMode.grid);
      }

      // colorDisplayMode 非 hidden 时，同步选中代码工具 item
      final codeEnabled = t.colorDisplayMode != ColorDisplayMode.hidden;
      if (codeEnabled && !enabledOtherTools.contains(ToolMode.code)) {
        enabledOtherTools.add(ToolMode.code);
      } else if (!codeEnabled && enabledOtherTools.contains(ToolMode.code)) {
        enabledOtherTools.remove(ToolMode.code);
      }

      debugPrint(
          '[结果页面] 工具配置恢复: gridShow=${t.gridShow}, colorDisplayMode=${t.colorDisplayMode}');
    }

    // 加载颜色映射表（必须先加载，画布才能正确渲染）
    await _loadUsedColors(updateDefaultBrushColor: true);
  }

  /// 从服务端加载作品详情（只传了 projectId 的场景）
  Future<void> _loadFromServer(String projectId) async {
    // 延迟到 build 完成后再显示 loading，避免 visitChildElements() 错误
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.loading();
    });
    try {
      final request = PixelImgRequest();
      final project = await request.getWorksDetail(projectId);
      if (project == null) {
        showToast('作品不存在或已被删除');
        Get.dismiss();
        Get.back();
        return;
      }

      debugPrint('[结果页面] 服务端数据加载成功: ${project.title}');

      // 复用 _initWithProject 的公共逻辑
      _initWithProject(project);

      // 加载颜色映射表（必须先加载，画布才能正确渲染）
      await _loadUsedColors(updateDefaultBrushColor: true);
      await _onCanvasSessionReady();
      _baselineDraftVersionForViewOnlyExistingProject();
    } catch (e) {
      debugPrint('[结果页面] 加载服务端数据失败: $e');
      showToast('加载失败，请重试');
      Get.dismiss();
      Get.back();
      return;
    } finally {
      Get.dismiss();
    }
  }

  /// 返回：不保存退出 / 保存退出
  void confirmExit() {
    Get.dialog<bool>(
      const BCOkCancelContent(
        title: '确认退出',
        content: '你编辑的画布还未保存到作品，确认退出吗？',
        cancelText: '不保存退出',
        okText: '保存退出',
      ),
      barrierDismissible: false,
    ).then((result) async {
      if (result == null) {
        _leaveCanvasImmediately();
        return;
      }
      if (result == true) {
        await _saveWorkAndExit();
      }
    });
  }

  /// 标题栏按钮：0 保存 / 1 导出
  void titleOption(int index) async {
    if (_isBlankCanvas()) {
      showToast('请先绘制数据');
      return;
    }
    if (index == 0) {
      if (currentProjectId != null && isSelfPost) {
        showSaveExitedProjectSheet();
      } else {
        if (!isSelfPost) {
          currentProjectId = null;
          currentProjectTitle = null;
        }
        saveProject();
      }
    } else if (index == 1) {
      final settings = await CreateShareSettingDialog.show();
      if (settings == null) return;
      await saveImage(
        showText: settings[0],
        showGrid: settings[1],
        showNumberBorder: settings[2],
        showBoldGrid: settings[3],
        showColorLegend: settings[4],
      );
    }
  }

  /// 保存/更新作品后退出画板（弹标题、刷新作品列表）
  Future<void> _saveWorkAndExit() async {
    final result = await _saveWorkCore(
      currentTitle: currentProjectTitle ?? '',
      showTitleDialog: true,
    );
    if (result == null) return;

    debugPrint('[保存退出] 项目ID: $currentProjectId, 标题: $currentProjectTitle');
    showToast('保存成功');
    if (Get.currentRoute == Routes.PIXELIZE_RESULT) {
      Get.back();
    }
  }

  /// 显示加载对话框
  void _showLoadingDialog() {
    if (_isShowingLoadingDialog) return;
    _isShowingLoadingDialog = true;
    Get.loading();
  }

  /// 导出图片到相册
  Future<void> exportImage() async {
    titleOption(1);
  }

  /// 保存已存在缓存的项目
  void showSaveExitedProjectSheet() async {
    final result = await Get.bottomSheet(BCCustomBottomSheet(
        title: '更新/另存',
        subTitle: '你想要更新现有的项目，还是保存为新项目？',
        items: ['另存为新项目', '更新', '取消']));
    if (result == null) {
      return;
    }
    final index = result.$1;
    if (index == 0) {
      // 另存为新项目
      await _saveAsNewProject();
    } else if (index == 1) {
      // 更新现有项目
      await _updateExistingProject();
    }
    // index == 2 是取消，不需要处理
  }

  /// 另存为新项目
  Future<void> _saveAsNewProject() async {
    // 临时保存原项目ID和标题
    final originalProjectId = currentProjectId;
    final originalProjectTitle = currentProjectTitle;
    final originalSessionWorkTitle = _sessionWorkTitle;

    // 清空 currentProjectId 以便生成新ID
    currentProjectId = null;
    _sessionWorkTitle = null;
    // 保留原标题作为新项目的默认标题（方便用户修改）

    // 调用保存方法
    await saveProject();

    // 如果保存失败（currentProjectId 仍为 null），恢复原项目ID和标题
    if (currentProjectId == null) {
      currentProjectId = originalProjectId;
      currentProjectTitle = originalProjectTitle;
      _sessionWorkTitle = originalSessionWorkTitle;
    }
  }

  /// 更新现有项目（复用 saveProject 保存到服务端）
  Future<void> _updateExistingProject() async {
    // saveProject 已改为服务端保存，直接调用即可
    await saveProject();
  }

  /// 导出图片并分享
  Future<void> saveImage({
    bool showText = true,
    bool showGrid = true,
    bool showNumberBorder = false,
    bool showBoldGrid = false,
    bool showColorLegend = false,
  }) async {
    try {
      await PixelCanvasExporter.presentSaveAndShare(
        generateBytes: () => saveCanvasImage(
          showText: showText,
          showGrid: showGrid,
          showBoldGrid: showBoldGrid,
          showNumberBorder: showNumberBorder,
          showColorLegend: showColorLegend,
          showBrandFrame: true,
        ),
      );
    } catch (e) {
      showToast('导出失败: $e');
    }
  }

  /// 当前项目 ID（从外部恢复编辑时传入，为空表示新项目）
  String? currentProjectId;

  /// 当前项目标题
  String? currentProjectTitle;

  /// 原始图片服务端 URL（从详情接口获取，用于保存时传给服务端）
  String? originalImageUrl;

  /// 保存作品到服务端（含 UI 交互：弹标题、loading、toast、自动返回）
  Future<void> saveProject() async {
    final result = await _saveWorkCore(
      currentTitle: currentProjectTitle != null ? currentProjectTitle! : '',
      showTitleDialog: true,
    );
    if (result == null) {
      return; // 用户取消或保存失败
    }
    debugPrint('[保存项目] 项目ID: $currentProjectId, 标题: $currentProjectTitle');
    showToast('保存成功');
    Get.dismiss();
    Get.until((route) => Get.currentRoute == Routes.HOME);
  }

  /// 核心保存逻辑（生成缩略图 → 上传 → 调保存接口），不包含 UI 返回操作
  ///
  /// [currentTitle] 作品标题（新作品默认 '我的作品'，已有作品用原标题）
  /// [showTitleDialog] 是否弹出标题输入框（发布时为 false，直接用默认标题）
  /// 返回 {'beanId': ..., 'pictureUrl': ...}，失败或用户取消返回 null
  Future<Map<String, String>?> _saveWorkCore({
    required String currentTitle,
    bool showTitleDialog = true,
  }) async {
    if (pixelCodes.isEmpty || gridWidth.value == 0 || gridHeight.value == 0) {
      showToast('画板数据为空，无法保存');
      return null;
    }

    // 1. 弹出标题输入框（可选）
    String title = currentTitle;
    if (showTitleDialog) {
      final inputTitle = await _showTitleDialog(currentTitle: title);
      if (inputTitle == null || inputTitle.trim().isEmpty) {
        return null; // 用户取消
      }
      title = inputTitle.trim();
    }

    // 2. 显示 loading
    Get.loading();
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      // 3. 准备需要上传的文件列表（缩略图 + 原图）
      final filesToUpload = <String>[];
      String? thumbnailPath;

      // 缩略图（必须）
      final thumbnailBytes = await saveCanvasImage(
        pixelSize: 50,
        showText: false,
        showGrid: false,
      );
      if (thumbnailBytes != null) {
        final dir = Directory.systemTemp;
        thumbnailPath =
            '${dir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.png';
        File(thumbnailPath).writeAsBytesSync(thumbnailBytes);
        filesToUpload.add(thumbnailPath);
      }

      // 原图（如果有本地文件且尚未有服务端 URL）
      if (originalImage.value != null &&
          await originalImage.value!.exists() &&
          (originalImageUrl == null || originalImageUrl!.isEmpty)) {
        filesToUpload.add(originalImage.value!.path);
      }

      // 4. 批量上传（一次请求传多个 file，服务端已支持多文件）
      List<String?> uploadedUrls = [];
      if (filesToUpload.isNotEmpty) {
        final request = PixelImgRequest();
        uploadedUrls = await request.uploadImages(filesToUpload);
      }

      // 解析结果：第一个是缩略图 URL
      String? pictureUrl;
      if (filesToUpload.isNotEmpty && uploadedUrls.isNotEmpty) {
        pictureUrl = uploadedUrls[0];
      }
      if (pictureUrl == null) {
        showToast('上传图片失败，请重试');
        Get.dismiss();
        return null;
      }

      // 如果有原图需要保存 URL（第二个或使用已有的 originalImageUrl）
      if (originalImage.value != null &&
          await originalImage.value!.exists() &&
          (originalImageUrl == null || originalImageUrl!.isEmpty) &&
          uploadedUrls.length >= 2) {
        originalImageUrl = uploadedUrls[1];
        debugPrint('[保存项目] 原图上传成功: $originalImageUrl');
      }

      // 清理临时缩略图文件
      try {
        final tmpFile = File(thumbnailPath!);
        if (await tmpFile.exists()) {
          await tmpFile.delete();
        }
      } catch (_) {}

      // 5. 压缩像素数据
      final compressedPixelData = PixelDataCodecUtil.compress(pixelCodes);
      debugPrint('[保存项目] 像素数据压缩后大小: ${compressedPixelData.length} 字符');

      // 6. 调用服务端保存接口（originalImageUrl 已在上一步更新或已有缓存）
      final request = PixelImgRequest();
      // 复用已有的颜色统计数据，格式为 ["code:count", ...]
      final colorDataList =
          allUsedColors.map((e) => '${e['code']}:${e['count']}').toList();
      final result = await request.saveWorks(
        isBlankCanvasMode ? 2 : 3,
        title,
        pictureUrl,
        originalImageUrl ?? '',
        compressedPixelData,
        PixelDataCodecUtil.encodingType,
        _currentBeadBrand?.key ?? 'mard',
        gridWidth.value,
        gridHeight.value,
        colorDataList,
        id: currentProjectId,
        colorLimitValue: _currentColorLimit?.limit ?? -1,
        toolData: CanvasToolsStatus(
          gridShow: gridShow.value,
          gridSpacing: gridSpacing.value,
          centerDashShow: centerDashShow.value,
          gridThickness: gridThickness.value,
          gridColor: gridColor.value.toARGB32(),
          gridStartPointX: gridStartPoint.value.dx,
          gridStartPointY: gridStartPoint.value.dy,
          colorDisplayMode: colorDisplayMode.value,
          highlightedCodes: Set.from(_highlightedCodes),
          overlayHighlightedCodes: Set.from(_overlayHighlightedCodes),
          areaPinnedRegions: Set.from(_areaPinnedRegions),
          sameColorPinnedCodes: Set.from(_sameColorPinnedCodes),
        ).toJsonString(),
      );

      if (result == null) {
        showToast('保存失败，请检查网络后重试');
        Get.dismiss();
        return null;
      }

      // 7. 如果是新保存（无 id），用返回的 id 更新
      currentProjectId ??= result;
      currentProjectTitle = title;

      // 8. 同步封面图链接到 imageInfo
      if (pixelizedImageInfo['picture'] == null ||
          (pixelizedImageInfo['picture'] as String).isEmpty) {
        pixelizedImageInfo['picture'] = pictureUrl;
      }

      await _finalizeWorkSavedSession();

      Get.dismiss();
      return {'beanId': currentProjectId!, 'pictureUrl': pictureUrl};
    } catch (e) {
      debugPrint('[保存项目] 保存失败: $e');
      showToast('保存失败: $e');
      Get.dismiss();
      return null;
    }
  }

  /// 当前会话是否存在需要随发布同步到服务端的本地草稿
  Future<bool> _hasPublishableLocalDraft() async {
    if (!_initialDraftCreated) return false;
    if (!await LocalDraftStore.exists(LocalDraftStore.singleDraftId)) {
      return false;
    }
    final raw = await LocalDraftStore.readMeta(LocalDraftStore.singleDraftId);
    return raw != null && raw['localDraft'] == true;
  }

  /// 发布到发帖界面
  Future<void> _publishToPostSend() async {
    final defaultTitle =
        currentProjectTitle != null && currentProjectTitle!.isNotEmpty
            ? currentProjectTitle!
            : '我的作品';

    String? beanId;
    String? coverImage;

    // 判断是否需要保存：
    // 1. 新作品（无 projectId）→ 走创建接口
    // 2. 已有作品 + 有修改 → 走更新接口（带 currentProjectId）
    // 3. 存在与当前作品匹配的本地草稿 → 先同步再发布
    // 4. 从作品列表进入且未改动 → 直接带 beanId 跳转（仅清理与当前作品绑定的草稿）
    final isNewProject =
        currentProjectId == null || currentProjectId!.trim().isEmpty;
    final hasModifications = _historyStack.length > 1;
    final hasRelevantDraft = await _hasPublishableLocalDraft();
    final needSave = isNewProject || hasModifications || hasRelevantDraft;

    if (needSave) {
      // 先保存/更新作品（不弹标题框；有 id 时 saveWorks 走更新）
      final result = await _saveWorkCore(
        currentTitle: defaultTitle,
        showTitleDialog: false,
      );
      if (result == null) {
        return; // 保存失败
      }
      beanId = result['beanId'] as String;
      coverImage = result['pictureUrl'] as String?;
    } else {
      // 已有作品且未修改：直接发布；仅清理与当前作品绑定的草稿
      beanId = currentProjectId;
      coverImage = pixelizedImageInfo['picture'] as String?;
      await _finalizeWorkSavedSession();
    }

    // Demo 环境无发帖页，保存成功后提示即可
    showToast('作品已保存，发布功能需在完整版 App 中使用');
    Get.until((route) => Get.currentRoute == Routes.HOME);
  }

  /// 显示标题输入弹窗，返回用户输入的标题或 null（取消）
  Future<String?> _showTitleDialog({String currentTitle = ''}) async {
    return await showSaveTitleDialog(currentTitle: currentTitle);
  }

  /// 列出所有本地草稿（按更新时间倒序，供草稿列表 UI 使用）
  static Future<List<LocalDraftSummary>> listLocalDrafts() {
    return LocalDraftStore.listSummaries();
  }

  /// 删除指定本地草稿
  static Future<void> deleteLocalDraft(String draftId) {
    return LocalDraftStore.deleteDraft(draftId);
  }

  /// 写入草稿 meta 的老作品 id（无则空字符串）
  String _beanProjectIdForDraftMeta() {
    final id = currentProjectId?.trim();
    return (id != null && id.isNotEmpty) ? id : kEmptyDraftBeanProjectId;
  }

  /// 作品保存/发布结束后是否应删除本地草稿（其他作品的草稿应保留）
  Future<bool> _shouldDeleteLocalDraftOnFinalize() async {
    if (!await LocalDraftStore.exists(LocalDraftStore.singleDraftId)) {
      return false;
    }
    final raw = await LocalDraftStore.readMeta(LocalDraftStore.singleDraftId);
    if (raw == null || raw['localDraft'] != true) return false;

    final draftBeanId = readDraftBeanProjectId(raw);
    final currentBeanId = currentProjectId?.trim() ?? '';

    if (!_initialDraftCreated && !_hasUnsavedDraftEdits()) {
      if (draftBeanId.isEmpty && currentBeanId.isEmpty) return true;
      return draftBeanId == currentBeanId;
    }

    if (_initialDraftCreated) {
      if (draftBeanId.isEmpty && currentBeanId.isEmpty) return true;
      if (draftBeanId.isEmpty && currentBeanId.isNotEmpty) return true;
      return draftBeanId == currentBeanId;
    }

    return draftBeanId == currentBeanId;
  }

  /// 作品已保存到服务端：停止自动草稿；仅删除与当前作品绑定的本地草稿
  Future<void> _finalizeWorkSavedSession() async {
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = null;
    _pendingAutoSaveAfterCurrent = false;
    _suppressDraftOnClose = true;
    _exitRefreshHandled = true;

    if (await _shouldDeleteLocalDraftOnFinalize()) {
      if (await LocalDraftStore.exists(LocalDraftStore.singleDraftId)) {
        await LocalDraftStore.deleteDraft(LocalDraftStore.singleDraftId);
      }
      _currentLocalDraftId = null;
      debugPrint('[保存项目] 作品已保存，已清理本地草稿');
    } else {
      debugPrint('[保存项目] 保留其他作品的本地草稿');
    }
  }

  /// 确保当前会话已绑定草稿 ID
  String _ensureLocalDraftId() {
    _currentLocalDraftId = LocalDraftStore.singleDraftId;
    return _currentLocalDraftId!;
  }

  /// 是否满足落盘条件；[allowEmptyCanvas] 为 true 时允许空白画布（初始草稿）
  bool _canPersistDraft({bool allowEmptyCanvas = false}) {
    if (!isDataLoaded.value) return false;
    if (gridWidth.value == 0 || gridHeight.value == 0) return false;
    if (pixelCodes.isEmpty) return allowEmptyCanvas;
    if (_isBlankCanvas() && pixelCodes.every((code) => code.isEmpty)) {
      return allowEmptyCanvas;
    }
    return true;
  }

  /// 画布是否具备可落盘的数据（非空网格）
  bool _hasCanvasSaveableData() => _canPersistDraft();

  /// 是否存在尚未同步到本地的编辑
  bool _hasPendingDraftChanges({
    bool force = false,
    bool allowEmptyCanvas = false,
  }) {
    if (!_canPersistDraft(allowEmptyCanvas: allowEmptyCanvas || force)) {
      return false;
    }
    if (force) return _hasUnsavedDraftEdits();
    return _hasUnsavedDraftEdits();
  }

  CanvasToolsStatus _buildCanvasToolsStatus() {
    return CanvasToolsStatus(
      gridShow: gridShow.value,
      gridSpacing: gridSpacing.value,
      centerDashShow: centerDashShow.value,
      gridThickness: gridThickness.value,
      gridColor: gridColor.value.toARGB32(),
      gridStartPointX: gridStartPoint.value.dx,
      gridStartPointY: gridStartPoint.value.dy,
      colorDisplayMode: colorDisplayMode.value,
      highlightedCodes: Set.from(_highlightedCodes),
      overlayHighlightedCodes: Set.from(_overlayHighlightedCodes),
      areaPinnedRegions: Set.from(_areaPinnedRegions),
      sameColorPinnedCodes: Set.from(_sameColorPinnedCodes),
    );
  }

  /// 将画布状态写入本地草稿
  ///
  /// - [syncWrite]：生命周期类保存使用同步写入，确保进程结束前落盘
  /// - [copyOriginalImage]：实时保存跳过原图复制，复用已有草稿路径
  Future<void> _saveLocalDraft({
    required String reason,
    bool syncWrite = false,
    bool copyOriginalImage = false,
    bool force = false,
    bool updateThumbnail = false,
    bool allowEmptyCanvas = false,
  }) async {
    if (_suppressDraftOnClose) return;
    if (!_hasPendingDraftChanges(
      force: force,
      allowEmptyCanvas: allowEmptyCanvas,
    )) {
      return;
    }
    if (_isSavingLocalDraft) {
      _pendingAutoSaveAfterCurrent = true;
      return;
    }

    final codesSnapshot = List<String>.from(pixelCodes);
    final saveVersion = _canvasEditVersion;

    _isSavingLocalDraft = true;
    try {
      final draftId = _ensureLocalDraftId();
      final draftDir = (await LocalDraftStore.draftDirectory(draftId)).path;
      final existingRaw = await LocalDraftStore.readMeta(draftId);

      final now = DateTime.now().millisecondsSinceEpoch;

      final localOriginalPath = await _resolveDraftOriginalImagePath(
        draftDir: draftDir,
        existingRaw: existingRaw,
        copyIfMissing: copyOriginalImage,
      );

      final effectiveUpdateThumbnail = await _shouldRenderDraftThumbnail(
        updateThumbnail: updateThumbnail,
        draftDir: draftDir,
      );

      final compressedFuture = codesSnapshot.length > _compressInIsolateThreshold
          ? compute(_compressPixelCodesInIsolate, codesSnapshot)
          : Future<String>.value(PixelDataCodecUtil.compress(codesSnapshot));

      final thumbnailBytesFuture = _renderDraftThumbnailBytes(
        codes: codesSnapshot,
        updateThumbnail: effectiveUpdateThumbnail,
      );

      final parallelResults = await Future.wait<dynamic>([
        compressedFuture,
        thumbnailBytesFuture,
      ]);
      final compressedPixelData = parallelResults[0] as String;
      final thumbnailBytes = parallelResults[1] as Uint8List?;

      final thumbnailLocalPath = await _writeDraftThumbnailFile(
        draftDir: draftDir,
        existingRaw: existingRaw,
        updateThumbnail: effectiveUpdateThumbnail,
        thumbnailBytes: thumbnailBytes,
        thumbWriteToken: now,
      );

      final sessionWorkTitle = _sessionWorkTitleForSave(existingRaw);
      final title = localDraftDisplayTitle(now);
      final meta = <String, dynamic>{
        'id': currentProjectId ?? '',
        'beanProjectId': _beanProjectIdForDraftMeta(),
        'localDraftId': draftId,
        'title': title,
        if (currentProjectId?.isNotEmpty == true &&
            sessionWorkTitle != null &&
            sessionWorkTitle.isNotEmpty)
          'workTitle': sessionWorkTitle,
        'createdAt': existingRaw?['createdAt'] as int? ?? now,
        'updatedAt': now,
        'gridWidth': gridWidth.value,
        'gridHeight': gridHeight.value,
        'beadBrandKey': _currentBeadBrand?.key ?? 'mard',
        'colorLimitValue': _currentColorLimit?.limit ?? -1,
        'pixelCodes': <String>[],
        'pixelData': compressedPixelData,
        'pixelDataEncoding': PixelDataCodecUtil.encodingType,
        // 实时保存跳过 colorData，恢复后由 _loadUsedColors 重算
        'colorData': reason == 'auto'
            ? <String>[]
            : allUsedColors.map((e) => '${e['code']}:${e['count']}').toList(),
        'enabledTools': enabledOtherTools.map((m) => m.value).toList(),
        'picture': pixelizedImageInfo['picture'],
        'originalImage': originalImageUrl,
        'tools': _buildCanvasToolsStatus().toJsonString(),
        'localDraft': true,
        'saveReason': reason,
        'isBlankCanvas': isBlankCanvasMode,
        'isSelfPost': isSelfPost,
        'isFromPostDetail': isFromPostDetail,
        'originalImageLocalPath': localOriginalPath,
        'thumbnailLocalPath': thumbnailLocalPath,
      };

      await LocalDraftStore.writeMeta(draftId, meta, syncWrite: syncWrite);

      final manifestPicture = () {
        if (thumbnailLocalPath != null && thumbnailLocalPath.isNotEmpty) {
          return thumbnailLocalPath;
        }
        if (!effectiveUpdateThumbnail) {
          return existingRaw?['thumbnailLocalPath'] as String?;
        }
        return null;
      }();

      await LocalDraftStore.upsertManifestEntry(
        LocalDraftSummary(
          id: draftId,
          title: title,
          createdAt: meta['createdAt'] as int,
          updatedAt: now,
          gridWidth: gridWidth.value,
          gridHeight: gridHeight.value,
          projectId: currentProjectId,
          picture: manifestPicture,
        ),
      );

      _lastSavedEditVersion = saveVersion;
      _initialDraftCreated = true;
      debugPrint('[结果页面] 本地草稿已保存 [$draftId] ($reason, v$saveVersion)');
    } catch (e) {
      debugPrint('[结果页面] 本地草稿保存失败: $e');
    } finally {
      _isSavingLocalDraft = false;
      if (_pendingAutoSaveAfterCurrent) {
        _pendingAutoSaveAfterCurrent = false;
        if (_canvasEditVersion > _lastSavedEditVersion) {
          _saveLocalDraft(
            reason: 'auto_retry',
            syncWrite: false,
            copyOriginalImage: false,
            updateThumbnail: true,
          );
        }
      }
    }
  }

  /// 轻量渲染草稿缩略图 PNG（与 [saveCanvasImage] 分离，不受导出可读性下限影响）
  Future<Uint8List?> _renderDraftThumbnailBytes({
    required List<String> codes,
    required bool updateThumbnail,
  }) async {
    if (!updateThumbnail || !_canPersistDraft(allowEmptyCanvas: true)) {
      return null;
    }

    if (_beadColorMap.isEmpty &&
        codes.any((code) => code.isNotEmpty)) {
      await _loadUsedColors(updateDefaultBrushColor: false);
    }

    try {
      return PixelCanvasExporter.exportThumbnail(
        codes: codes,
        gridWidth: gridWidth.value,
        gridHeight: gridHeight.value,
        beadColorMap: Map<String, Color>.from(_beadColorMap),
        circleMode: isCircleMode.value,
      );
    } catch (e) {
      debugPrint('[结果页面] 草稿缩略图渲染失败: $e');
      return null;
    }
  }

  /// 将缩略图字节写入草稿目录，或复用已有封面路径
  Future<String?> _writeDraftThumbnailFile({
    required String draftDir,
    required Map<String, dynamic>? existingRaw,
    required bool updateThumbnail,
    Uint8List? thumbnailBytes,
    int? thumbWriteToken,
  }) async {
    const legacyFileName = 'thumbnail.png';
    final legacyThumbPath = p.join(draftDir, legacyFileName);

    Future<String?> existingPath() async {
      final saved = existingRaw?['thumbnailLocalPath'] as String?;
      if (saved != null && saved.isNotEmpty && await File(saved).exists()) {
        return saved;
      }
      if (await File(legacyThumbPath).exists()) {
        return legacyThumbPath;
      }
      return null;
    }

    if (thumbnailBytes != null &&
        thumbnailBytes.isNotEmpty &&
        thumbWriteToken != null) {
      final thumbPath = p.join(draftDir, 'thumbnail_$thumbWriteToken.png');
      try {
        final previousPath = existingRaw?['thumbnailLocalPath'] as String?;
        await File(thumbPath).writeAsBytes(thumbnailBytes, flush: true);
        _evictDraftThumbnailCache(thumbPath);
        if (previousPath != null && previousPath.isNotEmpty) {
          _evictDraftThumbnailCache(previousPath);
        }
        _evictDraftThumbnailCache(legacyThumbPath);
        await _cleanupOldDraftThumbnails(
          draftDir,
          keepPath: thumbPath,
        );
        return thumbPath;
      } catch (e) {
        debugPrint('[结果页面] 草稿缩略图写入失败: $e');
      }
    }

    // 本次需要刷新但渲染/写入失败：不复用旧缩略图，避免列表展示过期画面
    if (updateThumbnail) {
      return null;
    }

    return existingPath();
  }

  void _evictDraftThumbnailCache(String path) {
    try {
      PaintingBinding.instance.imageCache.evict(FileImage(File(path)));
    } catch (_) {}
  }

  Future<void> _cleanupOldDraftThumbnails(
    String draftDir, {
    required String keepPath,
  }) async {
    try {
      final dir = Directory(draftDir);
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final name = p.basename(entity.path);
        final isThumbnail = name == 'thumbnail.png' ||
            (name.startsWith('thumbnail_') && name.endsWith('.png'));
        if (!isThumbnail || entity.path == keepPath) continue;
        _evictDraftThumbnailCache(entity.path);
        await entity.delete();
      }
    } catch (e) {
      debugPrint('[结果页面] 清理旧缩略图失败: $e');
    }
  }

  /// 解析草稿原图本地路径：实时保存复用已有文件，生命周期保存才复制
  Future<String?> _resolveDraftOriginalImagePath({
    required String draftDir,
    required Map<String, dynamic>? existingRaw,
    required bool copyIfMissing,
  }) async {
    final existingPath = existingRaw?['originalImageLocalPath'] as String?;
    if (existingPath != null && existingPath.isNotEmpty) {
      if (await File(existingPath).exists()) {
        return existingPath;
      }
    }

    if (!copyIfMissing) return existingPath;

    final srcOriginal = originalImage.value;
    if (srcOriginal == null || !await srcOriginal.exists()) {
      return existingPath;
    }

    final ext = p.extension(srcOriginal.path);
    final destPath = p.join(draftDir, 'original_image$ext');
    await srcOriginal.copy(destPath);
    return destPath;
  }

  /// 从指定本地草稿恢复画布
  Future<bool> _restoreLocalDraft(String draftId) async {
    try {
      final raw = await LocalDraftStore.readMeta(draftId);
      if (raw == null || raw['localDraft'] != true) return false;

      final project = PixelProject.fromJson(raw);
      if (project.pixelCodes.isEmpty && (project.pixelData?.isEmpty ?? true)) {
        return false;
      }

      _currentLocalDraftId = LocalDraftStore.singleDraftId;

      final sessionTitle = currentProjectTitle?.trim();
      final draftBeanId = readDraftBeanProjectId(raw);
      final hasExistingProject = draftBeanId.isNotEmpty;

      _isBlankCanvasModeFlag = raw['isBlankCanvas'] as bool? ?? false;
      isSelfPost = raw['isSelfPost'] as bool? ?? true;
      isFromPostDetail = raw['isFromPostDetail'] as bool? ?? false;

      await _initWithProject(project);

      if (hasExistingProject) {
        final storedWorkTitle = (raw['workTitle'] as String?)?.trim();
        final restoredTitle = sessionTitle?.isNotEmpty == true
            ? sessionTitle
            : storedWorkTitle?.isNotEmpty == true
                ? storedWorkTitle
                : !isAutoLocalDraftTitle(project.title)
                    ? project.title
                    : null;
        _bindExistingWorkSession(
          projectId: draftBeanId,
          workTitle: restoredTitle,
        );
      } else {
        currentProjectId = null;
        currentProjectTitle = project.title;
      }

      final localOriginal = raw['originalImageLocalPath'] as String?;
      if (localOriginal != null && localOriginal.isNotEmpty) {
        final file = File(localOriginal);
        if (await file.exists()) {
          originalImage.value = file;
        }
      }

      _lastSavedEditVersion = _canvasEditVersion;
      _initialDraftCreated = true;
      debugPrint('[结果页面] 本地草稿恢复成功 [$draftId]: ${project.title}');
      return true;
    } catch (e) {
      debugPrint('[结果页面] 本地草稿恢复失败: $e');
      return false;
    }
  }

  /// 生成并上传像素缩略图到服务器
  ///
  /// 1. 调用 [saveCanvasImage] 生成小尺寸缩略图（pixelSize=10，无文字/网格/编号等）
  /// 2. 将图片 bytes 写入临时文件
  /// 3. 通过 multipart/form-data 上传到服务器
  /// 返回上传后的图片 URL，失败返回 null
  Future<String?> uploadThumbnail() async {
    try {
      final bytes = await saveCanvasImage(
        pixelSize: 30,
        showText: false,
        showGrid: false,
      );
      if (bytes == null) {
        debugPrint('[上传缩略图] 生成图片失败');
        return null;
      }

      // 写入临时文件
      final dir = Directory.systemTemp;
      final filePath =
          '${dir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // 上传到服务器（返回图片 URL）
      final request = PixelImgRequest();
      final pictureUrl = await request.uploadImg(filePath);

      // 清理临时文件
      if (await file.exists()) {
        await file.delete();
      }
      debugPrint('[上传缩略图] 上传结果: $pictureUrl');
      return pictureUrl;
    } catch (e) {
      debugPrint('[上传缩略图] 上传失败: $e');
      return null;
    }
  }

  /// 保存 PixelCanvas 内容为高清图片（委托给 PixelCanvasExporter）
  ///
  /// 每个像素块按 [pixelSize] 像素绘制，生成高清 PNG。
  /// 默认 pixelSize=108，实际输出尺寸由导出器按网格与 GPU 预算自适应。
  Future<Uint8List?> saveCanvasImage(
      {int pixelSize = 108,
      bool showText = true,
      bool showGrid = true,
      bool showBoldGrid = false,
      bool showNumberBorder = false,
      bool showColorLegend = false,
      bool showBrandFrame = false}) async {
    final brand = _currentBeadBrand;
    final paletteSize = allColors.isNotEmpty
        ? allColors.length
        : (brand?.totalColors ?? 0);
    return PixelCanvasExporter.export(
      codes: pixelCodes.toList(),
      gridWidth: gridWidth.value,
      gridHeight: gridHeight.value,
      beadColorMap: Map<String, Color>.from(_beadColorMap),
      pixelSize: pixelSize,
      circleMode: isCircleMode.value,
      showText: showText,
      showGrid: showGrid,
      showBoldGrid: showBoldGrid,
      showNumberBorder: showNumberBorder,
      showColorLegend: showColorLegend,
      gridSpacing: gridSpacing.value,
      gridThickness: gridThickness.value,
      gridColor: gridColor.value,
      gridStartPoint: gridStartPoint.value,
      centerDashShow: centerDashShow.value,
      showBrandFrame: showBrandFrame,
      beadBrandName: brand?.key.toUpperCase() ??
          (beadBrandLabel.value.isNotEmpty ? beadBrandLabel.value : 'MARD'),
      beadBrandPaletteSize: paletteSize,
      workTitle: _exportWorkTitleForImage(),
      userNickname: _exportUserDisplayNameForImage(),
    );
  }

  String _exportWorkTitleForImage() {
    final projectId = currentProjectId?.trim();
    final title = _sessionWorkTitleForSave(null);
    if (projectId != null &&
        projectId.isNotEmpty &&
        title != null &&
        title.isNotEmpty) {
      return title;
    }
    return '本地草稿';
  }

  String _exportUserDisplayNameForImage() => '--';

  /// PixelCanvas 的 GlobalKey（用于保存图片）
  final GlobalKey pixelCanvasKey = GlobalKey();

  /// 加载实际使用的颜色
  /// [updateDefaultBrushColor] 是否更新默认画笔颜色（仅在初始化和切换品牌时为 true）
  Future<void> _loadUsedColors({bool updateDefaultBrushColor = false}) async {
    if (pixelCodes.isEmpty || gridWidth.value == 0 || gridHeight.value == 0) {
      return;
    }

    isLoadingColors.value = true;

    try {
      // 使用当前品牌的 jsonPath 加载对应的颜色库
      final jsonPath = _currentBeadBrand?.jsonPath ?? 'assets/mard_colors.json';
      debugPrint('[结果页面] 加载颜色库: $jsonPath');
      debugPrint('[结果页面] 当前品牌: ${_currentBeadBrand?.displayName}');

      // 加载颜色库 JSON
      final jsonString = await rootBundle.loadString(jsonPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final colors = json['colors'] as List;

      debugPrint('[结果页面] 颜色库总颜色数: ${colors.length}');

      // 构建颜色映射（code -> Color）和反向映射（Color -> code）
      _beadColorMap.clear();
      _colorToCodeMap.clear();
      allColors.clear();

      for (final colorData in colors) {
        final c = colorData as Map<String, dynamic>;
        final code = c['code'] as String;
        final hex = c['hex'] as String;

        // 解析十六进制颜色值
        final hexValue = hex.replaceAll('#', '');
        final r = int.parse(hexValue.substring(0, 2), radix: 16);
        final g = int.parse(hexValue.substring(2, 4), radix: 16);
        final b = int.parse(hexValue.substring(4, 6), radix: 16);

        final color = Color.fromARGB(255, r, g, b);
        _beadColorMap[code] = color;
        _colorToCodeMap[color] = code;

        // 添加到全部颜色列表
        allColors.add({
          'code': code,
          'color': color,
        });
      }
      debugPrint('[结果页面] 颜色映射构建完成，_beadColorMap大小: ${_beadColorMap.length}');

      // 统计每个颜色代码的使用数量
      final codeUsageMap = <String, int>{};
      for (final code in pixelCodes) {
        if (code.isNotEmpty) {
          codeUsageMap[code] = (codeUsageMap[code] ?? 0) + 1;
        }
      }

      debugPrint('[结果页面] pixelCodes中的唯一颜色代码数: ${codeUsageMap.keys.length}');

      // 从 pixelCodes 中提取实际使用的颜色代码并去重
      final uniqueCodes =
          pixelCodes.toSet().where((code) => code.isNotEmpty).toList();

      debugPrint(
          '[结果页面] 提取的唯一颜色代码: ${uniqueCodes.take(10)}${uniqueCodes.length > 10 ? '...' : ''}');

      // 根据代码获取实际颜色
      usedColors.clear();
      colorUsageStats.clear();

      final usageList = <Map<String, dynamic>>[];
      int notFoundCount = 0;
      for (final code in uniqueCodes) {
        final color = _beadColorMap[code];
        if (color != null) {
          usedColors.add(color);
          usageList.add({
            'code': code,
            'color': color,
            'count': codeUsageMap[code] ?? 0,
          });
        } else {
          notFoundCount++;
          debugPrint('[结果页面] 警告：颜色代码 $code 在颜色映射中未找到');
        }
      }

      debugPrint('[结果页面] 未映射的颜色数: $notFoundCount');
      debugPrint('[结果页面] 成功映射的颜色数: ${usedColors.length}');

      // 按使用数量降序排序
      usageList
          .sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      // 所有使用的颜色（用于切换颜色弹窗）
      allUsedColors.value = usageList;

      // 主界面只显示前20个
      colorUsageStats.value = usageList.take(20).toList();

      // // 设置默认画笔颜色（仅在初始化和切换品牌时）
      // if (updateDefaultBrushColor) {
      //   if (usageList.length >= 3) {
      //     final thirdColor = usageList[2];
      //     brushColorCode.value = thirdColor['code'] as String;
      //     brushColor.value = thirdColor['color'] as Color;
      //     debugPrint('[结果页面] 设置默认画笔颜色为使用颜色列表第三个: ${thirdColor['code']}');
      //   } else if (usageList.isNotEmpty) {
      //     // 如果只有一个颜色，使用第一个
      //     final firstColor = usageList[0];
      //     brushColorCode.value = firstColor['code'] as String;
      //     brushColor.value = firstColor['color'] as Color;
      //     debugPrint('[结果页面] 只有1种颜色，设置默认画笔颜色为: ${firstColor['code']}');
      //   } else {
      //     // 空白画布：从颜色库取第一个颜色作为默认画笔色
      //     if (allColors.isNotEmpty) {
      //       final firstLibColor = allColors[0];
      //       brushColorCode.value = firstLibColor['code'] as String;
      //       brushColor.value = firstLibColor['color'] as Color;
      //       debugPrint('[结果页面] 空白画布，设置默认画笔颜色为颜色库第一个: ${firstLibColor['code']}');
      //     }
      //   }
      // }

      // 计算快速访问色：从颜色库中选取4个未使用的颜色
      final usedCodesSet = uniqueCodes.toSet();
      final unusedColors = <Map<String, dynamic>>[];

      for (final colorData in colors) {
        final c = colorData as Map<String, dynamic>;
        final code = c['code'] as String;

        // 跳过已使用的颜色
        if (usedCodesSet.contains(code)) {
          continue;
        }

        // 解析颜色
        final hex = c['hex'] as String;
        final hexValue = hex.replaceAll('#', '');
        final r = int.parse(hexValue.substring(0, 2), radix: 16);
        final g = int.parse(hexValue.substring(2, 4), radix: 16);
        final b = int.parse(hexValue.substring(4, 6), radix: 16);
        final color = Color.fromARGB(255, r, g, b);

        unusedColors.add({
          'code': code,
          'color': color,
        });

        // 只需要4个
        if (unusedColors.length >= 4) {
          break;
        }
      }

      quickAccessColors.value = unusedColors.take(4).toList();

      debugPrint('[结果页面] ===== 颜色加载完成 =====');
      debugPrint('[结果页面] 实际使用的颜色数: ${usedColors.length}');
      debugPrint(
          '[结果页面] 前20个颜色统计: ${colorUsageStats.map((e) => "${e['code']}:${e['count']}").join(", ")}');

      debugPrint(
          '[结果页面] 快速访问色: ${quickAccessColors.map((e) => "${e['code']}").join(", ")}');
    } catch (e) {
      debugPrint('[结果页面] 加载颜色失败: $e');
      debugPrint('[结果页面] 错误堆栈: ${StackTrace.current}');
      usedColors.clear();
      colorUsageStats.clear();
    } finally {
      isLoadingColors.value = false;
    }
  }

  /// 判断是否为空白画布（用户尚未绘制任何像素数据）
  bool _isBlankCanvas() {
    return pixelCodes.isNotEmpty && pixelCodes.every((code) => code.isEmpty);
  }

  /// 切换工具模式
  void switchToolMode(ToolMode mode) {
    // 切离点位线模式时清除所有点位线数据
    if (currentToolMode.value == ToolMode.locationLine && mode != ToolMode.locationLine) {
      _locationLineCenterKeys.clear();
    }
    currentToolMode.value = mode;
  }

  /// 添加/切换点位线中心坐标（由画布点击触发，toggle 方式）
  void setLocationLineCenter(int col, int row) {
    final key = '$col,$row';
    if (_locationLineCenterKeys.contains(key)) {
      _locationLineCenterKeys.remove(key);
    } else {
      _locationLineCenterKeys.add(key);
    }
  }

  /// 切换其他工具状态（多选工具）
  void toggleOtherTool(ToolMode mode) {
    if (enabledOtherTools.contains(mode)) {
      enabledOtherTools.remove(mode);
    } else {
      enabledOtherTools.add(mode);
    }
    debugPrint('[结果页面] 切换其他工具状态: ${mode.value}');
    _markCanvasDirty();
  }

  /// 检查其他工具是否已启用
  bool isOtherToolEnabled(ToolMode mode) {
    return enabledOtherTools.contains(mode);
  }

  /// 放大（以画板中心为缩放中心）
  void zoomIn() {
    _zoom(1.2);
  }

  /// 缩小（以画板中心为缩放中心）
  void zoomOut() {
    _zoom(0.8);
  }

  /// 以画板中心为缩放中心进行缩放
  void _zoom(double scale) {
    const double minScale = 0.4; // 最小缩放
    const double maxScale = 10.0; // 最大缩放

    final currentMatrix = transformationController.value;
    final canvasSize = canvasDisplaySize.value;

    // 获取当前缩放值
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    // 计算新的缩放值并限制在范围内
    final newScale = (currentScale * scale).clamp(minScale, maxScale);

    // 如果缩放值没有变化，不做处理
    if ((newScale - currentScale).abs() < 0.001) {
      debugPrint('[缩放] 已达到缩放限制: $newScale');
      return;
    }

    // 如果画板尺寸还未设置，使用默认缩放
    if (canvasSize == Size.zero) {
      final newMatrix = Matrix4.copy(currentMatrix);
      newMatrix.scale(newScale / currentScale);
      transformationController.value = newMatrix;
      return;
    }

    // 获取当前平移值
    final currentTranslate = currentMatrix.getTranslation();

    // 计算画板中心在当前变换后的屏幕位置
    final canvasCenterX = canvasSize.width / 2;
    final canvasCenterY = canvasSize.height / 2;
    final screenCenterX = canvasCenterX * currentScale + currentTranslate.x;
    final screenCenterY = canvasCenterY * currentScale + currentTranslate.y;

    // 计算新的平移值，使画板中心保持在屏幕同一位置
    final newTranslateX = screenCenterX - canvasCenterX * newScale;
    final newTranslateY = screenCenterY - canvasCenterY * newScale;

    // 构建新的变换矩阵
    final newMatrix = Matrix4.identity()
      ..translate(newTranslateX, newTranslateY)
      ..scale(newScale);

    transformationController.value = newMatrix;
    debugPrint('[缩放] 缩放值: $currentScale → $newScale');
  }

  /// 设置画笔颜色
  void setBrushColor(Color color, String code) {
    brushColor.value = color;
    brushColorCode.value = code;
    debugPrint('[结果页面] 设置画笔颜色: $code ($color)');
  }

  /// 清空画笔颜色
  void clearBrushColor() {
    brushColor.value = Colors.transparent;
    brushColorCode.value = '';
    debugPrint('[结果页面] 清空画笔颜色');
  }

  /// 用当前选中颜色填充整个画布
  Future<void> fillAll() async {
    final code = brushColorCode.value;
    if (code.isEmpty) {
      showToast('请先选择颜色');
      return;
    }
    final confirmed = await AppOverlay.dialog.confirmAsync(
      title: '填充画布',
      message: '将用您选中的颜色（$code）填充整个画布',
    );
    if (confirmed != true) return;
    for (int i = 0; i < pixelCodes.length; i++) {
      pixelCodes[i] = code;
    }
    pixelCodes.refresh();
    await _loadUsedColors();
    _pushHistory(pixelCodes.toList());
    showToast('填充完成');
  }

  /// 替换颜色：将指定颜色代码的像素替换为目标颜色
  Future<void> replaceColors(List<String> fromCodes, String toCode) async {
    if (fromCodes.isEmpty) {
      showToast('请先选择要替换的颜色');
      return;
    }
    if (toCode.isEmpty) {
      showToast('请选择目标颜色');
      return;
    }

    int count = 0;
    for (int i = 0; i < pixelCodes.length; i++) {
      if (fromCodes.contains(pixelCodes[i])) {
        pixelCodes[i] = toCode;
        count++;
      }
    }

    if (count > 0) {
      pixelCodes.refresh();
      await _loadUsedColors();
      _pushHistory(pixelCodes.toList());
      // showToast('已替换 $count 个像素');
      showToast('替换成功');
    } else {
      showToast('没有需要替换的数据');
    }
  }

  /// 清空指定颜色的像素
  Future<void> clearColors(List<String> codes) async {
    if (codes.isEmpty) {
      showToast('请先选择要清空的颜色');
      return;
    }

    int count = 0;
    for (int i = 0; i < pixelCodes.length; i++) {
      if (codes.contains(pixelCodes[i])) {
        pixelCodes[i] = '';
        count++;
      }
    }

    if (count > 0) {
      pixelCodes.refresh();
      await _loadUsedColors();
      _pushHistory(pixelCodes.toList());
      // showToast('已清空 $count 个像素');
      showToast('已清空');
    } else {
      showToast('没有需要清空的数据');
    }
  }

  /// 泛填充：从指定位置开始，填充所有相邻同色区域
  void floodFill(int startX, int startY) {
    final code = brushColorCode.value;
    if (code.isEmpty) return;

    final w = gridWidth.value;
    final h = gridHeight.value;
    if (startX < 0 || startX >= w || startY < 0 || startY >= h) return;

    final targetCode = pixelCodes[startY * w + startX];
    // 如果目标颜色与画笔颜色相同，无需操作
    if (targetCode == code) return;

    // BFS 泛填充
    final filled = <int>{};
    final queue = <int>[startY * w + startX];
    filled.add(queue.first);

    while (queue.isNotEmpty) {
      final index = queue.removeAt(0);
      pixelCodes[index] = code;

      final row = index ~/ w;
      final col = index % w;

      // 上
      if (row > 0) {
        final up = (row - 1) * w + col;
        if (!filled.contains(up) && pixelCodes[up] == targetCode) {
          filled.add(up);
          queue.add(up);
        }
      }
      // 下
      if (row < h - 1) {
        final down = (row + 1) * w + col;
        if (!filled.contains(down) && pixelCodes[down] == targetCode) {
          filled.add(down);
          queue.add(down);
        }
      }
      // 左
      if (col > 0) {
        final left = row * w + col - 1;
        if (!filled.contains(left) && pixelCodes[left] == targetCode) {
          filled.add(left);
          queue.add(left);
        }
      }
      // 右
      if (col < w - 1) {
        final right = row * w + col + 1;
        if (!filled.contains(right) && pixelCodes[right] == targetCode) {
          filled.add(right);
          queue.add(right);
        }
      }
    }

    pixelCodes.refresh();
    _loadUsedColors();
    _pushHistory(pixelCodes.toList());
  }

  /// 提取颜色：获取指定位置像素块的颜色，设为画笔颜色
  void extractColor(int x, int y) {
    final index = y * gridWidth.value + x;
    if (index < 0 || index >= pixelCodes.length) return;

    final code = pixelCodes[index];
    if (code.isEmpty) {
      showToast('该像素块没有颜色');
      return;
    }

    final color = _beadColorMap[code];
    if (color == null) return;

    // 设置画笔颜色
    setBrushColor(color, code);

    // 检查是否在使用颜色或快速访问色列表中
    final isUsed = colorUsageStats.any((item) => item['code'] == code);
    final isQuickAccess = quickAccessColors.any((item) => item['code'] == code);

    // 如果都不在，添加到 selectedColors
    if (!isUsed && !isQuickAccess) {
      final isAlreadySelected =
          selectedColors.any((item) => item['code'] == code);
      if (!isAlreadySelected) {
        if (selectedColors.length >= 4) {
          selectedColors.removeLast();
        }
        selectedColors.insert(0, {
          'code': code,
          'color': color,
        });
      }
    }

    showToast('已提取颜色');

    // 提取完成后切回绘画模式
    currentToolMode.value = ToolMode.draw;
  }

  /// 显示颜色切换弹窗
  void showColorSwitchDialog() {
    // 用 allUsedColors 的前10个颜色初始化弹窗的快速访问色（临时）
    _dialogQuickAccessColors.value = allUsedColors.take(10).toList();
    // 重置选中状态
    multiSelectedColorCodes.clear();
    quickAccessSelectedCode.value = null;

    AppOverlay.dialog.customAsync(
      child: ColorSwitchDialog(controller: this),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  /// 显示更多设置弹窗（网格工具项点击时触发）
  void _showMoreSettingsSheet() {
    final context = Get.context;
    if (context == null) return;
    MoreSettingsSheet.show(
      context,
      gridSpacing: gridSpacing.value,
      centerDashShow: centerDashShow.value,
      gridShow: gridShow.value,
      baseplateStitch: 52,
      gridThickness: gridThickness.value,
      gridColor: gridColor.value,
      gridStartPoint: gridStartPoint.value.dx,
      onGridSpacingChanged: (value) {
        gridSpacing.value = value;
        _markCanvasDirty();
      },
      onCenterDashChanged: (value) {
        centerDashShow.value = value;
        _markCanvasDirty();
      },
      onGridShowChanged: (value) {
        gridShow.value = value;
        // 同步工具栏网格 item 选中状态
        if (value && !isOtherToolEnabled(ToolMode.grid)) {
          toggleOtherTool(ToolMode.grid);
        } else if (!value && isOtherToolEnabled(ToolMode.grid)) {
          toggleOtherTool(ToolMode.grid);
        }
        _markCanvasDirty();
      },
      onGridThicknessChanged: (value) {
        gridThickness.value = value;
        _markCanvasDirty();
      },
      onGridColorChanged: (value) {
        gridColor.value = value;
        _markCanvasDirty();
      },
      onGridStartPointChanged: (value) {
        gridStartPoint.value = value;
        _markCanvasDirty();
      },
    );
  }

  /// 显示色号显示模式选择弹窗（代码工具项点击时触发）
  void _showColorDisplayModeSheet() {
    final context = Get.context;
    if (context == null) return;
    ColorDisplayModeSheet.show(
      context,
      initialMode: colorDisplayMode.value,
      onModeChanged: (mode) {
        colorDisplayMode.value = mode;
        // 联动代码工具 item：hidden 模式取消选中，其他模式自动选中
        final shouldBeEnabled = mode != ColorDisplayMode.hidden;
        if (shouldBeEnabled && !isOtherToolEnabled(ToolMode.code)) {
          toggleOtherTool(ToolMode.code);
        } else if (!shouldBeEnabled && isOtherToolEnabled(ToolMode.code)) {
          toggleOtherTool(ToolMode.code);
        }
        _markCanvasDirty();
      },
    );
  }

  /// 切换喷枪大小
  void setSprayGunSize(int size) {
    sprayGunSize.value = size;
    currentToolMode.value = ToolMode.sprayGun;
    Get.back();
  }

  /// 选择形状类型
  void setShapeType(String shapeType) {
    selectedShapeType.value = shapeType;
    currentToolMode.value = ToolMode.shape;
    Get.back();
  }

  /// 批量提交形状像素到画板（一次性写入，触发历史记录）
  void drawShapePixels(Set<String> gridKeys) {
    if (gridKeys.isEmpty) return;
    final w = gridWidth.value;
    final h = gridHeight.value;
    for (final key in gridKeys) {
      final parts = key.split(',');
      if (parts.length != 2) continue;
      final x = int.tryParse(parts[0]);
      final y = int.tryParse(parts[1]);
      if (x == null || y == null) continue;
      if (x < 0 || x >= w || y < 0 || y >= h) continue;
      final index = y * w + x;
      if (index < 0 || index >= pixelCodes.length) continue;
      pixelCodes[index] = brushColorCode.value;
    }
    // 立即触发颜色统计和历史记录
    _loadUsedColors();
    _pushHistory(pixelCodes.toList());
  }

  /// 计算形状像素集合（网格坐标 key = 'x,y'），不修改 pixelCodes
  Set<String> computeShapePixels(int x0, int y0, int x1, int y1) {
    return ShapeComputer.computeShape(
      selectedShapeType.value,
      x0,
      y0,
      x1,
      y1,
      gridWidth: gridWidth.value,
      gridHeight: gridHeight.value,
    );
  }

  /// 设置待绘制文本（不立即显示，等待用户点击画板）
  void setPendingText(String text) {
    pendingText.value = text;
    currentToolMode.value = ToolMode.text;
    isTextFloating.value = false; // 不立即显示
    textScale.value = 1.0;
    textPosition.value = const Offset(2, 2); // 默认位置
  }

  /// 在指定位置显示浮动文本（用户点击画板时调用）
  void showFloatingTextAt(double gridX, double gridY) {
    if (pendingText.value.isEmpty) return;
    textPosition.value = Offset(gridX, gridY);
    isTextFloating.value = true;
    _computeTextGridPositions();
  }

  /// 更新浮动文本位置
  void updateTextPosition(Offset position) {
    textPosition.value = position;
    if (isTextFloating.value) {
      _computeTextGridPositions();
    }
  }

  /// 获取文本在网格坐标系中的占位范围（宽, 高）
  Offset getTextBounds() {
    if (pendingText.value.isEmpty) return Offset.zero;
    final text = pendingText.value.toUpperCase();
    final s = textScale.value.round(); // 整数档位：1/2/3/4
    int maxX = 0;
    int maxY = 0;
    for (int ci = 0; ci < text.length; ci++) {
      final pattern = _getCharPattern(text[ci]);
      if (pattern == null) continue;
      final charStartX = ci * (5 * s + 1);
      for (int row = 0; row < pattern.length; row++) {
        for (int col = 0; col < pattern[row].length; col++) {
          if (pattern[row][col] == 1) {
            final px = charStartX + col * s + (s - 1);
            final py = row * s + (s - 1);
            if (px > maxX) maxX = px;
            if (py > maxY) maxY = py;
          }
        }
      }
    }
    return Offset(maxX.toDouble(), maxY.toDouble());
  }

  /// 更新文本位置（限制不超出画板边界）
  void updateTextPositionClamped(Offset position) {
    final bounds = getTextBounds();
    final gw = gridWidth.value;
    final gh = gridHeight.value;
    final maxX = (gw - 1 - bounds.dx).clamp(0.0, double.infinity);
    final maxY = (gh - 1 - bounds.dy).clamp(0.0, double.infinity);
    final clampedX = position.dx.clamp(0.0, maxX);
    final clampedY = position.dy.clamp(0.0, maxY);
    textPosition.value = Offset(clampedX, clampedY);
    if (isTextFloating.value) {
      _computeTextGridPositions();
    }
  }

  /// 缩放浮动文本
  void scaleText(double scale) {
    textScale.value = (scale).clamp(1.0, 4.0);
  }

  /// 增大文本缩放
  void increaseTextScale() {
    textScale.value = (textScale.value + 1.0).clamp(1.0, 4.0);
    if (isTextFloating.value) _computeTextGridPositions();
  }

  /// 减小文本缩放
  void decreaseTextScale() {
    textScale.value = (textScale.value - 1.0).clamp(1.0, 4.0);
    if (isTextFloating.value) _computeTextGridPositions();
  }

  /// 应用浮动文本到像素画板
  void applyText() {
    if (pendingText.value.isEmpty) return;

    final text = pendingText.value.toUpperCase();
    final colorCode = brushColorCode.value;
    final startX = textPosition.value.dx.round();
    final startY = textPosition.value.dy.round();
    final s = textScale.value.round(); // 整数档位：1/2/3/4

    for (int charIndex = 0; charIndex < text.length; charIndex++) {
      final char = text[charIndex];
      final pattern = _getCharPattern(char);
      if (pattern == null) continue;

      final charStartX = startX + charIndex * (5 * s + 1);

      for (int row = 0; row < pattern.length; row++) {
        for (int col = 0; col < pattern[row].length; col++) {
          if (pattern[row][col] == 1) {
            // 每个点展开为 s×s 像素块
            for (int dy = 0; dy < s; dy++) {
              for (int dx = 0; dx < s; dx++) {
                final pixelX = charStartX + col * s + dx;
                final pixelY = startY + row * s + dy;
                final index = pixelY * gridWidth.value + pixelX;

                if (index >= 0 &&
                    index < pixelCodes.length &&
                    pixelX >= 0 &&
                    pixelX < gridWidth.value &&
                    pixelY >= 0 &&
                    pixelY < gridHeight.value) {
                  pixelCodes[index] = colorCode;
                }
              }
            }
          }
        }
      }
    }

    // 更新颜色统计
    _loadUsedColors();
    // 保存历史记录
    _pushHistory(pixelCodes.toList());
    // 关闭浮动文本
    discardText();
  }

  /// 遗弃浮动文本
  void discardText() {
    isTextFloating.value = false;
    pendingText.value = '';
    textScale.value = 1.0;
    textPosition.value = Offset.zero;
    textGridPositions.clear();
    currentToolMode.value = ToolMode.draw;
  }

  /// 检查指定网格坐标是否被文本选中占用
  bool isGridOccupiedByText(int gridX, int gridY) {
    return textGridPositions.contains('$gridX,$gridY');
  }

  /// 计算文本占用的网格坐标集合
  void _computeTextGridPositions() {
    textGridPositions.clear();
    if (pendingText.value.isEmpty) return;

    final text = pendingText.value.toUpperCase();
    final startX = textPosition.value.dx.round();
    final startY = textPosition.value.dy.round();
    final s = textScale.value.round(); // 整数档位：1/2/3/4
    final gw = gridWidth.value;
    final gh = gridHeight.value;

    for (int charIndex = 0; charIndex < text.length; charIndex++) {
      final char = text[charIndex];
      final pattern = _getCharPattern(char);
      if (pattern == null) continue;

      final charStartX = startX + charIndex * (5 * s + 1);

      for (int row = 0; row < pattern.length; row++) {
        for (int col = 0; col < pattern[row].length; col++) {
          if (pattern[row][col] == 1) {
            // 每个点展开为 s×s 像素块
            for (int dy = 0; dy < s; dy++) {
              for (int dx = 0; dx < s; dx++) {
                final pixelX = charStartX + col * s + dx;
                final pixelY = startY + row * s + dy;

                if (pixelX >= 0 && pixelX < gw && pixelY >= 0 && pixelY < gh) {
                  textGridPositions.add('$pixelX,$pixelY');
                }
              }
            }
          }
        }
      }
    }
  }

  /// 获取字符的5x7像素模式（返回7行，每行5列）
  /// 委托给 PixelFontData，数据已外置到 lib/util/pixel_font_data.dart
  List<List<int>>? _getCharPattern(String char) =>
      PixelFontData.getCharPattern(char);

  /// 获取喷枪渲染范围（返回需要渲染的相对坐标列表）
  /// 使用高斯距离加权概率，模拟真实喷枪效果：中心密、边缘疏
  List<(int, int)> getSprayGunRange() {
    final rng = Random();

    switch (sprayGunSize.value) {
      case 1: // 小喷枪：半径2，稀疏点状
        return _generateSprayPositions(rng, radius: 2, density: 0.12);
      case 2: // 中喷枪：半径3，柔和散射
        return _generateSprayPositions(rng, radius: 3, density: 0.10);
      case 3: // 大喷枪：半径4，大面积稀疏
        return _generateSprayPositions(rng, radius: 4, density: 0.07);
      default:
        return [(0, 0)];
    }
  }

  /// 生成喷枪像素点（高斯距离加权 + 概率筛选）
  ///
  /// [radius] 喷射半径（网格单位）
  /// [density] 目标覆盖率（0.0~1.0），实际会按距离衰减
  List<(int, int)> _generateSprayPositions(
    Random rng, {
    required int radius,
    required double density,
  }) {
    final positions = <(int, int)>[];

    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        // 只在圆形范围内采样
        final distSq = dx * dx + dy * dy;
        if (distSq > radius * radius) continue;

        // 高斯距离权重：中心概率=100%，边缘概率趋近于0
        final dist = sqrt(distSq.toDouble());
        // sigma 较小使衰减更快，中心集中、边缘极稀疏
        final sigma = radius * 0.45;
        final weight = exp(-(dist * dist) / (2 * sigma * sigma));

        // 综合概率 = 密度基准 × 距离权重
        final probability = density * weight;

        if (rng.nextDouble() < probability) {
          positions.add((dx, dy));
        }
      }
    }

    // 保证至少绘制1个点（避免完全空白）
    if (positions.isEmpty) {
      // 在中心附近随机取一个点
      final cx = rng.nextInt(3) - 1; // -1, 0, 1
      final cy = rng.nextInt(3) - 1;
      positions.add((cx, cy));
    }

    return positions;
  }

  /// 左转90度
  void rotateLeft90() {
    final w = gridWidth.value;
    final h = gridHeight.value;
    if (w == 0 || h == 0) return;

    final oldCodes = pixelCodes.toList();
    final newCodes = List<String>.filled(h * w, '');

    // 左转90度：newGrid[y][x] = oldGrid[x][w-1-y]
    for (int y = 0; y < w; y++) {
      for (int x = 0; x < h; x++) {
        final oldIndex = x * w + (w - 1 - y);
        final newIndex = y * h + x;
        newCodes[newIndex] = oldCodes[oldIndex];
      }
    }

    pixelCodes.value = newCodes;
    gridWidth.value = h;
    gridHeight.value = w;
    _pushHistory(newCodes);
    _loadUsedColors();
    lastRotateOption.value = 'left90';
    // Get.back();
  }

  /// 右转90度
  void rotateRight90() {
    final w = gridWidth.value;
    final h = gridHeight.value;
    if (w == 0 || h == 0) return;

    final oldCodes = pixelCodes.toList();
    final newCodes = List<String>.filled(h * w, '');

    // 右转90度：newGrid[y][x] = oldGrid[h-1-x][y]
    for (int y = 0; y < w; y++) {
      for (int x = 0; x < h; x++) {
        final oldIndex = (h - 1 - x) * w + y;
        final newIndex = y * h + x;
        newCodes[newIndex] = oldCodes[oldIndex];
      }
    }

    pixelCodes.value = newCodes;
    gridWidth.value = h;
    gridHeight.value = w;
    _pushHistory(newCodes);
    _loadUsedColors();
    lastRotateOption.value = 'right90';
    Get.back();
  }

  /// 旋转180度
  void rotate180() {
    final w = gridWidth.value;
    final h = gridHeight.value;
    if (w == 0 || h == 0) return;

    final oldCodes = pixelCodes.toList();
    final newCodes = List<String>.filled(w * h, '');

    // 180度：newGrid[y][x] = oldGrid[h-1-y][w-1-x]
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final oldIndex = (h - 1 - y) * w + (w - 1 - x);
        final newIndex = y * w + x;
        newCodes[newIndex] = oldCodes[oldIndex];
      }
    }

    pixelCodes.value = newCodes;
    _pushHistory(newCodes);
    _loadUsedColors();
    lastRotateOption.value = '180';
    Get.back();
  }

  /// 水平翻转（左右翻转）
  void flipHorizontal() {
    final w = gridWidth.value;
    final h = gridHeight.value;
    if (w == 0 || h == 0) return;

    final oldCodes = pixelCodes.toList();
    final newCodes = List<String>.filled(w * h, '');

    // 水平翻转：newGrid[y][x] = oldGrid[y][w-1-x]
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final oldIndex = y * w + (w - 1 - x);
        final newIndex = y * w + x;
        newCodes[newIndex] = oldCodes[oldIndex];
      }
    }

    pixelCodes.value = newCodes;
    _pushHistory(newCodes);
    _loadUsedColors();
    lastFlipOption.value = 'horizontal';
    // Get.back();
    // showToast('已水平翻转');
  }

  /// 垂直翻转（上下翻转）
  void flipVertical() {
    final w = gridWidth.value;
    final h = gridHeight.value;
    if (w == 0 || h == 0) return;

    final oldCodes = pixelCodes.toList();
    final newCodes = List<String>.filled(w * h, '');

    // 垂直翻转：newGrid[y][x] = oldGrid[h-1-y][x]
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final oldIndex = (h - 1 - y) * w + x;
        final newIndex = y * w + x;
        newCodes[newIndex] = oldCodes[oldIndex];
      }
    }

    pixelCodes.value = newCodes;
    _pushHistory(newCodes);
    _loadUsedColors();
    lastFlipOption.value = 'vertical';
    Get.back();
    // showToast('已垂直翻转');
  }

  /// 从颜色选择弹窗中选择颜色
  void selectColorFromPicker(Color color, String code) {
    // 检查颜色是否已经在使用的颜色列表中
    final isUsed = colorUsageStats.any((item) => item['code'] == code);

    // 检查颜色是否已经在快速访问色列表中
    final isQuickAccess = quickAccessColors.any((item) => item['code'] == code);

    // 如果不在使用的颜色列表或快速访问色列表中，添加到selectedColors
    if (!isUsed && !isQuickAccess) {
      // 检查是否已经在selectedColors中
      final isAlreadySelected =
          selectedColors.any((item) => item['code'] == code);

      if (!isAlreadySelected) {
        // 如果已经有4个颜色，移除最后一个
        if (selectedColors.length >= 4) {
          selectedColors.removeLast();
        }
        // 插入新颜色到最前面（索引0）
        selectedColors.insert(0, {
          'code': code,
          'color': color,
        });
      }
    }

    // 设置画笔颜色
    setBrushColor(color, code);
  }

  /// 获取颜色对应的代码
  String? getColorCode(Color color) {
    return _colorToCodeMap[color];
  }

  /// 更新像素块颜色
  void updatePixelColor(int x, int y, {String? codeValue, int? countValue}) {
    if (currentToolMode.value == ToolMode.view) {
      // 查看模式：弹出色号操作弹窗
      _showColorActionSheet(x, y,codeValue: codeValue,countValue: countValue);
      return;
    }

    final index = y * gridWidth.value + x;
    if (index >= 0 && index < pixelCodes.length) {
      if (currentToolMode.value == ToolMode.draw ||
          currentToolMode.value == ToolMode.sprayGun) {
        // 绘画模式/喷枪模式：设置颜色
        pixelCodes[index] = brushColorCode.value;
      } else if (currentToolMode.value == ToolMode.eraser) {
        // 橡皮擦模式：清空颜色
        pixelCodes[index] = '';
      }

      // 编辑像素后，清除该位置的已拼标记（透明度+✅），恢复正常显示
      _clearPixelCheckedMark(x, y);
    }

    // 防抖重新计算颜色统计（避免频繁遍历）
    _colorStatsDebounce?.cancel();
    _colorStatsDebounce = Timer(const Duration(milliseconds: 100), () {
      _loadUsedColors();
    });

    // 实时保存：绘制过程中即标记脏数据（不等待历史栈合并）
    _markCanvasDirty();

    // 防抖保存历史记录（合并连续绘制操作）
    _historyDebounce?.cancel();
    _historyDebounce = Timer(const Duration(milliseconds: 300), () {
      _pushHistory(pixelCodes.toList(), scheduleAutoSave: false);
    });
  }

  // ===== 查看模式：色号操作弹窗相关方法 =====

  /// 查看模式下点击像素块，弹出色号操作弹窗
  void _showColorActionSheet(int x, int y,
      {String? codeValue, int? countValue}) {
    String code = "";
    int count = 0;
    if (codeValue != null && countValue != null) {
      code = codeValue;
      count = countValue;
    } else {
      final index = y * gridWidth.value + x;
      if (index < 0 || index >= pixelCodes.length) return;
      code = pixelCodes[index];
      if (code.isEmpty) return;
      // 统计该色号使用数量
      count = pixelCodes.where((c) => c == code).length;
    }
    // 获取颜色
    final color = _beadColorMap[code] ?? Colors.grey;
    ColorActionSheet.show(
      Get.context!,
      code: code,
      codeColor: color,
      count: count,
      tapX: x,
      tapY: y,
      highlightedCodes: highlightedCodes,
      onHighlight: (currentCode) => _toggleHighlight(currentCode),
      onOverlayHighlight: (currentCode) => _toggleOverlayHighlight(currentCode),
      onAreaPinned: () => _toggleAreaPinned(x, y, code),
      onSameColorPinned: (currentCode) => _toggleSameColorPinned(currentCode),
      onMergeToOther: (currentCode) => _mergeToOtherColor(currentCode),
      onAutoReplaceSimilar: (onCodeChanged) =>
          _autoReplaceWithSimilar(code, onCodeChanged),
      onMergeBelowThreshold: () => _showMergeBelowThresholdDialog(),
      onDelete: (currentCode) => _deleteColorCode(currentCode),
    );
  }

  /// 切换高亮状态（单色号高亮）
  void _toggleHighlight(String code) {
    if (_highlightedCodes.contains(code)) {
      // 取消高亮：移除该色号
      _highlightedCodes.remove(code);
    } else {
      // 设置高亮：只保留当前色号（替换式）
      _highlightedCodes.clear();
      _highlightedCodes.add(code);
    }
    _debouncedUpdateMaskedGridKeys();
    _markCanvasDirty();
  }

  /// 切换叠加高亮状态（多色号同时高亮）
  void _toggleOverlayHighlight(String code) {
    if (_overlayHighlightedCodes.contains(code)) {
      _overlayHighlightedCodes.remove(code);
    } else {
      _overlayHighlightedCodes.add(code);
    }
    _debouncedUpdateMaskedGridKeys();
    _markCanvasDirty();
  }

  /// 切换区域已拼状态（以点击位置为中心的连通区域）
  void _toggleAreaPinned(int centerX, int centerY, String code) {
    final regionKey = '$centerX,$centerY';

    if (_areaPinnedRegions.contains(regionKey)) {
      // 取消区域已拼
      _areaPinnedRegions.remove(regionKey);
      _removeCheckedRegion(centerX, centerY, code);
    } else {
      // 标记区域已拼：找到连通区域并标记
      final connectedRegion = _findConnectedRegion(centerX, centerY, code);
      _areaPinnedRegions.add(regionKey);
      _checkedGridKeys.addAll(connectedRegion);
    }
    _markCanvasDirty();
  }

  /// 切换同一色号已拼好状态（全画板同色号）
  void _toggleSameColorPinned(String code) {
    if (_sameColorPinnedCodes.contains(code)) {
      // 取消：移除该色号的所有✅标记
      _sameColorPinnedCodes.remove(code);
      _removeAllCodeFromChecked(code);
    } else {
      // 标记：全画板该色号的像素都显示✅
      _sameColorPinnedCodes.add(code);
      for (int i = 0; i < pixelCodes.length; i++) {
        if (pixelCodes[i] == code) {
          final row = i ~/ gridWidth.value;
          final col = i % gridWidth.value;
          _checkedGridKeys.add('$col,$row');
        }
      }
    }
    _markCanvasDirty();
  }

  /// 自动替换成相似色号
  void _autoReplaceWithSimilar(
      String targetCode, void Function(String) onCodeChanged) {
    final targetColor = _beadColorMap[targetCode];
    if (targetColor == null) return;

    // 找到最相似的色号（排除自身）
    String? mostSimilarCode;
    double minDistance = double.infinity;

    for (final entry in _beadColorMap.entries) {
      if (entry.key == targetCode) continue;

      final color = entry.value;
      final distance = _colorDistance(targetColor, color);
      if (distance < minDistance) {
        minDistance = distance;
        mostSimilarCode = entry.key;
      }
    }

    if (mostSimilarCode == null || mostSimilarCode == targetCode) {
      showToast('未找到可替换的相似色号');
      return;
    }

    // 执行替换并保存历史
    _pushHistory(pixelCodes.toList());
    for (int i = 0; i < pixelCodes.length; i++) {
      if (pixelCodes[i] == targetCode) {
        pixelCodes[i] = mostSimilarCode!;
      }
    }
    _loadUsedColors();

    // 清理相关的标记状态
    _cleanupCodeMarkers(targetCode);
    onCodeChanged(mostSimilarCode!);
    showToast('已将 $targetCode 替换为 $mostSimilarCode');
  }

  /// 合并到其他色号（弹出选择弹窗或自动合并到数量最多的相邻色号）
  void _mergeToOtherColor(String code) {
    showToast('合并功能开发中...');
  }

  Future<void> _showMergeBelowThresholdDialog() async {
    final value = await AppOverlay.dialog.inputAsync(
      title: '合并小于指定数量的色号',
      hintText: '请输入数量',
      initialValue: '5',
      keyboardType: TextInputType.number,
    );
    if (value == null) return;
    final threshold = int.tryParse(value) ?? 0;
    if (threshold <= 0) {
      showToast('请输入有效数字');
      return;
    }
    _mergeBelowThreshold(threshold);
  }

  /// 合并使用量小于阈值的色号：每个小色号分别匹配到 >= 阈值中颜色最相似的色号
  Future<void> _mergeBelowThreshold(int threshold) async {
    // 统计每个色号的使用量
    final codeCountMap = <String, int>{};
    for (final code in pixelCodes) {
      if (code.isNotEmpty) {
        codeCountMap[code] = (codeCountMap[code] ?? 0) + 1;
      }
    }

    // 分离：小于阈值（待合并）和大于等于阈值（目标候选）
    final smallCodes = <String>[];
    final bigCodes = <String>[];  // 候选目标色号列表
    for (final entry in codeCountMap.entries) {
      if (entry.value >= threshold) {
        bigCodes.add(entry.key);
      } else {
        smallCodes.add(entry.key);
      }
    }

    if (smallCodes.isEmpty) {
      showToast('没有使用量小于 $threshold 的色号');
      return;
    }
    if (bigCodes.isEmpty) {
      showToast('没有可合并到的目标色号');
      return;
    }

    // 为每个小色号找到颜色最相似的大色号，建立映射关系
    final mergeMap = <String, String>{};
    for (final smallCode in smallCodes) {
      final smallColor = _beadColorMap[smallCode];
      if (smallColor == null) continue;

      String? mostSimilar;
      double minDist = double.infinity;
      for (final bigCode in bigCodes) {
        final bigColor = _beadColorMap[bigCode];
        if (bigColor == null) continue;
        final dist = _colorDistance(smallColor, bigColor);
        if (dist < minDist) {
          minDist = dist;
          mostSimilar = bigCode;
        }
      }
      if (mostSimilar != null && mostSimilar != smallCode) {
        mergeMap[smallCode] = mostSimilar!;
      }
    }

    if (mergeMap.isEmpty) {
      showToast('没有找到可合并的目标色号');
      return;
    }

    // 执行替换：按映射关系逐个替换
    _pushHistory(pixelCodes.toList());
    int mergedCount = 0;
    for (int i = 0; i < pixelCodes.length; i++) {
      final target = mergeMap[pixelCodes[i]];
      if (target != null) {
        pixelCodes[i] = target;
        mergedCount++;
      }
    }

    // 清理被合并的色号标记
    for (final smallCode in mergeMap.keys) {
      _cleanupCodeMarkers(smallCode);
    }

    await _loadUsedColors();

    // 汇总替换信息用于提示
    final summary = mergeMap.entries.map((e) => '${e.key}→${e.value}').join('、');
    showToast(
        '已将 ${mergeMap.length} 个小色号合并（$summary），共 $mergedCount 个像素块');
  }

  /// 删除指定色号（清空所有该色号的像素）
  void _deleteColorCode(String code) async {
    final result = await AppOverlay.dialog.confirmAsync(
      title: '确认删除',
      message: '确定要删除色号 $code 吗？\n这将清空所有使用该色号的像素块。',
      confirmText: '确认删除',
    );
    if (result != true) return;
    if (Get.isBottomSheetOpen == true) Get.back();
    _pushHistory(pixelCodes.toList());
    for (int i = 0; i < pixelCodes.length; i++) {
      if (pixelCodes[i] == code) {
        pixelCodes[i] = '';
      }
    }
    _loadUsedColors();
    _cleanupCodeMarkers(code);
    showToast('已删除色号 $code');
  }

  // ===== 高亮/标记辅助方法 =====

  /// 防抖更新遮罩（运行时操作调用，合并连续切换）
  void _debouncedUpdateMaskedGridKeys() {
    _maskedGridDebounce?.cancel();
    _maskedGridDebounce = Timer(const Duration(milliseconds: 50), () {
      _updateMaskedGridKeys();
    });
  }

  /// 立即更新需要遮罩显示的像素块集合（恢复数据时直接调用，无需防抖）
  void _updateMaskedGridKeys() {
    _maskedGridKeys.clear();

    // 合并高亮色号和叠加高亮色号
    final allHighlighted = <String>{
      ..._highlightedCodes,
      ..._overlayHighlightedCodes
    };

    // 如果没有高亮色号，不需要遮罩
    if (allHighlighted.isEmpty) return;

    // 遍历所有像素，非高亮色号的加入遮罩集合
    for (int row = 0; row < gridHeight.value; row++) {
      for (int col = 0; col < gridWidth.value; col++) {
        final index = row * gridWidth.value + col;
        if (index >= pixelCodes.length) continue;
        final code = pixelCodes[index];
        // 空像素（已删除）也需加入遮罩，避免删除后像素块"反亮"
        if (code.isEmpty || !allHighlighted.contains(code)) {
          _maskedGridKeys.add('$col,$row');
        }
      }
    }
  }

  /// BFS查找连通的同色像素区域
  Set<String> _findConnectedRegion(int startCol, int startRow, String code) {
    final visited = <String>{};
    final queue = <(int, int)>[(startCol, startRow)];
    final result = <String>{};

    while (queue.isNotEmpty) {
      final (col, row) = queue.removeLast();
      final key = '$col,$row';

      if (visited.contains(key)) continue;
      if (col < 0 ||
          col >= gridWidth.value ||
          row < 0 ||
          row >= gridHeight.value) continue;

      final index = row * gridWidth.value + col;
      if (index >= pixelCodes.length) continue;
      if (pixelCodes[index] != code) continue;

      visited.add(key);
      result.add(key);

      // 四方向扩展
      queue.addAll([
        (col + 1, row),
        (col - 1, row),
        (col, row + 1),
        (col, row - 1),
      ]);
    }

    return result;
  }

  /// 移除指定连通区域的✅标记
  void _removeCheckedRegion(int centerX, int centerY, String code) {
    final connectedRegion = _findConnectedRegion(centerX, centerY, code);
    _checkedGridKeys.removeAll(connectedRegion);
  }

  /// 移除指定色号的所有✅标记
  void _removeAllCodeFromChecked(String code) {
    _checkedGridKeys.removeWhere((key) {
      final commaIndex = key.indexOf(',');
      if (commaIndex < 0) return false;
      final col = int.tryParse(key.substring(0, commaIndex)) ?? -1;
      final row = int.tryParse(key.substring(commaIndex + 1)) ?? -1;
      if (col < 0 || row < 0) return false;
      final index = row * gridWidth.value + col;
      return index < pixelCodes.length && pixelCodes[index] == code;
    });
  }

  /// 清除单个像素的已拼标记（编辑像素时调用）
  /// 同时重新计算该位置的蒙层状态（变色后可能需要被遮盖）
  void _clearPixelCheckedMark(int x, int y) {
    final gridKey = '$x,$y';
    final index = y * gridWidth.value + x;

    // 从已拼集合中移除（透明度+✅恢复）
    if (_checkedGridKeys.contains(gridKey)) {
      _checkedGridKeys.remove(gridKey);
    }

    // 重新判断蒙层状态：
    // 如果有高亮色号且编辑后的新色号不在高亮集合中 → 加入蒙层
    // 如果没有高亮或新色号在高亮集合中 → 移出蒙层
    if (index >= 0 && index < pixelCodes.length) {
      final newCode = pixelCodes[index];
      if (_highlightedCodes.isNotEmpty &&
          newCode.isNotEmpty &&
          !_highlightedCodes.contains(newCode)) {
        _maskedGridKeys.add(gridKey);
      } else {
        _maskedGridKeys.remove(gridKey);
      }
    }
  }

  /// 清理指定色号的所有标记状态
  void _cleanupCodeMarkers(String code) {
    _highlightedCodes.remove(code);
    _overlayHighlightedCodes.remove(code);
    _sameColorPinnedCodes.remove(code);
    // 区域已拼需要特殊处理（基于坐标），这里简单清理包含该色号的
    _areaPinnedRegions.removeWhere((regionKey) {
      final commaIndex = regionKey.indexOf(',');
      if (commaIndex < 0) return false;
      final col = int.tryParse(regionKey.substring(0, commaIndex)) ?? -1;
      final row = int.tryParse(regionKey.substring(commaIndex + 1)) ?? -1;
      if (col < 0 || row < 0) return false;
      final index = row * gridWidth.value + col;
      return index < pixelCodes.length && pixelCodes[index] == code;
    });
    _updateMaskedGridKeys();
    _removeAllCodeFromChecked(code);
  }

  /// 计算两个颜色的欧氏距离（用于找相似色）
  double _colorDistance(Color a, Color b) {
    final dr = a.red.toDouble() - b.red.toDouble();
    final dg = a.green.toDouble() - b.green.toDouble();
    final db = a.blue.toDouble() - b.blue.toDouble();
    return (dr * dr + dg * dg + db * db);
  }

  /// 重置画板缩放
  void resetZoom() {
    transformationController.value = Matrix4.identity();
  }

  /// 保存状态到历史栈
  void _pushHistory(List<String> codes, {bool scheduleAutoSave = true}) {
    // 如果当前不是在历史末尾，丢弃后面的记录（新操作覆盖 redo 历史）
    if (_historyIndex < _historyStack.length - 1) {
      _historyStack.removeRange(_historyIndex + 1, _historyStack.length);
    }

    _historyStack.add(List<String>.from(codes));

    // 限制历史栈大小
    if (_historyStack.length > _maxHistory) {
      _historyStack.removeAt(0);
    } else {
      _historyIndex++;
    }

    _updateHistoryState();

    if (scheduleAutoSave) {
      _markCanvasDirty();
    }
  }

  /// 更新撤销/恢复按钮状态
  void _updateHistoryState() {
    hasPreStep.value = _historyIndex > 0;
    hasNextStep.value = _historyIndex < _historyStack.length - 1;
  }

  /// 撤销（上一步）
  void undo() {
    if (_historyIndex <= 0) return;
    _historyDebounce?.cancel();
    _colorStatsDebounce?.cancel();
    _historyIndex--;
    pixelCodes.value = List<String>.from(_historyStack[_historyIndex]);
    _updateHistoryState();
    _loadUsedColors();
    _markCanvasDirty();
  }

  /// 恢复（下一步）
  void redo() {
    if (_historyIndex >= _historyStack.length - 1) return;
    _historyDebounce?.cancel();
    _colorStatsDebounce?.cancel();
    _historyIndex++;
    pixelCodes.value = List<String>.from(_historyStack[_historyIndex]);
    _updateHistoryState();
    _loadUsedColors();
    _markCanvasDirty();
  }

  /// 切换减色选项（基于当前像素的相似色合并，保留所有用户编辑）
  Future<void> changeColorLimit(int index) async {
    if (selectedColorLimitIndex.value == index) return;

    // 先标记正在重新处理（防止 PixelCanvas 提前加载颜色）
    isReprocessing.value = true;

    // 更新索引
    selectedColorLimitIndex.value = index;

    // 获取新的ColorLimit枚举
    final newColorLimit = ColorLimit.values[index];
    _currentColorLimit = newColorLimit;

    // 更新标签
    colorLimitLabel.value = newColorLimit.label;
    // 显示loading窗
    _showLoadingDialog();

    // 用相似色合并方式处理减色（不依赖原图，保留用户编辑）
    await _remapColorsToLimitedColors();
  }

  /// 切换品牌色选项
  Future<void> changeBeadBrand(int index) async {
    if (selectedBeadBrandIndex.value == index) return;

    // 先标记正在重新处理（防止 PixelCanvas 提前加载颜色）
    isReprocessing.value = true;

    // 更新索引
    selectedBeadBrandIndex.value = index;

    // 获取新的BeadBrand枚举
    final newBeadBrand = BeadBrand.values[index];
    _currentBeadBrand = newBeadBrand;

    // 更新标签
    beadBrandLabel.value = newBeadBrand.displayName;
    // 显示loading窗
    _showLoadingDialog();

    // 统一使用 CIE Lab 相似色映射（保留用户在画布上的所有编辑，不依赖原图重处理）
    await _remapColorsToNewBrand();
  }

  /// RGB → CIE Lab（委托 ColorDelta）
  static List<double> _rgbToLab(int r, int g, int b) =>
      ColorDelta.rgbToLab(r, g, b);

  /// 品牌切换：基于原始RGB快照 + 用户编辑差量的 CIE Lab 相似色映射
  ///
  /// 核心保证：_originalPixelRGBs 在首次切换时捕获（存 RGB 值），之后永不更新。
  /// 这样 A→B→A 时，最后一步从同一份 RGB 数据映射回 MARD，能完全还原初始效果。
  Future<void> _remapColorsToNewBrand() async {
    try {
      final newJsonPath =
          _currentBeadBrand?.jsonPath ?? 'assets/mard_colors.json';
      debugPrint('[品牌切换] 加载新品牌: $newJsonPath');

      // === Step 0: 首次切换时，用当前 _beadColorMap 捕获 RGB 快照 ===
      if (!_originalSnapshotReady) {
        debugPrint('[品牌切换] 首次切换，捕获原始 RGB 快照...');
        _originalPixelRGBs = pixelCodes.map((code) {
          if (code.isEmpty) return null;
          final c = _beadColorMap[code];
          if (c == null) return null;
          return c.value;
        }).toList();
        _originalSnapshotReady = true;
        debugPrint('[品牌切换] 快照已保存: ${pixelCodes.length} 个像素');
      }

      // === Step 1: 收集所有需要参与映射的 RGB ===
      // - baseRGBs: 快照中的原始 RGB（未变/已变都收集）
      // - newDrawnRGBs: 快照为空但当前有色的（用户在空白处新画的）
      final baseRGBs = <int>{};
      final newDrawnRGBs = <int>{};

      for (int i = 0; i < pixelCodes.length; i++) {
        final currentCode = pixelCodes[i];
        if (currentCode.isEmpty) continue;

        final currentColor = _beadColorMap[currentCode];
        if (currentColor == null) continue;

        final originalRGB =
            i < _originalPixelRGBs.length ? _originalPixelRGBs[i] : null;

        if (originalRGB != null) {
          baseRGBs.add(originalRGB); // 有快照 → 基准层
        } else {
          newDrawnRGBs.add(currentColor.value); // 无快照 → 新绘制
        }
      }

      // 合并所有需要映射的 RGB
      final allRGBs = Set<int>.from(baseRGBs)..addAll(newDrawnRGBs);

      debugPrint(
          '[品牌切换] 基准色数: ${baseRGBs.length}, 新绘色数: ${newDrawnRGBs.length}, 总计: ${allRGBs.length}');

      if (allRGBs.isEmpty) {
        debugPrint('[品牌切换] 无绘制数据，仅刷新颜色库');
        await _loadUsedColors(updateDefaultBrushColor: true);
        showToast('已应用新的品牌色');
        return;
      }

      // === Step 2: 加载新品牌颜色库，预转为 CIE Lab 空间 ===
      final jsonString = await rootBundle.loadString(newJsonPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final colors = json['colors'] as List;

      final newBrandColorsLab = <List<dynamic>>[];
      for (final colorData in colors) {
        final c = colorData as Map<String, dynamic>;
        final code = c['code'] as String;
        final hex = (c['hex'] as String).replaceAll('#', '');
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        newBrandColorsLab.add([code, ..._rgbToLab(r, g, b)]);
      }
      debugPrint('[品牌切换] 新品牌颜色库大小: ${newBrandColorsLab.length}');

      // === Step 3: 构建 RGB → 新品牌代码的映射表 ===
      final rgbMapping = <int, String>{};
      for (final rgb in allRGBs) {
        final oldColor = Color(rgb);
        final oldLab = _rgbToLab(
          (oldColor.r * 255).round(),
          (oldColor.g * 255).round(),
          (oldColor.b * 255).round(),
        );
        double minDist = double.maxFinite;
        String? bestCode;

        for (final nc in newBrandColorsLab) {
          final de = ColorDelta.deltaE00FromLab(
            oldLab,
            [nc[1] as double, nc[2] as double, nc[3] as double],
          );
          if (de < minDist) {
            minDist = de;
            bestCode = nc[0].toString();
          }
        }

        if (bestCode != null) {
          rgbMapping[rgb] = bestCode;
        }
      }
      debugPrint('[品牌切换] 映射表大小: ${rgbMapping.length}');

      // === Step 4: 用快照 RGB 统一替换所有像素 ===
      int replacedCount = 0;
      for (int i = 0; i < pixelCodes.length; i++) {
        final originalRGB =
            i < _originalPixelRGBs.length ? _originalPixelRGBs[i] : null;

        if (originalRGB != null && rgbMapping.containsKey(originalRGB)) {
          pixelCodes[i] = rgbMapping[originalRGB]!;
          replacedCount++;
        } else {
          // 快照为空（用户在空白区域画过），用当前像素的 RGB 映射
          final currentCode = pixelCodes[i];
          if (currentCode.isNotEmpty) {
            final currentColor = _beadColorMap[currentCode];
            if (currentColor != null &&
                rgbMapping.containsKey(currentColor.value)) {
              pixelCodes[i] = rgbMapping[currentColor.value]!;
              replacedCount++;
            }
          }
        }
      }
      pixelCodes.refresh();
      debugPrint('[品牌切换] 已替换 $replacedCount 个像素');

      // === Step 5: 刷新颜色统计和历史栈 ===
      await _loadUsedColors(updateDefaultBrushColor: true);

      _historyStack.clear();
      _historyIndex = -1;
      _pushHistory(pixelCodes.toList());

      showToast('已应用新的品牌色');
    } catch (e) {
      debugPrint('[品牌切换] 失败: $e');
      showToast('品牌色切换失败');
    } finally {
      isReprocessing.value = false;
      Get.dismiss();
    }
  }

  /// 减色处理：基于当前像素的使用频率 + CIE Lab 相似度合并颜色
  ///
  /// 算法：
  /// 1. 统计每种颜色的使用次数，按频率降序排列
  /// 2. 取 Top N 种（N = colorLimit.limit）作为"锚点颜色"
  /// 3. 剩余每种颜色 → 在锚点中找 Delta E 最近似色作为替换目标
  /// 4. 批量替换 pixelCodes 并刷新统计
  Future<void> _remapColorsToLimitedColors() async {
    try {
      final limitValue = _currentColorLimit?.limit ?? -1;
      debugPrint('[减色处理] 目标颜色数上限: $limitValue');

      // 1. 统计每个颜色代码的使用频率
      final colorCount = <String, int>{};
      for (final code in pixelCodes) {
        if (code.isNotEmpty) {
          colorCount[code] = (colorCount[code] ?? 0) + 1;
        }
      }
      debugPrint('[减色处理] 当前使用颜色数: ${colorCount.length}');

      if (colorCount.length <= limitValue || limitValue == -1) {
        debugPrint('[减色处理] 颜色数已在限制内，无需合并');
        return;
      }

      final labByCode = <String, List<double>>{};
      for (final code in colorCount.keys) {
        final c = _beadColorMap[code];
        if (c != null) {
          labByCode[code] = _rgbToLab(
            (c.r * 255).round(),
            (c.g * 255).round(),
            (c.b * 255).round(),
          );
        }
      }

      final mergeMapping = ColorMergeUtil.buildMergeMapping(
        colorCount: colorCount,
        labByCode: labByCode,
        maxColors: limitValue,
      );
      debugPrint('[减色处理] 合并映射: $mergeMapping');

      final codes = List<String>.from(pixelCodes);
      final mergedCount = ColorMergeUtil.applyMapping(codes, mergeMapping);
      if (mergedCount > 0) {
        pixelCodes.value = codes;
      }
      pixelCodes.refresh();
      debugPrint('[减色处理] 已合并 $mergedCount 个像素');

      // 6. 刷新颜色统计和历史栈
      await _loadUsedColors(updateDefaultBrushColor: true);

      _historyStack.clear();
      _historyIndex = -1;
      _pushHistory(pixelCodes.toList());

      // showToast('已应用新的减色选项');
    } catch (e) {
      debugPrint('[减色处理] 失败: $e');
      showToast('减色处理失败');
    } finally {
      isReprocessing.value = false;
      Get.dismiss();
    }
  }

  /// 获取编辑工具列表
  List<ToolItem> get editTools => [
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_look.svg',
          label: '查看',
          toolMode: ToolMode.view,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_canvas.svg',
          label: '绘画',
          toolMode: ToolMode.draw,
        ),
       // // 新增模式
       // ToolItem(
       //    iconAsset: 'assets/icons/icon_tools_location_line.svg',
       //    label: '点位线',
       //    toolMode: ToolMode.locationLine,
       //  ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_clean.svg',
          label: '橡皮擦',
          toolMode: ToolMode.eraser,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_fill_all.svg',
          label: '填充',
          customOnTap: () => fillAll(),
          type: ToolType.immediateAction,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_fill_area.svg',
          label: '泛填充',
          toolMode: ToolMode.floodFill,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_extract.svg',
          label: '提取',
          toolMode: ToolMode.extract,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_change.svg',
          label: '切换',
          customOnTap: () => showColorSwitchDialog(),
          type: ToolType.immediateAction,
        ),
        ToolItem(
            iconAsset: 'assets/icons/icon_tools_shape.svg',
            label: '形状',
            toolMode: ToolMode.shape,
            type: ToolType.popupAction),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_spray_gun.svg',
          label: '喷枪',
          toolMode: ToolMode.sprayGun,
          type: ToolType.popupAction,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_text.svg',
          label: 'Text',
          toolMode: ToolMode.text,
          type: ToolType.popupAction,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_flip_horizontal.svg',
          label: '水平镜像',
          toolMode: ToolMode.flip,
          customOnTap: () => flipHorizontal(),
          type: ToolType.immediateAction,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_rotate_left90_default.svg',
          label: '左转90°‌',
          toolMode: ToolMode.rotate,
          customOnTap: () => rotateLeft90(),
          type: ToolType.immediateAction,
        ),
        // ToolItem(
        //   iconAsset: 'assets/icons/icon_tools_choose.svg',
        //   label: '选择',
        //   toolMode: ToolMode.select,
        // ),
      ];

  /// 获取其他工具列表
  List<ToolItem> get otherTools => [
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_item_shape.svg',
          label: '方形',
          toolMode: ToolMode.square,
          customOnTap: () => isCircleMode.value = !isCircleMode.value,
          isSelected: () => true,
          type: ToolType.multiSelect,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_grid.svg',
          label: '网格',
          toolMode: ToolMode.grid,
          type: ToolType.multiSelect,
          customOnTap: () {
            _showMoreSettingsSheet();
          },
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_code.svg',
          label: '代码',
          toolMode: ToolMode.code,
          type: ToolType.multiSelect,
          customOnTap: () {
            _showColorDisplayModeSheet();
          },
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_order.svg',
          label: '编号',
          toolMode: ToolMode.number,
          type: ToolType.multiSelect,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_example.svg',
          label: '参考',
          toolMode: ToolMode.reference,
          type: ToolType.multiSelect,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_zoom_in.svg',
          label: '放大',
          customOnTap: () => zoomIn(),
          type: ToolType.immediateAction,
        ),
        ToolItem(
          iconAsset: 'assets/icons/icon_tools_zoom_out.svg',
          label: '缩小',
          customOnTap: () => zoomOut(),
          type: ToolType.immediateAction,
        ),
      ];
}
