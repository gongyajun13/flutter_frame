# 🚀 GetX工具类使用指南

## 🎯 概述

基于GetX插件创建的全局工具类，提供强大的SnackBar和Dialog功能，支持队列管理、多种样式和自定义配置。

## 📁 文件结构

```
lib/utils/
├── getx_snackbar_util.dart    # 全局SnackBar工具类
├── getx_dialog_util.dart      # 全局Dialog工具类
└── getx_utils.dart           # 统一导出文件
```

## 🍞 SnackBar工具类

### 基础使用

```dart
import '../utils/getx_utils.dart';

// 成功提示
GetXSnackBarUtil.success(
  message: '操作成功完成！',
  title: '成功',
);

// 错误提示
GetXSnackBarUtil.error(
  message: '操作失败，请重试！',
  title: '错误',
);

// 警告提示
GetXSnackBarUtil.warning(
  message: '请注意相关风险！',
  title: '警告',
);

// 信息提示
GetXSnackBarUtil.info(
  message: '这是一条信息提示！',
  title: '提示',
);
```

### 自定义SnackBar

```dart
GetXSnackBarUtil.custom(
  message: '自定义样式的提示！',
  title: '自定义',
  backgroundColor: Colors.purple.shade600,
  textColor: Colors.white,
  iconColor: Colors.white,
  icon: Icons.star,
  duration: Duration(seconds: 5),
  position: SnackPosition.BOTTOM,
);
```

### 队列管理

```dart
// 显示多条消息（自动队列管理）
final configs = [
  SnackBarConfig(
    message: '第一条消息',
    type: SnackBarType.info,
    duration: Duration(seconds: 2),
  ),
  SnackBarConfig(
    message: '第二条消息',
    type: SnackBarType.success,
    duration: Duration(seconds: 2),
  ),
  SnackBarConfig(
    message: '第三条消息',
    type: SnackBarType.warning,
    duration: Duration(seconds: 2),
  ),
];
GetXSnackBarUtil.showMultiple(configs);

// 清除所有SnackBar
GetXSnackBarUtil.clearAll();
```

### 高级功能

```dart
// 带进度指示器的SnackBar
GetXSnackBarUtil.success(
  message: '正在处理中...',
  showProgressIndicator: true,
  duration: Duration(seconds: 5),
);

// 带点击回调的SnackBar
GetXSnackBarUtil.info(
  message: '点击查看详情',
  onTap: () {
    // 处理点击事件
    print('SnackBar被点击了');
  },
);
```

## 💬 Dialog工具类

### Loading对话框

```dart
// 显示Loading
GetXDialogUtil.showLoading(
  message: '正在加载中...',
  barrierDismissible: false, // 是否可点击外部关闭
);

// 隐藏Loading
GetXDialogUtil.hideLoading();

// 自定义Loading样式
GetXDialogUtil.showLoading(
  customLoading: Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('自定义Loading...'),
      ],
    ),
  ),
);
```

### 确认对话框

```dart
GetXDialogUtil.showConfirm(
  title: '确认删除',
  message: '确定要删除这个项目吗？此操作不可撤销。',
  confirmText: '删除',
  cancelText: '取消',
  confirmColor: Colors.red.shade600,
  onConfirm: () {
    // 确认操作
    GetXSnackBarUtil.success(message: '删除成功！');
  },
  onCancel: () {
    // 取消操作
    GetXSnackBarUtil.info(message: '已取消删除');
  },
);
```

### 警告对话框

```dart
GetXDialogUtil.showAlert(
  title: '网络异常',
  message: '网络连接异常，请检查网络设置后重试。',
  buttonText: '我知道了',
  buttonColor: Colors.orange.shade600,
  onPressed: () {
    GetXSnackBarUtil.info(message: '已确认网络异常');
  },
);
```

### 输入对话框

```dart
GetXDialogUtil.showInput(
  title: '输入用户名',
  hintText: '请输入用户名',
  initialValue: '默认值',
  confirmText: '确认',
  cancelText: '取消',
  keyboardType: TextInputType.emailAddress,
  maxLines: 1,
  maxLength: 50,
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
```

### 选择对话框

```dart
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
```

### 底部弹窗

```dart
GetXDialogUtil.showBottomSheet(
  child: Container(
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('底部弹窗内容'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Get.back();
            GetXSnackBarUtil.success(message: '底部弹窗操作完成');
          },
          child: Text('确认'),
        ),
      ],
    ),
  ),
);
```

### 自定义对话框

```dart
GetXDialogUtil.showCustom(
  child: Center(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 48, color: Colors.amber),
          SizedBox(height: 16),
          Text('自定义对话框'),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('关闭'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    GetXSnackBarUtil.success(message: '自定义对话框操作成功');
                  },
                  child: Text('确认'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
```

## 🔧 实际应用场景

### 1. 网络请求处理

```dart
// 网络请求前显示Loading
GetXDialogUtil.showLoading(message: '正在请求数据...');

// 模拟网络请求
Future.delayed(Duration(seconds: 2), () {
  GetXDialogUtil.hideLoading();
  
  // 根据请求结果显示不同提示
  final success = true; // 模拟请求结果
  if (success) {
    GetXSnackBarUtil.success(message: '数据加载成功！');
  } else {
    GetXSnackBarUtil.error(message: '网络请求失败，请重试');
  }
});
```

