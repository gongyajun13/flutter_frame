# 💾 本地数据缓存工具类使用指南

## 📋 概述

基于`shared_preferences`插件创建的本地数据缓存工具类，支持存储各种类型的数据，包括基本数据类型、复杂对象、带过期时间的数据等。

## 🎯 功能特点

### 1. 基本数据类型支持
- ✅ **字符串** - String类型数据
- ✅ **整数** - int类型数据
- ✅ **浮点数** - double类型数据
- ✅ **布尔值** - bool类型数据
- ✅ **字符串列表** - List<String>类型数据

### 2. 复杂数据类型支持
- ✅ **Map对象** - 自动JSON序列化/反序列化
- ✅ **List对象** - 自动JSON序列化/反序列化
- ✅ **自定义对象** - 支持任意可序列化对象
- ✅ **DateTime** - 日期时间对象
- ✅ **Duration** - 时间间隔对象

### 3. 高级功能
- ✅ **带过期时间的数据** - 自动过期清理
- ✅ **批量操作** - 批量存储、读取、删除
- ✅ **数据迁移** - 从旧key迁移到新key
- ✅ **存储统计** - 获取存储信息和使用情况

### 4. 工具方法
- ✅ **键存在检查** - 检查指定key是否存在
- ✅ **获取所有键** - 获取所有存储的key
- ✅ **存储大小计算** - 估算存储数据大小
- ✅ **过期数据清理** - 自动清理过期数据

## 🚀 使用方法

### 1. 初始化

```dart
import '../utils/local_cache_util.dart';

// 在应用启动时初始化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalCacheUtil.init();
  runApp(MyApp());
}
```

### 2. 基本数据类型操作

#### 字符串操作
```dart
// 存储字符串
await LocalCacheUtil.setString('username', '张三');

// 读取字符串
String? username = await LocalCacheUtil.getString('username');
String? email = await LocalCacheUtil.getString('email', defaultValue: '未设置');
```

#### 数值操作
```dart
// 存储整数
await LocalCacheUtil.setInt('age', 25);

// 存储浮点数
await LocalCacheUtil.setDouble('score', 95.5);

// 读取数值
int? age = await LocalCacheUtil.getInt('age');
double? score = await LocalCacheUtil.getDouble('score', defaultValue: 0.0);
```

#### 布尔值操作
```dart
// 存储布尔值
await LocalCacheUtil.setBool('isLogin', true);

// 读取布尔值
bool? isLogin = await LocalCacheUtil.getBool('isLogin', defaultValue: false);
```

#### 字符串列表操作
```dart
// 存储字符串列表
await LocalCacheUtil.setStringList('hobbies', ['读书', '游泳', '编程']);

// 读取字符串列表
List<String>? hobbies = await LocalCacheUtil.getStringList('hobbies');
```

### 3. 复杂数据类型操作

#### Map对象操作
```dart
// 存储Map对象
Map<String, dynamic> userInfo = {
  'name': '张三',
  'age': 25,
  'city': '北京',
  'hobbies': ['读书', '游泳'],
};

await LocalCacheUtil.setMap('user_info', userInfo);

// 读取Map对象
Map<String, dynamic>? userInfo = await LocalCacheUtil.getMap('user_info');
```

#### List对象操作
```dart
// 存储List对象
List<dynamic> numbers = [1, 2, 3, 4, 5];
await LocalCacheUtil.setList('numbers', numbers);

// 读取List对象
List<dynamic>? numbers = await LocalCacheUtil.getList('numbers');
```

#### 自定义对象操作
```dart
// 存储自定义对象
class User {
  final String name;
  final int age;
  
  User({required this.name, required this.age});
  
  Map<String, dynamic> toJson() => {'name': name, 'age': age};
  factory User.fromJson(Map<String, dynamic> json) => 
    User(name: json['name'], age: json['age']);
}

User user = User(name: '张三', age: 25);
await LocalCacheUtil.setObject('user', user.toJson());

// 读取自定义对象
Map<String, dynamic>? userData = await LocalCacheUtil.getObject<Map<String, dynamic>>('user');
if (userData != null) {
  User user = User.fromJson(userData);
}
```

