import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../network.dart';

/// 网络请求工具包使用示例
class NetworkUsageExample {
  /// 示例1：用户登录
  static Future<void> loginExample() async {
    try {
      final response = await NetworkUtils.login(
        username: 'test@example.com',
        password: 'password123',
      );

      if (response.success) {
        print('登录成功: ${response.data}');
        // 保存token
        if (response.data != null) {
          final token = response.data!['token'];
          if (token != null) {
            await AuthInterceptor.saveToken(token);
          }
        }
      } else {
        print('登录失败: ${response.message}');
      }
    } catch (e) {
      print('登录异常: $e');
    }
  }

  /// 示例2：获取用户信息
  static Future<void> getUserProfileExample() async {
    final response = await NetworkUtils.getUserProfile();
    
    if (response.success) {
      print('用户信息: ${response.data}');
    } else {
      print('获取用户信息失败: ${response.message}');
    }
  }

  /// 示例3：上传文件
  static Future<void> uploadFileExample() async {
    final response = await NetworkUtils.uploadAvatar(
      filePath: '/path/to/avatar.jpg',
      onProgress: (sent, total) {
        print('上传进度: ${(sent / total * 100).toStringAsFixed(2)}%');
      },
    );

    if (response.success) {
      print('上传成功: ${response.data}');
    } else {
      print('上传失败: ${response.message}');
    }
  }

  /// 示例4：获取产品列表（分页）
  static Future<void> getProductsExample() async {
    final response = await NetworkUtils.getProducts(
      page: 1,
      pageSize: 20,
      filters: {
        'category': 'electronics',
        'price_min': 100,
        'price_max': 1000,
      },
    );

    if (response.success && response.data != null) {
      final products = response.data!;
      print('产品总数: ${products.total}');
      print('当前页: ${products.page}');
      print('产品列表: ${products.items}');
    } else {
      print('获取产品列表失败: ${response.message}');
    }
  }

  /// 示例5：自定义请求
  static Future<void> customRequestExample() async {
    final service = NetworkService();
    
    // 自定义GET请求
    final response = await service.get<Map<String, dynamic>>(
      '/custom/endpoint',
      queryParameters: {
        'param1': 'value1',
        'param2': 'value2',
      },
      headers: {
        'Custom-Header': 'custom-value',
      },
    );

    if (response.success) {
      print('自定义请求成功: ${response.data}');
    } else {
      print('自定义请求失败: ${response.message}');
    }
  }

  /// 示例6：错误处理
  static Future<void> errorHandlingExample() async {
    try {
      final response = await NetworkUtils.getProductDetail(
        productId: 'non-existent-id',
      );

      if (response.success) {
        print('获取产品详情成功: ${response.data}');
      } else {
        // 处理业务错误
        switch (response.code) {
          case 404:
            print('产品不存在');
            break;
          case 403:
            print('没有权限访问该产品');
            break;
          default:
            print('获取产品详情失败: ${response.message}');
        }
      }
    } catch (e) {
      // 处理网络异常
      print('网络异常: $e');
    }
  }

  /// 示例7：取消请求
  static Future<void> cancelRequestExample() async {
    final cancelToken = CancelToken();
    
    // 5秒后取消请求
    Future.delayed(Duration(seconds: 5), () {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('请求超时');
      }
    });

    try {
      final response = await NetworkService().get<Map<String, dynamic>>(
        '/long-running-endpoint',
        cancelToken: cancelToken,
      );
      
      if (response.success) {
        print('请求完成: ${response.data}');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        print('请求已取消');
      } else {
        print('请求失败: $e');
      }
    }
  }

  /// 示例8：批量请求
  static Future<void> batchRequestExample() async {
    // 并行执行多个请求
    final futures = [
      NetworkUtils.getUserProfile(),
      NetworkUtils.getProducts(page: 1, pageSize: 10),
      NetworkService().get<Map<String, dynamic>>('/config'),
    ];

    try {
      final results = await Future.wait(futures);
      
      for (int i = 0; i < results.length; i++) {
        final response = results[i];
        if (response.success) {
          print('请求${i + 1}成功: ${response.data}');
        } else {
          print('请求${i + 1}失败: ${response.message}');
        }
      }
    } catch (e) {
      print('批量请求异常: $e');
    }
  }
}

/// 在Widget中使用网络请求的示例
class NetworkExampleWidget extends StatefulWidget {
  @override
  _NetworkExampleWidgetState createState() => _NetworkExampleWidgetState();
}

class _NetworkExampleWidgetState extends State<NetworkExampleWidget> {
  bool _loading = false;
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('网络请求示例')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _testLogin,
              child: Text('测试登录'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _testGetProducts,
              child: Text('获取产品列表'),
            ),
            SizedBox(height: 16),
            if (_loading)
              CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
          ],
        ),
      ),
    );
  }

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
        _result = response.success 
            ? '登录成功: ${response.data}'
            : '登录失败: ${response.message}';
      });
    } catch (e) {
      setState(() {
        _result = '登录异常: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testGetProducts() async {
    setState(() {
      _loading = true;
      _result = '正在获取产品列表...';
    });

    try {
      final response = await NetworkUtils.getProducts(
        page: 1,
        pageSize: 10,
      );

      setState(() {
        if (response.success && response.data != null) {
          final products = response.data!;
          _result = '产品总数: ${products.total}\n'
                   '当前页: ${products.page}\n'
                   '产品列表: ${products.items}';
        } else {
          _result = '获取产品列表失败: ${response.message}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '获取产品列表异常: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
