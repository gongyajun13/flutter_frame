import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_frame/widgets/pixelize/bc_gradient_container.dart';
import 'package:flutter_frame/constants/app_colors.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:get/get.dart';

class BCCustomBottomSheet extends StatelessWidget {
  final String title;
  final String? subTitle;
  final List<String> items;
  const BCCustomBottomSheet(
      {super.key, required this.title, required this.items, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BCGradientContainer(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 26.w),

            /// 标题
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: kPFFont,
                color: AppColors.textColorPrimary,
              ),
            ),
            if (subTitle?.isNotEmpty == true) ...[
              SizedBox(height: 20.w),
              Text(
                subTitle ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: kPFFont,
                  color: AppColors.textColorSecond,
                ),
              )
            ],

            SizedBox(height: 20.w),

            /// item 列表
            ...List.generate(items.length, (index) {
              final value = items[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.back(result: (index, value));
                },
                child: Container(
                  height: 54.w,
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: kPFFont,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                ),
              );
            }),

            /// 底部安全区
            (Platform.isAndroid && MediaQuery.paddingOf(context).bottom == 0)
                ? SizedBox(height: 20.w)
                : SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + 10.w,
                  ),
          ],
        )),

        /// 关闭按钮
        Positioned(
          right: 12.w,
          top: 12.w,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Image.asset(
              'assets/icons/icon_sheet_close.png',
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
      ],
    );
  }
}
