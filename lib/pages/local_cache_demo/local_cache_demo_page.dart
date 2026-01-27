import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import 'package:get/get.dart';
import 'local_cache_demo_controller.dart';

/// 本地缓存工具类演示页面
class LocalCacheDemoPage extends BaseScrollPage<LocalCacheDemoController> {
  const LocalCacheDemoPage({super.key});

  @override
  String? get pageTitle => '本地缓存工具演示';

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        pageTitle!,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      ),
      backgroundColor: AppDesignTokens.successColor,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 存储信息卡片
        _buildStorageInfoCard(),
        
        SizedBox(height: AppDesignTokens.spacingV16),
        
        // 基本数据类型操作
        _buildSectionCard(
          '基本数据类型操作',
          AppDesignTokens.infoColor,
          [
            _buildBasicDataSection(),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV16),
        
        // 复杂数据类型操作
        _buildSectionCard(
          '复杂数据类型操作',
          AppDesignTokens.secondaryColor,
          [
            _buildComplexDataSection(),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV16),
        
        // 批量操作
        _buildSectionCard(
          '批量操作',
          AppDesignTokens.warningColor,
          [
            _buildBatchOperationSection(),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV16),
        
        // 高级功能
        _buildSectionCard(
          '高级功能',
          AppDesignTokens.primaryColor,
          [
            _buildAdvancedFeatureSection(),
          ],
        ),
        
        SizedBox(height: AppDesignTokens.spacingV16),
        
        // 工具方法
        _buildSectionCard(
          '工具方法',
          AppDesignTokens.errorColor,
          [
            _buildUtilitySection(),
          ],
        ),
      ],
    );
  }

  /// 构建存储信息卡片
  Widget _buildStorageInfoCard() {
    return Obx(() => AppCard(
          size: AppCardSize.large,
          backgroundColor: AppDesignTokens.successColor.withOpacity(0.1),
          showBorder: true,
          borderColor: AppDesignTokens.successColor.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.storage,
                    color: AppDesignTokens.successColor,
                    size: AppDesignTokens.iconSizeMedium,
                  ),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text(
                    '存储信息',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize18,
                      fontWeight: AppDesignTokens.fontWeightBold,
                      color: AppDesignTokens.successDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDesignTokens.spacingV12),
              _buildInfoRow('总键数', '${controller.storageInfo['totalKeys'] ?? 0}'),
              _buildInfoRow('存储大小', '${controller.storageInfo['storageSize'] ?? 0} 字节'),
              if (controller.storageInfo['typeCount'] != null) ...[
                SizedBox(height: AppDesignTokens.spacingV8),
                Text(
                  '数据类型分布：',
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.successDark,
                  ),
                ),
                SizedBox(height: AppDesignTokens.spacingV4),
                ...(controller.storageInfo['typeCount'] as Map<String, int>).entries.map(
                  (entry) => _buildInfoRow(entry.key, '${entry.value}'),
                ),
              ],
            ],
          ),
        ));
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              color: AppDesignTokens.successColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSize14,
              fontWeight: AppDesignTokens.fontWeightSemiBold,
              color: AppDesignTokens.successDark,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建基本数据类型操作
  Widget _buildBasicDataSection() {
    return Column(
      children: [
        _buildOperationRow(
          '字符串',
          'Hello World',
          controller.testStringOperation,
        ),
        _buildOperationRow(
          '整数',
          '12345',
          controller.testIntOperation,
        ),
        _buildOperationRow(
          '浮点数',
          '3.14159',
          controller.testDoubleOperation,
        ),
        _buildOperationRow(
          '布尔值',
          'true',
          controller.testBoolOperation,
        ),
        _buildOperationRow(
          '字符串列表',
          '["A", "B", "C"]',
          controller.testStringListOperation,
        ),
      ],
    );
  }

  /// 构建复杂数据类型操作
  Widget _buildComplexDataSection() {
    return Column(
      children: [
        _buildOperationRow(
          'Map对象',
          '{"name": "张三", "age": 25}',
          controller.testMapOperation,
        ),
        _buildOperationRow(
          'List对象',
          '[1, 2, 3, 4, 5]',
          controller.testListOperation,
        ),
        _buildOperationRow(
          'DateTime',
          '2024-01-01 12:00:00',
          controller.testDateTimeOperation,
        ),
        _buildOperationRow(
          'Duration',
          '1小时30分钟',
          controller.testDurationOperation,
        ),
      ],
    );
  }

  /// 构建批量操作
  Widget _buildBatchOperationSection() {
    return Column(
      children: [
        AppButton(
          text: '批量存储数据',
          onPressed: controller.testBatchSet,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.infoColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '批量读取数据',
          onPressed: controller.testBatchGet,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.successColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '批量删除数据',
          onPressed: controller.testBatchRemove,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.errorColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
      ],
    );
  }

  /// 构建高级功能
  Widget _buildAdvancedFeatureSection() {
    return Column(
      children: [
        AppButton(
          text: '存储带过期时间的数据',
          onPressed: controller.testExpiryData,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.secondaryColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '读取带过期时间的数据',
          onPressed: controller.testGetExpiryData,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.warningColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '清理过期数据',
          onPressed: controller.testCleanExpiredData,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.primaryColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '数据迁移',
          onPressed: controller.testDataMigration,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.infoColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
      ],
    );
  }

  /// 构建工具方法
  Widget _buildUtilitySection() {
    return Column(
      children: [
        AppButton(
          text: '检查键是否存在',
          onPressed: controller.testContainsKey,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.infoColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '获取所有键',
          onPressed: controller.testGetAllKeys,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.secondaryColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '清空所有数据',
          onPressed: controller.testClearAll,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.errorColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV12),
        AppButton(
          text: '刷新存储信息',
          onPressed: controller.loadStorageInfo,
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.successColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
      ],
    );
  }

  /// 构建操作行
  Widget _buildOperationRow(String type, String example, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingV8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize14,
                    fontWeight: AppDesignTokens.fontWeightSemiBold,
                    color: AppDesignTokens.textPrimary,
                  ),
                ),
                Text(
                  example,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSize12,
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: AppButton(
              text: '测试',
              onPressed: onPressed,
              type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.infoColor,
              size: AppButtonSize.small,
            ),
          ),
        ],
      ),
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
