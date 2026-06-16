import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_frame/widgets/pixelize/bc_gradient_text_button.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:get/get.dart';

import 'package:flutter_frame/constants/app_values.dart';

class BCOkCancelContent extends StatelessWidget {
  const BCOkCancelContent(
      {super.key,
      required this.title,
      this.titleStyle,
      this.content,
      this.contentStyle,
      this.okText = '确认',
      this.cancelText = '取消',
      this.padding,
      this.margin,
      this.decoration});

  final String title;
  final TextStyle? titleStyle;
  final String? content;
  final TextStyle? contentStyle;
  final String okText;
  final String cancelText;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: double.infinity,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.w),
          decoration: decoration ??
              BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.r)),
                color: AppColors.appCardBgColor,
              ),
          margin: margin ?? EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: kPFFont,
                            color: AppColors.textColorPrimary)
                        .merge(titleStyle),
                  ),
                  if (content != null)
                    Padding(
                      padding: EdgeInsets.only(top: 10.w),
                      child: Text(
                        content!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.c16)
                            .merge(contentStyle),
                      ),
                    ),
                ],
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
                        child: Text(
                          cancelText,
                        )),
                  ),
                  Expanded(
                    child: BCGradientTextButton(
                        onPressed: () {
                          Get.back(result: true);
                        },
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        child: Text(
                          okText,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
