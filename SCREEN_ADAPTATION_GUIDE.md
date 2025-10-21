# 📱 Flutter ScreenUtil 屏幕适配指南

## 🎯 概述

本项目已完整集成 `flutter_screenutil` 屏幕适配功能，支持多设备尺寸的自动适配，确保应用在不同屏幕尺寸的设备上都能完美显示。

## 🚀 快速开始

### 1. 初始化配置

在 `main.dart` 中已经完成初始化：

```dart
ScreenUtilInit(
  designSize: const Size(375, 812), // 设计稿尺寸 (iPhone X)
  minTextAdapt: true, // 是否根据宽度/高度中的最小值适配文字
  splitScreenMode: true, // 支持分屏尺寸
  builder: (context, child) {
    return GetMaterialApp(
      // ... 应用配置
    );
  },
)
```

### 2. 基础使用

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 字体大小适配
Text('Hello', style: TextStyle(fontSize: 16.sp))

// 宽度适配
Container(width: 100.w)

// 高度适配
Container(height: 50.h)

// 圆角适配
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8.r)
  )
)

// 边距适配
Padding(padding: EdgeInsets.all(16.w))
```

## 🛠️ 适配工具类

### ScreenUtilHelper 工具类

提供了统一的适配方法和常用尺寸：

```dart
import '../utils/screen_util_helper.dart';

// 字体大小
Text('标题', style: TextStyle(fontSize: ScreenUtilHelper.FontSizes.xl))

// 间距
SizedBox(height: ScreenUtilHelper.HeightSpacing.lg)

// 圆角
BorderRadius.circular(ScreenUtilHelper.Radius.lg)

// 按钮高度
SizedBox(height: ScreenUtilHelper.ButtonHeight.large)

// 图标大小
Icon(Icons.home, size: ScreenUtilHelper.IconSize.lg)
```

### 常用尺寸常量

#### 字体大小
- `FontSizes.xs` - 10sp
- `FontSizes.sm` - 12sp
- `FontSizes.base` - 14sp
- `FontSizes.lg` - 16sp
- `FontSizes.xl` - 18sp
- `FontSizes.xxl` - 20sp
- `FontSizes.xxxl` - 24sp
- `FontSizes.huge` - 28sp
- `FontSizes.giant` - 32sp

#### 间距
- `Spacing.xs` - 4px
- `Spacing.sm` - 8px
- `Spacing.base` - 12px
- `Spacing.lg` - 16px
- `Spacing.xl` - 20px
- `Spacing.xxl` - 24px
- `Spacing.xxxl` - 32px
- `Spacing.huge` - 40px
- `Spacing.giant` - 48px

#### 高度间距
- `HeightSpacing.xs` - 4px
- `HeightSpacing.sm` - 8px
- `HeightSpacing.base` - 12px
- `HeightSpacing.lg` - 16px
- `HeightSpacing.xl` - 20px
- `HeightSpacing.xxl` - 24px
- `HeightSpacing.xxxl` - 32px
- `HeightSpacing.huge` - 40px
- `HeightSpacing.giant` - 48px

#### 圆角半径
- `Radius.xs` - 4px
- `Radius.sm` - 6px
- `Radius.base` - 8px
- `Radius.lg` - 12px
- `Radius.xl` - 16px
- `Radius.xxl` - 20px
- `Radius.xxxl` - 24px
- `Radius.huge` - 32px
- `Radius.giant` - 40px

#### 按钮高度
- `ButtonHeight.small` - 32px
- `ButtonHeight.medium` - 40px
- `ButtonHeight.large` - 48px
- `ButtonHeight.xlarge` - 56px

#### 图标大小
- `IconSize.xs` - 12px
- `IconSize.sm` - 16px
- `IconSize.base` - 20px
- `IconSize.lg` - 24px
- `IconSize.xl` - 28px
- `IconSize.xxl` - 32px
- `IconSize.xxxl` - 36px
- `IconSize.huge` - 40px
- `IconSize.giant` - 48px

## 📐 设计稿规范

### 设计稿尺寸
- **基准尺寸**: 375 × 812 (iPhone X)
- **设计单位**: px
- **适配方式**: 宽度适配为主，高度适配为辅

### 设计建议
1. **字体大小**: 最小 12sp，推荐 14-18sp
2. **按钮高度**: 最小 44px，推荐 48-56px
3. **间距**: 使用 4px 的倍数 (4, 8, 12, 16, 20, 24, 32...)
4. **圆角**: 使用 4px 的倍数 (4, 8, 12, 16, 20, 24...)

## 🔧 高级功能

### 1. 响应式布局

```dart
// 根据屏幕大小显示不同布局
if (ScreenUtilHelper.isTablet) {
  // 平板布局
  return TabletLayout();
} else if (ScreenUtilHelper.isLargeScreen) {
  // 大屏手机布局
  return LargeScreenLayout();
} else if (ScreenUtilHelper.isSmallScreen) {
  // 小屏手机布局
  return SmallScreenLayout();
} else {
  // 标准手机布局
  return StandardLayout();
}
```

### 2. 屏幕信息获取

```dart
// 获取屏幕信息
final screenInfo = ScreenUtilHelper.getScreenInfo();
print('屏幕宽度: ${screenInfo['screenWidth']}');
print('屏幕高度: ${screenInfo['screenHeight']}');
print('像素密度: ${screenInfo['pixelRatio']}');

