import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'image_util_demo_controller.dart';

/// 图片处理演示页面
class ImageUtilDemoView extends BaseScrollPage<ImageUtilDemoController> {
  const ImageUtilDemoView({super.key});

  @override
  String? get pageTitle => '图片处理工具';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      backgroundColor: AppDesignTokens.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: controller.clearImages,
          tooltip: '清除所有',
        ),
      ],
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 图片预览区域
        _buildImagePreview(),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 图片信息
        _buildImageInfo(),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 选择图片
        _buildPickSection(),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 裁剪图片
        _buildCropSection(),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 压缩图片
        _buildCompressSection(),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 上传图片
        _buildUploadSection(),
        
        SizedBox(height: AppDesignTokens.spacingV20),
        
        // 完整流程
        _buildCompleteFlowSection(),
      ],
    );
  }

  /// 图片预览区域
  Widget _buildImagePreview() {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: AppDesignTokens.grey100,
            borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: AppDesignTokens.iconSizeExtraLarge,
                  color: AppDesignTokens.grey400,
                ),
                SizedBox(height: AppDesignTokens.spacingV8),
                Text(
                  '暂无图片',
                  style: TextStyle(
                    color: AppDesignTokens.textSecondary,
                    fontSize: AppDesignTokens.fontSize14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
          boxShadow: AppDesignTokens.shadowMedium,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
          child: Stack(
            children: [
              // PageView 图片预览
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.switchToImage(index);
                },
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    controller.selectedImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppDesignTokens.grey100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: AppDesignTokens.iconSizeLarge,
                                color: AppDesignTokens.grey400,
                              ),
                              SizedBox(height: AppDesignTokens.spacingV8),
                              Text(
                                '图片加载失败',
                                style: TextStyle(
                                  color: AppDesignTokens.textSecondary,
                                  fontSize: AppDesignTokens.fontSize14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              
              // 图片计数指示器
              if (controller.selectedImages.length > 1)
                Positioned(
                  top: AppDesignTokens.spacing12,
                  right: AppDesignTokens.spacing12,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignTokens.spacing8,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                    ),
                    child: Text(
                      '${controller.currentImageIndex.value + 1}/${controller.selectedImages.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppDesignTokens.fontSize12,
                        fontWeight: AppDesignTokens.fontWeightMedium,
                      ),
                    ),
                  ),
                ),
              
              // 左右切换按钮
              if (controller.selectedImages.length > 1) ...[
                // 左箭头
                if (controller.currentImageIndex.value > 0)
                  Positioned(
                    left: AppDesignTokens.spacing12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: controller.previousImage,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: AppDesignTokens.iconSizeMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // 右箭头
                if (controller.currentImageIndex.value < controller.selectedImages.length - 1)
                  Positioned(
                    right: AppDesignTokens.spacing12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: controller.nextImage,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: AppDesignTokens.iconSizeMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// 图片信息
  Widget _buildImageInfo() {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return const SizedBox.shrink();
      }

      return AppCard(
        size: AppCardSize.large,
        showShadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '图片信息',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize16,
                    fontWeight: AppDesignTokens.fontWeightBold,
                  ),
                ),
                if (controller.selectedImages.length > 1) ...[
                  SizedBox(width: AppDesignTokens.spacing8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignTokens.spacing8,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
                    ),
                    child: Text(
                      '第 ${controller.currentImageIndex.value + 1} 张',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSize12,
                        color: AppDesignTokens.infoColor,
                        fontWeight: AppDesignTokens.fontWeightMedium,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppDesignTokens.spacingV12),
            if (controller.originalSize.value.isNotEmpty)
              _buildInfoRow('原始大小', controller.originalSize.value),
            if (controller.compressedSize.value.isNotEmpty)
              _buildInfoRow('压缩后', controller.compressedSize.value),
            if (controller.selectedImages.length > 1)
              _buildInfoRow('已选择', '${controller.selectedImages.length} 张图片'),
            if (controller.selectedImages.length > 1)
              _buildInfoRow('当前图片', '${controller.currentImageIndex.value + 1}/${controller.selectedImages.length}'),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDesignTokens.spacingV8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              fontWeight: AppDesignTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// 选择图片区域
  Widget _buildPickSection() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. 选择图片',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Row(
            children: [
              Expanded(
                child: AppButton.primary(
                  text: '选择图片',
                  onPressed: controller.showImagePickerDialog,
                  icon: Icons.add_photo_alternate,
                  isFullWidth: true,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing12),
              Expanded(
                child: AppButton(
                  text: '微信选择',
                  onPressed: controller.showWechatPickerDialog,
                  icon: Icons.wechat,
                  type: AppButtonType.primary,
                  backgroundColor: AppDesignTokens.successColor,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 裁剪图片区域
  Widget _buildCropSection() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2. 裁剪图片',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Wrap(
            spacing: AppDesignTokens.spacing8,
            runSpacing: AppDesignTokens.spacingV8,
            children: [
              AppButton.primary(
                text: '自由裁剪',
                onPressed: controller.cropFree,
                size: AppButtonSize.small,
              ),
              AppButton.primary(
                text: '正方形 1:1',
                onPressed: controller.cropToSquare,
                size: AppButtonSize.small,
              ),
              AppButton.primary(
                text: '4:3',
                onPressed: controller.cropTo4x3,
                size: AppButtonSize.small,
              ),
              AppButton.primary(
                text: '16:9',
                onPressed: controller.cropTo16x9,
                size: AppButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 压缩图片区域
  Widget _buildCompressSection() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3. 压缩图片',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Row(
            children: [
              Expanded(
                child: AppButton.primary(
                  text: '标准压缩 (85%)',
                  onPressed: () => controller.compressImage(quality: 85),
                  isFullWidth: true,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing12),
              Expanded(
                child: AppButton.primary(
                  text: '高度压缩 (60%)',
                  onPressed: () => controller.compressImage(quality: 60),
                  isFullWidth: true,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV8),
          Row(
            children: [
              Expanded(
                child: AppButton.outline(
                  text: '压缩到 500KB',
                  onPressed: () => controller.compressToSize(maxSizeKB: 500),
                  isFullWidth: true,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing12),
              Expanded(
                child: AppButton.outline(
                  text: '压缩到 200KB',
                  onPressed: () => controller.compressToSize(maxSizeKB: 200),
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 上传图片区域
  Widget _buildUploadSection() {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4. 上传图片',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          Obx(() {
            if (controller.isUploading.value) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.uploadProgress.value,
                    backgroundColor: AppDesignTokens.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppDesignTokens.primaryColor),
                  ),
                  SizedBox(height: AppDesignTokens.spacingV8),
                  Text(
                    '上传中... ${(controller.uploadProgress.value * 100).toInt()}%',
                    style: TextStyle(fontSize: AppDesignTokens.fontSize12),
                  ),
                ],
              );
            }

            return AppButton.primary(
              text: '上传图片（模拟）',
              onPressed: controller.uploadImage,
              icon: Icons.cloud_upload,
              isFullWidth: true,
            );
          }),
        ],
      ),
    );
  }

  /// 完整流程区域
  Widget _buildCompleteFlowSection() {
    return AppCard(
      size: AppCardSize.large,
      backgroundColor: AppDesignTokens.infoColor.withOpacity(0.1),
      showBorder: true,
      borderColor: AppDesignTokens.infoColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppDesignTokens.infoColor,
                size: AppDesignTokens.iconSizeMedium,
              ),
              SizedBox(width: AppDesignTokens.spacing8),
              Text(
                '完整流程',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize16,
                  fontWeight: AppDesignTokens.fontWeightBold,
                  color: AppDesignTokens.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV8),
          Text(
            '选择 → 裁剪 → 压缩 → 上传',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize12,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '一键完整流程',
            onPressed: controller.completeFlow,
            icon: Icons.play_arrow,
            type: AppButtonType.primary,
            backgroundColor: AppDesignTokens.infoColor,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
