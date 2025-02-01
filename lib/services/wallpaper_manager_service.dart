import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../services/image_optimization_service.dart';
import '../services/cache_manager.dart';

class WallpaperManagerService {
  static const String backgroundTaskKey = 'autoWallpaperChange';

  static Future<bool> setWallpaper({
    required String url,
    required int wallpaperLocation,
    required Function(double) onProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Wallpaper setting is not supported on web');
    }

    try {
      // Download and cache the image
      final file = await CustomCacheManager.instance.getSingleFile(
        url,
        key: url,
      );

      // Optimize the image
      final optimizedFile = await ImageOptimizationService.optimizeImage(file);
      if (optimizedFile == null) return false;

      // Set the wallpaper
      final result = await WallpaperManager.setWallpaperFromFile(
        optimizedFile.path,
        wallpaperLocation,
      );

      return result;
    } catch (e) {
      debugPrint('Set wallpaper error: $e');
      return false;
    }
  }

  static Future<void> initializeAutoChange() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> scheduleWallpaperChange(Duration interval) async {
    await Workmanager().registerPeriodicTask(
      backgroundTaskKey,
      backgroundTaskKey,
      frequency: interval,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Future<void> cancelAutoChange() async {
    await Workmanager().cancelByUniqueName(backgroundTaskKey);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == WallpaperManagerService.backgroundTaskKey) {
        // Implement your auto-change logic here
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Background task error: $e');
      return false;
    }
  });
}