### 2. 表单验证

```dart
// 表单提交验证
void submitForm() {
  if (emailController.text.isEmpty) {
    GetXSnackBarUtil.warning(message: '邮箱地址不能为空');
    return;
  }
  
  if (!emailController.text.contains('@')) {
    GetXSnackBarUtil.error(message: '请输入有效的邮箱地址');
    return;
  }
  
  // 显示确认对话框
  GetXDialogUtil.showConfirm(
    title: '确认提交',
    message: '确定要提交表单吗？',
    onConfirm: () {
      // 提交表单
      GetXSnackBarUtil.success(message: '表单提交成功！');
    },
  );
}
```

### 3. 批量操作

```dart
// 批量删除操作
void batchDelete() {
  GetXDialogUtil.showConfirm(
    title: '批量删除',
    message: '确定要删除选中的 ${selectedItems.length} 个项目吗？',
    confirmText: '删除',
    confirmColor: Colors.red.shade600,
    onConfirm: () {
      // 显示Loading
      GetXDialogUtil.showLoading(message: '正在删除...');
      
      // 模拟批量删除
      Future.delayed(Duration(seconds: 2), () {
        GetXDialogUtil.hideLoading();
        GetXSnackBarUtil.success(message: '已成功删除 ${selectedItems.length} 个项目');
      });
    },
  );
}
```

### 4. 用户反馈收集

```dart
// 收集用户反馈
void collectFeedback() {
  GetXDialogUtil.showInput(
    title: '用户反馈',
    hintText: '请输入您的建议或问题...',
    maxLines: 5,
    maxLength: 500,
    onConfirm: (feedback) {
      if (feedback.isNotEmpty) {
        GetXSnackBarUtil.success(message: '感谢您的反馈！');
        // 发送反馈到服务器
      } else {
        GetXSnackBarUtil.warning(message: '请输入反馈内容');
      }
    },
  );
}
```

## 🎨 样式自定义

### SnackBar样式

```dart
// 自定义SnackBar样式
GetXSnackBarUtil.custom(
  message: '自定义样式',
  backgroundColor: Colors.purple.shade600,
  textColor: Colors.white,
  iconColor: Colors.white,
  icon: Icons.star,
  duration: Duration(seconds: 5),
  position: SnackPosition.BOTTOM,
  showProgressIndicator: true,
);
```

### Dialog样式

```dart
// 自定义Dialog样式
GetXDialogUtil.showCustom(
  child: Container(
    // 自定义样式
  ),
  barrierColor: Colors.black.withOpacity(0.8),
  transitionDuration: Duration(milliseconds: 500),
  transitionCurve: Curves.elasticOut,
);
```

## 📱 演示页面

运行应用后，点击"GetX工具类演示"按钮可以体验：

1. **SnackBar演示**
   - 成功、错误、警告、信息提示
   - 自定义样式SnackBar
   - 多条消息队列管理
   - 清除所有SnackBar

2. **Dialog演示**
   - Loading对话框
   - 确认对话框
   - 警告对话框
   - 输入对话框
   - 选择对话框
   - 底部弹窗
   - 自定义对话框

3. **组合使用演示**
   - 网络请求模拟
   - 表单验证模拟
   - 批量操作模拟

## ⚡ 核心特性

### SnackBar特性
- ✅ 队列管理，避免重叠
- ✅ 多种预设样式（成功、错误、警告、信息）
- ✅ 自定义样式支持
- ✅ 进度指示器支持
- ✅ 点击回调支持
- ✅ 自动消失时间控制

### Dialog特性
- ✅ Loading对话框
- ✅ 确认/取消对话框
- ✅ 警告对话框
- ✅ 输入对话框
- ✅ 选择对话框
- ✅ 底部弹窗
- ✅ 完全自定义对话框
- ✅ 动画效果支持

## 🎯 最佳实践

1. **统一使用工具类** - 使用 `GetXSnackBarUtil` 和 `GetXDialogUtil` 而不是直接使用GetX
2. **合理使用队列** - 多条消息使用队列管理，避免重叠
3. **适当的提示时间** - 根据消息重要性设置合适的显示时间
4. **用户体验优化** - 提供清晰的操作反馈和确认机制
5. **错误处理** - 网络请求等操作要有完善的错误提示

## 🚀 集成到现有项目

### 1. 导入工具类
```dart
import '../utils/getx_utils.dart';
```

### 2. 替换现有提示
```dart
// 替换前
Get.snackbar('成功', '操作成功');

// 替换后
GetXSnackBarUtil.success(message: '操作成功');
```

### 3. 替换现有对话框
```dart
// 替换前
Get.dialog(CircularProgressIndicator());

// 替换后
GetXDialogUtil.showLoading(message: '加载中...');
```

**现在您的项目拥有了强大的GetX工具类，可以轻松实现各种用户交互功能！** 🎉