#### DateTime和Duration操作
```dart
// 存储DateTime
DateTime now = DateTime.now();
await LocalCacheUtil.setDateTime('last_login', now);

// 存储Duration
Duration duration = Duration(hours: 2, minutes: 30);
await LocalCacheUtil.setDuration('session_timeout', duration);

// 读取DateTime和Duration
DateTime? lastLogin = await LocalCacheUtil.getDateTime('last_login');
Duration? timeout = await LocalCacheUtil.getDuration('session_timeout');
```

### 4. 批量操作

#### 批量存储
```dart
Map<String, dynamic> batchData = {
  'username': '张三',
  'age': 25,
  'isVip': true,
  'scores': [95, 87, 92],
};

bool success = await LocalCacheUtil.setBatch(batchData);
```

#### 批量读取
```dart
List<String> keys = ['username', 'age', 'isVip'];
Map<String, dynamic> data = await LocalCacheUtil.getBatch(keys);
```

#### 批量删除
```dart
List<String> keysToRemove = ['temp_data1', 'temp_data2', 'temp_data3'];
bool success = await LocalCacheUtil.removeKeys(keysToRemove);
```

### 5. 高级功能

#### 带过期时间的数据
```dart
// 存储带过期时间的数据（5分钟后过期）
await LocalCacheUtil.setWithExpiry(
  'temp_token', 
  'abc123', 
  Duration(minutes: 5)
);

// 读取带过期时间的数据
String? token = await LocalCacheUtil.getWithExpiry<String>('temp_token');
if (token == null) {
  print('数据不存在或已过期');
}
```

#### 数据迁移
```dart
// 从旧key迁移到新key
bool success = await LocalCacheUtil.migrateData(
  'old_user_id', 
  'new_user_id',
  removeOld: true  // 是否删除旧数据
);
```

#### 清理过期数据
```dart
// 清理所有过期数据
int cleanedCount = await LocalCacheUtil.cleanExpiredData();
print('清理了 $cleanedCount 个过期数据');
```

### 6. 工具方法

#### 检查键是否存在
```dart
bool exists = await LocalCacheUtil.containsKey('username');
```

#### 获取所有键
```dart
Set<String> allKeys = await LocalCacheUtil.getAllKeys();
```

#### 获取存储信息
```dart
Map<String, dynamic> info = await LocalCacheUtil.getStorageInfo();
print('总键数: ${info['totalKeys']}');
print('存储大小: ${info['storageSize']} 字节');
print('数据类型分布: ${info['typeCount']}');
```

#### 删除和清空
```dart
// 删除指定key
await LocalCacheUtil.remove('username');

// 清空所有数据
await LocalCacheUtil.clear();
```

## 📱 演示页面功能

### 1. 存储信息展示
- 总键数统计
- 存储大小计算
- 数据类型分布
- 实时更新显示

### 2. 基本数据类型测试
- 字符串存储和读取
- 整数存储和读取
- 浮点数存储和读取
- 布尔值存储和读取
- 字符串列表存储和读取

### 3. 复杂数据类型测试
- Map对象存储和读取
- List对象存储和读取
- DateTime存储和读取
- Duration存储和读取

### 4. 批量操作测试
- 批量存储数据
- 批量读取数据
- 批量删除数据

### 5. 高级功能测试
- 带过期时间的数据存储
- 带过期时间的数据读取
- 过期数据清理
- 数据迁移功能

### 6. 工具方法测试
- 键存在检查
- 获取所有键
- 清空所有数据
- 刷新存储信息

## 🎯 最佳实践

### 1. 初始化
```dart
// 在main函数中初始化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalCacheUtil.init();
  runApp(MyApp());
}
```

### 2. 错误处理
```dart
try {
  await LocalCacheUtil.setString('key', 'value');
} catch (e) {
  print('存储失败: $e');
}
```

