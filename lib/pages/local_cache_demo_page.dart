import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/local_cache_util.dart';
import '../utils/getx_snackbar_util.dart';
import '../utils/getx_dialog_util.dart';

/// 本地缓存工具类演示页面
class LocalCacheDemoPage extends StatefulWidget {
  const LocalCacheDemoPage({super.key});

  @override
  State<LocalCacheDemoPage> createState() => _LocalCacheDemoPageState();
}

class _LocalCacheDemoPageState extends State<LocalCacheDemoPage> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  Map<String, dynamic> _storageInfo = {};

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// 加载存储信息
  Future<void> _loadStorageInfo() async {
    final info = await LocalCacheUtil.getStorageInfo();
    setState(() {
      _storageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '本地缓存工具演示',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade600,
                Colors.green.shade700,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 存储信息卡片
            _buildStorageInfoCard(),
            
            SizedBox(height: 16.h),
            
            // 基本数据类型操作
            _buildSectionCard(
              '基本数据类型操作',
              Colors.blue,
              [
                _buildBasicDataSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 复杂数据类型操作
            _buildSectionCard(
              '复杂数据类型操作',
              Colors.purple,
              [
                _buildComplexDataSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 批量操作
            _buildSectionCard(
              '批量操作',
              Colors.orange,
              [
                _buildBatchOperationSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 高级功能
            _buildSectionCard(
              '高级功能',
              Colors.teal,
              [
                _buildAdvancedFeatureSection(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 工具方法
            _buildSectionCard(
              '工具方法',
              Colors.red,
              [
                _buildUtilitySection(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建存储信息卡片
  Widget _buildStorageInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage,
                color: Colors.green.shade600,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '存储信息',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow('总键数', '${_storageInfo['totalKeys'] ?? 0}'),
          _buildInfoRow('存储大小', '${_storageInfo['storageSize'] ?? 0} 字节'),
          if (_storageInfo['typeCount'] != null) ...[
            SizedBox(height: 8.h),
            Text(
              '数据类型分布：',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: 4.h),
            ...(_storageInfo['typeCount'] as Map<String, int>).entries.map(
              (entry) => _buildInfoRow(entry.key, '${entry.value}'),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.green.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建基本数据类型操作
  Widget _buildBasicDataSection() {
    return Column(
      children: [
        _buildOperationRow(
          '字符串',
          'Hello World',
          () => _testStringOperation(),
        ),
        _buildOperationRow(
          '整数',
          '12345',
          () => _testIntOperation(),
        ),
        _buildOperationRow(
          '浮点数',
          '3.14159',
          () => _testDoubleOperation(),
        ),
        _buildOperationRow(
          '布尔值',
          'true',
          () => _testBoolOperation(),
        ),
        _buildOperationRow(
          '字符串列表',
          '["A", "B", "C"]',
          () => _testStringListOperation(),
        ),
      ],
    );
  }

  /// 构建复杂数据类型操作
  Widget _buildComplexDataSection() {
    return Column(
      children: [
        _buildOperationRow(
          'Map对象',
          '{"name": "张三", "age": 25}',
          () => _testMapOperation(),
        ),
        _buildOperationRow(
          'List对象',
          '[1, 2, 3, 4, 5]',
          () => _testListOperation(),
        ),
        _buildOperationRow(
          'DateTime',
          '2024-01-01 12:00:00',
          () => _testDateTimeOperation(),
        ),
        _buildOperationRow(
          'Duration',
          '1小时30分钟',
          () => _testDurationOperation(),
        ),
      ],
    );
  }

  /// 构建批量操作
  Widget _buildBatchOperationSection() {
    return Column(
      children: [
        _buildButton(
          '批量存储数据',
          Colors.blue.shade600,
          () => _testBatchSet(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '批量读取数据',
          Colors.green.shade600,
          () => _testBatchGet(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '批量删除数据',
          Colors.red.shade600,
          () => _testBatchRemove(),
        ),
      ],
    );
  }

  /// 构建高级功能
  Widget _buildAdvancedFeatureSection() {
    return Column(
      children: [
        _buildButton(
          '存储带过期时间的数据',
          Colors.purple.shade600,
          () => _testExpiryData(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '读取带过期时间的数据',
          Colors.orange.shade600,
          () => _testGetExpiryData(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '清理过期数据',
          Colors.teal.shade600,
          () => _testCleanExpiredData(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '数据迁移',
          Colors.indigo.shade600,
          () => _testDataMigration(),
        ),
      ],
    );
  }

  /// 构建工具方法
  Widget _buildUtilitySection() {
    return Column(
      children: [
        _buildButton(
          '检查键是否存在',
          Colors.cyan.shade600,
          () => _testContainsKey(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '获取所有键',
          Colors.pink.shade600,
          () => _testGetAllKeys(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '清空所有数据',
          Colors.red.shade600,
          () => _testClearAll(),
        ),
        SizedBox(height: 12.h),
        _buildButton(
          '刷新存储信息',
          Colors.green.shade600,
          () => _loadStorageInfo(),
        ),
      ],
    );
  }

  /// 构建操作行
  Widget _buildOperationRow(String type, String example, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  example,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildButton(
              '测试',
              Colors.blue.shade600,
              onPressed,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建按钮
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 40.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 构建区域卡片
  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            ...children,
          ],
        ),
      ),
    );
  }

  // ==================== 测试方法 ====================

  /// 测试字符串操作
  Future<void> _testStringOperation() async {
    const key = 'test_string';
    const value = 'Hello, Local Cache!';
    
    await LocalCacheUtil.setString(key, value);
    final result = await LocalCacheUtil.getString(key);
    
    GetXSnackBarUtil.success(
      message: '字符串存储成功\nKey: $key\nValue: $result',
      title: '字符串操作',
    );
    _loadStorageInfo();
  }

  /// 测试整数操作
  Future<void> _testIntOperation() async {
    const key = 'test_int';
    const value = 12345;
    
    await LocalCacheUtil.setInt(key, value);
    final result = await LocalCacheUtil.getInt(key);
    
    GetXSnackBarUtil.success(
      message: '整数存储成功\nKey: $key\nValue: $result',
      title: '整数操作',
    );
    _loadStorageInfo();
  }

  /// 测试浮点数操作
  Future<void> _testDoubleOperation() async {
    const key = 'test_double';
    const value = 3.14159;
    
    await LocalCacheUtil.setDouble(key, value);
    final result = await LocalCacheUtil.getDouble(key);
    
    GetXSnackBarUtil.success(
      message: '浮点数存储成功\nKey: $key\nValue: $result',
      title: '浮点数操作',
    );
    _loadStorageInfo();
  }

  /// 测试布尔值操作
  Future<void> _testBoolOperation() async {
    const key = 'test_bool';
    const value = true;
    
    await LocalCacheUtil.setBool(key, value);
    final result = await LocalCacheUtil.getBool(key);
    
    GetXSnackBarUtil.success(
      message: '布尔值存储成功\nKey: $key\nValue: $result',
      title: '布尔值操作',
    );
    _loadStorageInfo();
  }

  /// 测试字符串列表操作
  Future<void> _testStringListOperation() async {
    const key = 'test_string_list';
    const value = ['Apple', 'Banana', 'Orange'];
    
    await LocalCacheUtil.setStringList(key, value);
    final result = await LocalCacheUtil.getStringList(key);
    
    GetXSnackBarUtil.success(
      message: '字符串列表存储成功\nKey: $key\nValue: $result',
      title: '字符串列表操作',
    );
    _loadStorageInfo();
  }

  /// 测试Map操作
  Future<void> _testMapOperation() async {
    const key = 'test_map';
    const value = {'name': '张三', 'age': 25, 'city': '北京'};
    
    await LocalCacheUtil.setMap(key, value);
    final result = await LocalCacheUtil.getMap(key);
    
    GetXSnackBarUtil.success(
      message: 'Map对象存储成功\nKey: $key\nValue: $result',
      title: 'Map操作',
    );
    _loadStorageInfo();
  }

  /// 测试List操作
  Future<void> _testListOperation() async {
    const key = 'test_list';
    const value = [1, 2, 3, 4, 5];
    
    await LocalCacheUtil.setList(key, value);
    final result = await LocalCacheUtil.getList(key);
    
    GetXSnackBarUtil.success(
      message: 'List对象存储成功\nKey: $key\nValue: $result',
      title: 'List操作',
    );
    _loadStorageInfo();
  }

  /// 测试DateTime操作
  Future<void> _testDateTimeOperation() async {
    const key = 'test_datetime';
    final value = DateTime.now();
    
    await LocalCacheUtil.setDateTime(key, value);
    final result = await LocalCacheUtil.getDateTime(key);
    
    GetXSnackBarUtil.success(
      message: 'DateTime存储成功\nKey: $key\nValue: $result',
      title: 'DateTime操作',
    );
    _loadStorageInfo();
  }

  /// 测试Duration操作
  Future<void> _testDurationOperation() async {
    const key = 'test_duration';
    const value = Duration(hours: 1, minutes: 30);
    
    await LocalCacheUtil.setDuration(key, value);
    final result = await LocalCacheUtil.getDuration(key);
    
    GetXSnackBarUtil.success(
      message: 'Duration存储成功\nKey: $key\nValue: $result',
      title: 'Duration操作',
    );
    _loadStorageInfo();
  }

  /// 测试批量存储
  Future<void> _testBatchSet() async {
    final data = {
      'batch_string': '批量字符串',
      'batch_int': 999,
      'batch_double': 2.718,
      'batch_bool': false,
      'batch_list': ['批量', '数据', '测试'],
    };
    
    final success = await LocalCacheUtil.setBatch(data);
    
    GetXSnackBarUtil.success(
      message: '批量存储${success ? '成功' : '失败'}\n存储了 ${data.length} 个数据',
      title: '批量存储',
    );
    _loadStorageInfo();
  }

  /// 测试批量读取
  Future<void> _testBatchGet() async {
    final keys = ['batch_string', 'batch_int', 'batch_double', 'batch_bool', 'batch_list'];
    final result = await LocalCacheUtil.getBatch(keys);
    
    GetXSnackBarUtil.info(
      message: '批量读取结果：\n${result.toString()}',
      title: '批量读取',
    );
  }

  /// 测试批量删除
  Future<void> _testBatchRemove() async {
    final keys = ['batch_string', 'batch_int', 'batch_double'];
    final success = await LocalCacheUtil.removeKeys(keys);
    
    GetXSnackBarUtil.warning(
      message: '批量删除${success ? '成功' : '失败'}\n删除了 ${keys.length} 个数据',
      title: '批量删除',
    );
    _loadStorageInfo();
  }

  /// 测试带过期时间的数据
  Future<void> _testExpiryData() async {
    const key = 'expiry_data';
    const value = '这个数据将在5秒后过期';
    const expiry = Duration(seconds: 5);
    
    final success = await LocalCacheUtil.setWithExpiry(key, value, expiry);
    
    GetXSnackBarUtil.success(
      message: '带过期时间的数据存储${success ? '成功' : '失败'}\n数据将在5秒后过期',
      title: '过期数据存储',
    );
    _loadStorageInfo();
  }

  /// 测试读取带过期时间的数据
  Future<void> _testGetExpiryData() async {
    const key = 'expiry_data';
    final result = await LocalCacheUtil.getWithExpiry<String>(key);
    
    GetXSnackBarUtil.info(
      message: '读取过期数据结果：\n${result ?? '数据不存在或已过期'}',
      title: '读取过期数据',
    );
  }

  /// 测试清理过期数据
  Future<void> _testCleanExpiredData() async {
    final cleanedCount = await LocalCacheUtil.cleanExpiredData();
    
    GetXSnackBarUtil.warning(
      message: '清理过期数据完成\n清理了 $cleanedCount 个过期数据',
      title: '清理过期数据',
    );
    _loadStorageInfo();
  }

  /// 测试数据迁移
  Future<void> _testDataMigration() async {
    const oldKey = 'test_string';
    const newKey = 'migrated_string';
    
    final success = await LocalCacheUtil.migrateData(oldKey, newKey);
    
    GetXSnackBarUtil.info(
      message: '数据迁移${success ? '成功' : '失败'}\n从 $oldKey 迁移到 $newKey',
      title: '数据迁移',
    );
    _loadStorageInfo();
  }

  /// 测试检查键是否存在
  Future<void> _testContainsKey() async {
    const key = 'test_string';
    final exists = await LocalCacheUtil.containsKey(key);
    
    GetXSnackBarUtil.info(
      message: '键 "$key" ${exists ? '存在' : '不存在'}',
      title: '检查键存在',
    );
  }

  /// 测试获取所有键
  Future<void> _testGetAllKeys() async {
    final keys = await LocalCacheUtil.getAllKeys();
    
    GetXSnackBarUtil.info(
      message: '所有键：\n${keys.join(', ')}',
      title: '获取所有键',
    );
  }

  /// 测试清空所有数据
  Future<void> _testClearAll() async {
    // 使用GetXDialogUtil的确认对话框
    GetXDialogUtil.showConfirm(
      title: '确认清空',
      message: '确定要清空所有本地缓存数据吗？此操作不可恢复！',
      confirmText: '确定清空',
      cancelText: '取消',
      onConfirm: () async {
        final success = await LocalCacheUtil.clear();
        GetXSnackBarUtil.success(
          message: '清空所有数据${success ? '成功' : '失败'}',
          title: '清空数据',
        );
        _loadStorageInfo();
      },
    );
  }
}
