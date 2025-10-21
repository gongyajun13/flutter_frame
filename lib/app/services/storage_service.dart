import 'package:get/get.dart';
import '../../utils/local_cache_util.dart';

/// 全局存储服务
/// 
/// 使用 GetX 的依赖注入管理全局存储
class StorageService extends GetxService {
  /// 初始化服务
  Future<StorageService> init() async {
    // 初始化本地缓存
    await LocalCacheUtil.init();
    return this;
  }

  /// 保存字符串
  Future<bool> setString(String key, String value) {
    return LocalCacheUtil.setString(key, value);
  }

  /// 获取字符串
  Future<String?> getString(String key) async {
    return LocalCacheUtil.getString(key);
  }

  /// 保存 Map
  Future<bool> setMap(String key, Map<String, dynamic> map) {
    return LocalCacheUtil.setMap(key, map);
  }

  /// 获取 Map
  Future<Map<String, dynamic>?> getMap(String key) async {
    return LocalCacheUtil.getMap(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) {
    return LocalCacheUtil.setBool(key, value);
  }

  /// 获取布尔值
  Future<bool?> getBool(String key) async {
    return LocalCacheUtil.getBool(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) {
    return LocalCacheUtil.setInt(key, value);
  }

  /// 获取整数
  Future<int?> getInt(String key) async {
    return LocalCacheUtil.getInt(key);
  }

  /// 删除指定 key
  Future<bool> remove(String key) {
    return LocalCacheUtil.remove(key);
  }

  /// 清除所有数据
  Future<bool> clear() {
    return LocalCacheUtil.clear();
  }

  /// 检查 key 是否存在
  Future<bool> containsKey(String key) async {
    return LocalCacheUtil.containsKey(key);
  }
}

