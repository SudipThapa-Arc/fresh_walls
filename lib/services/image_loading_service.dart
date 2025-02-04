import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_app/services/cache_manager.dart';
import '../services/web_cache_config.dart';
import '../config/api_keys.dart';

class ImageLoadingService {
  static Widget loadImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    Map<String, String>? headers,
  }) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: fit,
        headers: {
          'Authorization': ApiKeys.pexelsApiKey,
          'Access-Control-Allow-Origin': '*',
          ...?headers,
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        httpHeaders: {
          'Authorization': ApiKeys.pexelsApiKey,
          ...?headers,
        },
        memCacheWidth: 800,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    }
  }

  static Future<void> preloadImage(String url, BuildContext context) async {
    if (kIsWeb) {
      final configuration = ImageConfiguration(
        bundle: DefaultAssetBundle.of(context),
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final provider = NetworkImage(
        url,
        headers: {'Authorization': ApiKeys.pexelsApiKey},
      );
      await precacheImage(provider, context);
    } else {
      await precacheImage(
        CachedNetworkImageProvider(
          url,
          headers: {'Authorization': ApiKeys.pexelsApiKey},
        ),
        context,
      );
    }
  }
}
