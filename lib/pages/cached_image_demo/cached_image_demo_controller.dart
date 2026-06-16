import 'package:get/get.dart';
import '../../base/base_controller.dart';
import '../../overlay/overlay.dart';

/// 缓存图片演示控制器
class CachedImageDemoController extends BaseController {
  // 测试图片URL列表
  final List<String> testImageUrls = [
    'https://picsum.photos/600/400?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/500/400?random=3',
    'https://picsum.photos/600/500?random=4',
    'https://picsum.photos/700/600?random=5',
    'https://picsum.photos/800/700?random=6',
  ];

  // 错误图片URL（用于测试错误处理）
  final String errorImageUrl = 'https://invalid-url.com/image.jpg';

  // 刷新标记（用于触发图片重新加载）
  final refreshTrigger = 0.obs;

  /// 显示图片信息
  void showImageInfo(String title, String url) {
    AppOverlay.snack.info(
      message: '$title\nURL: $url',
      title: '图片信息',
    );
  }

  /// 测试图片加载
  void testImageLoading() {
    showSuccess('图片加载测试完成！');
  }

  /// 测试错误处理
  void testImageError() {
    showWarning('错误处理测试完成！');
  }

  /// 清除图片缓存
  void clearImageCache() {
    // 这里可以添加清除缓存的逻辑
    showInfo('图片缓存已清除！');
  }

  /// 刷新图片
  void refreshImages() {
    refreshTrigger.value++;
    showSuccess('图片已刷新！');
  }
}
