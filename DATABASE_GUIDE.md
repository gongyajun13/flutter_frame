# 💾 数据库使用指南

## 📋 概述

本项目使用 **sqflite** 作为本地数据库解决方案，提供了完整的数据库操作工具类和 Repository 模式实现，适合中型以上项目的复杂数据存储需求。

## 🎯 功能特点

### 1. 数据库管理
- ✅ **单例模式** - `AppDatabase` 管理数据库实例
- ✅ **版本管理** - 支持数据库版本升级和迁移
- ✅ **自动初始化** - 在应用启动时自动初始化

### 2. 数据库工具类
- ✅ **CRUD 操作** - 完整的增删改查功能
- ✅ **批量操作** - 支持批量插入、更新、删除
- ✅ **事务支持** - 支持数据库事务操作
- ✅ **查询功能** - 支持复杂 SQL 查询
- ✅ **统计功能** - 记录数统计、存在性检查

### 3. Repository 模式
- ✅ **数据仓库** - 封装业务逻辑的数据访问层
- ✅ **类型安全** - 使用强类型模型
- ✅ **易于扩展** - 方便添加新的数据仓库

### 4. 数据模型
- ✅ **表模型** - 对应数据库表结构
- ✅ **JSON 支持** - 支持与网络数据互转
- ✅ **Map 转换** - 支持与数据库 Map 互转

## 🚀 快速开始

### 1. 初始化数据库

数据库已在 `InitServices` 中自动初始化，无需手动调用：

```dart
// lib/app/services/init_services.dart
static Future<void> init() async {
  // ...
  await AppDatabase.instance.database; // 自动初始化
  // ...
}
```

### 2. 使用 DatabaseHelper

`DatabaseHelper` 提供了通用的数据库操作方法：

```dart
import '../../database/database_helper.dart';

// 插入数据
await DatabaseHelper.insert('users', {
  'id': 'user_1',
  'username': 'john',
  'email': 'john@example.com',
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// 查询数据
final users = await DatabaseHelper.query(
  'users',
  where: 'email = ?',
  whereArgs: ['john@example.com'],
  orderBy: 'created_at DESC',
);

// 更新数据
await DatabaseHelper.update(
  'users',
  {'username': 'john_updated'},
  where: 'id = ?',
  whereArgs: ['user_1'],
);

// 删除数据
await DatabaseHelper.delete(
  'users',
  where: 'id = ?',
  whereArgs: ['user_1'],
);

// 统计记录数
final count = await DatabaseHelper.count('users');

// 检查记录是否存在
final exists = await DatabaseHelper.exists(
  'users',
  where: 'email = ?',
  whereArgs: ['john@example.com'],
);
```

### 3. 使用 Repository

推荐使用 Repository 模式进行数据操作：

```dart
import '../../database/repositories/user_repository.dart';
import '../../database/models/user_table_model.dart';

final repository = UserRepository();

// 插入用户
final user = UserTableModel(
  id: 'user_1',
  username: 'john',
  email: 'john@example.com',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await repository.insertUser(user);

// 获取用户
final user = await repository.getUserById('user_1');
final userByEmail = await repository.getUserByEmail('john@example.com');

// 获取所有用户
final users = await repository.getAllUsers(
  orderBy: 'created_at DESC',
  limit: 10,
  offset: 0,
);

// 更新用户
final updatedUser = user.copyWith(name: 'John Doe');
await repository.updateUser(updatedUser);

// 删除用户
await repository.deleteUser('user_1');

// 搜索用户
final results = await repository.searchUsers('john');
```

### 4. 创建自定义 Repository

参考现有 Repository 创建新的数据仓库：

```dart
import '../database_helper.dart';
import '../models/your_table_model.dart';
import '../../utils/app_logger.dart';

class YourRepository {
  static const String _tableName = 'your_table';

  Future<String> insertItem(YourTableModel item) async {
    try {
      await DatabaseHelper.insert(_tableName, item.toMap());
      return item.id;
    } catch (e) {
      AppLogger.e('插入失败', error: e);
      rethrow;
    }
  }

  Future<List<YourTableModel>> getAllItems() async {
    try {
      final maps = await DatabaseHelper.query(_tableName);
      return maps.map((map) => YourTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('获取失败', error: e);
      rethrow;
    }
  }

  // ... 其他方法
}
```

