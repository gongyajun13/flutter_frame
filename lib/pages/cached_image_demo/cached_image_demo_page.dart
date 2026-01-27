import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cached_image_widgets.dart';
import 'cached_image_demo_controller.dart';
import 'package:get/get.dart';

/// 缓存图片Widget演示页面
class CachedImageDemoPage extends BaseScrollPage<CachedImageDemoController> {
  const CachedImageDemoPage({super.key});

  @override
  String? get pageTitle => '缓存图片Widget演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      backgroundColor: AppDesignTokens.infoColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing16,
        vertical: AppDesignTokens.spacingV12,
      );

  @override
  Widget buildScrollContent(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像类型演示
            _buildSectionCard(
              '头像类型图片',
              AppDesignTokens.secondaryColor,
              [
                _buildAvatarSection(),
              ],
            ),
            
            SizedBox(height: AppDesignTokens.spacingV16),
            
            // 圆角类型演示
            _buildSectionCard(
              '圆角类型图片',
              AppDesignTokens.successColor,
              [
                _buildRoundedSection(),
              ],
            ),
            
            SizedBox(height: AppDesignTokens.spacingV16),
            
            // 毛玻璃效果演示
            _buildSectionCard(
              '毛玻璃效果图片',
              AppDesignTokens.warningColor,
              [
                _buildGlassSection(),
              ],
            ),
            
            SizedBox(height: AppDesignTokens.spacingV16),
            
            // 占位图演示
            _buildSectionCard(
              '占位图类型图片',
              AppDesignTokens.primaryColor,
              [
                _buildPlaceholderSection(),
              ],
            ),
            
            SizedBox(height: AppDesignTokens.spacingV16),
            
            // 自定义占位图和错误处理演示
            _buildSectionCard(
              '自定义占位图和错误处理',
              AppDesignTokens.errorColor,
              [
                _buildCustomSection(),
              ],
            ),
            
            SizedBox(height: AppDesignTokens.spacingV16),
            
            // 测试按钮
            _buildSectionCard(
              '测试功能',
              AppDesignTokens.infoColor,
              [
                _buildTestButtons(),
              ],
            ),
          ],
        ));
  }

  /// 构建头像类型演示
  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '不同尺寸的头像图片：',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Wrap(
          spacing: AppDesignTokens.spacing12,
          runSpacing: AppDesignTokens.spacingV12,
          children: [
            AvatarImageWidget(
              imageUrl: controller.testImageUrls[0],
              size: 50,
              onTap: () => controller.showImageInfo('小头像', controller.testImageUrls[0]),
            ),
            AvatarImageWidget(
              imageUrl: controller.testImageUrls[1],
              size: 60,
              onTap: () => controller.showImageInfo('中头像', controller.testImageUrls[1]),
            ),
            AvatarImageWidget(
              imageUrl: controller.testImageUrls[2],
              size: 70,
              onTap: () => controller.showImageInfo('大头像', controller.testImageUrls[2]),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Text(
          '自定义占位图的头像：',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Wrap(
          spacing: AppDesignTokens.spacing12,
          runSpacing: AppDesignTokens.spacingV12,
          children: [
            AvatarImageWidget(
              imageUrl: controller.testImageUrls[3],
              size: 60,
              placeholder: CustomPlaceholderWidget(
                icon: Icons.person,
                title: '加载中...',
                    backgroundColor: AppDesignTokens.infoColor.withOpacity(0.1),
                iconColor: AppDesignTokens.infoColor,
              ),
              onTap: () => controller.showImageInfo('自定义占位图头像', controller.testImageUrls[3]),
            ),
            AvatarImageWidget(
              imageUrl: controller.errorImageUrl,
              size: 60,
              errorWidget: CustomErrorWidget(
                icon: Icons.person_off,
                message: '头像加载失败',
                    backgroundColor: AppDesignTokens.errorColor.withOpacity(0.1),
                iconColor: AppDesignTokens.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建圆角类型演示
  Widget _buildRoundedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '不同尺寸的圆角图片：',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Wrap(
          spacing: AppDesignTokens.spacing12,
          runSpacing: AppDesignTokens.spacingV12,
          children: [
            RoundedImageWidget(
              imageUrl: controller.testImageUrls[0],
              width: 90.w,
              height: 90.w,
              onTap: () => controller.showImageInfo('小圆角图片', controller.testImageUrls[0]),
            ),
            RoundedImageWidget(
              imageUrl: controller.testImageUrls[1],
              width: 120.w,
              height: 80.w,
              onTap: () => controller.showImageInfo('矩形圆角图片', controller.testImageUrls[1]),
            ),
            RoundedImageWidget(
              imageUrl: controller.testImageUrls[2],
              width: 100.w,
              height: 100.w,
              borderRadius: 20,
              onTap: () => controller.showImageInfo('大圆角图片', controller.testImageUrls[2]),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Text(
          '长宽比不同的圆角图片：',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        RoundedImageWidget(
          imageUrl: controller.testImageUrls[3],
          width: double.infinity,
          height: 140.h,
          fit: BoxFit.cover,
          onTap: () => controller.showImageInfo('全宽圆角图片', controller.testImageUrls[3]),
        ),
      ],
    );
  }

  /// 构建毛玻璃效果演示
  Widget _buildGlassSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '毛玻璃效果图片：',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Wrap(
          spacing: AppDesignTokens.spacing12,
          runSpacing: AppDesignTokens.spacingV12,
          children: [
            GlassImageWidget(
              imageUrl: controller.testImageUrls[0],
              width: 110.w,
              height: 110.w,
              onTap: () => controller.showImageInfo('毛玻璃效果图片1', controller.testImageUrls[0]),
            ),
            GlassImageWidget(
              imageUrl: controller.testImageUrls[1],
              width: 110.w,
              height: 110.w,
              onTap: () => controller.showImageInfo('毛玻璃效果图片2', controller.testImageUrls[1]),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        GlassImageWidget(
          imageUrl: controller.testImageUrls[2],
          width: double.infinity,
          height: 160.h,
          fit: BoxFit.cover,
          onTap: () => controller.showImageInfo('全宽毛玻璃效果图片', controller.testImageUrls[2]),
        ),
      ],
    );
  }

  /// 构建占位图演示
  Widget _buildPlaceholderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '占位图类型图片：',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Wrap(
          spacing: AppDesignTokens.spacing12,
          runSpacing: AppDesignTokens.spacingV12,
          children: [
            PlaceholderImageWidget(
              imageUrl: controller.testImageUrls[0],
              width: 90.w,
              height: 90.w,
              onTap: () => controller.showImageInfo('占位图图片1', controller.testImageUrls[0]),
            ),
            PlaceholderImageWidget(
              imageUrl: controller.testImageUrls[1],
              width: 90.w,
              height: 90.w,
              onTap: () => controller.showImageInfo('占位图图片2', controller.testImageUrls[1]),
            ),
            PlaceholderImageWidget(
              imageUrl: controller.testImageUrls[2],
              width: 90.w,
              height: 90.w,
              onTap: () => controller.showImageInfo('占位图图片3', controller.testImageUrls[2]),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        PlaceholderImageWidget(
          imageUrl: controller.testImageUrls[3],
          width: double.infinity,
          height: 120.h,
          fit: BoxFit.cover,
          onTap: () => controller.showImageInfo('全宽占位图图片', controller.testImageUrls[3]),
        ),
      ],
    );
  }

  /// 构建自定义演示
  Widget _buildCustomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义占位图：',
          style: TextStyle(
            fontSize: AppDesignTokens.fontSize14,
            color: AppDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Wrap(
          spacing: AppDesignTokens.spacing12,
          runSpacing: AppDesignTokens.spacingV12,
          children: [
            CachedImageWidget(
              imageUrl: controller.testImageUrls[0],
              width: 90.w,
              height: 90.w,
              imageType: ImageType.custom,
              placeholder: CustomPlaceholderWidget(
                icon: Icons.image,
                title: '加载中',
                    backgroundColor: AppDesignTokens.infoColor.withOpacity(0.1),
                iconColor: AppDesignTokens.infoColor,
              ),
              onTap: () => controller.showImageInfo('自定义占位图', controller.testImageUrls[0]),
            ),
            CachedImageWidget(
              imageUrl: controller.testImageUrls[1],
              width: 90.w,
              height: 90.w,
              imageType: ImageType.custom,
              placeholder: CustomPlaceholderWidget(
                icon: Icons.photo_camera,
                title: '拍照中',
                    backgroundColor: AppDesignTokens.successColor.withOpacity(0.1),
                iconColor: AppDesignTokens.successColor,
              ),
              onTap: () => controller.showImageInfo('拍照占位图', controller.testImageUrls[1]),
            ),
            CachedImageWidget(
              imageUrl: controller.errorImageUrl,
              width: 90.w,
              height: 90.w,
              imageType: ImageType.custom,
              errorWidget: CustomErrorWidget(
                icon: Icons.error_outline,
                message: '加载失败',
                    backgroundColor: AppDesignTokens.errorColor.withOpacity(0.1),
                iconColor: AppDesignTokens.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建测试按钮
  Widget _buildTestButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: '测试图片加载',
                onPressed: controller.testImageLoading,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.infoColor,
                size: AppButtonSize.small,
              ),
            ),
            SizedBox(width: AppDesignTokens.spacing12),
            Expanded(
              child: AppButton(
                text: '测试错误处理',
                onPressed: controller.testImageError,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.errorColor,
                size: AppButtonSize.small,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: '清除图片缓存',
                onPressed: controller.clearImageCache,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.warningColor,
                size: AppButtonSize.small,
              ),
            ),
            SizedBox(width: AppDesignTokens.spacing12),
            Expanded(
              child: AppButton(
                text: '刷新图片',
                onPressed: controller.refreshImages,
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.successColor,
                size: AppButtonSize.small,
              ),
            ),
          ],
        ),
      ],
    );
  }  /// 构建区域卡片
  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return AppCard(
      size: AppCardSize.large,
      showShadow: true,
      showBorder: true,
      borderColor: color.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),
              SizedBox(width: AppDesignTokens.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize17,
                    fontWeight: AppDesignTokens.fontWeightBold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingV18),
          ...children,
        ],
      ),
    );
  }
}
