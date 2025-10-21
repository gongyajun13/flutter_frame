import 'package:flutter/material.dart';
import '../network/network.dart';

/// 网络请求演示页面
class NetworkDemoPage extends StatefulWidget {
  const NetworkDemoPage({Key? key}) : super(key: key);

  @override
  State<NetworkDemoPage> createState() => _NetworkDemoPageState();
}

class _NetworkDemoPageState extends State<NetworkDemoPage> {
  bool _loading = false;
  String _result = '点击按钮测试网络请求';
  String _userInfo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络请求演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 结果显示区域
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 用户信息显示区域
            if (_userInfo.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '用户信息: $_userInfo',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 按钮区域
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _testLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('测试登录'),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 获取用户信息按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _getUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('获取用户信息'),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 获取产品列表按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _getProducts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('获取产品列表'),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 自定义请求按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _customRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('自定义请求'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 测试登录
  Future<void> _testLogin() async {
    setState(() {
      _loading = true;
      _result = '正在登录...';
    });

    try {
      final response = await NetworkUtils.login(
        username: 'test@example.com',
        password: 'password123',
      );

      setState(() {
        if (response.success) {
          _result = '登录成功!\n\n响应数据:\n${response.data}';
          // 模拟保存token
          if (response.data != null && response.data!['token'] != null) {
            _userInfo = '已登录用户: ${response.data!['username'] ?? 'test@example.com'}';
          }
        } else {
          _result = '登录失败!\n\n错误信息:\n${response.message}\n\n错误代码: ${response.code}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '登录异常!\n\n异常信息:\n$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 获取用户信息
  Future<void> _getUserProfile() async {
    setState(() {
      _loading = true;
      _result = '正在获取用户信息...';
    });

    try {
      final response = await NetworkUtils.getUserProfile();

      setState(() {
        if (response.success) {
          _result = '获取用户信息成功!\n\n用户信息:\n${response.data}';
          _userInfo = '用户: ${response.data?['name'] ?? '未知用户'}';
        } else {
          _result = '获取用户信息失败!\n\n错误信息:\n${response.message}\n\n错误代码: ${response.code}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '获取用户信息异常!\n\n异常信息:\n$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 获取产品列表
  Future<void> _getProducts() async {
    setState(() {
      _loading = true;
      _result = '正在获取产品列表...';
    });

    try {
      final response = await NetworkUtils.getProducts(
        page: 1,
        pageSize: 5,
        filters: {
          'category': 'electronics',
        },
      );

      setState(() {
        if (response.success && response.data != null) {
          final products = response.data!;
          _result = '获取产品列表成功!\n\n'
                   '总数: ${products.total}\n'
                   '当前页: ${products.page}\n'
                   '每页大小: ${products.pageSize}\n'
                   '是否有更多: ${products.hasMore}\n\n'
                   '产品列表:\n${products.items}';
        } else {
          _result = '获取产品列表失败!\n\n错误信息:\n${response.message}\n\n错误代码: ${response.code}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '获取产品列表异常!\n\n异常信息:\n$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 自定义请求
  Future<void> _customRequest() async {
    setState(() {
      _loading = true;
      _result = '正在发送自定义请求...';
    });

    try {
      final service = NetworkService();
      final response = await service.get<Map<String, dynamic>>(
        '/config',
        queryParameters: {
          'version': '1.0.0',
          'platform': 'flutter',
        },
        headers: {
          'Custom-Header': 'custom-value',
        },
      );

      setState(() {
        if (response.success) {
          _result = '自定义请求成功!\n\n响应数据:\n${response.data}';
        } else {
          _result = '自定义请求失败!\n\n错误信息:\n${response.message}\n\n错误代码: ${response.code}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '自定义请求异常!\n\n异常信息:\n$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