// 打印完整屏幕信息
ScreenUtilHelper.printScreenInfo();
```

### 3. 自定义适配方法

```dart
// 获取适配后的边距
EdgeInsets padding = ScreenUtilHelper.padding(
  horizontal: 20,
  vertical: 16,
);

// 获取适配后的间距
SizedBox spacing = ScreenUtilHelper.spacing(
  width: 12,
  height: 8,
);

// 获取适配后的容器尺寸
Size containerSize = ScreenUtilHelper.containerSize(
  width: 200,
  height: 100,
);

// 获取适配后的边框半径
BorderRadius borderRadius = ScreenUtilHelper.borderRadius(
  all: 12,
);

// 获取适配后的阴影
List<BoxShadow> shadows = ScreenUtilHelper.boxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
);
```

## 📱 设备适配

### 设备类型判断
```dart
// 小屏设备 (< 360px)
bool isSmall = ScreenUtilHelper.isSmallScreen;

// 大屏设备 (> 414px)
bool isLarge = ScreenUtilHelper.isLargeScreen;

// 平板设备 (> 768px)
bool isTablet = ScreenUtilHelper.isTablet;
```

### 适配比例
```dart
// 宽度比例
double widthRatio = ScreenUtilHelper.widthRatio;

// 高度比例
double heightRatio = ScreenUtilHelper.heightRatio;
```

## 🎨 实际应用示例

### 1. 卡片组件
```dart
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: ScreenUtilHelper.borderRadius(all: 12),
  ),
  child: Padding(
    padding: ScreenUtilHelper.padding(all: 16),
    child: Column(
      children: [
        Text(
          '标题',
          style: TextStyle(
            fontSize: ScreenUtilHelper.FontSizes.xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        ScreenUtilHelper.spacing(height: 12),
        Text(
          '内容',
          style: TextStyle(
            fontSize: ScreenUtilHelper.FontSizes.base,
          ),
        ),
      ],
    ),
  ),
)
```

### 2. 按钮组件
```dart
SizedBox(
  width: double.infinity,
  height: ScreenUtilHelper.ButtonHeight.large,
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: ScreenUtilHelper.borderRadius(all: 8),
      ),
    ),
    child: Text(
      '按钮',
      style: TextStyle(
        fontSize: ScreenUtilHelper.FontSizes.base,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

### 3. 列表项组件
```dart
ListTile(
  leading: Icon(
    Icons.home,
    size: ScreenUtilHelper.IconSize.lg,
  ),
  title: Text(
    '标题',
    style: TextStyle(
      fontSize: ScreenUtilHelper.FontSizes.lg,
      fontWeight: FontWeight.w600,
    ),
  ),
  subtitle: Text(
    '副标题',
    style: TextStyle(
      fontSize: ScreenUtilHelper.FontSizes.sm,
      color: Colors.grey.shade600,
    ),
  ),
  contentPadding: ScreenUtilHelper.padding(
    horizontal: 16,
    vertical: 8,
  ),
)
```

## 📊 演示页面

运行应用后，点击"屏幕适配演示"按钮可以体验：

1. **屏幕信息展示** - 显示当前设备的屏幕参数
2. **字体大小演示** - 展示不同字体大小的适配效果
3. **间距演示** - 展示不同间距的适配效果
4. **按钮演示** - 展示不同按钮高度的适配效果
5. **圆角演示** - 展示不同圆角半径的适配效果
6. **图标演示** - 展示不同图标大小的适配效果
7. **响应式布局** - 根据设备类型显示不同布局
8. **调试功能** - 打印屏幕信息到控制台

## ⚠️ 注意事项

### 1. 设计稿尺寸
- 确保设计稿尺寸与 `designSize` 一致
- 推荐使用 iPhone X (375×812) 作为基准尺寸

### 2. 字体适配
- 启用 `minTextAdapt: true` 确保文字在小屏设备上可读
- 最小字体大小建议 12sp

### 3. 分屏适配
- 启用 `splitScreenMode: true` 支持分屏模式
- 在分屏模式下确保布局仍然可用

### 4. 性能优化
- 避免在 build 方法中频繁调用适配方法
- 使用常量或静态变量存储常用尺寸

## 🔍 调试技巧

### 1. 打印屏幕信息
```dart
// 在控制台查看屏幕信息
ScreenUtilHelper.printScreenInfo();
```

### 2. 检查适配效果
- 在不同设备上测试应用
- 使用模拟器测试不同屏幕尺寸
- 检查文字是否过小或过大

### 3. 常见问题
- **文字过小**: 检查是否使用了 `.sp` 后缀
- **布局错乱**: 检查是否所有尺寸都使用了适配
- **按钮过小**: 确保按钮高度至少 44px

## 🎯 最佳实践

1. **统一使用工具类** - 使用 `ScreenUtilHelper` 而不是直接使用 `.sp`、`.w`、`.h`
2. **使用语义化常量** - 使用 `FontSizes.lg` 而不是 `16.sp`
3. **响应式设计** - 根据设备类型提供不同的布局
4. **测试多设备** - 在多种设备上测试适配效果
5. **保持一致性** - 使用统一的间距和字体大小规范

## 📈 适配效果

通过 ScreenUtil 适配，应用可以：
- ✅ 在不同屏幕尺寸上保持一致的视觉效果
- ✅ 自动适配字体大小，确保可读性
- ✅ 响应式布局，适配平板和手机
- ✅ 支持分屏模式
- ✅ 提供统一的开发体验

**现在您的应用已经完美支持多设备屏幕适配！** 🎉
