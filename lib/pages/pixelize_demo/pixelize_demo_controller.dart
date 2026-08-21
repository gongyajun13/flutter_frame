import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../base/base_controller.dart';
import '../../app/routes/app_pages.dart';
import '../../utils/pixelize_util.dart';
import 'data/local_draft_store.dart';

/// 入口模式
enum PixelizeEntryMode {
  blankCanvas('空白画布'),
  fromImage('图片生成');

  final String label;
  const PixelizeEntryMode(this.label);
}

/// 像素化演示控制器
class PixelizeDemoController extends BaseController {
  final ImagePicker _picker = ImagePicker();

  /// 当前入口模式
  final Rx<PixelizeEntryMode> entryMode = PixelizeEntryMode.fromImage.obs;

  /// 当前选中的网格大小
  final Rx<GridSize> selectedGridSize = GridSize.size52x52.obs;

  /// 默认色号品牌（颜色数量不限，画板内可再减色）
  static const BeadBrand _defaultBeadBrand = BeadBrand.mard;
  static const ColorLimit _defaultColorLimit = ColorLimit.unlimited;

  /// 是否正在处理
  final RxBool isProcessing = false.obs;

  /// 本地草稿摘要（最多一份）
  final Rx<LocalDraftSummary?> localDraft = Rx<LocalDraftSummary?>(null);

  /// 是否正在加载草稿信息
  final RxBool isDraftLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    refreshLocalDraft();
  }

  /// 刷新标题栏展示的本地草稿
  Future<void> refreshLocalDraft() async {
    isDraftLoading.value = true;
    try {
      final drafts = await LocalDraftStore.listSummaries();
      localDraft.value = drafts.isNotEmpty ? drafts.first : null;
    } catch (e) {
      localDraft.value = null;
    } finally {
      isDraftLoading.value = false;
    }
  }

  /// 继续编辑本地草稿
  Future<void> openLocalDraft() async {
    final draft = localDraft.value;
    if (draft == null) {
      showError('暂无本地草稿');
      return;
    }
    await Get.toNamed(
      Routes.PIXELIZE_RESULT,
      arguments: {
        'restoreLocalDraft': true,
        'draftId': draft.id,
      },
    );
    await refreshLocalDraft();
  }

  void switchEntryMode(PixelizeEntryMode mode) {
    entryMode.value = mode;
  }

  void setGridSize(GridSize gridSize) {
    selectedGridSize.value = gridSize;
  }

  /// 空白画布：直接进入编辑页
  Future<void> startBlankCanvas() async {
    final gridSize = selectedGridSize.value;
    await Get.toNamed(
      Routes.PIXELIZE_RESULT,
      arguments: {
        'isBlankCanvas': true,
        'gridWidth': gridSize.width,
        'gridHeight': gridSize.height,
      },
    );
    await refreshLocalDraft();
  }

  /// 选择图片并像素化
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image == null) return;

      final gridSize = selectedGridSize.value;
      final aspectRatioX = gridSize.width.toDouble();
      final aspectRatioY = gridSize.height.toDouble();

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: aspectRatioX, ratioY: aspectRatioY),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪图片',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            aspectRatioPresets: [
              if (aspectRatioX == aspectRatioY) CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: '裁剪图片',
            aspectRatioPresets: [
              if (aspectRatioX == aspectRatioY) CropAspectRatioPreset.square,
            ],
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (croppedFile == null) return;

      isProcessing.value = true;
      await _pixelizeAndNavigate(File(croppedFile.path));
    } catch (e) {
      showError('选择图片失败: $e');
      isProcessing.value = false;
    }
  }

  Future<void> _pixelizeAndNavigate(File imageFile) async {
    try {
      final result = await PixelizeUtil.pixelizeImage(
        imageFile,
        selectedGridSize.value,
        _defaultColorLimit,
        _defaultBeadBrand,
      );

      if (result == null) {
        showError('像素化处理失败');
        return;
      }

      final info = await PixelizeUtil.getImageInfo(result.imageFile);

      while (Get.isDialogOpen ?? false) {
        try {
          Get.back();
        } catch (_) {
          break;
        }
      }
      isProcessing.value = false;

      await Get.toNamed(
        Routes.PIXELIZE_RESULT,
        arguments: {
          'originalImage': imageFile,
          'pixelizedImage': result.imageFile,
          'pixelizedImageInfo': info,
          'pixelCodes': result.pixelCodes,
          'gridWidth': result.gridWidth,
          'gridHeight': result.gridHeight,
          'gridSize': selectedGridSize.value.label,
          'colorLimit': _defaultColorLimit.label,
          'colorLimitEnum': _defaultColorLimit,
          'beadBrand': _defaultBeadBrand.displayName,
          'beadBrandEnum': _defaultBeadBrand,
        },
      );
    } catch (e) {
      showError('像素化处理失败: $e');
      isProcessing.value = false;
    }
  }
}
