import 'package:flutter/material.dart';
import '../pixelize_result_controller.dart';

/// 工具类型
enum ToolType {
  /// 单选工具（编辑工具：查看、绘画、橡皮擦、填充等）
  singleSelect,
  /// 多选工具（其他工具：方形、网格、代码、编号、参考）
  multiSelect,
  /// 即时动作工具（放大、缩小）
  immediateAction,
  /// 弹窗工具（旋转）
  popupAction,
}

/// 工具模式枚举
enum ToolMode {
  // 编辑工具（单选）
  /// 绘画模式
  draw(0),
  /// 橡皮擦模式
  eraser(1),
  /// 查看模式
  view(2),
  /// 填充模式
  fill(3),
  /// 泛填充模式
  floodFill(4),
  /// 提取模式
  extract(5),
  /// 切换模式
  swap(6),
  /// 形状模式
  shape(7),
  /// 喷枪模式
  sprayGun(8),
  /// 文本模式
  text(9),
  /// 翻转模式
  flip(10),
  /// 旋转模式
  rotate(11),
  /// 选择模式
  select(12),

  // 其他工具（多选）
  /// 方形显示
  square(13),
  /// 网格显示
  grid(14),
  /// 代码显示
  code(15),
  /// 编号显示
  number(16),
  /// 参考图显示
  reference(17),
  // 新模式
  /// 点位线
  locationLine(18);

  final int value;
  const ToolMode(this.value);

  /// 从整数值获取工具模式
  static ToolMode? fromValue(int value) {
    try {
      return ToolMode.values.firstWhere((mode) => mode.value == value);
    } catch (e) {
      return null;
    }
  }

  /// 是否为编辑工具（单选）
  bool get isEditTool => value <= 12;

  /// 是否为其他工具（多选）
  bool get isOtherTool => value >= 13 && value <= 17;
}

/// 工具项数据类
class ToolItem {
  final String iconAsset;
  final String label;
  final ToolMode? toolMode;
  final VoidCallback? customOnTap;
  final bool Function()? isSelected;
  final ToolType type;

  ToolItem({
    required this.iconAsset,
    required this.label,
    this.toolMode,
    this.customOnTap,
    this.isSelected,
    this.type = ToolType.singleSelect,
  }) : assert(toolMode != null || customOnTap != null);

  VoidCallback getOnTap(PixelizeResultController controller) {
    if (customOnTap != null) return customOnTap!;

    switch (type) {
      case ToolType.singleSelect:
        return () => controller.switchToolMode(toolMode!);
      case ToolType.multiSelect:
        return () => controller.toggleOtherTool(toolMode!);
      case ToolType.immediateAction:
      case ToolType.popupAction:
        return () {};
    }
  }

  bool getIsSelected(PixelizeResultController controller) {
    if (isSelected != null) return isSelected!();

    switch (type) {
      case ToolType.singleSelect:
        return controller.currentToolMode.value == toolMode!;
      case ToolType.multiSelect:
        return controller.isOtherToolEnabled(toolMode!);
      case ToolType.immediateAction:
      case ToolType.popupAction:
        return false;
    }
  }
}
