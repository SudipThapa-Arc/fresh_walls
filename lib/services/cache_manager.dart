import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

class CustomCacheManager {
  static const key = 'wallpaperCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  static Future<void> clearCache() async {
    await instance.emptyCache();
  }

  static Future<bool> hasValidCache(String url) async {
    final fileInfo = await instance.getFileFromCache(url);
    return fileInfo != null && fileInfo.validTill.isAfter(DateTime.now());
  }

  static Future<File?> getCachedFile(String url) async {
    try {
      final fileInfo = await instance.getFileFromCache(url);
      if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
        return fileInfo.file;
      }
      return null;
    } catch (e) {
      print('Cache error: $e');
      return null;
    }
  }
}
