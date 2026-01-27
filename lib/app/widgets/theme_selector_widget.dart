import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../models/theme_model.dart';
import 'live_theme_preview.dart';

/// 主题选择器主页面
class ThemeSelectorPage extends StatelessWidget {
  const ThemeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('主题设置'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.resetToDefault(),
                tooltip: '重置为默认主题',
              ),
            ],
          ),
          body: Stack(
            children: [
              const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemeModeSelector(),
                    SizedBox(height: 24),
                    PresetThemesSection(),
                    SizedBox(height: 24),
                    CustomThemesSection(),
                    SizedBox(height: 24),
                    ThemeHistorySection(),
                    SizedBox(height: 24),
                    RealTimeThemePreview(),
                  ],
                ),
              ),
              // 主题切换指示器
              const ThemeChangeIndicator(),
            ],
          ),
        );
      },
    );
  }
}

/// 主题模式选择器（浅色/深色/跟随系统）
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '主题模式',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeOption(
                        context,
                        controller,
                        ThemeMode.light,
                        Icons.light_mode,
                        '浅色',
                        '使用浅色主题',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeOption(
                        context,
                        controller,
                        ThemeMode.dark,
                        Icons.dark_mode,
                        '深色',
                        '使用深色主题',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeOption(
                        context,
                        controller,
                        ThemeMode.system,
                        Icons.brightness_auto,
                        '跟随系统',
                        '跟随系统设置',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeOption(
    BuildContext context,
    ThemeController controller,
    ThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = controller.themeMode.value == mode;
    
    return GestureDetector(
      onTap: () async {
        await controller.switchThemeMode(mode);
        // 显示切换成功提示
        controller.showSuccess('已切换到$title模式');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 预设主题区域
class PresetThemesSection extends StatelessWidget {
  const PresetThemesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '预设主题',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.availableThemes.length,
                  itemBuilder: (context, index) {
                    final theme = controller.availableThemes[index];
                    return ThemePreviewCard(
                      theme: theme,
                      isSelected: controller.currentTheme.value == theme,
                      onTap: () => controller.switchToTheme(theme),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 自定义主题区域
class CustomThemesSection extends StatefulWidget {
  const CustomThemesSection({super.key});

  @override
  State<CustomThemesSection> createState() => _CustomThemesSectionState();
}

class _CustomThemesSectionState extends State<CustomThemesSection> {
  List<AppTheme> _customThemes = [];

  @override
  void initState() {
    super.initState();
    _loadCustomThemes();
  }

  Future<void> _loadCustomThemes() async {
    final controller = Get.find<ThemeController>();
    final customThemes = await controller.themeService.getCustomThemes();
    setState(() {
      _customThemes = customThemes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '自定义主题',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateCustomThemeDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('创建'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_customThemes.isEmpty)
                  const Text('暂无自定义主题')
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _customThemes.length,
                    itemBuilder: (context, index) {
                      final theme = _customThemes[index];
                      return ThemePreviewCard(
                        theme: theme,
                        isSelected: controller.currentTheme.value == theme,
                        onTap: () => controller.switchToTheme(theme),
                        onDelete: () => _deleteCustomTheme(theme),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateCustomThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateCustomThemeDialog(
        onThemeCreated: () async {
          await _loadCustomThemes();
          // 强制刷新UI
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  Future<void> _deleteCustomTheme(AppTheme theme) async {
    final controller = Get.find<ThemeController>();
    await controller.themeService.deleteCustomTheme(theme.id);
    await _loadCustomThemes();
    // 强制刷新UI
    if (mounted) {
      setState(() {});
    }
    controller.showSuccess('自定义主题已删除');
  }
}

/// 主题历史记录区域
class ThemeHistorySection extends StatefulWidget {
  const ThemeHistorySection({super.key});

  @override
  State<ThemeHistorySection> createState() => _ThemeHistorySectionState();
}

class _ThemeHistorySectionState extends State<ThemeHistorySection> {
  List<AppTheme> _themeHistory = [];

  @override
  void initState() {
    super.initState();
    _loadThemeHistory();
  }

  Future<void> _loadThemeHistory() async {
    final controller = Get.find<ThemeController>();
    final history = await controller.themeService.getThemeHistory();
    setState(() {
      _themeHistory = history.take(6).toList(); // 只显示最近6个
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '最近使用',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (_themeHistory.isNotEmpty)
                      TextButton(
                        onPressed: () => _clearHistory(),
                        child: const Text('清除历史'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_themeHistory.isEmpty)
                  const Text('暂无历史记录')
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: _themeHistory.length,
                    itemBuilder: (context, index) {
                      final theme = _themeHistory[index];
                      return ThemePreviewCard(
                        theme: theme,
                        isSelected: controller.currentTheme.value == theme,
                        onTap: () => controller.switchToTheme(theme),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _clearHistory() async {
    final controller = Get.find<ThemeController>();
    await controller.themeService.clearAllThemeSettings();
    await _loadThemeHistory();
    controller.showSuccess('历史记录已清除');
  }
}

/// 主题预览区域
class ThemePreviewSection extends StatelessWidget {
  const ThemePreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '预览效果',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ThemePreviewWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 主题预览卡片
class ThemePreviewCard extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        // 显示切换成功提示
        Get.find<ThemeController>().showSuccess('已切换到${theme.name}');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          border: Border.all(
            color: isSelected 
                ? theme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 颜色预览条和操作按钮
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  if (onDelete != null) const SizedBox(width: 8),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  theme.name,
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                theme.brightness == Brightness.dark ? '深色' : '浅色',
                style: TextStyle(
                  color: theme.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题预览组件
class ThemePreviewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: controller.currentTheme.value.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.currentTheme.value.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // 模拟AppBar
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: controller.currentTheme.value.surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '预览标题',
                    style: TextStyle(
                      color: controller.currentTheme.value.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 模拟按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('主要按钮'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('次要按钮'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 模拟卡片
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.currentTheme.value.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '这是一个预览卡片，展示当前主题的视觉效果。',
                  style: TextStyle(
                    color: controller.currentTheme.value.textColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 创建自定义主题对话框
class CreateCustomThemeDialog extends StatefulWidget {
  final VoidCallback? onThemeCreated;
  
  const CreateCustomThemeDialog({
    super.key,
    this.onThemeCreated,
  });

  @override
  State<CreateCustomThemeDialog> createState() => _CreateCustomThemeDialogState();
}

class _CreateCustomThemeDialogState extends State<CreateCustomThemeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.blueAccent;
  Brightness _brightness = Brightness.light;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建自定义主题'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '主题名称',
                hintText: '请输入主题名称',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入主题名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('主色调'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showColorPicker(_primaryColor, (color) {
                          setState(() {
                            _primaryColor = color;
                          });
                        }),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('辅助色'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showColorPicker(_secondaryColor, (color) {
                          setState(() {
                            _secondaryColor = color;
                          });
                        }),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _secondaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('主题类型'),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<Brightness>(
                    segments: const [
                      ButtonSegment<Brightness>(
                        value: Brightness.light,
                        label: Text('浅色'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment<Brightness>(
                        value: Brightness.dark,
                        label: Text('深色'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {_brightness},
                    onSelectionChanged: (Set<Brightness> selection) {
                      setState(() {
                        _brightness = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _createTheme,
          child: const Text('创建'),
        ),
      ],
    );
  }

  void _showColorPicker(Color currentColor, ValueChanged<Color> onColorChanged) {
    final ValueNotifier<Color> selectedColorNotifier = ValueNotifier<Color>(currentColor);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: ValueListenableBuilder<Color>(
            valueListenable: selectedColorNotifier,
            builder: (context, selectedColor, child) {
              return ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  selectedColorNotifier.value = color;
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              onColorChanged(selectedColorNotifier.value);
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _createTheme() async {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<ThemeController>();
      await controller.createCustomTheme(
        name: _nameController.text.trim(),
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        brightness: _brightness,
      );
      Navigator.of(context).pop();
      widget.onThemeCreated?.call();
    }
  }
}

/// 颜色选择器
class ColorPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color == pickerColor;
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
