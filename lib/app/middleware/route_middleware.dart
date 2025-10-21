import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 路由中间件
/// 
/// 用于路由跳转前的拦截和处理
class RouteMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    // 这里可以添加路由拦截逻辑
    // 例如：检查用户登录状态
    
    debugPrint('RouteMiddleware: 导航到 $route');
    
    return null; // 返回 null 表示允许导航
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    debugPrint('RouteMiddleware: 调用页面 ${page?.name}');
    return super.onPageCalled(page);
  }

  @override
  Widget onPageBuilt(Widget page) {
    debugPrint('RouteMiddleware: 页面构建完成');
    return page;
  }

  @override
  void onPageDispose() {
    debugPrint('RouteMiddleware: 页面销毁');
    super.onPageDispose();
  }
}

