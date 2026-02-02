import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/init_services.dart';
import 'app/controllers/theme_controller.dart';
import 'app/widgets/live_theme_preview.dart';

void main() async {
  // 确保 Flutter Binding 初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化全局服务
  await InitServices.init();
  
  // 初始化主题控制器
  Get.put(ThemeController());
  
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
        return Obx(() {
          final themeController = Get.find<ThemeController>();
          return ThemeTransitionWrapper(
            child: GetMaterialApp(
              title: 'Flutter Frame',
              debugShowCheckedModeBanner: false,
              theme: themeController.currentThemeData,
              darkTheme: themeController.isDarkTheme 
                  ? themeController.currentThemeData
                  : ThemeData.dark(),
              themeMode: themeController.themeMode.value,
              // 本地化配置
              locale: const Locale('zh', 'CN'),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('zh', 'CN'),
                Locale('en', 'US'),
              ],
              // GetX 路由配置
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,
              // 默认过渡动画
              defaultTransition: Transition.cupertino,
              // 路由观察器（用于调试）
              routingCallback: (routing) {
                debugPrint('Route: ${routing?.current}');
              },
            ),
          );
        });
      },
    );
  }
}
