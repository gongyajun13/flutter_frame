import '../../base/base_controller.dart';
import '../../utils/screen_util_helper.dart';

/// 屏幕适配演示控制器
class ScreenAdaptationDemoController extends BaseController {
  /// 打印屏幕信息到控制台
  void printScreenInfo() {
    ScreenUtilHelper.printScreenInfo();
    showSuccess('屏幕信息已打印到控制台');
  }
}
