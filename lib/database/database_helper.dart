import 'package:sqflite/sqflite.dart';
import '../utils/app_logger.dart';
import 'app_database.dart';

/// 数据库操作工具类
/// 提供常用的数据库操作方法，类似 LocalCacheUtil 的设计
class DatabaseHelper {
  DatabaseHelper._();

  /// 获取数据库实例
  static Future<Database> get _db async {
    return await AppDatabase.instance.database;
  }

  // ==================== 通用 CRUD 操作 ====================

  /// 插入数据
  /// 
  /// [table] 表名
  /// [data] 要插入的数据（Map）
  /// [conflictAlgorithm] 冲突处理策略（默认 replace）
  /// 
  /// 返回插入的行 ID
  static Future<int> insert(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    try {
      final db = await _db;
      final id = await db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
      AppLogger.d('插入数据到 $table，ID: $id');
      return id;
    } catch (e) {
      AppLogger.e('插入数据失败: $table', error: e);
      rethrow;
    }
  }

  /// 批量插入数据
  /// 
  /// [table] 表名
  /// [dataList] 要插入的数据列表
  /// [conflictAlgorithm] 冲突处理策略
  /// 
  /// 返回插入的行数
  static Future<int> insertAll(
    String table,
    List<Map<String, dynamic>> dataList, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    if (dataList.isEmpty) return 0;

    try {
      final db = await _db;
      int count = 0;
      
      final batch = db.batch();
      for (var data in dataList) {
        batch.insert(table, data, conflictAlgorithm: conflictAlgorithm);
      }
      await batch.commit(noResult: false);
      count = dataList.length;
      
      AppLogger.d('批量插入 $count 条数据到 $table');
      return count;
    } catch (e) {
      AppLogger.e('批量插入数据失败: $table', error: e);
      rethrow;
    }
  }

  /// 查询数据
  /// 
  /// [table] 表名
  /// [columns] 要查询的列（默认所有列）
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 参数
  /// [orderBy] 排序
  /// [limit] 限制数量
  /// [offset] 偏移量
  /// 
  /// 返回查询结果列表
  static Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await _db;
      final result = await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      AppLogger.d('查询 $table，返回 ${result.length} 条数据');
      return result;
    } catch (e) {
      AppLogger.e('查询数据失败: $table', error: e);
      rethrow;
    }
  }

  /// 查询单条数据
  /// 
  /// [table] 表名
  /// [columns] 要查询的列
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 参数
  /// 
  /// 返回单条数据，如果不存在返回 null
  static Future<Map<String, dynamic>?> queryFirst(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final results = await query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      AppLogger.e('查询单条数据失败: $table', error: e);
      rethrow;
    }
  }

  /// 更新数据
  /// 
  /// [table] 表名
  /// [data] 要更新的数据
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 参数
  /// 
  /// 返回受影响的行数
  static Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    try {
      final db = await _db;
      final count = await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
      AppLogger.d('更新 $table，影响 $count 行');
      return count;
    } catch (e) {
      AppLogger.e('更新数据失败: $table', error: e);
      rethrow;
    }
  }

  /// 删除数据
  /// 
  /// [table] 表名
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 参数
  /// 
  /// 返回受影响的行数
  static Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await _db;
      final count = await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      AppLogger.d('删除 $table，影响 $count 行');
      return count;
    } catch (e) {
      AppLogger.e('删除数据失败: $table', error: e);
      rethrow;
    }
  }

  /// 执行原始 SQL
  /// 
  /// [sql] SQL 语句
  /// [arguments] SQL 参数
  /// 
  /// 返回查询结果（如果是 SELECT）或受影响的行数
  static Future<dynamic> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await _db;
      final result = await db.rawQuery(sql, arguments);
      AppLogger.d('执行原始 SQL: $sql');
      return result;
    } catch (e) {
      AppLogger.e('执行原始 SQL 失败: $sql', error: e);
      rethrow;
    }
  }

  /// 执行原始 SQL（非查询）
  /// 
  /// [sql] SQL 语句
  /// [arguments] SQL 参数
  /// 
  /// 返回受影响的行数
  static Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await _db;
      final count = await db.rawUpdate(sql, arguments);
      AppLogger.d('执行原始更新 SQL: $sql，影响 $count 行');
      return count;
    } catch (e) {
      AppLogger.e('执行原始更新 SQL 失败: $sql', error: e);
      rethrow;
    }
  }

  /// 执行原始 SQL（非查询，无返回值）
  /// 
  /// [sql] SQL 语句
  /// [arguments] SQL 参数
  static Future<void> rawExecute(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await _db;
      await db.rawInsert(sql, arguments);
      AppLogger.d('执行原始 SQL: $sql');
    } catch (e) {
      AppLogger.e('执行原始 SQL 失败: $sql', error: e);
      rethrow;
    }
  }

  // ==================== 事务操作 ====================

  /// 执行事务
  /// 
  /// [action] 事务中要执行的操作
  /// 
  /// 返回事务执行结果
  static Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    try {
      final db = await _db;
      return await db.transaction(action);
    } catch (e) {
      AppLogger.e('事务执行失败', error: e);
      rethrow;
    }
  }

  // ==================== 统计操作 ====================

  /// 获取表中的记录数
  /// 
  /// [table] 表名
  /// [where] WHERE 子句（可选）
  /// [whereArgs] WHERE 参数（可选）
  /// 
  /// 返回记录数
  static Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      AppLogger.d('$table 表记录数: $count');
      return count;
    } catch (e) {
      AppLogger.e('统计记录数失败: $table', error: e);
      rethrow;
    }
  }

  /// 检查表中是否存在指定条件的记录
  /// 
  /// [table] 表名
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 参数
  /// 
  /// 返回是否存在
  static Future<bool> exists(
    String table, {
    required String where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final count = await DatabaseHelper.count(table, where: where, whereArgs: whereArgs);
      return count > 0;
    } catch (e) {
      AppLogger.e('检查记录是否存在失败: $table', error: e);
      rethrow;
    }
  }

  // ==================== 表操作 ====================

  /// 清空表（删除所有数据）
  /// 
  /// [table] 表名
  /// 
  /// 返回删除的行数
  static Future<int> clearTable(String table) async {
    try {
      return await delete(table);
    } catch (e) {
      AppLogger.e('清空表失败: $table', error: e);
      rethrow;
    }
  }

  /// 删除表
  /// 
  /// [table] 表名
  static Future<void> dropTable(String table) async {
    try {
      final db = await _db;
      await db.execute('DROP TABLE IF EXISTS $table');
      AppLogger.d('删除表: $table');
    } catch (e) {
      AppLogger.e('删除表失败: $table', error: e);
      rethrow;
    }
  }
}
