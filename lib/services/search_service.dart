import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_keys.dart';

class SearchService {
  static Future<List<Map<String, dynamic>>> searchWallpapers(
    String query, {
    int page = 1,
    int perPage = 80,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.pexels.com/v1/search?query=${Uri.encodeComponent(query)}&per_page=$perPage&page=$page',
        ),
        headers: {'Authorization': ApiKeys.pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['photos']);
      }
      throw Exception('Failed to search wallpapers');
    } catch (e) {
      throw Exception('Error searching wallpapers: $e');
    }
  }
}
