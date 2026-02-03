import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'simple_network_demo_controller.dart';

/// 简化网络请求演示页面
class SimpleNetworkDemoPage extends BaseScrollPage<SimpleNetworkDemoController> {
  const SimpleNetworkDemoPage({super.key});

  @override
  String? get pageTitle => '简洁网络请求演示';

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
  EdgeInsets get pagePadding => EdgeInsets.all(AppDesignTokens.spacing16);

  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 结果显示区域（固定高度）
        SizedBox(
          height: 200.h,
          child: _buildResultSection(),
        ),

        SizedBox(height: AppDesignTokens.spacingV16),

        // 用户信息显示区域
        Obx(() => controller.currentUser.value != null
            ? _buildUserInfoSection()
            : const SizedBox.shrink()),
        
        Obx(() => controller.currentUser.value != null
            ? SizedBox(height: AppDesignTokens.spacingV16)
            : const SizedBox.shrink()),

        // 产品列表显示区域
        Obx(() => controller.products.isNotEmpty
            ? _buildProductsSection()
            : const SizedBox.shrink()),
        
        Obx(() => controller.products.isNotEmpty
            ? SizedBox(height: AppDesignTokens.spacingV16)
            : const SizedBox.shrink()),

        // 按钮区域
        _buildActionButtons(),
      ],
    );
  }

  /// 构建结果显示区域
  Widget _buildResultSection() {
    return AppCard(
      backgroundColor: AppDesignTokens.grey50,
      showBorder: true,
      borderColor: AppDesignTokens.grey300,
      child: Obx(() => SingleChildScrollView(
            child: Text(
              controller.result.value,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                height: AppDesignTokens.lineHeightNormal,
                color: AppDesignTokens.textSecondary,
              ),
            ),
          )),
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfoSection() {
    final user = controller.currentUser.value!;
    
    return AppCard(
      backgroundColor: AppDesignTokens.infoColor.withOpacity(0.1),
      showBorder: true,
      borderColor: AppDesignTokens.infoColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前用户: ${user.username}',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.infoDark,
            ),
          ),
          if (user.name != null) ...[
            SizedBox(height: AppDesignTokens.spacingV8),
            Text(
              '姓名: ${user.name}',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.infoColor,
              ),
            ),
          ],
          SizedBox(height: AppDesignTokens.spacingV4),
          Text(
            '邮箱: ${user.email}',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.infoColor,
            ),
          ),
          if (user.phone != null) ...[
            SizedBox(height: AppDesignTokens.spacingV4),
            Text(
              '电话: ${user.phone}',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.infoColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建产品列表区域
  Widget _buildProductsSection() {
    return AppCard(
      backgroundColor: AppDesignTokens.successColor.withOpacity(0.1),
      showBorder: true,
      borderColor: AppDesignTokens.successColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '产品列表 (${controller.products.length}个)',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize16,
              fontWeight: AppDesignTokens.fontWeightBold,
              color: AppDesignTokens.successDark,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingV8),
              ...controller.products.take(3).map((product) => Padding(
                padding: EdgeInsets.symmetric(vertical: AppDesignTokens.spacingV4),
                child: Text(
                  '• ${product.name} - ¥${product.price}',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    color: AppDesignTokens.successColor,
                  ),
                ),
              )),
          if (controller.products.length > 3) ...[
            SizedBox(height: AppDesignTokens.spacingV4),
            Text(
              '... 还有${controller.products.length - 3}个产品',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize12,
                color: AppDesignTokens.successLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppButton.primary(
            text: '用户登录',
            onPressed: controller.testLogin,
            icon: Icons.login,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '获取用户信息',
            onPressed: controller.getUserProfile,
            icon: Icons.person,
            type: AppButtonType.primary,
            isFullWidth: true,
            backgroundColor: AppDesignTokens.successColor,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '获取产品列表',
            onPressed: controller.getProducts,
            icon: Icons.list,
            type: AppButtonType.primary,
            isFullWidth: true,
            backgroundColor: AppDesignTokens.warningColor,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '创建产品',
            onPressed: controller.createProduct,
            icon: Icons.add_circle,
            type: AppButtonType.primary,
            isFullWidth: true,
            backgroundColor: AppDesignTokens.secondaryColor,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton.secondary(
            text: '静默请求（无loading/错误提示）',
            onPressed: controller.silentRequest,
            icon: Icons.visibility_off,
            isFullWidth: true,
          ),
          SizedBox(height: AppDesignTokens.spacingV12),
          AppButton(
            text: '上传文件',
            onPressed: controller.uploadFileDemo,
            icon: Icons.upload_file,
            type: AppButtonType.primary,
            isFullWidth: true,
            backgroundColor: AppDesignTokens.infoColor,
          ),
        ],
      ),
    );
  }
}
