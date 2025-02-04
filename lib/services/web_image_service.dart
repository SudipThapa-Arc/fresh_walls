import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class WebImageService {
  static Future<void> downloadImage(String url, String filename) async {
    if (!kIsWeb) return;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Access-Control-Allow-Origin': '*'},
      );

      final contentType = response.headers['content-type'] ?? 'image/jpeg';
      final blob = html.Blob([response.bodyBytes], contentType);
      final urlDownload = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement()
        ..href = urlDownload
        ..setAttribute('download', '$filename.jpg')
        ..style.display = 'none';

      html.document.body!.children.add(anchor);
      anchor.click();

      // Cleanup
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(urlDownload);
    } catch (e) {
      debugPrint('Web image download error: $e');
      rethrow;
    }
  }

  static Future<String> getImageDataUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    return 'data:image/jpeg;base64,${base64Encode(response.bodyBytes)}';
  }
}
