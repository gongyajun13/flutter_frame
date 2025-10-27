import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'deepseek_demo_controller.dart';
import '../../network/config/deepseek_config.dart';
import '../../network/services/deepseek_service.dart';

/// DeepSeek 演示页面视图 - 对话主导设计
class DeepSeekDemoView extends GetView<DeepSeekDemoController> {
  const DeepSeekDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true, // 避免键盘遮挡
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 对话区域 - 占据主要空间
          Expanded(
            child: _buildChatArea(),
          ),
          
          // 输入区域 - 固定在底部，自动处理安全区域
          SafeArea(
            top: false, // 不处理顶部安全区域（由AppBar处理）
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }

  /// 构建应用栏 - 集成API设置
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.purple.shade600,
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => Row(
        children: [
          // AI头像
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '🤖',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
          SizedBox(width: 12.w),
          
          // 标题信息
          Expanded(
            child: GestureDetector(
              onTap: _showApiKeyDialog,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DeepSeek AI',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      // 连接状态指示器
                      Obx(() => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: controller.isApiKeySet.value
                              ? (controller.isApiConnected.value 
                                  ? Colors.green.shade300 
                                  : Colors.orange.shade300)
                              : Colors.red.shade300,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      )),
                      SizedBox(width: 6.w),
                      Obx(() => Text(
                        controller.isApiKeySet.value 
                            ? (controller.isApiConnected.value ? '已连接 · 点击设置' : '密钥已设置 · 点击设置')
                            : '未连接 · 点击设置API',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // API密钥快捷设置按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: _showApiKeyDialog,
              child: Container(
                padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: controller.isApiKeySet.value
                    ? (controller.isApiConnected.value 
                        ? Colors.green.withOpacity(0.2) 
                        : Colors.orange.withOpacity(0.2))
                    : Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Obx(() => Icon(
                controller.isApiKeySet.value 
                    ? (controller.isApiConnected.value ? Icons.key : Icons.key_off)
                    : Icons.key_off,
                color: Colors.white,
                size: 16.sp,
              )),
              ),
            ),
          ),
        ],
      )),
      actions: [
        // 模型选择按钮
        Obx(() => PopupMenuButton<String>(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  controller.selectedModel.value.contains('chat') ? 'Chat' : 'Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onSelected: (value) {
            controller.changeModel(value);
          },
          itemBuilder: (context) => controller.availableModels.map((model) {
            return PopupMenuItem(
              value: model,
              child: Row(
                children: [
                  Icon(
                    model.contains('chat') ? Icons.chat_bubble_outline : Icons.code,
                    size: 16.sp,
                    color: controller.selectedModel.value == model 
                        ? Colors.blue.shade600 
                        : Colors.grey.shade600,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model,
                          style: TextStyle(
                            fontWeight: controller.selectedModel.value == model 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            color: controller.selectedModel.value == model 
                                ? Colors.blue.shade600 
                                : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          model.contains('chat') ? '通用对话模型' : '专业代码模型',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.selectedModel.value == model)
                    Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.blue.shade600,
                    ),
                ],
              ),
            );
          }).toList(),
        )),

