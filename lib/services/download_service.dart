import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DownloadService extends ChangeNotifier {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _error;

  bool get isDownloading => _isDownloading;
  double get progress => _progress;
  String? get error => _error;

  Future<String?> downloadWallpaper(String url, String filename) async {
    try {
      _isDownloading = true;
      _progress = 0.0;
      _error = null;
      notifyListeners();

      if (kIsWeb) {
        return await _downloadForWeb(url);
      } else {
        return await _downloadForMobile(url, filename);
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isDownloading = false;
      _progress = 0.0;
      notifyListeners();
    }
  }

  Future<String?> _downloadForMobile(String url, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename.jpg';
    final file = File(filePath);

    final response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));
    final totalBytes = response.contentLength ?? 0;
    var downloadedBytes = 0;

    final fileStream = file.openWrite();
    await for (final chunk in response.stream) {
      fileStream.add(chunk);
      downloadedBytes += chunk.length;
      _progress = downloadedBytes / totalBytes;
      notifyListeners();
    }
    await fileStream.close();
    return filePath;
  }

  Future<String?> _downloadForWeb(String url) async {
    // Web download implementation
    return url;
  }

  Future<File> getCachedFile(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    return file;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  static Future<void> shareWallpaper(String url) async {
    try {
      await Share.share(
        'Check out this awesome wallpaper: $url',
        subject: 'Fresh Walls Wallpaper',
      );
    } catch (e) {
      print('Share error: $e');
    }
  }
}
