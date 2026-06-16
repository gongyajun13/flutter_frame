import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

/// 简化版页面基类（用于像素画板全屏页面）
abstract class BaseView<T extends BaseController> extends GetView<T> {
  const BaseView({super.key});

  PreferredSizeWidget? appBar(BuildContext context) => null;

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: body(context),
    );
  }
}