        SizedBox(width: 8.w),
      ],
    );
  }


  /// 构建对话区域 - 主要视图
  Widget _buildChatArea() {
    return Container(
      margin: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // 巧妙的类型切换器
          _buildTypeSwitch(),
          
          // 内容区域
          Expanded(
            child: Obx(() {
              if (controller.selectedTabIndex.value == 0) {
                return _buildChatContent();
              } else {
                return _buildCodeContent();
              }
            }),
          ),
        ],
      ),
    );
  }

  /// 构建巧妙的类型切换器
  Widget _buildTypeSwitch() {
    return Container(
      margin: EdgeInsets.all(12.w),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildSwitchButton(
              title: '智能对话',
              subtitle: 'AI Chat',
              icon: Icons.chat_bubble_outline,
              isSelected: controller.selectedTabIndex.value == 0,
              onTap: () => controller.selectedTabIndex.value = 0,
            )),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Obx(() => _buildSwitchButton(
              title: '代码助手',
              subtitle: 'Code Gen',
              icon: Icons.code_outlined,
              isSelected: controller.selectedTabIndex.value == 1,
              onTap: () => controller.selectedTabIndex.value = 1,
            )),
          ),
        ],
      ),
    );
  }

  /// 构建切换按钮
  Widget _buildSwitchButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade400,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade500,
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

  /// 构建聊天内容
  Widget _buildChatContent() {
    return Column(
      children: [
        // 对话状态栏
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Text(
                '💬',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '智能对话模式',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // 消息数量 + 清空按钮
              Obx(() => Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${controller.conversationHistory.length}条',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (controller.conversationHistory.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Material(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.r),
                        onTap: controller.clearChatHistory,
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            Icons.clear_all,
                            size: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              )),
            ],
          ),
        ),
        
        // 分割线
        Divider(height: 1.h, color: Colors.grey.shade200),
        
        // 消息列表 - 占据最大空间
        Expanded(
          child: _buildMessageList(),
        ),
      ],
    );
  }

  /// 构建代码内容
  Widget _buildCodeContent() {
    return Column(
      children: [
        // 代码状态栏
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Text(
                '💻',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '代码助手模式',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // 快捷操作按钮
              Row(
                children: [
                  _buildQuickActionButton(
                    icon: Icons.auto_awesome,
                    tooltip: '生成代码',
                    onPressed: controller.generateCode,
                  ),
                  SizedBox(width: 4.w),
                  _buildQuickActionButton(
                    icon: Icons.help_outline,
                    tooltip: '解释代码',
                    onPressed: controller.explainCode,
                  ),
                  SizedBox(width: 4.w),
                  _buildQuickActionButton(
                    icon: Icons.clear,
                    tooltip: '清空结果',
                    onPressed: controller.clearCodeResponse,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 分割线
        Divider(height: 1.h, color: Colors.grey.shade200),
        
        // 代码响应区域
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildCodeLoadingState();
              }
              
              if (controller.codeResponse.value.isEmpty) {
                return _buildCodeEmptyState();
              }
              
              return Column(
                children: [
                  // 复制按钮行
                  Row(
                    children: [
                      Text(
                        'AI 响应结果',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: controller.codeResponse.value),
                            );
                            Get.snackbar(
                              '已复制',
                              '内容已复制到剪贴板',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.8),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy,
                                  size: 12.sp,
                                  color: Colors.blue.shade600,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '复制',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
                  // 代码内容
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          controller.codeResponse.value,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'Courier',
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.r),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Icon(
              icon,
              size: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建消息列表
  Widget _buildMessageList() {
    return Obx(() {
      if (controller.conversationHistory.isEmpty && 
          controller.chatResponse.value.isEmpty) {
        return _buildEmptyState();
      }
      
      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.conversationHistory.length + 
            (controller.chatResponse.value.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < controller.conversationHistory.length) {
            final message = controller.conversationHistory[index];
            return _buildMessageBubble(
              content: message.content,
              isUser: message.role == 'user',
            );
          } else {
            return _buildMessageBubble(
              content: controller.chatResponse.value,
              isUser: false,
              isLoading: controller.isLoading.value,
            );
          }
        },
      );
    });
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Text(
              '🤖',
              style: TextStyle(fontSize: 60.sp),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            '开始与AI对话',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '输入消息开始智能对话体验',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble({
    required String content,
    required bool isUser,
    bool isLoading = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(false),
            SizedBox(width: 12.w),
          ],
          
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                      )
                    : null,
                color: isUser ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 20.r : 8.r),
                  topRight: Radius.circular(isUser ? 8.r : 20.r),
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: isLoading
                  ? _buildLoadingIndicator()
                  : isUser
                      ? SelectableText(
                          content,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                            strong: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                            code: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.blue.shade700,
                              backgroundColor: Colors.blue.shade50,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                          ),
                          selectable: true,
                        ),
            ),
          ),
          
          if (isUser) ...[
            SizedBox(width: 12.w),
            _buildAvatar(true),
          ],
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUser
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.blue.shade400, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 16.sp,
      ),
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14.w,
          height: 14.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'AI正在思考...',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 构建代码加载状态
  Widget _buildCodeLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'AI正在生成代码...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建代码空状态
  Widget _buildCodeEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.red.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Text(
              '💻',
              style: TextStyle(fontSize: 60.sp),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            '代码助手已就绪',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '输入代码需求或代码片段开始使用',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建输入区域 - 自适应不同模式
  Widget _buildInputArea() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 56.h, // 确保最小高度
        maxHeight: 200.h, // 限制最大高度，防止溢出
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), // 优化内边距
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.selectedTabIndex.value == 0) {
          return _buildChatInput();
        } else {
          return _buildCodeInput();
        }
      }),
    );
  }

  /// 构建聊天输入
  Widget _buildChatInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.messageController,
            minLines: 1, // 最小行数
            decoration: InputDecoration(
              hintText: '输入消息...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
                borderSide: BorderSide(color: Colors.blue.shade400),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => controller.sendChatMessage(),
          ),
        ),
        SizedBox(width: 8.w),
        Obx(() => Material(
          borderRadius: BorderRadius.circular(20.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: controller.isLoading.value 
                ? null 
                : controller.sendChatMessage,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: controller.isLoading.value
                    ? null
                    : LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                      ),
                color: controller.isLoading.value 
                    ? Colors.grey.shade300 
                    : null,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
            ),
          ),
        )),
      ],
    );
  }

  /// 构建代码输入
  Widget _buildCodeInput() {
    return Column(
      children: [
        TextField(
          controller: controller.codeController,
          minLines: 3, // 代码输入框最小3行
          decoration: InputDecoration(
            hintText: '输入代码需求或代码片段...',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.orange.shade400),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildCodeActionButton(
                title: '生成代码',
                icon: Icons.auto_awesome,
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                onPressed: controller.isLoading.value 
                    ? null 
                    : controller.generateCode,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildCodeActionButton(
                title: '解释代码',
                icon: Icons.help_outline,
                colors: [Colors.green.shade400, Colors.green.shade600],
                onPressed: controller.isLoading.value 
                    ? null 
                    : controller.explainCode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建代码操作按钮
  Widget _buildCodeActionButton({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback? onPressed,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            gradient: onPressed != null
                ? LinearGradient(colors: colors)
                : null,
            color: onPressed == null ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 显示优化的API密钥设置对话框
  void _showApiKeyDialog() {
    
    final RxBool isObscured = true.obs;
    final RxBool isValidating = false.obs;
    // 使用controller中的validationMessage，确保状态同步
    controller.validationMessage.value = ''; // 重置验证消息
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.85, // 限制最大高度
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
                Colors.purple.shade50,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.vpn_key_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'API 密钥设置',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'DeepSeek AI 服务配置',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 内容区域 - 可滚动
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 当前状态
                    Obx(() => Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            color: _getStatusColor(),
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStatusTitle(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(),
                                  ),
                                ),
                                Text(
                                  _getStatusSubtitle(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    
                    SizedBox(height: 16.h),
                    
                    // 输入区域
                    Text(
                      'API 密钥',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() => TextField(
                      controller: controller.apiKeyController,
                      obscureText: isObscured.value,
                      decoration: InputDecoration(
                        hintText: '请输入 DeepSeek API 密钥',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.key_rounded,
                          color: Colors.grey.shade500,
                          size: 20.sp,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 显示/隐藏密钥
                            IconButton(
                              onPressed: () => isObscured.value = !isObscured.value,
                              icon: Icon(
                                isObscured.value 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                                color: Colors.grey.shade500,
                                size: 18.sp,
                              ),
                            ),
                            // 清空按钮
                            if (controller.apiKeyController.text.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  controller.apiKeyController.clear();
                                  controller.validationMessage.value = '';
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade500,
                                  size: 18.sp,
                                ),
                              ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),
                          onChanged: (value) {
                            controller.validationMessage.value = '';
                          },
                    )),
                    
                    // 验证信息
                    SizedBox(height: 8.h),
                    Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: controller.validationMessage.value.isEmpty ? 0 : null,
                      child: controller.validationMessage.value.isEmpty
                          ? const SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: controller.validationMessage.value.startsWith('✅')
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: controller.validationMessage.value.startsWith('✅')
                                      ? Colors.green.shade200
                                      : Colors.red.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    controller.validationMessage.value.startsWith('✅')
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: controller.validationMessage.value.startsWith('✅')
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      controller.validationMessage.value,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: controller.validationMessage.value.startsWith('✅')
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    )),
                    
                    SizedBox(height: 16.h),
                    
                    // 帮助信息
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '如何获取API密钥？',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '1. 访问 platform.deepseek.com\n2. 注册并登录账户\n3. 进入API Keys页面创建密钥\n4. 复制密钥并粘贴到上方输入框',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blue.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 操作按钮
                    Row(
                      children: [
                        // 测试连接按钮
                        Expanded(
                          child: Obx(() => OutlinedButton.icon(
                                onPressed: isValidating.value
                                    ? null
                                    : () async {
                                        if (controller.apiKeyController.text.trim().isEmpty) {
                                          controller.validationMessage.value = '请先输入API密钥';
                                          return;
                                        }
                                        
                                        isValidating.value = true;
                                        controller.validationMessage.value = '';
                                        
                                        // 临时设置密钥用于测试（与保存按钮逻辑一致）
                                        String tempApiKey = controller.apiKeyController.text.trim();
                                        DeepSeekService.initialize(tempApiKey); // 使用initialize方法
                                        
                                        try {
                                          final isConnected = await DeepSeekService.checkConnection(); // 直接调用服务方法
                                          if (isConnected) {
                                            // 测试成功，同步更新全局状态（但不清空输入框，因为用户可能还要保存）
                                            controller.isApiKeySet.value = true;
                                            controller.isApiConnected.value = true;
                                            controller.validationMessage.value = '✅ 连接测试成功！可以保存设置';
                                          } else {
                                            // 测试失败，清除全局状态
                                            controller.isApiKeySet.value = false;
                                            controller.isApiConnected.value = false;
                                            controller.validationMessage.value = '❌ 连接测试失败，请检查密钥是否正确';
                                            // 清除临时设置的密钥
                                            DeepSeekConfig.setApiKey('');
                                          }
                                        } catch (e) {
                                          // 异常时清除全局状态
                                          controller.isApiKeySet.value = false;
                                          controller.isApiConnected.value = false;
                                          controller.validationMessage.value = '❌ 测试失败：网络连接异常';
                                          // 清除临时设置的密钥
                                          DeepSeekConfig.setApiKey('');
                                        }
                                        
                                        isValidating.value = false;
                                      },
                            icon: isValidating.value
                                ? SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.orange.shade600),
                                    ),
                                  )
                                : Icon(Icons.wifi_outlined, size: 16.sp),
                            label: Text(
                              isValidating.value ? '测试中...' : '测试连接',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              side: BorderSide(color: Colors.orange.shade300),
                              foregroundColor: Colors.orange.shade700,
                            ),
                          )),
                        ),
                        
                        SizedBox(width: 12.w),
                        
                        // 保存按钮
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (controller.apiKeyController.text.trim().isEmpty) {
                                controller.validationMessage.value = '请输入API密钥';
                                return;
                              }
                              
                              // 先关闭对话框，然后进行验证
                              Get.back();
                              await controller.setApiKey();
                            },
                            icon: Icon(Icons.save_rounded, size: 16.sp),
                            label: Text(
                              '保存设置',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade400,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    // 清除按钮
                    Obx(() => controller.isApiKeySet.value
                        ? SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                title: const Text('确认清除'),
                                content: const Text('确定要清除已保存的API密钥吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('取消'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // 清除密钥逻辑
                                      controller.clearApiKey();
                                      Get.back(); // 关闭确认对话框
                                      Get.back(); // 关闭设置对话框
                                      
                                      Get.snackbar(
                                        '已清除',
                                        'API密钥已清除',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.orange.withOpacity(0.8),
                                        colorText: Colors.white,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade400,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('清除'),
                                  ),
                                ],
                              ),
                            );
                          },
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade600,
                                size: 16.sp,
                              ),
                              label: Text(
                                '清除已保存的密钥',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                        )
                        : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// 获取状态颜色
  Color _getStatusColor() {
    if (!controller.isApiKeySet.value) {
      return Colors.red.shade600;
    } else if (controller.isApiConnected.value) {
      return Colors.green.shade600;
    } else {
      return Colors.orange.shade600;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon() {
    if (!controller.isApiKeySet.value) {
      return Icons.error_outline;
    } else if (controller.isApiConnected.value) {
      return Icons.check_circle_outline;
    } else {
      return Icons.warning_outlined;
    }
  }

  /// 获取状态标题
  String _getStatusTitle() {
    if (!controller.isApiKeySet.value) {
      return '连接状态：未配置';
    } else if (controller.isApiConnected.value) {
      return '连接状态：已连接';
    } else {
      return '连接状态：待验证';
    }
  }

  /// 获取状态副标题
  String _getStatusSubtitle() {
    if (!controller.isApiKeySet.value) {
      return '请设置API密钥以使用AI服务';
    } else if (controller.isApiConnected.value) {
      return 'API密钥已验证，可以正常使用';
    } else {
      return 'API密钥已设置，点击测试连接验证';
    }
  }
}