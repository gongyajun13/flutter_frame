import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../../overlay/overlay.dart';
import '../../utils/url_launcher_util.dart';
import '../../widgets/simple_fullscreen_webview.dart';

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
  final TextEditingController _smsMessageController = TextEditingController();
  final TextEditingController _emailSubjectController = TextEditingController();
  final TextEditingController _emailBodyController = TextEditingController();

  // 历史记录
  final List<Map<String, dynamic>> _history = [];

  // 当前选中的标签页
  int _selectedTab = 0;

  // 展开/收起状态
  final Map<String, bool> _expandedSections = {};

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
    _smsMessageController.dispose();
    _emailSubjectController.dispose();
    _emailBodyController.dispose();
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
    _smsMessageController.text = '这是一条测试短信';
    _emailSubjectController.text = '测试邮件';
    _emailBodyController.text = '这是一封测试邮件，来自Flutter应用。';

    // 初始化展开状态
    _expandedSections['url'] = true;
    _expandedSections['phone'] = false;
    _expandedSections['email'] = false;
    _expandedSections['map'] = false;
    _expandedSections['app'] = false;
    _expandedSections['social'] = false;
    _expandedSections['confirm'] = false;
    _expandedSections['utility'] = false;
  }

  /// 添加历史记录
  void _addHistory(String type, String target, LaunchResult result) {
    setState(() {
      _history.insert(0, {
        'type': type,
        'target': target,
        'result': result,
        'time': DateTime.now(),
      });
      // 只保留最近20条记录
      if (_history.length > 20) {
        _history.removeLast();
      }
    });
  }

  /// 切换展开状态
  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !(_expandedSections[key] ?? false);
    });
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
        child: Column(
          children: [
            // 标签页选择器
            _buildTabBar(),

            // 内容区域
            Expanded(
              child: _selectedTab == 0
                  ? _buildMainContent()
                  : _buildHistoryContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标签页选择器
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('功能演示', 0),
          ),
          Expanded(
            child: _buildTabButton('历史记录', 1),
          ),
        ],
      ),
    );
  }

  /// 构建标签按钮
  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  /// 构建主内容区域
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 平台信息卡片
          _buildPlatformInfoCard(),

          SizedBox(height: 20.h),

          // 快速测试区域
          _buildQuickTestSection(),

          SizedBox(height: 20.h),

          // 基础URL跳转
          _buildExpandableSectionCard(
            '基础URL跳转',
            Colors.blue,
            'url',
            _buildUrlJumpSection(),
          ),

          SizedBox(height: 16.h),

          // 电话相关跳转
          _buildExpandableSectionCard(
            '电话相关跳转',
            Colors.green,
            'phone',
            _buildPhoneSection(),
          ),

          SizedBox(height: 16.h),

          // 邮件相关跳转
          _buildExpandableSectionCard(
            '邮件相关跳转',
            Colors.orange,
            'email',
            _buildEmailSection(),
          ),

          SizedBox(height: 16.h),

          // 地图相关跳转
          _buildExpandableSectionCard(
            '地图相关跳转',
            Colors.red,
            'map',
            _buildMapSection(),
          ),

          SizedBox(height: 16.h),

          // 应用相关跳转
          _buildExpandableSectionCard(
            '应用相关跳转',
            Colors.purple,
            'app',
            _buildAppSection(),
          ),

          SizedBox(height: 16.h),

          // 社交媒体跳转
          _buildExpandableSectionCard(
            '社交媒体跳转',
            Colors.teal,
            'social',
            _buildSocialSection(),
          ),

          SizedBox(height: 16.h),

          // 带确认的跳转
          _buildExpandableSectionCard(
            '带确认的跳转',
            Colors.pink,
            'confirm',
            _buildConfirmSection(),
          ),

          SizedBox(height: 16.h),

          // 工具方法
          _buildExpandableSectionCard(
            '工具方法',
            Colors.cyan,
            'utility',
            _buildUtilitySection(),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// 构建历史记录内容
  Widget _buildHistoryContent() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              '暂无历史记录',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '使用功能后会显示在这里',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 清除历史按钮
        Container(
          margin: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '共 ${_history.length} 条记录',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _history.clear();
                  });
                  AppOverlay.snack.success(message: '历史记录已清除');
                },
                icon: Icon(Icons.delete_outline, size: 18.sp),
                label: Text('清除全部', style: TextStyle(fontSize: 14.sp)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),

        // 历史记录列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];
              return _buildHistoryItem(item);
            },
          ),
        ),
      ],
    );
  }

  /// 构建历史记录项
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final result = item['result'] as LaunchResult;
    final time = item['time'] as DateTime;

    Color resultColor;
    IconData resultIcon;
    String resultText;

    switch (result) {
      case LaunchResult.success:
        resultColor = Colors.green;
        resultIcon = Icons.check_circle;
        resultText = '成功';
        break;
      case LaunchResult.failed:
        resultColor = Colors.red;
        resultIcon = Icons.error;
        resultText = '失败';
        break;
      case LaunchResult.notSupported:
        resultColor = Colors.orange;
        resultIcon = Icons.block;
        resultText = '不支持';
        break;
      case LaunchResult.cancelled:
        resultColor = Colors.grey;
        resultIcon = Icons.cancel;
        resultText = '已取消';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: resultColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(resultIcon, color: resultColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type'] as String,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['target'] as String,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              resultText,
              style: TextStyle(
                fontSize: 12.sp,
                color: resultColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建快速测试区域
  Widget _buildQuickTestSection() {
    final quickTests = [
      {'name': '百度', 'url': 'https://www.baidu.com', 'icon': Icons.search},
      {'name': 'GitHub', 'url': 'https://github.com', 'icon': Icons.code},
      {'name': 'Google', 'url': 'https://www.google.com', 'icon': Icons.language},
      {'name': 'Flutter', 'url': 'https://flutter.dev', 'icon': Icons.flutter_dash},
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.orange.shade600, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '快速测试',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: quickTests.map((test) {
              return _buildQuickTestChip(
                test['name'] as String,
                test['url'] as String,
                test['icon'] as IconData,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建快速测试芯片
  Widget _buildQuickTestChip(String name, String url, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16.sp, color: Colors.blue.shade600),
      label: Text(name, style: TextStyle(fontSize: 13.sp)),
      onPressed: () {
        _urlController.text = url;
        _testWebUrl(ul.LaunchMode.externalApplication);
      },
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blue.shade200),
      elevation: 1,
    );
  }

  /// 构建可展开的区域卡片
  Widget _buildExpandableSectionCard(
      String title,
      Color color,
      String key,
      Widget content,
      ) {
    final isExpanded = _expandedSections[key] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5.w,
        ),
      ),
      child: Column(
        children: [
          // 标题栏（可点击）
          InkWell(
            onTap: () => _toggleSection(key),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: color,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          // 内容区域
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: content,
            ),
        ],
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
          Icons.link,
          suffix: IconButton(
            icon: Icon(Icons.paste, size: 20.sp),
            onPressed: () async {
              final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
              if (clipboardData?.text != null) {
                setState(() {
                  _urlController.text = clipboardData!.text!;
                });
                AppOverlay.snack.success(message: '已粘贴剪贴板内容');
              }
            },
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                '外部浏览器',
                Colors.blue.shade600,
                Icons.open_in_browser,
                    () => _testWebUrl(ul.LaunchMode.externalApplication),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildButton(
                '应用内浏览器',
                Colors.green.shade600,
                Icons.web,
                    () => _testWebUrl(ul.LaunchMode.inAppBrowserView),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '平台默认',
          Colors.purple.shade600,
          Icons.smartphone,
              () => _testWebUrl(ul.LaunchMode.platformDefault),
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
          Icons.phone,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                '拨打电话',
                Colors.green.shade600,
                Icons.call,
                    () => _testPhoneCall(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildButton(
                '发送短信',
                Colors.blue.shade600,
                Icons.message,
                    () => _testSendSms(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildInputField(
          '短信内容（可选）',
          _smsMessageController,
          '请输入短信内容',
          Icons.textsms,
          isOptional: true,
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
          Icons.email,
        ),
        SizedBox(height: 16.h),
        _buildInputField(
          '邮件主题（可选）',
          _emailSubjectController,
          '请输入邮件主题',
          Icons.subject,
          isOptional: true,
        ),
        SizedBox(height: 16.h),
        _buildInputField(
          '邮件内容（可选）',
          _emailBodyController,
          '请输入邮件内容',
          Icons.text_fields,
          isOptional: true,
          maxLines: 3,
        ),
        SizedBox(height: 16.h),
        _buildButton(
          '发送邮件',
          Colors.orange.shade600,
          Icons.send,
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
                Icons.location_on,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildInputField(
                '经度',
                _longitudeController,
                '经度',
                Icons.location_on,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildInputField(
          '地址',
          _addressController,
          '请输入地址',
          Icons.place,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildButton(
                '坐标打开地图',
                Colors.red.shade600,
                Icons.map,
                    () => _testOpenMapByCoordinate(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildButton(
                '地址打开地图',
                Colors.orange.shade600,
                Icons.location_searching,
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
          Icons.shop,
              () => _testOpenAppStore(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '打开系统设置',
          Colors.indigo.shade600,
          Icons.settings,
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
                Icons.chat,
                    () => _testOpenWeChat(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildButton(
                '打开QQ',
                Colors.blue.shade600,
                Icons.message,
                    () => _testOpenQQ(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '打开支付宝',
          Colors.blue.shade700,
          Icons.account_balance_wallet,
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
          Icons.link,
              () => _testUrlWithConfirm(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '带确认的电话拨打',
          Colors.red.shade600,
          Icons.phone,
              () => _testPhoneWithConfirm(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '带确认的邮件发送',
          Colors.orange.shade600,
          Icons.email,
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
          Icons.check_circle_outline,
              () => _testCanLaunchUrl(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '检查电话支持',
          Colors.green.shade600,
          Icons.phone_in_talk,
              () => _testCanMakePhoneCall(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '检查邮件支持',
          Colors.orange.shade600,
          Icons.mark_email_read,
              () => _testCanSendEmail(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '检查短信支持',
          Colors.blue.shade600,
          Icons.sms_outlined,
              () => _testCanSendSms(),
        ),
      ],
    );
  }

  /// 构建输入框
  Widget _buildInputField(
      String label,
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool isOptional = false,
        int maxLines = 1,
        Widget? suffix,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: Colors.grey.shade600),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            if (isOptional) ...[
              SizedBox(width: 4.w),
              Text(
                '(可选)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
            ),
            prefixIcon: Icon(icon, size: 20.sp, color: Colors.grey.shade400),
            suffixIcon: suffix,
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
  Widget _buildButton(
      String text,
      Color color,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      height: 48.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }


  // ==================== 测试方法 ====================

  /// 测试网页跳转
  Future<void> _testWebUrl(ul.LaunchMode mode) async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      AppOverlay.snack.warning(message: '请输入URL地址');
      return;
    }

    // 简单的URL验证
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      AppOverlay.snack.warning(message: 'URL格式不正确，请以 http:// 或 https:// 开头');
      return;
    }

    // 如果是应用内浏览器模式，使用本地 WebView
    if (mode == ul.LaunchMode.inAppBrowserView) {
      // 使用本地实现的 SimpleFullScreenWebView
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimpleFullScreenWebView(
            url: url,
            title: _getUrlTitle(url),
          ),
        ),
      );
      // 记录历史
      _addHistory('应用内浏览器', url, LaunchResult.success);
      return;
    }

    // 其他模式使用 url_launcher
    await UrlLauncherUtil.launchWebUrl(
      url,
      mode: mode,
      onResult: (result, error) {
        _addHistory('URL跳转', url, result);
        _handleLaunchResult(result, error, url);
      },
    );
  }

  /// 从URL提取标题
  String _getUrlTitle(String url) {
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

  /// 测试拨打电话
  Future<void> _testPhoneCall() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppOverlay.snack.warning(message: '请输入电话号码');
      return;
    }

    await UrlLauncherUtil.makePhoneCall(
      phone,
      onResult: (result, error) {
        _addHistory('拨打电话', phone, result);
        _handleLaunchResult(result, error, phone);
      },
    );
  }

  /// 测试发送短信
  Future<void> _testSendSms() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppOverlay.snack.warning(message: '请输入电话号码');
      return;
    }

    final message = _smsMessageController.text.trim();
    await UrlLauncherUtil.sendSms(
      phone,
      message: message.isNotEmpty ? message : null,
      onResult: (result, error) {
        _addHistory('发送短信', phone, result);
        _handleLaunchResult(result, error, phone);
      },
    );
  }

  /// 测试发送邮件
  Future<void> _testSendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppOverlay.snack.warning(message: '请输入邮箱地址');
      return;
    }

    final subject = _emailSubjectController.text.trim();
    final body = _emailBodyController.text.trim();

    await UrlLauncherUtil.sendEmail(
      to: email,
      subject: subject.isNotEmpty ? subject : null,
      body: body.isNotEmpty ? body : null,
      onResult: (result, error) {
        _addHistory('发送邮件', email, result);
        _handleLaunchResult(result, error, email);
      },
    );
  }

  /// 测试通过坐标打开地图
  Future<void> _testOpenMapByCoordinate() async {
    final latStr = _latitudeController.text.trim();
    final lngStr = _longitudeController.text.trim();

    if (latStr.isEmpty || lngStr.isEmpty) {
      AppOverlay.snack.warning(message: '请输入纬度和经度');
      return;
    }

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);

    if (lat == null || lng == null) {
      AppOverlay.snack.warning(message: '请输入有效的坐标');
      return;
    }

    await UrlLauncherUtil.openMap(
      latitude: lat,
      longitude: lng,
      label: '测试位置',
      onResult: (result, error) {
        _addHistory('打开地图', '$lat, $lng', result);
        _handleLaunchResult(result, error, '$lat, $lng');
      },
    );
  }

  /// 测试通过地址打开地图
  Future<void> _testOpenMapByAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      AppOverlay.snack.warning(message: '请输入地址');
      return;
    }

    await UrlLauncherUtil.openMap(
      address: address,
      onResult: (result, error) {
        _addHistory('打开地图', address, result);
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
        _addHistory('打开应用商店', '应用商店', result);
        _handleLaunchResult(result, error, '应用商店');
      },
    );
  }

  /// 测试打开系统设置
  Future<void> _testOpenSettings() async {
    await UrlLauncherUtil.openSettings(
      onResult: (result, error) {
        _addHistory('打开系统设置', '系统设置', result);
        _handleLaunchResult(result, error, '系统设置');
      },
    );
  }

  /// 测试打开微信
  Future<void> _testOpenWeChat() async {
    await UrlLauncherUtil.openWeChat(
      onResult: (result, error) {
        _addHistory('打开微信', '微信', result);
        _handleLaunchResult(result, error, '微信');
      },
    );
  }

  /// 测试打开QQ
  Future<void> _testOpenQQ() async {
    await UrlLauncherUtil.openQQ(
      qqNumber: '123456789',
      onResult: (result, error) {
        _addHistory('打开QQ', 'QQ', result);
        _handleLaunchResult(result, error, 'QQ');
      },
    );
  }

  /// 测试打开支付宝
  Future<void> _testOpenAlipay() async {
    await UrlLauncherUtil.openAlipay(
      onResult: (result, error) {
        _addHistory('打开支付宝', '支付宝', result);
        _handleLaunchResult(result, error, '支付宝');
      },
    );
  }

  /// 测试带确认的URL跳转
  Future<void> _testUrlWithConfirm() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      AppOverlay.snack.warning(message: '请输入URL地址');
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
      AppOverlay.snack.warning(message: '请输入电话号码');
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
      AppOverlay.snack.warning(message: '请输入邮箱地址');
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
      AppOverlay.snack.warning(message: '请输入URL地址');
      return;
    }

    final canLaunch = await UrlLauncherUtil.canOpenUrl(url);
    AppOverlay.snack.info(
      message: 'URL支持状态：${canLaunch ? '支持' : '不支持'}\nURL: $url',
      title: 'URL支持检查',
    );
  }

  /// 测试检查电话支持
  Future<void> _testCanMakePhoneCall() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppOverlay.snack.warning(message: '请输入电话号码');
      return;
    }

    final canCall = await UrlLauncherUtil.canMakePhoneCall(phone);
    AppOverlay.snack.info(
      message: '电话支持状态：${canCall ? '支持' : '不支持'}\n电话: $phone',
      title: '电话支持检查',
    );
  }

  /// 测试检查邮件支持
  Future<void> _testCanSendEmail() async {
    final canEmail = await UrlLauncherUtil.canSendEmail();
    AppOverlay.snack.info(
      message: '邮件支持状态：${canEmail ? '支持' : '不支持'}',
      title: '邮件支持检查',
    );
  }

  /// 测试检查短信支持
  Future<void> _testCanSendSms() async {
    final canSms = await UrlLauncherUtil.canSendSms();
    AppOverlay.snack.info(
      message: '短信支持状态：${canSms ? '支持' : '不支持'}',
      title: '短信支持检查',
    );
  }

  /// 处理跳转结果
  void _handleLaunchResult(LaunchResult result, String? error, String target) {
    switch (result) {
      case LaunchResult.success:
        AppOverlay.snack.success(
          message: '跳转成功：$target',
          title: '操作完成',
        );
        break;
      case LaunchResult.failed:
        AppOverlay.snack.error(
          message: '跳转失败：$target\n错误：$error',
          title: '操作失败',
        );
        break;
      case LaunchResult.notSupported:
        AppOverlay.snack.warning(
          message: '当前设备不支持此操作：$target',
          title: '不支持',
        );
        break;
      case LaunchResult.cancelled:
        AppOverlay.snack.info(
          message: '用户取消了操作：$target',
          title: '已取消',
        );
        break;
    }
  }
}