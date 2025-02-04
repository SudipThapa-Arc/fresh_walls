import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:universal_html/html.dart' as html;

class WebCacheConfig {
  static late final CacheManager instance;

  static Future<void> init() async {
    instance = CacheManager(
      Config(
        'wallpaperWebCache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200,
        repo: JsonCacheInfoRepository(databaseName: 'wallpaperWebCache'),
        fileService: HttpFileService(),
        fileSystem: MemoryCacheSystem(),
      ),
    );
  }

  static Future<void> clearCache() async {
    await instance.emptyCache();
    await instance.dispose();
    html.window.localStorage.clear();
  }
}

class MemoryCacheSystem implements FileSystem {
  final Map<String, List<int>> _cache = {};

  @override
  Future<File> createFile(String key) async {
    return MemoryFile(key, this);
  }

  @override
  Future<void> deleteFile(String key) async {
    _cache.remove(key);
  }

  @override
  Future<bool> exists(String key) async {
    return _cache.containsKey(key);
  }

  @override
  Future<File> readFile(String key) async {
    return MemoryFile(key, this);
  }
}
