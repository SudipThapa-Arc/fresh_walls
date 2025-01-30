import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class ImageOptimizationService {
  static Future<File?> optimizeImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 85,
        minWidth: 1080,
        minHeight: 1920,
        rotate: 0,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('Image optimization error: $e');
      return null;
    }
  }

  static Future<List<int>?> optimizeImageBytes(List<int> bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        Uint8List.fromList(bytes),
        quality: 85,
        minWidth: 1080,
        minHeight: 1920,
        rotate: 0,
      );
      return result;
    } catch (e) {
      debugPrint('Image bytes optimization error: $e');
      return null;
    }
  }

  static Future<File?> resizeForThumbnail(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        minWidth: 300,
        minHeight: 300,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('Thumbnail creation error: $e');
      return null;
    }
  }
}
