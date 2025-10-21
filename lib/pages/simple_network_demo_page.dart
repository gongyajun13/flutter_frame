import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../network/services/api_service.dart';
import '../network/models/user_model.dart';
import '../network/models/product_model.dart';
import '../network/models/api_response.dart';

/// 简洁网络请求演示页面
class SimpleNetworkDemoPage extends StatefulWidget {
  const SimpleNetworkDemoPage({Key? key}) : super(key: key);

  @override
  State<SimpleNetworkDemoPage> createState() => _SimpleNetworkDemoPageState();
}

class _SimpleNetworkDemoPageState extends State<SimpleNetworkDemoPage> {
  String _result = '点击按钮测试简洁的网络请求';
  UserModel? _currentUser;
  List<ProductModel> _products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '简洁网络请求演示',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 结果显示区域
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey.shade50,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 用户信息显示区域
            if (_currentUser != null) ...[
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前用户: ${_currentUser!.username}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (_currentUser!.name != null) ...[
                      Text(
                        '姓名: ${_currentUser!.name}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade700),
                      ),
                      SizedBox(height: 4.h),
                    ],
                    Text(
                      '邮箱: ${_currentUser!.email}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade700),
                    ),
                    if (_currentUser!.phone != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        '电话: ${_currentUser!.phone}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade700),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // 产品列表显示区域
            if (_products.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '产品列表 (${_products.length}个)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...(_products.take(3).map((product) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        '• ${product.name} - ¥${product.price}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.green.shade700),
                      ),
                    ))),
                    if (_products.length > 3) ...[
                      SizedBox(height: 4.h),
                      Text(
                        '... 还有${_products.length - 3}个产品',
                        style: TextStyle(fontSize: 12.sp, color: Colors.green.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // 按钮区域
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildActionButton(
                      '用户登录',
                      _testLogin,
                      Colors.blue,
                      Icons.login,
                    ),
                    SizedBox(height: 12.h),
                    _buildActionButton(
                      '获取用户信息',
                      _getUserProfile,
                      Colors.green,
                      Icons.person,
                    ),
                    SizedBox(height: 12.h),
                    _buildActionButton(
                      '获取产品列表',
                      _getProducts,
                      Colors.orange,
                      Icons.list,
                    ),
                    SizedBox(height: 12.h),
                    _buildActionButton(
                      '创建产品',
                      _createProduct,
                      Colors.purple,
                      Icons.add_circle,
                    ),
                    SizedBox(height: 12.h),
                    _buildActionButton(
                      '静默请求（无loading/错误提示）',
                      _silentRequest,
                      Colors.grey,
                      Icons.visibility_off,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
    String text,
    VoidCallback onPressed,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }

  /// 测试用户登录
  void _testLogin() {
    setState(() {
      _result = '正在执行用户登录...';
    });

    ApiService.login(
      username: 'test@example.com',
      password: 'password123',
      onSuccess: (LoginResponseModel data) {
        setState(() {
          _currentUser = data.user;
          _result = '登录成功!\n\n用户信息:\n${data.user.toString()}\n\nToken: ${data.token}';
        });
      },
      onError: (String message, int code) {
        setState(() {
          _result = '登录失败!\n\n错误信息: $message\n错误代码: $code';
        });
      },
      onException: (dynamic error) {
        setState(() {
          _result = '登录异常!\n\n异常信息: $error';
        });
      },
    );
  }

  /// 获取用户信息
  void _getUserProfile() {
    setState(() {
      _result = '正在获取用户信息...';
    });

    ApiService.getUserProfile(
      onSuccess: (UserModel data) {
        setState(() {
          _currentUser = data;
          _result = '获取用户信息成功!\n\n用户信息:\n${data.toString()}';
        });
      },
      onError: (String message, int code) {
        setState(() {
          _result = '获取用户信息失败!\n\n错误信息: $message\n错误代码: $code';
        });
      },
      onException: (dynamic error) {
        setState(() {
          _result = '获取用户信息异常!\n\n异常信息: $error';
        });
      },
    );
  }

  /// 获取产品列表
  void _getProducts() {
    setState(() {
      _result = '正在获取产品列表...';
    });

    ApiService.getProducts(
      page: 1,
      pageSize: 5,
      filters: {
        'category': 'electronics',
        'isActive': true,
      },
      onSuccess: (PaginatedResponse<ProductModel> data) {
        setState(() {
          _products = data.items;
          _result = '获取产品列表成功!\n\n'
                   '总数: ${data.total}\n'
                   '当前页: ${data.page}\n'
                   '每页大小: ${data.pageSize}\n'
                   '是否有更多: ${data.hasMore}\n\n'
                   '产品列表:\n${data.items.map((p) => p.toString()).join('\n')}';
        });
      },
      onError: (String message, int code) {
        setState(() {
          _result = '获取产品列表失败!\n\n错误信息: $message\n错误代码: $code';
        });
      },
      onException: (dynamic error) {
        setState(() {
          _result = '获取产品列表异常!\n\n异常信息: $error';
        });
      },
    );
  }

  /// 创建产品
  void _createProduct() {
    setState(() {
      _result = '正在创建产品...';
    });

    ApiService.createProduct(
      productData: CreateProductRequestModel(
        name: '测试产品 ${DateTime.now().millisecondsSinceEpoch}',
        description: '这是一个测试产品',
        price: 99.99,
        category: 'electronics',
        stock: 100,
      ),
      onSuccess: (ProductModel data) {
        setState(() {
          _result = '创建产品成功!\n\n产品信息:\n${data.toString()}';
        });
      },
      onError: (String message, int code) {
        setState(() {
          _result = '创建产品失败!\n\n错误信息: $message\n错误代码: $code';
        });
      },
      onException: (dynamic error) {
        setState(() {
          _result = '创建产品异常!\n\n异常信息: $error';
        });
      },
    );
  }

  /// 静默请求（不显示loading和错误提示）
  void _silentRequest() {
    setState(() {
      _result = '正在执行静默请求...';
    });

    ApiService.getUserProfile(
      showLoading: false, // 不显示loading
      showError: false,   // 不显示错误提示
      onSuccess: (UserModel data) {
        setState(() {
          _currentUser = data;
          _result = '静默请求成功!\n\n用户信息:\n${data.toString()}\n\n注意: 此请求没有显示loading和错误提示';
        });
      },
      onError: (String message, int code) {
        setState(() {
          _result = '静默请求失败!\n\n错误信息: $message\n错误代码: $code\n\n注意: 此请求没有显示loading和错误提示';
        });
      },
      onException: (dynamic error) {
        setState(() {
          _result = '静默请求异常!\n\n异常信息: $error\n\n注意: 此请求没有显示loading和错误提示';
        });
      },
    );
  }
}