### 3. 默认值使用
```dart
// 使用默认值避免null
String username = await LocalCacheUtil.getString('username') ?? '游客';
int age = await LocalCacheUtil.getInt('age') ?? 0;
bool isLogin = await LocalCacheUtil.getBool('isLogin') ?? false;
```

### 4. 批量操作优化
```dart
// 批量操作比单个操作更高效
Map<String, dynamic> data = {
  'key1': 'value1',
  'key2': 'value2',
  'key3': 'value3',
};
await LocalCacheUtil.setBatch(data);
```

### 5. 过期数据管理
```dart
// 定期清理过期数据
Timer.periodic(Duration(hours: 1), (timer) async {
  await LocalCacheUtil.cleanExpiredData();
});
```

## 🔧 高级用法

### 1. 用户偏好设置
```dart
class UserPreferences {
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications';
  
  static Future<void> setTheme(String theme) async {
    await LocalCacheUtil.setString(_themeKey, theme);
  }
  
  static Future<String> getTheme() async {
    return await LocalCacheUtil.getString(_themeKey) ?? 'light';
  }
  
  static Future<void> setLanguage(String language) async {
    await LocalCacheUtil.setString(_languageKey, language);
  }
  
  static Future<String> getLanguage() async {
    return await LocalCacheUtil.getString(_languageKey) ?? 'zh';
  }
  
  static Future<void> setNotifications(bool enabled) async {
    await LocalCacheUtil.setBool(_notificationsKey, enabled);
  }
  
  static Future<bool> getNotifications() async {
    return await LocalCacheUtil.getBool(_notificationsKey) ?? true;
  }
}
```

### 2. 缓存管理
```dart
class CacheManager {
  static const String _cachePrefix = 'cache_';
  static const Duration _defaultExpiry = Duration(hours: 24);
  
  static Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    final cacheKey = '$_cachePrefix$key';
    await LocalCacheUtil.setWithExpiry(
      cacheKey, 
      data, 
      expiry ?? _defaultExpiry
    );
  }
  
  static Future<T?> getCachedData<T>(String key) async {
    final cacheKey = '$_cachePrefix$key';
    return await LocalCacheUtil.getWithExpiry<T>(cacheKey);
  }
  
  static Future<void> clearCache() async {
    final allKeys = await LocalCacheUtil.getAllKeys();
    final cacheKeys = allKeys.where((key) => key.startsWith(_cachePrefix));
    await LocalCacheUtil.removeKeys(cacheKeys.toList());
  }
}
```

### 3. 数据同步
```dart
class DataSync {
  static Future<void> syncUserData(Map<String, dynamic> userData) async {
    // 存储用户数据
    await LocalCacheUtil.setMap('user_data', userData);
    
    // 记录同步时间
    await LocalCacheUtil.setDateTime('last_sync', DateTime.now());
  }
  
  static Future<bool> isDataStale() async {
    final lastSync = await LocalCacheUtil.getDateTime('last_sync');
    if (lastSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    // 如果超过1小时，认为数据过期
    return difference.inHours >= 1;
  }
}
```

## 🎊 总结

**本地数据缓存工具类提供了完整的本地存储解决方案：**

- ✅ **多种数据类型** - 支持基本类型和复杂对象
- ✅ **高级功能** - 过期时间、批量操作、数据迁移
- ✅ **工具方法** - 存储统计、键管理、清理功能
- ✅ **易于使用** - 简单的API，丰富的功能
- ✅ **性能优化** - 批量操作，智能缓存

**现在您可以在项目中使用这个工具类来管理本地数据存储，提升应用性能和用户体验！** 🚀

## 🚀 快速开始

1. 在main函数中初始化工具类
2. 使用相应的存储方法保存数据
3. 使用读取方法获取数据
4. 利用高级功能管理数据生命周期
5. 享受高效的本地数据存储体验

**本地数据缓存工具类使用指南完成！** 🎉
