// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_cache_manager/file_system.dart';
// import 'package:universal_html/html.dart' as html;
// import 'dart:typed_data';

// class WebCacheConfig {
//   static late final CacheManager instance;

//   static Future<void> init() async {
//     instance = CacheManager(
//       Config(
//         'wallpaperWebCache',
//         stalePeriod: const Duration(days: 7),
//         maxNrOfCacheObjects: 200,
//         repo: JsonCacheInfoRepository(databaseName: 'wallpaperWebCache'),
//         fileService: HttpFileService(),
//         fileSystem: MemoryCacheSystem(),
//       ),
//     );
//   }

//   static Future<void> clearCache() async {
//     await instance.emptyCache();
//     await instance.dispose();
//     html.window.localStorage.clear();
//   }
// }

// class MemoryCacheSystem implements FileSystem {
//   final Map<String, List<int>> _cache = {};

//   @override
//   Future<File> createFile(String key) async {
//     return MemoryFile(key, this);
//   }

//   @override
//   Future<void> deleteFile(String key) async {
//     _cache.remove(key);
//   }

//   @override
//   Future<bool> exists(String key) async {
//     return _cache.containsKey(key);
//   }

//   @override
//   Future<File> readFile(String key) async {
//     return MemoryFile(key, this);
//   }

//   void putFile(String key, List<int> bytes) {
//     _cache[key] = bytes;
//   }

//   List<int>? getFileBytes(String key) {
//     return _cache[key];
//   }
// }

// class MemoryFile implements html.File {
//   final String key;
//   final MemoryCacheSystem fileSystem;

//   MemoryFile(this.key, this.fileSystem);

//   @override
//   Future<void> delete() async {
//     await fileSystem.deleteFile(key);
//   }

//   @override
//   String get path => key;

//   @override
//   Future<Uint8List> readAsBytes() async {
//     final bytes = fileSystem.getFileBytes(key);
//     if (bytes == null) {
//       throw Exception('File not found: $key');
//     }
//     return Uint8List.fromList(bytes);
//   }

//   @override
//   Stream<Uint8List> readAsStream() async* {
//     yield await readAsBytes();
//   }

//   @override
//   Future<void> writeAsBytes(List<int> bytes) async {
//     fileSystem.putFile(key, bytes);
//   }

//   @override
//   // TODO: implement lastModified
//   int? get lastModified => throw UnimplementedError();

//   @override
//   // TODO: implement lastModifiedDate
//   DateTime get lastModifiedDate => throw UnimplementedError();

//   @override
//   // TODO: implement name
//   String get name => throw UnimplementedError();

//   @override
//   // TODO: implement relativePath
//   String? get relativePath => throw UnimplementedError();

//   @override
//   // TODO: implement size
//   int get size => throw UnimplementedError();

//   @override
//   html.Blob slice([int? start, int? end, String? contentType]) {
//     throw UnimplementedError();
//   }

//   @override
//   // TODO: implement type
//   String get type => throw UnimplementedError();
// }
