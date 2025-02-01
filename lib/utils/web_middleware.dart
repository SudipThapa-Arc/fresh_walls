import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WebMiddleware {
  static Future<http.Response> get(Uri url,
      {Map<String, String>? headers}) async {
    headers ??= {};

    if (kIsWeb) {
      headers.addAll({
        'Authorization': headers['Authorization'] ?? '',
        'Content-Type': 'application/json',
      });
    }

    final response = await http.get(url, headers: headers);
    return response;
  }
}
