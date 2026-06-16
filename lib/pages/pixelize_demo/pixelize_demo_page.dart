import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../base/base_page.dart';
import '../../constants/app_colors.dart';
import '../../utils/pixelize_util.dart';
import 'data/local_draft_store.dart';
import 'pixelize_demo_controller.dart';

/// 拼豆创作入口
class PixelizeDemoPage extends BasePage<PixelizeDemoController> {
  const PixelizeDemoPage({super.key});

  static const _accent = AppColors.cF9B400;
  static const _ink = AppColors.c19;
  static const _muted = AppColors.get999;

  @override
  String? get pageTitle => '拼豆创作';

  @override
  bool get showAppBar => false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          super.build(context),
          if (controller.isProcessing.value) _buildLoadingOverlay(),
        ],
      );
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return ColoredBox(
      color: AppColors.getF7,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDraftBanner(),
                  SizedBox(height: 20.h),
                  _buildModeCards(),
                  SizedBox(height: 28.h),
                  _buildGridSection(),
                  SizedBox(height: 28.h),
                  Obx(() {
                    if (controller.entryMode.value == PixelizeEntryMode.blankCanvas) {
                      return _buildStartButton(
                        label: '开始创作',
                        onTap: controller.startBlankCanvas,
                      );
                    }
                    return _buildImageUpload();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(4.w, top + 2.h, 12.w, 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.w, color: _ink),
          ),
          Expanded(
            child: Text(
              pageTitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
          ),
          _buildDraftAction(),
        ],
      ),
    );
  }

  Widget _buildDraftAction() {
    return Obx(() {
      if (controller.isDraftLoading.value) {
        return SizedBox(
          width: 72.w,
          child: Center(
            child: SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
            ),
          ),
        );
      }

      final draft = controller.localDraft.value;
      if (draft == null) {
        return SizedBox(
          width: 72.w,
          child: Text(
            '无草稿',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12.sp, color: _muted),
          ),
        );
      }

      return GestureDetector(
        onTap: controller.openLocalDraft,
        child: SizedBox(
          width: 72.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                draft.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
              Text(
                '继续编辑',
                style: TextStyle(fontSize: 10.sp, color: _muted),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDraftBanner() {
    return Obx(() {
      final draft = controller.localDraft.value;
      if (draft == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: controller.openLocalDraft,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              _buildDraftThumb(draft),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '继续上次创作',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${draft.title} · ${draft.gridWidth}×${draft.gridHeight}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: _muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20.w, color: _muted),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDraftThumb(LocalDraftSummary draft) {
    final path = draft.picture;
    Widget img;
    if (path != null && !path.startsWith('http') && File(path).existsSync()) {
      img = Image.file(File(path), fit: BoxFit.cover);
    } else {
      img = Icon(Icons.grid_on, color: _accent, size: 22.w);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 48.w,
        height: 48.w,
        color: AppColors.getF2,
        child: img,
      ),
    );
  }

  Widget _buildModeCards() {
    return Obx(() {
      final mode = controller.entryMode.value;
      return Column(
        children: PixelizeEntryMode.values.map((item) {
          final selected = mode == item;
          final isBlank = item == PixelizeEntryMode.blankCanvas;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: () => controller.switchEntryMode(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: selected ? _accent : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: selected
                            ? _accent.withValues(alpha: 0.2)
                            : AppColors.getF2,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        isBlank ? Icons.grid_4x4_rounded : Icons.image_outlined,
                        color: selected ? _ink : _muted,
                        size: 22.w,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isBlank ? '空白网格，自由填色' : '导入照片，自动生成拼豆图',
                            style: TextStyle(fontSize: 12.sp, color: _muted),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, color: _accent, size: 22.w)
                    else
                      Icon(Icons.circle_outlined, color: AppColors.getC4, size: 22.w),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '画板尺寸',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: GridSize.values.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final size = GridSize.values[index];
              return Obx(() {
                final selected = controller.selectedGridSize.value == size;
                return GestureDetector(
                  onTap: () => controller.setGridSize(size),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _ink : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      size.label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : _ink,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: _ink,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.getDB, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 36.w, color: _accent),
            SizedBox(height: 10.h),
            Text(
              '选择图片',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '色号与颜色数量可在画板中调整',
              style: TextStyle(fontSize: 12.sp, color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Material(
      color: Colors.black45,
      child: Center(
        child: Container(
          width: 140.w,
          padding: EdgeInsets.symmetric(vertical: 28.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32.w,
                height: 32.w,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: _accent),
              ),
              SizedBox(height: 14.h),
              Text(
                '生成中…',
                style: TextStyle(fontSize: 14.sp, color: _ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
