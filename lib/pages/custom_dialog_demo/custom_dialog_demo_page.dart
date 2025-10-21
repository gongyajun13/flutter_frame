import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/getx_dialog_util.dart';

class CustomDialogDemoPage extends StatelessWidget {
  const CustomDialogDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '自定义对话框演示',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              title: '基础自定义对话框',
              children: [
                _buildDemoButton(
                  '简单自定义对话框',
                  () => _showSimpleCustomDialog(),
                ),
                _buildDemoButton(
                  '带标题的自定义对话框',
                  () => _showCustomWithTitleDialog(),
                ),
                _buildDemoButton(
                  '带按钮的自定义对话框',
                  () => _showCustomWithButtonsDialog(),
                ),
                _buildDemoButton(
                  '全屏自定义对话框',
                  () => _showFullScreenDialog(),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            _buildSectionCard(
              title: '高级自定义对话框',
              children: [
                _buildDemoButton(
                  '带图标的对话框',
                  () => _showIconDialog(),
                ),
                _buildDemoButton(
                  '表单对话框',
                  () => _showFormDialog(),
                ),
                _buildDemoButton(
                  '列表选择对话框',
                  () => _showListDialog(),
                ),
                _buildDemoButton(
                  '图片预览对话框',
                  () => _showImagePreviewDialog(),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            _buildSectionCard(
              title: '特殊效果对话框',
              children: [
                _buildDemoButton(
                  '渐变背景对话框',
                  () => _showGradientDialog(),
                ),
                _buildDemoButton(
                  '毛玻璃效果对话框',
                  () => _showBlurDialog(),
                ),
                _buildDemoButton(
                  '动画效果对话框',
                  () => _showAnimatedDialog(),
                ),
                _buildDemoButton(
                  '自定义关闭按钮',
                  () => _showCustomCloseDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDemoButton(String text, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 简单自定义对话框
  void _showSimpleCustomDialog() {
    GetXDialogUtil.showCustom(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 48.w,
            color: Colors.blue,
          ),
          SizedBox(height: 16.h),
          Text(
            '这是一个简单的自定义对话框',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            '你可以在这里放置任何内容',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 带标题的自定义对话框
  void _showCustomWithTitleDialog() {
    GetXDialogUtil.showCustomWithTitle(
      title: '系统提示',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            size: 48.w,
            color: Colors.orange,
          ),
          SizedBox(height: 16.h),
          Text(
            '这是一个带标题的对话框',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            '标题会显示在对话框顶部',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 带按钮的自定义对话框
  void _showCustomWithButtonsDialog() {
    GetXDialogUtil.showCustomWithButtons(
      title: '确认操作',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.help_outline,
            size: 48.w,
            color: Colors.blue,
          ),
          SizedBox(height: 16.h),
          Text(
            '确定要执行此操作吗？',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            '此操作不可撤销',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      buttons: [
        GetXDialogUtil.buildCancelButton(
          text: '取消',
          onPressed: () => print('取消操作'),
        ),
        GetXDialogUtil.buildConfirmButton(
          text: '确定',
          onPressed: () => print('确认操作'),
        ),
      ],
    );
  }

  // 全屏自定义对话框
  void _showFullScreenDialog() {
    GetXDialogUtil.showCustomFullScreen(
      title: '全屏对话框',
      child: Container(
        color: Colors.blue.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fullscreen,
              size: 64.w,
              color: Colors.blue,
            ),
            SizedBox(height: 24.h),
            Text(
              '全屏对话框',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '这是一个全屏的自定义对话框',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }

  // 带图标的对话框
  void _showIconDialog() {
    GetXDialogUtil.showCustomWithTitle(
      title: '成功',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.check_circle,
              size: 48.w,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            '操作成功完成！',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '您的操作已经成功执行',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 表单对话框
  void _showFormDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    
    GetXDialogUtil.showCustomWithButtons(
      title: '用户信息',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: '姓名',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: '邮箱',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
      buttons: [
        GetXDialogUtil.buildCancelButton(
          text: '取消',
          onPressed: () => print('取消表单'),
        ),
        GetXDialogUtil.buildConfirmButton(
          text: '保存',
          onPressed: () {
            print('保存用户信息: ${nameController.text}, ${emailController.text}');
          },
        ),
      ],
    );
  }

  // 列表选择对话框
  void _showListDialog() {
    final List<String> options = [
      '选项 1',
      '选项 2',
      '选项 3',
      '选项 4',
      '选项 5',
    ];
    
    GetXDialogUtil.showCustomWithTitle(
      title: '选择选项',
      child: Container(
        height: 200.h,
        child: ListView.builder(
          itemCount: options.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(options[index]),
              leading: Icon(Icons.radio_button_unchecked),
              onTap: () {
                print('选择了: ${options[index]}');
                Get.back();
              },
            );
          },
        ),
      ),
    );
  }

  // 图片预览对话框
  void _showImagePreviewDialog() {
    GetXDialogUtil.showCustom(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              'https://picsum.photos/400/400?random=10',
              width: 200.w,
              height: 200.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200.w,
                  height: 200.w,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.broken_image,
                    size: 48.w,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '图片预览',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 渐变背景对话框
  void _showGradientDialog() {
    GetXDialogUtil.showCustom(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.gradient,
              size: 48.w,
              color: Colors.white,
            ),
            SizedBox(height: 16.h),
            Text(
              '渐变背景对话框',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '这是一个带有渐变背景的对话框',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // 毛玻璃效果对话框
  void _showBlurDialog() {
    GetXDialogUtil.showCustom(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.blur_on,
              size: 48.w,
              color: Colors.white,
            ),
            SizedBox(height: 16.h),
            Text(
              '毛玻璃效果',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '这是一个带有毛玻璃效果的对话框',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // 动画效果对话框
  void _showAnimatedDialog() {
    GetXDialogUtil.showCustom(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.animation,
                  size: 48.w,
                  color: Colors.purple,
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          Text(
            '动画效果对话框',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '这个对话框有动画效果',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      transitionDuration: Duration(milliseconds: 500),
      transitionCurve: Curves.elasticOut,
    );
  }

  // 自定义关闭按钮
  void _showCustomCloseDialog() {
    GetXDialogUtil.showCustom(
      title: '自定义关闭',
      showCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings,
            size: 48.w,
            color: Colors.orange,
          ),
          SizedBox(height: 16.h),
          Text(
            '自定义关闭按钮',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '这个对话框没有默认的关闭按钮',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GetXDialogUtil.buildSecondaryButton(
                text: '稍后再说',
                onPressed: () => print('稍后再说'),
                icon: Icons.schedule,
              ),
              GetXDialogUtil.buildPrimaryButton(
                text: '立即设置',
                onPressed: () => print('立即设置'),
                icon: Icons.settings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
