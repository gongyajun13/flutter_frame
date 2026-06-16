import '../data/pixel_project.dart';

/// Demo 环境网络请求桩
class PixelImgRequest {
  Future<List<String?>> uploadImages(List<String> filePaths) async =>
      List.filled(filePaths.length, null);

  Future<String?> uploadImg(String filePath) async => null;

  Future<String?> saveWorks(
    int createSource,
    String title,
    String picture,
    String originalImage,
    String pixelData,
    String pixelDataEncoding,
    String beadBrandKey,
    int gridWidth,
    int gridHeight,
    List<String> allUsedColors, {
    String? id,
    int? colorLimitValue,
    String toolData = '',
  }) async =>
      null;

  Future<PixelProject?> getWorksDetail(String id) async => null;
}
