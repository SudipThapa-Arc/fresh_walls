import 'dart:html' as html;
import 'package:http/http.dart' as http;

class WebDownloadService {
  static Future<void> downloadImage(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      final blob = html.Blob([response.bodyBytes]);
      final urlDownload = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = urlDownload
        ..download = '$filename.jpg'
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(urlDownload);
    } catch (e) {
      print('Download error: $e');
      rethrow;
    }
  }
}
