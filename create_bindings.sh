#!/bin/bash

# 创建各个页面的 Binding 文件

# Screen Adaptation Demo
mkdir -p lib/pages/screen_adaptation_demo
cat > lib/pages/screen_adaptation_demo/screen_adaptation_demo_binding.dart << 'DART'
import 'package:get/get.dart';

class ScreenAdaptationDemoBinding extends Bindings {
  @override
  void dependencies() {}
}
DART

# GetX Utils Demo
mkdir -p lib/pages/getx_utils_demo
cat > lib/pages/getx_utils_demo/getx_utils_demo_binding.dart << 'DART'
import 'package:get/get.dart';

class GetXUtilsDemoBinding extends Bindings {
  @override
  void dependencies() {}
}
DART

# Cached Image Demo
mkdir -p lib/pages/cached_image_demo
cat > lib/pages/cached_image_demo/cached_image_demo_binding.dart << 'DART'
import 'package:get/get.dart';

class CachedImageDemoBinding extends Bindings {
  @override
  void dependencies() {}
}
DART

# Local Cache Demo
mkdir -p lib/pages/local_cache_demo
cat > lib/pages/local_cache_demo/local_cache_demo_binding.dart << 'DART'
import 'package:get/get.dart';

class LocalCacheDemoBinding extends Bindings {
  @override
  void dependencies() {}
}
DART

# URL Launcher Demo
mkdir -p lib/pages/url_launcher_demo
cat > lib/pages/url_launcher_demo/url_launcher_demo_binding.dart << 'DART'
import 'package:get/get.dart';

class UrlLauncherDemoBinding extends Bindings {
  @override
  void dependencies() {}
}
DART

# Fullscreen WebView Demo
mkdir -p lib/pages/fullscreen_webview_demo
cat > lib/pages/fullscreen_webview_demo/fullscreen_webview_demo_binding.dart << 'DART'
import 'package:get/get.dart';

class FullScreenWebViewDemoBinding extends Bindings {
  @override
  void dependencies() {}
}
DART

# WebView Bridge Demo
mkdir -p lib/pages/webview_bridge_demo
cat > lib/pages/webview_bridge_demo/webview_bridge_demo_binding.dart << 'DART'
import 'package:get/get.dart';

class WebViewBridgeDemoBinding extends Bindings {
  @override
  void dependencies() {}
}
DART

echo "All binding files created successfully!"
