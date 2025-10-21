import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io' show Platform;

/// WebView 缓存管理工具类
/// 
/// 提供了清除 WebView 相关缓存的各种方法
class WebViewCacheManager {
  WebViewCacheManager._();

  /// 清除所有 WebView 缓存（全局）
  /// 
  /// 包括：
  /// - Cookie
  /// - LocalStorage（需要通过 WebViewController 清除）
  /// - SessionStorage（需要通过 WebViewController 清除）
  /// - 缓存文件
  /// 
  /// 注意：LocalStorage 和 SessionStorage 需要在 WebView 加载后通过
  /// JavaScript 清除，此方法仅清除 Cookies
  static Future<void> clearAllCache() async {
    try {
      debugPrint('WebViewCacheManager: 开始清除全局缓存...');
      
      // 清除所有 Cookies
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint('WebViewCacheManager: 全局 Cookies 已清除');
      
      debugPrint('WebViewCacheManager: 全局缓存清除完成');
    } catch (e) {
      debugPrint('WebViewCacheManager: 清除全局缓存失败 - $e');
      rethrow;
    }
  }

  /// 清除指定 WebView 的完整缓存
  /// 
  /// [controller] WebViewController 实例
  /// [includeDiskFiles] 是否清除磁盘缓存文件（默认 true）
  static Future<void> clearCache(
    WebViewController controller, {
    bool includeDiskFiles = true,
  }) async {
    try {
      debugPrint('WebViewCacheManager: 开始清除缓存...');
      
      // 1. 清除所有 Cookies
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint('WebViewCacheManager: Cookies 已清除');
      
      // 2. 清除 LocalStorage 和 SessionStorage
      await controller.runJavaScript('''
        // 清除 LocalStorage
        if (window.localStorage) {
          window.localStorage.clear();
          console.log('LocalStorage cleared');
        }
        
        // 清除 SessionStorage
        if (window.sessionStorage) {
          window.sessionStorage.clear();
          console.log('SessionStorage cleared');
        }
        
        // 清除 IndexedDB（如果有）
        if (window.indexedDB && window.indexedDB.databases) {
          window.indexedDB.databases().then(function(dbs) {
            dbs.forEach(function(db) {
              window.indexedDB.deleteDatabase(db.name);
            });
            console.log('IndexedDB cleared');
          });
        }
      ''');
      debugPrint('WebViewCacheManager: LocalStorage/SessionStorage 已清除');
      
      // 3. Android 平台特定的缓存清理
      if (Platform.isAndroid && includeDiskFiles) {
        final androidController = controller.platform as AndroidWebViewController;
        await androidController.clearCache();
        debugPrint('WebViewCacheManager: Android 缓存文件已清除');
      }
      
      debugPrint('WebViewCacheManager: 缓存清除完成');
    } catch (e) {
      debugPrint('WebViewCacheManager: 清除缓存失败 - $e');
      rethrow;
    }
  }

  /// 仅清除 Cookies
  static Future<void> clearCookies() async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint('WebViewCacheManager: Cookies 已清除');
    } catch (e) {
      debugPrint('WebViewCacheManager: 清除 Cookies 失败 - $e');
      rethrow;
    }
  }

  /// 清除指定 WebView 的 LocalStorage
  static Future<void> clearLocalStorage(WebViewController controller) async {
    try {
      await controller.runJavaScript('''
        if (window.localStorage) {
          window.localStorage.clear();
          console.log('LocalStorage cleared');
        }
      ''');
      debugPrint('WebViewCacheManager: LocalStorage 已清除');
    } catch (e) {
      debugPrint('WebViewCacheManager: 清除 LocalStorage 失败 - $e');
      rethrow;
    }
  }

  /// 清除指定 WebView 的 SessionStorage
  static Future<void> clearSessionStorage(WebViewController controller) async {
    try {
      await controller.runJavaScript('''
        if (window.sessionStorage) {
          window.sessionStorage.clear();
          console.log('SessionStorage cleared');
        }
      ''');
      debugPrint('WebViewCacheManager: SessionStorage 已清除');
    } catch (e) {
      debugPrint('WebViewCacheManager: 清除 SessionStorage 失败 - $e');
      rethrow;
    }
  }

  /// 清除指定 WebView 的 IndexedDB
  static Future<void> clearIndexedDB(WebViewController controller) async {
    try {
      await controller.runJavaScript('''
        if (window.indexedDB && window.indexedDB.databases) {
          window.indexedDB.databases().then(function(dbs) {
            dbs.forEach(function(db) {
              window.indexedDB.deleteDatabase(db.name);
              console.log('Deleted IndexedDB:', db.name);
            });
          });
        }
      ''');
      debugPrint('WebViewCacheManager: IndexedDB 已清除');
    } catch (e) {
      debugPrint('WebViewCacheManager: 清除 IndexedDB 失败 - $e');
      rethrow;
    }
  }

  /// 清除 Android WebView 的磁盘缓存
  /// 
  /// 注意：此方法仅适用于 Android 平台
  static Future<void> clearDiskCache(WebViewController controller) async {
    if (!Platform.isAndroid) {
      debugPrint('WebViewCacheManager: clearDiskCache 仅支持 Android 平台');
      return;
    }

    try {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.clearCache();
      debugPrint('WebViewCacheManager: Android 磁盘缓存已清除');
    } catch (e) {
      debugPrint('WebViewCacheManager: 清除磁盘缓存失败 - $e');
      rethrow;
    }
  }

  /// 设置 Cookie
  /// 
  /// [url] Cookie 所属的 URL
  /// [name] Cookie 名称
  /// [value] Cookie 值
  /// [domain] Cookie 域（可选）
  /// [path] Cookie 路径（可选，默认 /）
  static Future<void> setCookie(
    String url,
    String name,
    String value, {
    String? domain,
    String path = '/',
  }) async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.setCookie(
        WebViewCookie(
          name: name,
          value: value,
          domain: domain ?? Uri.parse(url).host,
          path: path,
        ),
      );
      debugPrint('WebViewCacheManager: Cookie 已设置 - $name');
    } catch (e) {
      debugPrint('WebViewCacheManager: 设置 Cookie 失败 - $e');
      rethrow;
    }
  }
}

