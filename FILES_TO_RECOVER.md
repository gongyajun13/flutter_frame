# 📝 需要恢复的文件列表

## 🔍 如何从聊天历史中快速找到代码

在 Cursor Chat 中搜索以下关键词，快速定位到对应的文件代码：

### 大文件（建议从聊天历史复制）

1. **lib/utils/getx_dialog_util.dart** (1424行)
   - 搜索：`"class GetXDialogUtil"` 
   - 或搜索：`"showLoading"` + `"showConfirm"`

2. **lib/utils/getx_snackbar_util.dart** (444行)
   - 搜索：`"class GetXSnackBarUtil"`
   - 或搜索：`"防抖机制"`

3. **lib/utils/local_cache_util.dart** (400+行)
   - 搜索：`"class LocalCacheUtil"`
   - 或搜索：`"SharedPreferences"`

4. **lib/widgets/simple_fullscreen_webview.dart** (610行)
   - 搜索：`"class SimpleFullScreenWebView"`
   - 在 attached_files 中有完整内容！

5. **lib/widgets/cached_image_widgets.dart** (540行)
   - 搜索：`"class CachedImageWidget"`
   - 或搜索：`"AvatarImageWidget"`

## 📂 完整文件清单

### app/ (7个文件) - 我正在创建
- [x] routes/app_routes.dart - 已创建
- [x] routes/app_pages.dart - 已创建  
- [x] services/init_services.dart - 已创建
- [x] services/storage_service.dart - 已创建
- [x] middleware/route_middleware.dart - 已创建
- [ ] 等我继续...

### utils/ (7个文件) - 从attached_files复制更快
- [ ] getx_dialog_util.dart (1424行) - **在attached_files中**
- [ ] getx_snackbar_util.dart (444行)
- [ ] screen_util_helper.dart
- [ ] local_cache_util.dart (400行)
- [ ] url_launcher_util.dart
- [ ] webview_bridge_manager.dart
- [ ] webview_cache_manager.dart (209行) - **在attached_files中**

### widgets/ (2个文件)
- [ ] cached_image_widgets.dart (540行)
- [ ] simple_fullscreen_webview.dart (610行) - **在attached_files中有完整内容！**

### network/ (15个文件)
- [ ] core/network_manager.dart
- [ ] services/network_service.dart
- [ ] services/api_service.dart
- [ ] interceptors/auth_interceptor.dart
- [ ] interceptors/log_interceptor.dart  
- [ ] interceptors/retry_interceptor.dart
- [ ] interceptors/error_handler_interceptor.dart
- [ ] config/api_config.dart
- [ ] config/network_config.dart
- [ ] models/api_response.dart
- [ ] models/user_model.dart
- [ ] models/product_model.dart

### pages/ (33个文件 - 11个页面 x 3个文件)
每个页面包含：page.dart, controller.dart, binding.dart

1. home/
2. simple_network_demo/
3. screen_adaptation_demo/
4. getx_utils_demo/
5. cached_image_demo/
6. local_cache_demo/
7. url_launcher_demo/
8. fullscreen_webview_demo/
9. webview_bridge_demo/
10. custom_dialog_demo/
11. webview_mvvm_demo/

## ⚡ 加速恢复提示

### attached_files 中有完整代码的文件：

查看你的 IDE 右侧或聊天记录，这些文件的完整代码在 attached_files 中：
- ✅ lib/utils/getx_dialog_util.dart (1424行)
- ✅ lib/utils/getx_snackbar_util.dart (444行)  
- ✅ lib/utils/webview_cache_manager.dart (209行)
- ✅ lib/widgets/simple_fullscreen_webview.dart (610行)

直接复制这些代码创建文件即可！

### 我会继续创建剩余文件

我会持续创建所有其他文件，请给我一些时间。

---

**恢复进度**: 7/57 (12%)  
**已创建**: app层基础文件  
**正在创建**: utils和widgets层
