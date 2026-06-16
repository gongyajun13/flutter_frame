import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_frame/constants/app_values.dart';
import 'package:get/get.dart';

import 'package:flutter_frame/widgets/pixelize/bc_gradient_container.dart';
import 'package:flutter_frame/widgets/pixelize/bc_gradient_text_button.dart';
import 'package:flutter_frame/constants/app_colors.dart';

class SwitchItemData {
  final String title;
  bool value;
  SwitchItemData({required this.title, this.value = true});
}

class CreateShareSettingDialog extends StatefulWidget {
  final List<SwitchItemData> items;

  const CreateShareSettingDialog({
    super.key,
    required this.items,
  });

  @override
  State<StatefulWidget> createState() => _CreateShareSettingDialogState();
}

class _CreateShareSettingDialogState extends State<CreateShareSettingDialog> {
  late List<SwitchItemData> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: BCGradientContainer(
          padding: EdgeInsets.fromLTRB(20.w, 26.w, 20.w, 20.w),
          margin: EdgeInsets.symmetric(horizontal: 30.w),
          radius: BorderRadius.circular(12.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 标题
              Text(
                '导出选项',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: kPFFont,
                  color: AppColors.textColorPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              /// 副标题
              Text(
                '选择导出设置',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textColorSecond,
                ),
              ),

              SizedBox(height: 36.h),

              /// 5个开关item
              ...List.generate(_items.length, (index) {
                return _buildItem(index);
              }),

              SizedBox(height: 36.h),
              Row(
                spacing: 15.w,
                children: [
                  Expanded(
                    child: BCGradientTextButton(
                        isDisable: true,
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.symmetric(vertical: 11.w),
                        child: Text(
                          '取消',
                        )),
                  ),
                  Expanded(
                    child: BCGradientTextButton(
                        onPressed: () {
                          final result = _items.map((e) => e.value).toList();
                          Get.back(result: result);
                        },
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        child: Text(
                          '导出',
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

  Widget _buildItem(int index) {
    final item = _items[index];

    return Container(
      height: 44.w,
      alignment: Alignment.center,
      child: Row(
        children: [
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColorPrimary,
              ),
            ),
          ),

          /// iOS 风格 Switch
          Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: item.value,
              onChanged: (val) {
                setState(() {
                  item.value = val;
                });
              },
              activeTrackColor: const Color(0xFFFFD756),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFF2F2F2),
            ),
          ),
        ],
      ),
    );
  }
}
