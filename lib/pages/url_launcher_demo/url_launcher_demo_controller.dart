import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import '../../base/base_controller.dart';
import '../../utils/url_launcher_util.dart';
import '../../widgets/simple_fullscreen_webview.dart';

/// URL跳转演示控制器
class UrlLauncherDemoController extends BaseController {
  // ==================== TextEditingController ====================
  late final TextEditingController urlController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;
  late final TextEditingController addressController;
  late final TextEditingController smsMessageController;
  late final TextEditingController emailSubjectController;
  late final TextEditingController emailBodyController;

  // ==================== 状态变量 ====================
  // 历史记录（响应式）
  final history = <Map<String, dynamic>>[].obs;

  // 当前选中的标签页（响应式）
  final selectedTab = 0.obs;

  // 展开/收起状态（响应式）
  final expandedSections = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化 TextEditingController
    urlController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();
    addressController = TextEditingController();
    smsMessageController = TextEditingController();
    emailSubjectController = TextEditingController();
    emailBodyController = TextEditingController();

    // 注册到自动清理
    registerTextController(urlController);
    registerTextController(phoneController);
    registerTextController(emailController);
    registerTextController(latitudeController);
    registerTextController(longitudeController);
    registerTextController(addressController);
    registerTextController(smsMessageController);
    registerTextController(emailSubjectController);
    registerTextController(emailBodyController);

