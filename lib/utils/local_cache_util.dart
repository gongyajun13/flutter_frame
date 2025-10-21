import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地数据缓存工具类
/// 基于SharedPreferences实现，支持各种数据类型的存储
class LocalCacheUtil {
  // 私有构造函数，防止实例化
  LocalCacheUtil._();

  static SharedPreferences? _prefs;

  /// 初始化SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 确保SharedPreferences已初始化
  static Future<SharedPreferences> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== 基本数据类型存储 ====================

  /// 存储字符串
  static Future<bool> setString(String key, String value) async {
    final prefs = await _ensureInitialized();
    return prefs.setString(key, value);
  }

  /// 存储整数
  static Future<bool> setInt(String key, int value) async {
    final prefs = await _ensureInitialized();
    return prefs.setInt(key, value);
  }

  /// 存储双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await _ensureInitialized();
    return prefs.setDouble(key, value);
  }

  /// 存储布尔值
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _ensureInitialized();
    return prefs.setBool(key, value);
  }

  /// 存储字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _ensureInitialized();
    return prefs.setStringList(key, value);
  }

  // ==================== 复杂数据类型存储 ====================

  /// 存储Map对象（转换为JSON字符串）
  static Future<bool> setMap(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('存储Map失败: $e');
      return false;
    }
  }

  /// 存储List对象（转换为JSON字符串）
  static Future<bool> setList(String key, List<dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('存储List失败: $e');
      return false;
    }
  }

  /// 存储自定义对象（转换为JSON字符串）
  static Future<bool> setObject<T>(String key, T value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('存储对象失败: $e');
      return false;
    }
  }

  /// 存储DateTime对象
  static Future<bool> setDateTime(String key, DateTime value) async {
    return await setString(key, value.toIso8601String());
  }

  /// 存储Duration对象
  static Future<bool> setDuration(String key, Duration value) async {
    return await setInt(key, value.inMilliseconds);
  }

  // ==================== 数据读取方法 ====================

  /// 读取字符串
  static Future<String?> getString(String key, {String? defaultValue}) async {
    final prefs = await _ensureInitialized();
    return prefs.getString(key) ?? defaultValue;
  }

  /// 读取整数
  static Future<int?> getInt(String key, {int? defaultValue}) async {
    final prefs = await _ensureInitialized();
    return prefs.getInt(key) ?? defaultValue;
  }

  /// 读取双精度浮点数
  static Future<double?> getDouble(String key, {double? defaultValue}) async {
    final prefs = await _ensureInitialized();
    return prefs.getDouble(key) ?? defaultValue;
  }

  /// 读取布尔值
  static Future<bool?> getBool(String key, {bool? defaultValue}) async {
    final prefs = await _ensureInitialized();
    return prefs.getBool(key) ?? defaultValue;
  }

  /// 读取字符串列表
  static Future<List<String>?> getStringList(String key, {List<String>? defaultValue}) async {
    final prefs = await _ensureInitialized();
    return prefs.getStringList(key) ?? defaultValue;
  }

  /// 读取Map对象
  static Future<Map<String, dynamic>?> getMap(String key, {Map<String, dynamic>? defaultValue}) async {
    try {
      final jsonString = await getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return defaultValue;
    } catch (e) {
      print('读取Map失败: $e');
      return defaultValue;
    }
  }

  /// 读取List对象
  static Future<List<dynamic>?> getList(String key, {List<dynamic>? defaultValue}) async {
    try {
      final jsonString = await getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as List<dynamic>;
      }
      return defaultValue;
    } catch (e) {
      print('读取List失败: $e');
      return defaultValue;
    }
  }

  /// 读取自定义对象
  static Future<T?> getObject<T>(String key, {T? defaultValue}) async {
    try {
      final jsonString = await getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as T;
      }
      return defaultValue;
    } catch (e) {
      print('读取对象失败: $e');
      return defaultValue;
    }
  }

  /// 读取DateTime对象
  static Future<DateTime?> getDateTime(String key, {DateTime? defaultValue}) async {
    try {
      final dateString = await getString(key);
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
      return defaultValue;
    } catch (e) {
      print('读取DateTime失败: $e');
      return defaultValue;
    }
  }

  /// 读取Duration对象
  static Future<Duration?> getDuration(String key, {Duration? defaultValue}) async {
    try {
      final milliseconds = await getInt(key);
      if (milliseconds != null) {
        return Duration(milliseconds: milliseconds);
      }
      return defaultValue;
    } catch (e) {
      print('读取Duration失败: $e');
      return defaultValue;
    }
  }

  // ==================== 数据删除方法 ====================

  /// 删除指定key的数据
  static Future<bool> remove(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.remove(key);
  }

  /// 删除多个key的数据
  static Future<bool> removeKeys(List<String> keys) async {
    final prefs = await _ensureInitialized();
    bool success = true;
    for (String key in keys) {
      success = success && await prefs.remove(key);
    }
    return success;
  }

  /// 清空所有数据
  static Future<bool> clear() async {
    final prefs = await _ensureInitialized();
    return prefs.clear();
  }

  // ==================== 批量操作方法 ====================

  /// 批量存储数据
  static Future<bool> setBatch(Map<String, dynamic> data) async {
    final prefs = await _ensureInitialized();
    bool success = true;
    
    for (String key in data.keys) {
      final value = data[key];
      bool result = false;
      
      if (value is String) {
        result = await prefs.setString(key, value);
      } else if (value is int) {
        result = await prefs.setInt(key, value);
      } else if (value is double) {
        result = await prefs.setDouble(key, value);
      } else if (value is bool) {
        result = await prefs.setBool(key, value);
      } else if (value is List<String>) {
        result = await prefs.setStringList(key, value);
      } else if (value is Map || value is List) {
        try {
          final jsonString = jsonEncode(value);
          result = await prefs.setString(key, jsonString);
        } catch (e) {
          print('批量存储复杂对象失败: $e');
          result = false;
        }
      } else {
        print('不支持的数据类型: ${value.runtimeType}');
        result = false;
      }
      
      success = success && result;
    }
    
    return success;
  }

  /// 批量读取数据
  static Future<Map<String, dynamic>> getBatch(List<String> keys) async {
    final prefs = await _ensureInitialized();
    Map<String, dynamic> result = {};
    
    for (String key in keys) {
      if (prefs.containsKey(key)) {
        final value = prefs.get(key);
        result[key] = value;
      }
    }
    
    return result;
  }

  // ==================== 工具方法 ====================

  /// 检查key是否存在
  static Future<bool> containsKey(String key) async {
    final prefs = await _ensureInitialized();
    return prefs.containsKey(key);
  }

  /// 获取所有key
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _ensureInitialized();
    return prefs.getKeys();
  }

  /// 获取存储的数据大小（估算）
  static Future<int> getStorageSize() async {
    final prefs = await _ensureInitialized();
    int size = 0;
    
    for (String key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value is String) {
        size += value.length * 2; // UTF-16编码，每个字符2字节
      } else if (value is List<String>) {
        size += value.join().length * 2;
      } else {
        size += 8; // 其他类型估算为8字节
      }
    }
    
    return size;
  }

  /// 获取存储统计信息
  static Future<Map<String, dynamic>> getStorageInfo() async {
    final prefs = await _ensureInitialized();
    final keys = prefs.getKeys();
    
    Map<String, int> typeCount = {};
    for (String key in keys) {
      final value = prefs.get(key);
      final type = value.runtimeType.toString();
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }
    
    return {
      'totalKeys': keys.length,
      'storageSize': await getStorageSize(),
      'typeCount': typeCount,
    };
  }

  // ==================== 高级功能 ====================

  /// 存储带过期时间的数据
  static Future<bool> setWithExpiry(String key, dynamic value, Duration expiry) async {
    final expiryTime = DateTime.now().add(expiry);
    final data = {
      'value': value,
      'expiry': expiryTime.toIso8601String(),
    };
    
    return await setObject(key, data);
  }

  /// 读取带过期时间的数据
  static Future<T?> getWithExpiry<T>(String key, {T? defaultValue}) async {
    try {
      final data = await getObject<Map<String, dynamic>>(key);
      if (data == null) return defaultValue;
      
      final expiryString = data['expiry'] as String?;
      if (expiryString == null) return defaultValue;
      
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        // 数据已过期，删除
        await remove(key);
        return defaultValue;
      }
      
      return data['value'] as T?;
    } catch (e) {
      print('读取带过期时间的数据失败: $e');
      return defaultValue;
    }
  }

  /// 清理过期数据
  static Future<int> cleanExpiredData() async {
    final prefs = await _ensureInitialized();
    int cleanedCount = 0;
    
    for (String key in prefs.getKeys()) {
      try {
        final value = prefs.get(key);
        if (value is String) {
          // 尝试解析为带过期时间的数据
          final data = jsonDecode(value) as Map<String, dynamic>;
          if (data.containsKey('expiry')) {
            final expiryString = data['expiry'] as String;
            final expiry = DateTime.parse(expiryString);
            if (DateTime.now().isAfter(expiry)) {
              await prefs.remove(key);
              cleanedCount++;
            }
          }
        }
      } catch (e) {
        // 不是带过期时间的数据，跳过
        continue;
      }
    }
    
    return cleanedCount;
  }

  /// 数据迁移（从旧key迁移到新key）
  static Future<bool> migrateData(String oldKey, String newKey, {bool removeOld = true}) async {
    try {
      final prefs = await _ensureInitialized();
      final value = prefs.get(oldKey);
      if (value == null) return false;
      
      bool success = false;
      if (value is String) {
        success = await setString(newKey, value);
      } else if (value is int) {
        success = await setInt(newKey, value);
      } else if (value is double) {
        success = await setDouble(newKey, value);
      } else if (value is bool) {
        success = await setBool(newKey, value);
      } else if (value is List<String>) {
        success = await setStringList(newKey, value);
      }
      
      if (success && removeOld) {
        await remove(oldKey);
      }
      
      return success;
    } catch (e) {
      print('数据迁移失败: $e');
      return false;
    }
  }
}
