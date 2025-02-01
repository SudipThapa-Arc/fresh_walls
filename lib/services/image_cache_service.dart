import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_keys.dart';
import 'navigation_service.dart';

class ImageCacheService {
  static const int maxCacheSize = 100;
  static final DefaultCacheManager _cacheManager = DefaultCacheManager();

  static void initCache() {
    PaintingBinding.instance.imageCache.maximumSize = maxCacheSize;
    _cacheManager.emptyCache();
  }

  static Future<void> preloadImage(String url) async {
    try {
      await precacheImage(
        CachedNetworkImageProvider(
          url,
          headers: {'Authorization': ApiKeys.pexelsApiKey},
        ),
        NavigationService.navigatorKey.currentContext!,
      );
    } catch (e) {
      debugPrint('Error preloading image: $e');
    }
  }

  static Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
