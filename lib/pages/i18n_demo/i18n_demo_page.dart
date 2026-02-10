import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../base/base_page.dart';
import '../../theme/app_design_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../l10n/s.dart';
import 'i18n_demo_controller.dart';

/// 国际化演示页面
class I18nDemoPage extends BaseScrollPage<I18nDemoController> {
  const I18nDemoPage({super.key});

  @override
  String? get pageTitle => null;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(() => Text(
        S.language,
        style: TextStyle(fontSize: AppDesignTokens.fontSize18),
      )),
      backgroundColor: AppDesignTokens.primaryColor,
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
        _buildLanguageSelectorCard(),
        SizedBox(height: AppDesignTokens.spacingV16),
        _buildSectionCard(
          S.settings,
          AppDesignTokens.primaryColor,
          [_buildBasicTranslations()],
        ),
        SizedBox(height: AppDesignTokens.spacingV16),
        _buildSectionCard(
          '按钮翻译',
          AppDesignTokens.infoColor,
          [_buildButtonTranslations()],
        ),
        SizedBox(height: AppDesignTokens.spacingV16),
        _buildSectionCard(
          '状态提示',
          AppDesignTokens.warningColor,
          [_buildStatusTranslations()],
        ),
        SizedBox(height: AppDesignTokens.spacingV16),
        _buildSectionCard(
          '带参数的翻译',
          AppDesignTokens.successColor,
          [_buildParameterizedTranslations()],
        ),
        SizedBox(height: AppDesignTokens.spacingV16),
        _buildCurrentLanguageInfo(),
      ],
    ));
  }

  /// 构建语言选择器卡片
  Widget _buildLanguageSelectorCard() {
    return Obx(() => AppCard(
          size: AppCardSize.large,
          backgroundColor: AppDesignTokens.primaryColor.withOpacity(0.1),
          showBorder: true,
          borderColor: AppDesignTokens.primaryColor.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.language,
                    color: AppDesignTokens.primaryColor,
                    size: AppDesignTokens.iconSizeMedium,
                  ),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text(
                    S.language,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize18,
                      fontWeight: AppDesignTokens.fontWeightBold,
                      color: AppDesignTokens.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDesignTokens.spacingV16),
              Text(
                '当前语言: ${controller.currentLanguageName}',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize14,
                  color: AppDesignTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingV12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: S.chinese,
                      onPressed: controller.switchToChinese,
                      type: controller.isChinese
                          ? AppButtonType.primary
                          : AppButtonType.secondary,
                      backgroundColor: controller.isChinese
                          ? AppDesignTokens.primaryColor
                          : AppDesignTokens.textSecondary,
                      isFullWidth: true,
                    ),
                  ),
                  SizedBox(width: AppDesignTokens.spacing12),
                  Expanded(
                    child: AppButton(
                      text: S.english,
                      onPressed: controller.switchToEnglish,
                      type: controller.isEnglish
                          ? AppButtonType.primary
                          : AppButtonType.secondary,
                      backgroundColor: controller.isEnglish
                          ? AppDesignTokens.primaryColor
                          : AppDesignTokens.textSecondary,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  /// 构建基本翻译示例
  Widget _buildBasicTranslations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTranslationRow('appTitle', S.appTitle),
        _buildTranslationRow('welcome', S.welcome),
        _buildTranslationRow('language', S.language),
        _buildTranslationRow('theme', S.theme),
        _buildTranslationRow('settings', S.settings),
      ],
    );
  }

  /// 构建按钮翻译示例
  Widget _buildButtonTranslations() {
    return Column(
      children: [
        AppButton(
          text: S.confirm,
          onPressed: () {},
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.successColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV8),
        AppButton(
          text: S.cancel,
          onPressed: () {},
          type: AppButtonType.secondary,
          backgroundColor: AppDesignTokens.textSecondary,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV8),
        AppButton(
          text: S.ok,
          onPressed: () {},
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.infoColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV8),
        AppButton(
          text: S.save,
          onPressed: () {},
          type: AppButtonType.primary,
          backgroundColor: AppDesignTokens.warningColor,
          isFullWidth: true,
          size: AppButtonSize.small,
        ),
        SizedBox(height: AppDesignTokens.spacingV8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: S.edit,
                onPressed: () {},
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.secondaryColor,
                size: AppButtonSize.small,
              ),
            ),
            SizedBox(width: AppDesignTokens.spacing8),
            Expanded(
              child: AppButton(
                text: S.delete,
                onPressed: () {},
                type: AppButtonType.primary,
                backgroundColor: AppDesignTokens.errorColor,
                size: AppButtonSize.small,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建状态翻译示例
  Widget _buildStatusTranslations() {
    return Column(
      children: [
        _buildStatusItem(Icons.hourglass_empty, S.loading, AppDesignTokens.infoColor),
        _buildStatusItem(Icons.inbox, S.noData, AppDesignTokens.textSecondary),
        _buildStatusItem(Icons.wifi_off, S.networkError, AppDesignTokens.errorColor),
        _buildStatusItem(Icons.check_circle, S.operationSuccess, AppDesignTokens.successColor),
        _buildStatusItem(Icons.error, S.operationFailed, AppDesignTokens.errorColor),
        _buildStatusItem(Icons.refresh, S.pleaseRetry, AppDesignTokens.warningColor),
      ],
    );
  }

  /// 构建状态项
  Widget _buildStatusItem(IconData icon, String text, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingV8),
      padding: EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.w),
          SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                color: AppDesignTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建带参数的翻译示例
  Widget _buildParameterizedTranslations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppDesignTokens.spacing12),
          decoration: BoxDecoration(
            color: AppDesignTokens.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppDesignTokens.successColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '示例：',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize12,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingV8),
              Text(
                S.hello('张三'),
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize14,
                  color: AppDesignTokens.textPrimary,
                ),
              ),
              SizedBox(height: AppDesignTokens.spacingV4),
              Text(
                S.hello('John'),
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSize14,
                  color: AppDesignTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建当前语言信息
  Widget _buildCurrentLanguageInfo() {
    return Obx(() => AppCard(
          size: AppCardSize.medium,
          backgroundColor: AppDesignTokens.infoColor.withOpacity(0.1),
          showBorder: true,
          borderColor: AppDesignTokens.infoColor.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppDesignTokens.infoColor,
                    size: AppDesignTokens.iconSizeMedium,
                  ),
                  SizedBox(width: AppDesignTokens.spacing8),
                  Text(
                    '当前语言信息',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSize16,
                      fontWeight: AppDesignTokens.fontWeightBold,
                      color: AppDesignTokens.infoColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDesignTokens.spacingV12),
              _buildInfoRow('语言代码', controller.currentLocale.languageCode),
              if (controller.currentLocale.countryCode != null)
                _buildInfoRow('国家代码', controller.currentLocale.countryCode!),
              _buildInfoRow('显示名称', controller.currentLanguageName),
              _buildInfoRow('是否为中文', controller.isChinese ? '是' : '否'),
              _buildInfoRow('是否为英文', controller.isEnglish ? '是' : '否'),
            ],
          ),
        ));
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
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
              fontWeight: AppDesignTokens.fontWeightSemiBold,
              color: AppDesignTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建翻译行
  Widget _buildTranslationRow(String key, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingV8),
      padding: EdgeInsets.all(AppDesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surfaceColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize12,
                color: AppDesignTokens.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(width: AppDesignTokens.spacing12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSize14,
                fontWeight: AppDesignTokens.fontWeightSemiBold,
                color: AppDesignTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建区域卡片
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
