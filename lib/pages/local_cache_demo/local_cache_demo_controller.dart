import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../utils/local_cache_util.dart';
import '../../utils/getx_dialog_util.dart';

/// 本地缓存演示控制器
class LocalCacheDemoController extends BaseController {
  // 存储信息（响应式）
  final storageInfo = <String, dynamic>{}.obs;

  @override
  void onReady() {
    super.onReady();
    loadStorageInfo();
  }

  /// 加载存储信息
  Future<void> loadStorageInfo() async {
    final info = await LocalCacheUtil.getStorageInfo();
    storageInfo.value = info;
  }

  // ==================== 基本数据类型操作 ====================

  /// 测试字符串操作
  Future<void> testStringOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_string';
        const value = 'Hello, Local Cache!';
        
        await LocalCacheUtil.setString(key, value);
        final result = await LocalCacheUtil.getString(key);
        
        showSuccess('字符串存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试整数操作
  Future<void> testIntOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_int';
        const value = 12345;
        
        await LocalCacheUtil.setInt(key, value);
        final result = await LocalCacheUtil.getInt(key);
        
        showSuccess('整数存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试浮点数操作
  Future<void> testDoubleOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_double';
        const value = 3.14159;
        
        await LocalCacheUtil.setDouble(key, value);
        final result = await LocalCacheUtil.getDouble(key);
        
        showSuccess('浮点数存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试布尔值操作
  Future<void> testBoolOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_bool';
        const value = true;
        
        await LocalCacheUtil.setBool(key, value);
        final result = await LocalCacheUtil.getBool(key);
        
        showSuccess('布尔值存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试字符串列表操作
  Future<void> testStringListOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_string_list';
        const value = ['Apple', 'Banana', 'Orange'];
        
        await LocalCacheUtil.setStringList(key, value);
        final result = await LocalCacheUtil.getStringList(key);
        
        showSuccess('字符串列表存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  // ==================== 复杂数据类型操作 ====================

  /// 测试Map操作
  Future<void> testMapOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_map';
        const value = {'name': '张三', 'age': 25, 'city': '北京'};
        
        await LocalCacheUtil.setMap(key, value);
        final result = await LocalCacheUtil.getMap(key);
        
        showSuccess('Map对象存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试List操作
  Future<void> testListOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_list';
        const value = [1, 2, 3, 4, 5];
        
        await LocalCacheUtil.setList(key, value);
        final result = await LocalCacheUtil.getList(key);
        
        showSuccess('List对象存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试DateTime操作
  Future<void> testDateTimeOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_datetime';
        final value = DateTime.now();
        
        await LocalCacheUtil.setDateTime(key, value);
        final result = await LocalCacheUtil.getDateTime(key);
        
        showSuccess('DateTime存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试Duration操作
  Future<void> testDurationOperation() async {
    await executeAsync(
      action: () async {
        const key = 'test_duration';
        const value = Duration(hours: 1, minutes: 30);
        
        await LocalCacheUtil.setDuration(key, value);
        final result = await LocalCacheUtil.getDuration(key);
        
        showSuccess('Duration存储成功\nKey: $key\nValue: $result');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  // ==================== 批量操作 ====================

  /// 测试批量存储
  Future<void> testBatchSet() async {
    await executeAsync(
      action: () async {
        final data = {
          'batch_string': '批量字符串',
          'batch_int': 999,
          'batch_double': 2.718,
          'batch_bool': false,
          'batch_list': ['批量', '数据', '测试'],
        };
        
        final success = await LocalCacheUtil.setBatch(data);
        
        showSuccess('批量存储${success ? '成功' : '失败'}\n存储了 ${data.length} 个数据');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试批量读取
  Future<void> testBatchGet() async {
    await executeAsync(
      action: () async {
        final keys = ['batch_string', 'batch_int', 'batch_double', 'batch_bool', 'batch_list'];
        final result = await LocalCacheUtil.getBatch(keys);
        
        showInfo('批量读取结果：\n${result.toString()}');
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试批量删除
  Future<void> testBatchRemove() async {
    await executeAsync(
      action: () async {
        final keys = ['batch_string', 'batch_int', 'batch_double'];
        final success = await LocalCacheUtil.removeKeys(keys);
        
        showWarning('批量删除${success ? '成功' : '失败'}\n删除了 ${keys.length} 个数据');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  // ==================== 高级功能 ====================

  /// 测试带过期时间的数据
  Future<void> testExpiryData() async {
    await executeAsync(
      action: () async {
        const key = 'expiry_data';
        const value = '这个数据将在5秒后过期';
        const expiry = Duration(seconds: 5);
        
        final success = await LocalCacheUtil.setWithExpiry(key, value, expiry);
        
        showSuccess('带过期时间的数据存储${success ? '成功' : '失败'}\n数据将在5秒后过期');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试读取带过期时间的数据
  Future<void> testGetExpiryData() async {
    await executeAsync(
      action: () async {
        const key = 'expiry_data';
        final result = await LocalCacheUtil.getWithExpiry<String>(key);
        
        showInfo('读取过期数据结果：\n${result ?? '数据不存在或已过期'}');
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试清理过期数据
  Future<void> testCleanExpiredData() async {
    await executeAsync(
      action: () async {
        final cleanedCount = await LocalCacheUtil.cleanExpiredData();
        
        showWarning('清理过期数据完成\n清理了 $cleanedCount 个过期数据');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试数据迁移
  Future<void> testDataMigration() async {
    await executeAsync(
      action: () async {
        const oldKey = 'test_string';
        const newKey = 'migrated_string';
        
        final success = await LocalCacheUtil.migrateData(oldKey, newKey);
        
        showInfo('数据迁移${success ? '成功' : '失败'}\n从 $oldKey 迁移到 $newKey');
        await loadStorageInfo();
        return null;
      },
      showLoading: false,
    );
  }

  // ==================== 工具方法 ====================

  /// 测试检查键是否存在
  Future<void> testContainsKey() async {
    await executeAsync(
      action: () async {
        const key = 'test_string';
        final exists = await LocalCacheUtil.containsKey(key);
        
        showInfo('键 "$key" ${exists ? '存在' : '不存在'}');
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试获取所有键
  Future<void> testGetAllKeys() async {
    await executeAsync(
      action: () async {
        final keys = await LocalCacheUtil.getAllKeys();
        
        showInfo('所有键：\n${keys.join(', ')}');
        return null;
      },
      showLoading: false,
    );
  }

  /// 测试清空所有数据
  void testClearAll() {
    DialogUtil.showConfirm(
      title: '确认清空',
      message: '确定要清空所有本地缓存数据吗？此操作不可恢复！',
      confirmText: '确定清空',
      cancelText: '取消',
      confirmColor: const Color(0xFFD32F2F),
      onConfirm: () async {
        await executeAsync(
          action: () async {
            final success = await LocalCacheUtil.clear();
            showSuccess('清空所有数据${success ? '成功' : '失败'}');
            await loadStorageInfo();
            return null;
          },
          showLoading: false,
        );
      },
    );
  }
}
