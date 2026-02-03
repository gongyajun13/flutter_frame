import '../database_helper.dart';
import '../models/user_table_model.dart';
import '../../utils/app_logger.dart';

/// 用户数据仓库
/// 提供用户数据的 CRUD 操作
class UserRepository {
  static const String _tableName = 'users';

  /// 插入用户
  Future<String> insertUser(UserTableModel user) async {
    try {
      await DatabaseHelper.insert(_tableName, user.toMap());
      AppLogger.d('插入用户: ${user.id}');
      return user.id;
    } catch (e) {
      AppLogger.e('插入用户失败', error: e);
      rethrow;
    }
  }

  /// 批量插入用户
  Future<int> insertUsers(List<UserTableModel> users) async {
    try {
      final maps = users.map((user) => user.toMap()).toList();
      return await DatabaseHelper.insertAll(_tableName, maps);
    } catch (e) {
      AppLogger.e('批量插入用户失败', error: e);
      rethrow;
    }
  }

  /// 根据 ID 获取用户
  Future<UserTableModel?> getUserById(String id) async {
    try {
      final map = await DatabaseHelper.queryFirst(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return map != null ? UserTableModel.fromMap(map) : null;
    } catch (e) {
      AppLogger.e('获取用户失败: $id', error: e);
      rethrow;
    }
  }

  /// 根据邮箱获取用户
  Future<UserTableModel?> getUserByEmail(String email) async {
    try {
      final map = await DatabaseHelper.queryFirst(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );
      return map != null ? UserTableModel.fromMap(map) : null;
    } catch (e) {
      AppLogger.e('根据邮箱获取用户失败: $email', error: e);
      rethrow;
    }
  }

  /// 获取所有用户
  Future<List<UserTableModel>> getAllUsers({
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final maps = await DatabaseHelper.query(
        _tableName,
        orderBy: orderBy ?? 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => UserTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('获取所有用户失败', error: e);
      rethrow;
    }
  }

  /// 更新用户
  Future<int> updateUser(UserTableModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      return await DatabaseHelper.update(
        _tableName,
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      AppLogger.e('更新用户失败: ${user.id}', error: e);
      rethrow;
    }
  }

  /// 删除用户
  Future<int> deleteUser(String id) async {
    try {
      return await DatabaseHelper.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      AppLogger.e('删除用户失败: $id', error: e);
      rethrow;
    }
  }

  /// 删除所有用户
  Future<int> deleteAllUsers() async {
    try {
      return await DatabaseHelper.clearTable(_tableName);
    } catch (e) {
      AppLogger.e('删除所有用户失败', error: e);
      rethrow;
    }
  }

  /// 获取用户数量
  Future<int> getUserCount() async {
    try {
      return await DatabaseHelper.count(_tableName);
    } catch (e) {
      AppLogger.e('获取用户数量失败', error: e);
      rethrow;
    }
  }

  /// 检查用户是否存在
  Future<bool> userExists(String id) async {
    try {
      return await DatabaseHelper.exists(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      AppLogger.e('检查用户是否存在失败: $id', error: e);
      rethrow;
    }
  }

  /// 搜索用户（根据用户名、邮箱或姓名）
  Future<List<UserTableModel>> searchUsers(String keyword) async {
    try {
      AppLogger.d('搜索用户，关键词: $keyword');
      final maps = await DatabaseHelper.query(
        _tableName,
        where: 'username LIKE ? OR email LIKE ? OR name LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
        orderBy: 'created_at DESC',
      );
      AppLogger.d('搜索用户，找到 ${maps.length} 条记录');
      return maps.map((map) => UserTableModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('搜索用户失败: $keyword', error: e);
      rethrow;
    }
  }
}
