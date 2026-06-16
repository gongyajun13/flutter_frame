import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_frame/utils/toast_util.dart';
import 'package:flutter_frame/widgets/pixelize/bc_gradient_text_button.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:flutter_frame/overlay/overlay.dart';
import 'package:get/get.dart';

/// 显示保存项目标题输入弹窗，返回用户输入的标题或 null（取消）
Future<String?> showSaveTitleDialog({String currentTitle = ''}) async {
  final textController = TextEditingController(text: currentTitle);
  return AppOverlay.dialog.customAsync<String>(
    child: Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
            color: AppColors.appCardBgColor,
          ),
          margin: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '确认保存',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: kPFFont,
                  color: AppColors.textColorPrimary,
                ),
              ),
              SizedBox(height: 10.w),
              Text(
                '请设置作品名称后保存',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: kPFFont,
                  color: AppColors.textColorSecond,
                ),
              ),
              SizedBox(height: 16.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cF5F5F5,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  controller: textController,
                  maxLength: 20,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: '请输入作品标题',
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      fontFamily: kPFFont,
                    ),
                    border:  InputBorder.none,
                  ),
                  onSubmitted: (value) => Get.back(result: value.trim()),
                ),
              ),
              SizedBox(height: 36.w),
              Row(
                spacing: 15.w,
                children: [
                  Expanded(
                    child: BCGradientTextButton(
                      isDisable: true,
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.symmetric(vertical: 11.w),
                      child: const Text('取消'),
                    ),
                  ),
                  Expanded(
                    child: BCGradientTextButton(
                      onPressed: () {
                        if (textController.text.trim().isEmpty) {
                          showToast('请输入作品标题');
                          return;
                        }
                        Get.back(result: textController.text.trim());
                      },

                      padding: EdgeInsets.symmetric(vertical: 12.w),
                      child: const Text('确认保存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