    // 初始化默认值
    _initDefaultValues();
  }

  /// 初始化默认值
  void _initDefaultValues() {
    urlController.text = 'https://www.baidu.com';
    phoneController.text = '10086';
    emailController.text = 'test@example.com';
    latitudeController.text = '39.9042';
    longitudeController.text = '116.4074';
    addressController.text = '北京市天安门广场';
    smsMessageController.text = '这是一条测试短信';
    emailSubjectController.text = '测试邮件';
    emailBodyController.text = '这是一封测试邮件，来自Flutter应用。';

    // 初始化展开状态
    expandedSections['url'] = true;
    expandedSections['phone'] = false;
    expandedSections['email'] = false;
    expandedSections['map'] = false;
    expandedSections['app'] = false;
    expandedSections['social'] = false;
    expandedSections['confirm'] = false;
    expandedSections['utility'] = false;
  }

  /// 切换标签页
  void switchTab(int index) {
    selectedTab.value = index;
  }

  /// 切换展开状态
  void toggleSection(String key) {
    expandedSections[key] = !(expandedSections[key] ?? false);
  }

  /// 添加历史记录
  void addHistory(String type, String target, LaunchResult result) {
    history.insert(0, {
      'type': type,
      'target': target,
      'result': result,
      'time': DateTime.now(),
    });
    // 只保留最近20条记录
    if (history.length > 20) {
      history.removeLast();
    }
  }

  /// 清除历史记录
  void clearHistory() {
    history.clear();
    showSuccess('历史记录已清除');
  }

  /// 处理跳转结果
  void handleLaunchResult(LaunchResult result, String? error, String target) {
    switch (result) {
      case LaunchResult.success:
        showSuccess('跳转成功：$target');
        break;
      case LaunchResult.failed:
        showError('跳转失败：$target\n错误：$error');
        break;
      case LaunchResult.notSupported:
        showWarning('当前设备不支持此操作：$target');
        break;
      case LaunchResult.cancelled:
        showInfo('用户取消了操作：$target');
        break;
    }
  }

  /// 从URL提取标题
  String getUrlTitle(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.isEmpty) return '网页浏览';

      // 移除 www. 前缀
      String title = host.replaceFirst(RegExp(r'^www\.'), '');

      // 移除顶级域名
      title = title.split('.').first;

      // 首字母大写
      if (title.isNotEmpty) {
        title = title[0].toUpperCase() + title.substring(1);
      }

      return title.isEmpty ? '网页浏览' : title;
    } catch (e) {
      return '网页浏览';
    }
  }

  // ==================== 测试方法 ====================

  /// 测试网页跳转
  Future<void> testWebUrl(ul.LaunchMode mode) async {
    await executeAsync(
      action: () async {
        final url = urlController.text.trim();
        if (url.isEmpty) {
          showWarning('请输入URL地址');
          return null;
        }

        // 简单的URL验证
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          showWarning('URL格式不正确，请以 http:// 或 https:// 开头');
          return null;
        }

        // 如果是应用内浏览器模式，使用本地 WebView
        if (mode == ul.LaunchMode.inAppBrowserView) {
          // 使用 Get.to 导航到 WebView
          Get.to(() => SimpleFullScreenWebView(
                url: url,
                title: getUrlTitle(url),
              ));
          // 记录历史
          addHistory('应用内浏览器', url, LaunchResult.success);
          return null;
        }

        // 其他模式使用 url_launcher
        await UrlLauncherUtil.launchWebUrl(
          url,
          mode: mode,
          onResult: (result, error) {
            addHistory('URL跳转', url, result);
            handleLaunchResult(result, error, url);
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试拨打电话
  Future<void> testPhoneCall() async {
    await executeAsync(
      action: () async {
        final phone = phoneController.text.trim();
        if (phone.isEmpty) {
          showWarning('请输入电话号码');
          return null;
        }

        await UrlLauncherUtil.makePhoneCall(
          phone,
          onResult: (result, error) {
            addHistory('拨打电话', phone, result);
            handleLaunchResult(result, error, phone);
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试发送短信
  Future<void> testSendSms() async {
    await executeAsync(
      action: () async {
        final phone = phoneController.text.trim();
        if (phone.isEmpty) {
          showWarning('请输入电话号码');
          return null;
        }

        final message = smsMessageController.text.trim();
        await UrlLauncherUtil.sendSms(
          phone,
          message: message.isNotEmpty ? message : null,
          onResult: (result, error) {
            addHistory('发送短信', phone, result);
            handleLaunchResult(result, error, phone);
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试发送邮件
  Future<void> testSendEmail() async {
    await executeAsync(
      action: () async {
        final email = emailController.text.trim();
        if (email.isEmpty) {
          showWarning('请输入邮箱地址');
          return null;
        }

        final subject = emailSubjectController.text.trim();
        final body = emailBodyController.text.trim();

        await UrlLauncherUtil.sendEmail(
          to: email,
          subject: subject.isNotEmpty ? subject : null,
          body: body.isNotEmpty ? body : null,
          onResult: (result, error) {
            addHistory('发送邮件', email, result);
            handleLaunchResult(result, error, email);
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试通过坐标打开地图
  Future<void> testOpenMapByCoordinate() async {
    await executeAsync(
      action: () async {
        final latStr = latitudeController.text.trim();
        final lngStr = longitudeController.text.trim();

        if (latStr.isEmpty || lngStr.isEmpty) {
          showWarning('请输入纬度和经度');
          return null;
        }

        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);

        if (lat == null || lng == null) {
          showWarning('请输入有效的坐标');
          return null;
        }

        await UrlLauncherUtil.openMap(
          latitude: lat,
          longitude: lng,
          label: '测试位置',
          onResult: (result, error) {
            addHistory('打开地图', '$lat, $lng', result);
            handleLaunchResult(result, error, '$lat, $lng');
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试通过地址打开地图
  Future<void> testOpenMapByAddress() async {
    await executeAsync(
      action: () async {
        final address = addressController.text.trim();
        if (address.isEmpty) {
          showWarning('请输入地址');
          return null;
        }

        await UrlLauncherUtil.openMap(
          address: address,
          onResult: (result, error) {
            addHistory('打开地图', address, result);
            handleLaunchResult(result, error, address);
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试打开应用商店
  Future<void> testOpenAppStore() async {
    await executeAsync(
      action: () async {
        await UrlLauncherUtil.openAppStore(
          appId: '1234567890', // 示例ID
          packageName: 'com.example.app', // 示例包名
          onResult: (result, error) {
            addHistory('打开应用商店', '应用商店', result);
            handleLaunchResult(result, error, '应用商店');
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试打开系统设置
  Future<void> testOpenSettings() async {
    await executeAsync(
      action: () async {
        await UrlLauncherUtil.openSettings(
          onResult: (result, error) {
            addHistory('打开系统设置', '系统设置', result);
            handleLaunchResult(result, error, '系统设置');
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试打开微信
  Future<void> testOpenWeChat() async {
    await executeAsync(
      action: () async {
        await UrlLauncherUtil.openWeChat(
          onResult: (result, error) {
            addHistory('打开微信', '微信', result);
            handleLaunchResult(result, error, '微信');
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试打开QQ
  Future<void> testOpenQQ() async {
    await executeAsync(
      action: () async {
        await UrlLauncherUtil.openQQ(
          qqNumber: '123456789',
          onResult: (result, error) {
            addHistory('打开QQ', 'QQ', result);
            handleLaunchResult(result, error, 'QQ');
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试打开支付宝
  Future<void> testOpenAlipay() async {
    await executeAsync(
      action: () async {
        await UrlLauncherUtil.openAlipay(
          onResult: (result, error) {
            addHistory('打开支付宝', '支付宝', result);
            handleLaunchResult(result, error, '支付宝');
          },
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试带确认的URL跳转
  Future<void> testUrlWithConfirm() async {
    await executeAsync(
      action: () async {
        final url = urlController.text.trim();
        if (url.isEmpty) {
          showWarning('请输入URL地址');
          return null;
        }

        await UrlLauncherUtil.launchUrlWithConfirm(
          Get.context!,
          url,
          title: '确认跳转',
          message: '即将跳转到：\n$url',
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试带确认的电话拨打
  Future<void> testPhoneWithConfirm() async {
    await executeAsync(
      action: () async {
        final phone = phoneController.text.trim();
        if (phone.isEmpty) {
          showWarning('请输入电话号码');
          return null;
        }

        await UrlLauncherUtil.makePhoneCallWithConfirm(
          Get.context!,
          phone,
          title: '确认拨打电话',
          message: '即将拨打电话：\n$phone',
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试带确认的邮件发送
  Future<void> testEmailWithConfirm() async {
    await executeAsync(
      action: () async {
        final email = emailController.text.trim();
        if (email.isEmpty) {
          showWarning('请输入邮箱地址');
          return null;
        }

        await UrlLauncherUtil.sendEmailWithConfirm(
          Get.context!,
          to: email,
          subject: '测试邮件',
          body: '这是一封测试邮件',
          title: '确认发送邮件',
          message: '即将发送邮件到：\n$email',
        );
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试检查URL支持
  Future<void> testCanLaunchUrl() async {
    await executeAsync(
      action: () async {
        final url = urlController.text.trim();
        if (url.isEmpty) {
          showWarning('请输入URL地址');
          return null;
        }

        final canLaunch = await UrlLauncherUtil.canOpenUrl(url);
        showInfo('URL支持状态：${canLaunch ? '支持' : '不支持'}\nURL: $url');
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试检查电话支持
  Future<void> testCanMakePhoneCall() async {
    await executeAsync(
      action: () async {
        final phone = phoneController.text.trim();
        if (phone.isEmpty) {
          showWarning('请输入电话号码');
          return null;
        }

        final canCall = await UrlLauncherUtil.canMakePhoneCall(phone);
        showInfo('电话支持状态：${canCall ? '支持' : '不支持'}\n电话: $phone');
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试检查邮件支持
  Future<void> testCanSendEmail() async {
    await executeAsync(
      action: () async {
        final canEmail = await UrlLauncherUtil.canSendEmail();
        showInfo('邮件支持状态：${canEmail ? '支持' : '不支持'}');
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试检查短信支持
  Future<void> testCanSendSms() async {
    await executeAsync(
      action: () async {
        final canSms = await UrlLauncherUtil.canSendSms();
        showInfo('短信支持状态：${canSms ? '支持' : '不支持'}');
        return null;
      },
      showLoading: false,
    );
  }
}
