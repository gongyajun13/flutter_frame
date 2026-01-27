# AppDesignTokens 与主题系统集成说明

## 📋 概述

`AppDesignTokens` 现已与主题系统（`ThemeController`）集成，设计令牌的颜色值会根据当前选择的主题动态变化。

## 🎨 工作原理

### 1. 动态颜色获取

`AppDesignTokens` 的颜色属性现在是 **getter**，会从 `ThemeController` 获取当前主题的颜色：

```dart
// 主色调（从当前主题获取）
static Color get primaryColor => _currentTheme?.primaryColor ?? const Color(0xFF2196F3);

// 辅助色（从当前主题获取）
static Color get secondaryColor => _currentTheme?.secondaryColor ?? const Color(0xFF9C27B0);

// 背景色（从当前主题获取）
static Color get backgroundColor => _currentTheme?.backgroundColor ?? const Color(0xFFF5F5F5);

// 文字颜色（从当前主题获取）
static Color get textPrimary => _currentTheme?.textColor ?? const Color(0xFF212121);
```

### 2. 自动响应主题变化

当用户切换主题时，所有使用 `AppDesignTokens` 颜色的组件会自动更新：

```dart
// 在 GetBuilder 或 Obx 中使用
GetBuilder<ThemeController>(
  builder: (controller) {
    return Container(
      color: AppDesignTokens.primaryColor, // 自动使用当前主题的主色调
    );
  },
)
```

### 3. 回退机制

如果 `ThemeController` 未注册或主题不可用，`AppDesignTokens` 会使用默认颜色值，确保应用正常运行。

## 🔧 使用方式

### 方式 1：在响应式组件中使用（推荐）

```dart
// 使用 GetBuilder 包裹使用颜色的组件
GetBuilder<ThemeController>(
  builder: (controller) {
    return Container(
      color: AppDesignTokens.primaryColor,
      child: Text(
        '文本',
        style: TextStyle(color: AppDesignTokens.textPrimary),
      ),
    );
  },
)
```

### 方式 2：在 Obx 中使用

```dart
// 使用 Obx 包裹使用颜色的组件
Obx(() {
  final controller = Get.find<ThemeController>();
  return Container(
    color: AppDesignTokens.primaryColor,
    child: Text(
      '文本',
      style: TextStyle(color: AppDesignTokens.textPrimary),
    ),
  );
})
```

### 方式 3：在 BasePage 中使用

由于 `BasePage` 已经使用 `Obx` 包裹内容，可以直接使用：

```dart
class MyPage extends BaseScrollPage<MyController> {
  @override
  Widget buildScrollContent(BuildContext context) {
    return Container(
      color: AppDesignTokens.primaryColor, // 自动响应主题变化
      child: Text(
        '文本',
        style: TextStyle(color: AppDesignTokens.textPrimary),
      ),
    );
  }
}
```

## 📝 受影响的颜色属性

以下颜色属性现在会根据主题动态变化：

- ✅ `primaryColor` / `primaryLight` / `primaryDark`
- ✅ `secondaryColor` / `secondaryLight` / `secondaryDark`
- ✅ `successColor` / `successLight` / `successDark`
- ✅ `warningColor` / `warningLight` / `warningDark`
- ✅ `errorColor` / `errorLight` / `errorDark`
- ✅ `infoColor` / `infoLight` / `infoDark`
- ✅ `backgroundColor`
- ✅ `surfaceColor`
- ✅ `cardColor`
- ✅ `textPrimary` / `textSecondary` / `textDisabled` / `textHint`

以下属性保持固定值（不受主题影响）：

- ⚪ `grey50` ~ `grey900`（中性色）
- ⚪ 字体大小、间距、圆角等（非颜色属性）

## ⚠️ 注意事项

### 1. 响应式更新

由于 `AppDesignTokens` 的颜色是 getter，它们不会自动触发 UI 更新。你需要确保使用这些颜色的组件在响应式上下文中（`GetBuilder`、`Obx`、`BasePage` 等）。

### 2. 性能考虑

每次访问 `AppDesignTokens` 的颜色属性时，都会尝试获取 `ThemeController`。虽然这个操作很快，但建议：

- 在 `build` 方法中直接使用，不要缓存颜色值
- 使用 `GetBuilder<ThemeController>` 包裹需要响应主题变化的组件

### 3. 默认值

如果 `ThemeController` 未注册，`AppDesignTokens` 会使用默认颜色值，确保应用正常运行。

## 🎯 最佳实践

### 1. 使用 BasePage

继承 `BasePage` 或 `BaseScrollPage` 的页面会自动响应主题变化：

```dart
class MyPage extends BaseScrollPage<MyController> {
  @override
  Widget buildScrollContent(BuildContext context) {
    // 直接使用 AppDesignTokens，会自动响应主题变化
    return Container(
      color: AppDesignTokens.primaryColor,
    );
  }
}
```

### 2. 使用 AppCard 和 AppButton

`AppCard` 和 `AppButton` 已经使用 `AppDesignTokens`，会自动响应主题变化：

```dart
AppCard(
  child: Text('内容'),
)

AppButton.primary(
  text: '按钮',
  onPressed: () {},
)
```

### 3. 手动响应主题变化

如果需要在非响应式上下文中使用，可以手动监听主题变化：

```dart
GetBuilder<ThemeController>(
  builder: (controller) {
    return Container(
      color: AppDesignTokens.primaryColor,
    );
  },
)
```

## 🔄 迁移指南

如果你的代码中使用了 `AppDesignTokens` 的颜色，确保：

1. ✅ 在响应式上下文中使用（`GetBuilder`、`Obx`、`BasePage`）
2. ✅ 不要在 `initState` 或其他非响应式方法中缓存颜色值
3. ✅ 使用 `AppCard` 和 `AppButton` 等已集成的组件

## 📚 示例

### 示例 1：在 BasePage 中使用

```dart
class MyPage extends BaseScrollPage<MyController> {
  @override
  Widget buildScrollContent(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppDesignTokens.primaryColor,
          child: Text(
            '标题',
            style: TextStyle(
              color: AppDesignTokens.textPrimary,
              fontSize: AppDesignTokens.fontSize18,
            ),
          ),
        ),
        AppCard(
          child: Text('内容'),
        ),
      ],
    );
  }
}
```

### 示例 2：在自定义组件中使用

```dart
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppDesignTokens.surfaceColor,
            borderRadius: BorderRadius.circular(AppDesignTokens.radius12),
          ),
          child: Text(
            '文本',
            style: TextStyle(
              color: AppDesignTokens.textPrimary,
              fontSize: AppDesignTokens.fontSize16,
            ),
          ),
        );
      },
    );
  }
}
```

## 🎉 优势

1. **统一管理**：所有颜色值都从主题系统获取，保持一致性
2. **自动更新**：切换主题时，所有使用 `AppDesignTokens` 的组件自动更新
3. **向后兼容**：如果主题系统不可用，使用默认值，不影响现有功能
4. **易于维护**：颜色定义集中管理，修改主题即可影响整个应用
