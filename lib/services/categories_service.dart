import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_keys.dart';

class CategoriesService {
  static Future<List<Map<String, dynamic>>> getWallpapersByCategory(
    String category, {
    int page = 1,
    int perPage = 80,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.pexels.com/v1/search?query=$category&per_page=$perPage&page=$page',
        ),
        headers: {'Authorization': ApiKeys.pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['photos']);
      }
      throw Exception('Failed to load wallpapers');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
