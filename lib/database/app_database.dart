import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/app_logger.dart';

/// 应用数据库单例
/// 管理数据库的创建、打开、关闭和版本管理
class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  static Database? _database;

  /// 获取数据库单例
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  /// 数据库名称
  static const String _databaseName = 'app_database.db';

  /// 数据库版本
  static const int _databaseVersion = 1;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    AppLogger.d('数据库路径: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.d('创建数据库表，版本: $version');
    
    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar TEXT,
        name TEXT,
        phone TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建产品表
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        image TEXT,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_products_created_at ON products(created_at)');

    AppLogger.d('数据库表创建完成');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.d('升级数据库: $oldVersion -> $newVersion');
    // 根据版本号执行相应的迁移操作
    // 示例：如果需要添加新字段，可以在这里处理
  }

  /// 打开数据库时的回调
  Future<void> _onOpen(Database db) async {
    AppLogger.d('数据库已打开');
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      AppLogger.d('数据库已关闭');
    }
  }

  /// 删除数据库（用于测试或重置）
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    AppLogger.d('数据库已删除');
  }
}
