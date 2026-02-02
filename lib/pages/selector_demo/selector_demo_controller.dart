import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import 'models/province_model.dart';

/// 选择器 UI 组件演示控制器
class SelectorDemoController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    _loadProvinceData();
  }

  /// 加载省市区数据
  Future<void> _loadProvinceData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/province.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      provinces.assignAll(
        jsonList.map((e) => ProvinceModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      showError('加载省市区数据失败：$e');
    }
  }
  /// 选中的日期
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  /// 选中的时间
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  /// 选中的日期范围
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);

  /// 选中的日期和时间（同时选择）
  final Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);

  /// 选中的省市区信息
  final Rx<SelectedRegion?> selectedRegion = Rx<SelectedRegion?>(null);

  /// 省份列表
  final RxList<ProvinceModel> provinces = <ProvinceModel>[].obs;

  /// 选中的星座
  final Rx<String?> selectedConstellation = Rx<String?>(null);

  /// 选中的颜色
  final Rx<Color?> selectedColor = Rx<Color?>(null);

  /// 十二星座列表
  static const List<String> constellations = [
    '白羊座',
    '金牛座',
    '双子座',
    '巨蟹座',
    '狮子座',
    '处女座',
    '天秤座',
    '天蝎座',
    '射手座',
    '摩羯座',
    '水瓶座',
    '双鱼座',
  ];

  /// 选中的文件列表
  final RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;

  /// 选择日期
  Future<void> pickDate(BuildContext context) async {
    try {
      final now = DateTime.now();
      final result = await showDatePicker(
        context: context,
        initialDate: selectedDate.value ?? now,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 5),
      );
      if (result != null) {
        selectedDate.value = result;
        showSuccess('已选择日期：${_formatDate(result)}');
      }
    } catch (e) {
      showError('选择日期时出错：$e');
    }
  }

  /// 选择时间
  Future<void> pickTime(BuildContext context) async {
    try {
      final now = TimeOfDay.now();
      final result = await showTimePicker(
        context: context,
        initialTime: selectedTime.value ?? now,
      );
      if (result != null) {
        selectedTime.value = result;
        showSuccess('已选择时间：${_formatTime(result)}');
      }
    } catch (e) {
      showError('选择时间时出错：$e');
    }
  }

  /// 选择日期范围
  Future<void> pickDateRange(BuildContext context) async {
    try {
      final now = DateTime.now();
      final initialRange = selectedDateRange.value ??
          DateTimeRange(
            start: now,
            end: now.add(const Duration(days: 7)),
          );
      final result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 5),
        initialDateRange: initialRange,
      );
      if (result != null) {
        selectedDateRange.value = result;
        showSuccess(
          '已选择日期范围：${_formatDate(result.start)} ~ ${_formatDate(result.end)}',
        );
      }
    } catch (e) {
      showError('选择日期范围时出错：$e');
    }
  }

  /// 选择单个文件
  Future<void> pickSingleFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedFiles.assignAll(result.files);
        showSuccess('已选择文件：${result.files.first.name}');
      } else {
        showInfo('已取消选择文件');
      }
    } catch (e) {
      showError('选择文件时出错：$e');
    }
  }

  /// 选择多个文件
  Future<void> pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedFiles.assignAll(result.files);
        showSuccess('已选择 ${result.files.length} 个文件');
      } else {
        showInfo('已取消选择文件');
      }
    } catch (e) {
      showError('选择多个文件时出错：$e');
    }
  }

  /// 清空选择结果
  void clearSelections() {
    selectedDate.value = null;
    selectedTime.value = null;
    selectedDateRange.value = null;
    selectedDateTime.value = null;
    selectedRegion.value = null;
    selectedConstellation.value = null;
    selectedColor.value = null;
    selectedFiles.clear();
    showInfo('已清空所有选择结果');
  }

  /// 格式化省市区显示
  String formatRegionValue() {
    final value = selectedRegion.value;
    return value != null ? value.fullAddress : '未选择';
  }

  /// 格式化星座显示
  String formatConstellationValue() {
    return selectedConstellation.value ?? '未选择';
  }

  /// 格式化颜色显示
  String formatColorValue() {
    final color = selectedColor.value;
    if (color == null) return '未选择';
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String formatDateRange(DateTimeRange? range) {
    if (range == null) return '未选择';
    return '${_formatDate(range.start)} ~ ${_formatDate(range.end)}';
  }

  String formatDateValue() {
    final value = selectedDate.value;
    return value != null ? _formatDate(value) : '未选择';
  }

  String formatTimeValue() {
    final value = selectedTime.value;
    return value != null ? _formatTime(value) : '未选择';
  }

  String formatDateTimeValue() {
    final value = selectedDateTime.value;
    if (value == null) return '未选择';
    return '${_formatDate(value)} ${_formatTime(TimeOfDay.fromDateTime(value))}';
  }

  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    if (mb < 1024) {
      return '${mb.toStringAsFixed(2)} MB';
    }
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(2)} GB';
  }
}