### 5. 创建数据模型

参考现有模型创建新的表模型：

```dart
class YourTableModel {
  final String id;
  final String name;
  final DateTime createdAt;

  YourTableModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // 从数据库 Map 创建
  factory YourTableModel.fromMap(Map<String, dynamic> map) {
    return YourTableModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // 从 JSON 创建（用于网络数据）
  factory YourTableModel.fromJson(Map<String, dynamic> json) {
    return YourTableModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

## 📚 高级功能

### 1. 事务操作

使用事务确保数据一致性：

```dart
await DatabaseHelper.transaction((txn) async {
  // 在事务中执行多个操作
  await txn.insert('users', user1.toMap());
  await txn.insert('users', user2.toMap());
  await txn.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  // 如果任何操作失败，整个事务会回滚
});
```

### 2. 批量操作

批量插入提高性能：

```dart
final items = List.generate(100, (i) => YourTableModel(...));
await DatabaseHelper.insertAll('your_table', items.map((e) => e.toMap()).toList());
```

### 3. 复杂查询

使用原始 SQL 进行复杂查询：

```dart
// 联表查询
final results = await DatabaseHelper.rawQuery('''
  SELECT u.*, p.name as product_name
  FROM users u
  LEFT JOIN products p ON u.id = p.user_id
  WHERE u.created_at > ?
''', [DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch]);

// 聚合查询
final stats = await DatabaseHelper.rawQuery('''
  SELECT category, COUNT(*) as count, AVG(price) as avg_price
  FROM products
  GROUP BY category
''');
```

### 4. 数据库迁移

在 `AppDatabase._onUpgrade` 中处理数据库版本升级：

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // 添加新字段
    await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
  }
  if (oldVersion < 3) {
    // 创建新表
    await db.execute('CREATE TABLE orders (...)');
  }
}
```

## 🎨 在 Controller 中使用

```dart
import '../../base/base_controller.dart';
import '../../database/repositories/user_repository.dart';
import '../../database/models/user_table_model.dart';

class YourController extends BaseController {
  final UserRepository _userRepository = UserRepository();
  final RxList<UserTableModel> users = <UserTableModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      isLoading.value = true;
      final userList = await _userRepository.getAllUsers();
      users.assignAll(userList);
    } catch (e) {
      showError('加载用户失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addUser(UserTableModel user) async {
    try {
      await _userRepository.insertUser(user);
      await _loadUsers();
      showSuccess('添加用户成功');
    } catch (e) {
      showError('添加用户失败：$e');
    }
  }
}
```

## 📝 注意事项

1. **数据类型转换**
   - DateTime 需要转换为 `millisecondsSinceEpoch` 存储
   - bool 需要转换为 `0` 或 `1` 存储
   - 使用 `fromMap` 和 `toMap` 进行转换

2. **性能优化**
   - 批量操作使用 `insertAll` 而不是循环 `insert`
   - 大量数据操作使用事务
   - 合理使用索引提高查询性能

3. **错误处理**
   - 所有数据库操作都应该使用 try-catch
   - 使用 `AppLogger` 记录错误日志
   - 向用户显示友好的错误提示

4. **线程安全**
   - sqflite 是单线程的，不需要担心并发问题
   - 但要注意异步操作的顺序

## 🔗 相关文件

- `lib/database/app_database.dart` - 数据库单例管理
- `lib/database/database_helper.dart` - 数据库操作工具类
- `lib/database/models/` - 数据模型
- `lib/database/repositories/` - 数据仓库
- `lib/pages/database_demo/` - 数据库演示页面

## 📖 更多示例

查看 `lib/pages/database_demo/` 目录下的演示代码，了解完整的使用示例。
