import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../app/routes/app_pages.dart';
import '../utils/getx_utils.dart';

/// GetX工具类演示页面
class GetXUtilsDemoPage extends StatefulWidget {
  const GetXUtilsDemoPage({Key? key}) : super(key: key);

  @override
  State<GetXUtilsDemoPage> createState() => _GetXUtilsDemoPageState();
}

class _GetXUtilsDemoPageState extends State<GetXUtilsDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GetX工具类演示',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SnackBar演示区域
            _buildSectionCard(
              'SnackBar演示',
              Colors.blue,
              [
                _buildButton(
                  '成功提示',
                  Colors.green,
                  () => GetXSnackBarUtil.success(
                    message: '操作成功完成！',
                    title: '成功',
                  ),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '错误提示',
                  Colors.red,
                  () => GetXSnackBarUtil.error(
                    message: '操作失败，请重试！',
                    title: '错误',
                  ),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '警告提示',
                  Colors.orange,
                  () => GetXSnackBarUtil.warning(
                    message: '请注意相关风险！',
                    title: '警告',
                  ),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '信息提示',
                  Colors.blue,
                  () => GetXSnackBarUtil.info(
                    message: '这是一条信息提示！',
                    title: '提示',
                  ),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '自定义SnackBar',
                  Colors.purple,
                  () => GetXSnackBarUtil.custom(
                    message: '自定义样式的提示！',
                    title: '自定义',
                    backgroundColor: Colors.purple.shade600,
                    icon: Icons.star,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '多条消息队列',
                  Colors.teal,
                  () => _showMultipleSnackBars(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '清除所有SnackBar',
                  Colors.grey,
                  () => GetXSnackBarUtil.clearAll(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '测试SnackBar覆盖',
                  Colors.red,
                  () => _testSnackBarOverride(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '测试立即显示SnackBar',
                  Colors.purple,
                  () => _testImmediateSnackBar(),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Dialog演示区域
            _buildSectionCard(
              'Dialog演示',
              Colors.green,
              [
                _buildButton(
                  'Loading对话框',
                  Colors.blue,
                  () => _showLoadingDialog(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '确认对话框',
                  Colors.orange,
                  () => _showConfirmDialog(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '警告对话框',
                  Colors.red,
                  () => _showAlertDialog(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '输入对话框',
                  Colors.purple,
                  () => _showInputDialog(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '选择对话框',
                  Colors.teal,
                  () => _showSelectDialog(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '底部弹窗',
                  Colors.indigo,
                  () => _showBottomSheet(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '自定义对话框',
                  Colors.pink,
                  () =>  Get.toNamed(Routes.CUSTOM_DIALOG_DEMO),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // 组合使用演示
            _buildSectionCard(
              '组合使用演示',
              Colors.amber,
              [
                _buildButton(
                  '网络请求模拟',
                  Colors.blue,
                  () => _simulateNetworkRequest(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '表单验证模拟',
                  Colors.green,
                  () => _simulateFormValidation(),
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  '批量操作模拟',
                  Colors.orange,
                  () => _simulateBatchOperation(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建区域卡片
  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 16.h),
            ...children,
          ],
        ),
      ),
    );
  }

  /// 构建按钮
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 显示多条SnackBar
  void _showMultipleSnackBars() {
    final configs = [
      SnackBarConfig(
        message: '第一条消息',
        type: SnackBarType.info,
        duration: const Duration(seconds: 2),
      ),
      SnackBarConfig(
        message: '第二条消息',
        type: SnackBarType.success,
        duration: const Duration(seconds: 2),
      ),
      SnackBarConfig(
        message: '第三条消息',
        type: SnackBarType.warning,
        duration: const Duration(seconds: 2),
      ),
    ];
    GetXSnackBarUtil.showMultiple(configs);
  }

  /// 显示Loading对话框
  void _showLoadingDialog() {
    GetXDialogUtil.showLoading(
      message: '正在加载中...',
    );
    
    // 3秒后自动关闭
    Future.delayed(const Duration(seconds: 3), () {
      GetXDialogUtil.hideLoading();
      GetXSnackBarUtil.success(message: '加载完成！');
    });
  }

  /// 显示确认对话框
  void _showConfirmDialog() {
    GetXDialogUtil.showConfirm(
      title: '确认删除',
      message: '确定要删除这个项目吗？此操作不可撤销。',
      confirmText: '删除',
      cancelText: '取消',
      confirmColor: Colors.red.shade600,
      onConfirm: () {
        GetXSnackBarUtil.success(message: '删除成功！');
      },
      onCancel: () {
        GetXSnackBarUtil.info(message: '已取消删除');
      },
    );
  }

  /// 显示警告对话框
  void _showAlertDialog() {
    GetXDialogUtil.showAlert(
      title: '网络异常',
      message: '网络连接异常，请检查网络设置后重试。',
      buttonText: '我知道了',
      buttonColor: Colors.orange.shade600,
      onPressed: () {
        GetXSnackBarUtil.info(message: '已确认网络异常');
      },
    );
  }

  /// 显示输入对话框
  void _showInputDialog() {
    GetXDialogUtil.showInput(
      title: '输入用户名',
      hintText: '请输入用户名',
      confirmText: '确认',
      cancelText: '取消',
      onConfirm: (value) {
        if (value.isNotEmpty) {
          GetXSnackBarUtil.success(message: '用户名：$value');
        } else {
          GetXSnackBarUtil.warning(message: '用户名不能为空');
        }
      },
      onCancel: () {
        GetXSnackBarUtil.info(message: '已取消输入');
      },
    );
  }

  /// 显示选择对话框
  void _showSelectDialog() {
    final options = ['选项一', '选项二', '选项三', '选项四', '选项五'];
    GetXDialogUtil.showSelect(
      title: '请选择',
      options: options,
      onSelected: (index, option) {
        GetXSnackBarUtil.success(message: '选择了：$option');
      },
      onCancel: () {
        GetXSnackBarUtil.info(message: '已取消选择');
      },
    );
  }

  /// 显示底部弹窗
  void _showBottomSheet() {
    GetXDialogUtil.showBottomSheet(
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              '底部弹窗',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '这是一个底部弹窗示例，可以包含任何内容。',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  GetXSnackBarUtil.success(message: '底部弹窗操作完成');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  '确认',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  /// 显示自定义对话框
  void _showCustomDialog() {
    GetXDialogUtil.showCustom(
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 48.sp,
                color: Colors.amber.shade600,
              ),
              SizedBox(height: 16.h),
              Text(
                '自定义对话框',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '这是一个完全自定义的对话框，可以包含任何内容。',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        GetXSnackBarUtil.info(message: '自定义对话框已关闭');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        '关闭',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        GetXSnackBarUtil.success(message: '自定义对话框操作成功');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        '确认',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 模拟网络请求
  void _simulateNetworkRequest() {
    // 显示Loading
    GetXDialogUtil.showLoading(message: '正在请求数据...');
    
    // 模拟网络请求
    Future.delayed(const Duration(seconds: 2), () {
      GetXDialogUtil.hideLoading();
      
      // 模拟请求结果
      final success = DateTime.now().millisecond % 2 == 0;
      if (success) {
        GetXSnackBarUtil.success(message: '数据加载成功！');
      } else {
        GetXSnackBarUtil.error(message: '网络请求失败，请重试');
      }
    });
  }

  /// 模拟表单验证
  void _simulateFormValidation() {
    GetXDialogUtil.showInput(
      title: '表单验证',
      hintText: '请输入邮箱地址',
      keyboardType: TextInputType.emailAddress,
      onConfirm: (value) {
        if (value.isEmpty) {
          GetXSnackBarUtil.warning(message: '邮箱地址不能为空');
        } else if (!value.contains('@')) {
          GetXSnackBarUtil.error(message: '请输入有效的邮箱地址');
        } else {
          GetXSnackBarUtil.success(message: '邮箱地址验证通过');
        }
      },
    );
  }

  /// 模拟批量操作
  void _simulateBatchOperation() {
    GetXDialogUtil.showConfirm(
      title: '批量删除',
      message: '确定要删除选中的 5 个项目吗？',
      confirmText: '删除',
      cancelText: '取消',
      confirmColor: Colors.red.shade600,
      onConfirm: () {
        // 显示Loading
        GetXDialogUtil.showLoading(message: '正在删除...');
        
        // 模拟批量删除
        Future.delayed(const Duration(seconds: 2), () {
          GetXDialogUtil.hideLoading();
          GetXSnackBarUtil.success(message: '已成功删除 5 个项目');
        });
      },
      onCancel: () {
        GetXSnackBarUtil.info(message: '已取消批量删除');
      },
    );
  }

  /// 测试SnackBar覆盖功能
  void _testSnackBarOverride() {
    // 显示第一条消息
    GetXSnackBarUtil.info(message: '第一条消息 - 这条应该被覆盖');
    
    // 1秒后显示第二条消息，应该覆盖第一条
    Future.delayed(const Duration(seconds: 1), () {
      GetXSnackBarUtil.success(message: '第二条消息 - 这条应该覆盖第一条');
    });
    
    // 2秒后显示第三条消息，应该覆盖第二条
    Future.delayed(const Duration(seconds: 2), () {
      GetXSnackBarUtil.error(message: '第三条消息 - 这条应该覆盖第二条');
    });
    
    // 3秒后显示第四条消息，应该覆盖第三条
    Future.delayed(const Duration(seconds: 3), () {
      GetXSnackBarUtil.warning(message: '第四条消息 - 这条应该覆盖第三条');
    });
  }

  /// 测试立即显示SnackBar功能
  void _testImmediateSnackBar() {
    // 显示第一个SnackBar
    GetXSnackBarUtil.success(message: '第一个提示消息');
    
    // 使用立即显示方法，强制替换当前显示的
    Future.delayed(const Duration(milliseconds: 500), () {
      GetXSnackBarUtil.showImmediate(
        message: '立即显示的提示消息（强制替换）',
        title: '立即替换',
        type: SnackBarType.error,
      );
    });
    
    // 再立即显示第三个SnackBar
    Future.delayed(const Duration(milliseconds: 1000), () {
      GetXSnackBarUtil.showImmediate(
        message: '第三个立即显示的提示消息',
        title: '再次替换',
        type: SnackBarType.warning,
      );
    });
  }
}
