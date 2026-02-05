import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../utils/app_update_util.dart';
import '../../app/routes/app_pages.dart';
import '../../utils/getx_dialog_util.dart';
import '../../utils/getx_snackbar_util.dart';

/// GetX工具演示控制器
class GetXUtilsDemoController extends BaseController {
  /// 显示多条SnackBar
  void showMultipleSnackBars() {
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
    SnackBarUtil.showMultiple(configs);
  }

  /// 显示Loading对话框
  void showLoadingDialog() {
    DialogUtil.showLoading(
      message: '正在加载中...',
    );
    
    // 3秒后自动关闭
    Future.delayed(const Duration(seconds: 3), () {
      DialogUtil.hideLoading();
      SnackBarUtil.success(message: '加载完成！');
    });
  }

  /// 显示确认对话框
  void showConfirmDialog() {
    DialogUtil.showConfirm(
      title: '确认删除',
      message: '确定要删除这个项目吗？此操作不可撤销。',
      confirmText: '删除',
      cancelText: '取消',
      confirmColor: const Color(0xFFD32F2F),
      onConfirm: () {
        SnackBarUtil.success(message: '删除成功！');
      },
      onCancel: () {
        SnackBarUtil.info(message: '已取消删除');
      },
    );
  }

  /// 显示警告对话框
  void showAlertDialog() {
    DialogUtil.showAlert(
      title: '网络异常',
      message: '网络连接异常，请检查网络设置后重试。',
      buttonText: '我知道了',
      buttonColor: const Color(0xFFF57C00),
      onPressed: () {
        SnackBarUtil.info(message: '已确认网络异常');
      },
    );
  }

  /// 显示输入对话框
  void showInputDialog() {
    DialogUtil.showInput(
      title: '输入用户名',
      hintText: '请输入用户名',
      confirmText: '确认',
      cancelText: '取消',
      onConfirm: (value) {
        if (value.isNotEmpty) {
          SnackBarUtil.success(message: '用户名：$value');
        } else {
          SnackBarUtil.warning(message: '用户名不能为空');
        }
      },
      onCancel: () {
        SnackBarUtil.info(message: '已取消输入');
      },
    );
  }

  /// 显示选择对话框
  void showSelectDialog() {
    final options = ['选项一', '选项二', '选项三', '选项四', '选项五'];
    DialogUtil.showSelect(
      title: '请选择',
      options: options,
      onSelected: (index, option) {
        SnackBarUtil.success(message: '选择了：$option');
      },
      onCancel: () {
        SnackBarUtil.info(message: '已取消选择');
      },
    );
  }

  /// 显示底部弹窗
  void showBottomSheet() {
    DialogUtil.showBottomSheet(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '底部弹窗',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '这是一个底部弹窗示例，可以包含任何内容。',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  SnackBarUtil.success(message: '底部弹窗操作完成');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '确认',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 模拟网络请求
  void simulateNetworkRequest() {
    // 显示Loading
    DialogUtil.showLoading(message: '正在请求数据...');
    
    // 模拟网络请求
    Future.delayed(const Duration(seconds: 2), () {
      DialogUtil.hideLoading();
      
      // 模拟请求结果
      final success = DateTime.now().millisecond % 2 == 0;
      if (success) {
        SnackBarUtil.success(message: '数据加载成功！');
      } else {
        SnackBarUtil.error(message: '网络请求失败，请重试');
      }
    });
  }

  /// 模拟表单验证
  void simulateFormValidation() {
    DialogUtil.showInput(
      title: '表单验证',
      hintText: '请输入邮箱地址',
      keyboardType: TextInputType.emailAddress,
      onConfirm: (value) {
        if (value.isEmpty) {
          SnackBarUtil.warning(message: '邮箱地址不能为空');
        } else if (!value.contains('@')) {
          SnackBarUtil.error(message: '请输入有效的邮箱地址');
        } else {
          SnackBarUtil.success(message: '邮箱地址验证通过');
        }
      },
    );
  }

  /// 模拟批量操作
  void simulateBatchOperation() {
    DialogUtil.showConfirm(
      title: '批量删除',
      message: '确定要删除选中的 5 个项目吗？',
      confirmText: '删除',
      cancelText: '取消',
      confirmColor: const Color(0xFFD32F2F),
      onConfirm: () {
        // 显示Loading
        DialogUtil.showLoading(message: '正在删除...');
        
        // 模拟批量删除
        Future.delayed(const Duration(seconds: 2), () {
          DialogUtil.hideLoading();
          SnackBarUtil.success(message: '已成功删除 5 个项目');
        });
      },
      onCancel: () {
        SnackBarUtil.info(message: '已取消批量删除');
      },
    );
  }

  /// 测试SnackBar覆盖功能
  void testSnackBarOverride() {
    // 显示第一条消息
    SnackBarUtil.info(message: '第一条消息 - 这条应该被覆盖');
    
    // 1秒后显示第二条消息，应该覆盖第一条
    Future.delayed(const Duration(seconds: 1), () {
      SnackBarUtil.success(message: '第二条消息 - 这条应该覆盖第一条');
    });
    
    // 2秒后显示第三条消息，应该覆盖第二条
    Future.delayed(const Duration(seconds: 2), () {
      SnackBarUtil.error(message: '第三条消息 - 这条应该覆盖第二条');
    });
    
    // 3秒后显示第四条消息，应该覆盖第三条
    Future.delayed(const Duration(seconds: 3), () {
      SnackBarUtil.warning(message: '第四条消息 - 这条应该覆盖第三条');
    });
  }

  /// 测试立即显示SnackBar功能
  void testImmediateSnackBar() {
    // 显示第一个SnackBar
    SnackBarUtil.success(message: '第一个提示消息');
    
    // 使用立即显示方法，强制替换当前显示的
    Future.delayed(const Duration(milliseconds: 500), () {
      SnackBarUtil.showImmediate(
        message: '立即显示的提示消息（强制替换）',
        title: '立即替换',
        type: SnackBarType.error,
      );
    });
    
    // 再立即显示第三个SnackBar
    Future.delayed(const Duration(milliseconds: 1000), () {
      SnackBarUtil.showImmediate(
        message: '第三个立即显示的提示消息',
        title: '再次替换',
        type: SnackBarType.warning,
      );
    });
  }

  /// 显示应用更新演示
  Future<void> showUpdateDemo() async {
    await AppUpdateUtil.checkAndUpdate(
      silent: true,
      fetcher: () async {
        return AppUpdateInfo(
          latestVersion: '9.9.9',
          latestBuild: 99999,
          forceUpdate: false,
          title: '发现新版本',
          description: '1. 提升稳定性\n2. 修复若干已知问题\n3. 优化用户体验',
          androidApkUrl: 'https://aiera-android.oss-cn-shanghai.aliyuncs.com/aiera_debug/39940/hotdog-3.99.40-39940-20251024094111.apk',
          iosAppId: '1234567890',
        );
      },
    );
  }

  /// 导航到自定义对话框演示
  void navigateToCustomDialogDemo() {
    navigateTo(Routes.CUSTOM_DIALOG_DEMO);
  }
}
