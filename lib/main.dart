import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/init_services.dart';
import 'app/controllers/theme_controller.dart';
import 'app/widgets/live_theme_preview.dart';
import 'widgets/debug_panel/debug_panel_controller.dart';
import 'widgets/debug_panel/debug_ball.dart';

void main() async {
  // 确保 Flutter Binding 初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化全局服务（包含主题控制器初始化）
  await InitServices.init();
  
  // 初始化调试面板控制器（仅在 debug 模式）
  if (kDebugMode) {
    Get.put(DebugPanelController());
  }
  
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
              // 在 builder 中通过 Overlay 添加全局调试入口（悬浮球）
              builder: (context, child) {
                Widget app = child ?? const SizedBox.shrink();

                if (kDebugMode) {
                  // 在首帧之后，将 DebugBall 以 OverlayEntry 形式插入到全局 Overlay 中
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    DebugBallOverlay.ensureAttached();
                  });
                }

                return app;
              },
            ),
          );
        });
      },
    );
  }
}
