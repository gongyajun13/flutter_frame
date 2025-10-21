import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/init_services.dart';

void main() async {
  // 确保 Flutter Binding 初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化全局服务
  await InitServices.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Flutter Frame',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: TextTheme(
              displayLarge: TextStyle(fontSize: 32.sp),
              displayMedium: TextStyle(fontSize: 28.sp),
              displaySmall: TextStyle(fontSize: 24.sp),
              headlineMedium: TextStyle(fontSize: 20.sp),
              headlineSmall: TextStyle(fontSize: 18.sp),
              titleLarge: TextStyle(fontSize: 16.sp),
              bodyLarge: TextStyle(fontSize: 14.sp),
              bodyMedium: TextStyle(fontSize: 12.sp),
            ),
          ),
          // GetX 路由配置
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          // 默认过渡动画
          defaultTransition: Transition.cupertino,
          // 路由观察器（用于调试）
          routingCallback: (routing) {
            debugPrint('Route: ${routing?.current}');
          },
        );
      },
    );
  }
}
