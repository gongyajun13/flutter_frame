import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import '../utils/url_launcher_util.dart';
import '../utils/getx_snackbar_util.dart';

/// URL跳转工具类演示页面
class UrlLauncherDemoPage extends StatefulWidget {
  const UrlLauncherDemoPage({super.key});

  @override
  State<UrlLauncherDemoPage> createState() => _UrlLauncherDemoPageState();
}

class _UrlLauncherDemoPageState extends State<UrlLauncherDemoPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDefaultValues();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// 初始化默认值
  void _initDefaultValues() {
    _urlController.text = 'https://www.baidu.com';
    _phoneController.text = '10086';
    _emailController.text = 'test@example.com';
    _latitudeController.text = '39.9042';
    _longitudeController.text = '116.4074';
    _addressController.text = '北京市天安门广场';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'URL跳转工具演示',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.shade600,
                Colors.indigo.shade700,
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 平台信息卡片
              _buildPlatformInfoCard(),
              
              SizedBox(height: 20.h),
              
              // 基础URL跳转
              _buildSectionCard(
                '基础URL跳转',
                Colors.blue,
                [
                  _buildUrlJumpSection(),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // 电话相关跳转
              _buildSectionCard(
                '电话相关跳转',
                Colors.green,
                [
                  _buildPhoneSection(),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // 邮件相关跳转
              _buildSectionCard(
                '邮件相关跳转',
                Colors.orange,
                [
                  _buildEmailSection(),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // 地图相关跳转
              _buildSectionCard(
                '地图相关跳转',
                Colors.red,
                [
                  _buildMapSection(),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // 应用相关跳转
              _buildSectionCard(
                '应用相关跳转',
                Colors.purple,
                [
                  _buildAppSection(),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // 社交媒体跳转
              _buildSectionCard(
                '社交媒体跳转',
                Colors.teal,
                [
                  _buildSocialSection(),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // 带确认的跳转
              _buildSectionCard(
                '带确认的跳转',
                Colors.pink,
                [
                  _buildConfirmSection(),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // 工具方法
              _buildSectionCard(
                '工具方法',
                Colors.cyan,
                [
                  _buildUtilitySection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建平台信息卡片
  Widget _buildPlatformInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade50,
            Colors.indigo.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.indigo.shade200,
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.indigo.shade600,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '平台信息',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('当前平台', UrlLauncherUtil.getPlatformInfo()),
          _buildInfoRow('支持状态', '已初始化'),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.indigo.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建URL跳转部分
  Widget _buildUrlJumpSection() {
    return Column(
      children: [
        _buildInputField(
          'URL地址',
          _urlController,
          '请输入要跳转的URL',
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                '外部浏览器',
                Colors.blue.shade600,
                () => _testWebUrl(ul.LaunchMode.externalApplication),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildButton(
                '应用内浏览器',
                Colors.green.shade600,
                () => _testWebUrl(ul.LaunchMode.inAppBrowserView),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建电话部分
  Widget _buildPhoneSection() {
    return Column(
      children: [
        _buildInputField(
          '电话号码',
          _phoneController,
          '请输入电话号码',
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                '拨打电话',
                Colors.green.shade600,
                () => _testPhoneCall(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildButton(
                '发送短信',
                Colors.blue.shade600,
                () => _testSendSms(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建邮件部分
  Widget _buildEmailSection() {
    return Column(
      children: [
        _buildInputField(
          '邮箱地址',
          _emailController,
          '请输入邮箱地址',
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '发送邮件',
          Colors.orange.shade600,
          () => _testSendEmail(),
        ),
      ],
    );
  }

  /// 构建地图部分
  Widget _buildMapSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                '纬度',
                _latitudeController,
                '纬度',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildInputField(
                '经度',
                _longitudeController,
                '经度',
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildInputField(
          '地址',
          _addressController,
          '请输入地址',
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                '坐标打开地图',
                Colors.red.shade600,
                () => _testOpenMapByCoordinate(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildButton(
                '地址打开地图',
                Colors.orange.shade600,
                () => _testOpenMapByAddress(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建应用部分
  Widget _buildAppSection() {
    return Column(
      children: [
        _buildButton(
          '打开应用商店',
          Colors.purple.shade600,
          () => _testOpenAppStore(),
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '打开系统设置',
          Colors.indigo.shade600,
          () => _testOpenSettings(),
        ),
      ],
    );
  }

  /// 构建社交媒体部分
  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildButton(
                '打开微信',
                Colors.green.shade600,
                () => _testOpenWeChat(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildButton(
                '打开QQ',
                Colors.blue.shade600,
                () => _testOpenQQ(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '打开支付宝',
          Colors.blue.shade700,
          () => _testOpenAlipay(),
        ),
      ],
    );
  }

  /// 构建确认跳转部分
  Widget _buildConfirmSection() {
    return Column(
      children: [
        _buildButton(
          '带确认的URL跳转',
          Colors.pink.shade600,
          () => _testUrlWithConfirm(),
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '带确认的电话拨打',
          Colors.red.shade600,
          () => _testPhoneWithConfirm(),
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '带确认的邮件发送',
          Colors.orange.shade600,
          () => _testEmailWithConfirm(),
        ),
      ],
    );
  }

  /// 构建工具方法部分
  Widget _buildUtilitySection() {
    return Column(
      children: [
        _buildButton(
          '检查URL支持',
          Colors.cyan.shade600,
          () => _testCanLaunchUrl(),
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '检查电话支持',
          Colors.green.shade600,
          () => _testCanMakePhoneCall(),
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '检查邮件支持',
          Colors.orange.shade600,
          () => _testCanSendEmail(),
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '检查短信支持',
          Colors.blue.shade600,
          () => _testCanSendSms(),
        ),
      ],
    );
  }

  /// 构建输入框
  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.blue.shade400,
                width: 2.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  /// 构建按钮
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 3,
          shadowColor: color.withOpacity(0.4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// 构建区域卡片
  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ...children,
          ],
        ),
      ),
    );
  }

  // ==================== 测试方法 ====================

  /// 测试网页跳转
  Future<void> _testWebUrl(ul.LaunchMode mode) async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入URL地址');
      return;
    }

    await UrlLauncherUtil.launchWebUrl(
      url,
      mode: mode,
      onResult: (result, error) {
        _handleLaunchResult(result, error, url);
      },
    );
  }

  /// 测试拨打电话
  Future<void> _testPhoneCall() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入电话号码');
      return;
    }

    await UrlLauncherUtil.makePhoneCall(
      phone,
      onResult: (result, error) {
        _handleLaunchResult(result, error, phone);
      },
    );
  }

  /// 测试发送短信
  Future<void> _testSendSms() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入电话号码');
      return;
    }

    await UrlLauncherUtil.sendSms(
      phone,
      message: '这是一条测试短信',
      onResult: (result, error) {
        _handleLaunchResult(result, error, phone);
      },
    );
  }

  /// 测试发送邮件
  Future<void> _testSendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入邮箱地址');
      return;
    }

    await UrlLauncherUtil.sendEmail(
      to: email,
      subject: '测试邮件',
      body: '这是一封测试邮件，来自Flutter应用。',
      onResult: (result, error) {
        _handleLaunchResult(result, error, email);
      },
    );
  }

  /// 测试通过坐标打开地图
  Future<void> _testOpenMapByCoordinate() async {
    final latStr = _latitudeController.text.trim();
    final lngStr = _longitudeController.text.trim();
    
    if (latStr.isEmpty || lngStr.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入纬度和经度');
      return;
    }

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);
    
    if (lat == null || lng == null) {
      GetXSnackBarUtil.warning(message: '请输入有效的坐标');
      return;
    }

    await UrlLauncherUtil.openMap(
      latitude: lat,
      longitude: lng,
      label: '测试位置',
      onResult: (result, error) {
        _handleLaunchResult(result, error, '$lat, $lng');
      },
    );
  }

  /// 测试通过地址打开地图
  Future<void> _testOpenMapByAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入地址');
      return;
    }

    await UrlLauncherUtil.openMap(
      address: address,
      onResult: (result, error) {
        _handleLaunchResult(result, error, address);
      },
    );
  }

  /// 测试打开应用商店
  Future<void> _testOpenAppStore() async {
    await UrlLauncherUtil.openAppStore(
      appId: '1234567890', // 示例ID
      packageName: 'com.example.app', // 示例包名
      onResult: (result, error) {
        _handleLaunchResult(result, error, '应用商店');
      },
    );
  }

  /// 测试打开系统设置
  Future<void> _testOpenSettings() async {
    await UrlLauncherUtil.openSettings(
      onResult: (result, error) {
        _handleLaunchResult(result, error, '系统设置');
      },
    );
  }

  /// 测试打开微信
  Future<void> _testOpenWeChat() async {
    await UrlLauncherUtil.openWeChat(
      onResult: (result, error) {
        _handleLaunchResult(result, error, '微信');
      },
    );
  }

  /// 测试打开QQ
  Future<void> _testOpenQQ() async {
    await UrlLauncherUtil.openQQ(
      qqNumber: '123456789',
      onResult: (result, error) {
        _handleLaunchResult(result, error, 'QQ');
      },
    );
  }

  /// 测试打开支付宝
  Future<void> _testOpenAlipay() async {
    await UrlLauncherUtil.openAlipay(
      onResult: (result, error) {
        _handleLaunchResult(result, error, '支付宝');
      },
    );
  }

  /// 测试带确认的URL跳转
  Future<void> _testUrlWithConfirm() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入URL地址');
      return;
    }

    await UrlLauncherUtil.launchUrlWithConfirm(
      context,
      url,
      title: '确认跳转',
      message: '即将跳转到：\n$url',
    );
  }

  /// 测试带确认的电话拨打
  Future<void> _testPhoneWithConfirm() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入电话号码');
      return;
    }

    await UrlLauncherUtil.makePhoneCallWithConfirm(
      context,
      phone,
      title: '确认拨打电话',
      message: '即将拨打电话：\n$phone',
    );
  }

  /// 测试带确认的邮件发送
  Future<void> _testEmailWithConfirm() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入邮箱地址');
      return;
    }

    await UrlLauncherUtil.sendEmailWithConfirm(
      context,
      to: email,
      subject: '测试邮件',
      body: '这是一封测试邮件',
      title: '确认发送邮件',
      message: '即将发送邮件到：\n$email',
    );
  }

  /// 测试检查URL支持
  Future<void> _testCanLaunchUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入URL地址');
      return;
    }

    final canLaunch = await UrlLauncherUtil.canOpenUrl(url);
    GetXSnackBarUtil.info(
      message: 'URL支持状态：${canLaunch ? '支持' : '不支持'}\nURL: $url',
      title: 'URL支持检查',
    );
  }

  /// 测试检查电话支持
  Future<void> _testCanMakePhoneCall() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      GetXSnackBarUtil.warning(message: '请输入电话号码');
      return;
    }

    final canCall = await UrlLauncherUtil.canMakePhoneCall(phone);
    GetXSnackBarUtil.info(
      message: '电话支持状态：${canCall ? '支持' : '不支持'}\n电话: $phone',
      title: '电话支持检查',
    );
  }

  /// 测试检查邮件支持
  Future<void> _testCanSendEmail() async {
    final canEmail = await UrlLauncherUtil.canSendEmail();
    GetXSnackBarUtil.info(
      message: '邮件支持状态：${canEmail ? '支持' : '不支持'}',
      title: '邮件支持检查',
    );
  }

  /// 测试检查短信支持
  Future<void> _testCanSendSms() async {
    final canSms = await UrlLauncherUtil.canSendSms();
    GetXSnackBarUtil.info(
      message: '短信支持状态：${canSms ? '支持' : '不支持'}',
      title: '短信支持检查',
    );
  }

  /// 处理跳转结果
  void _handleLaunchResult(LaunchResult result, String? error, String target) {
    switch (result) {
      case LaunchResult.success:
        GetXSnackBarUtil.success(
          message: '跳转成功：$target',
          title: '操作完成',
        );
        break;
      case LaunchResult.failed:
        GetXSnackBarUtil.error(
          message: '跳转失败：$target\n错误：$error',
          title: '操作失败',
        );
        break;
      case LaunchResult.notSupported:
        GetXSnackBarUtil.warning(
          message: '当前设备不支持此操作：$target',
          title: '不支持',
        );
        break;
      case LaunchResult.cancelled:
        GetXSnackBarUtil.info(
          message: '用户取消了操作：$target',
          title: '已取消',
        );
        break;
    }
  }
}