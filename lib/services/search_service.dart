import 'package:http/http.dart' as http;
import 'package:wallpaper_app/models/search_filters.dart';
import 'dart:convert';
import '../config/api_keys.dart';

class SearchService {
  static Future<List<Map<String, dynamic>>> searchWallpapers(
    String query, {
    SearchFilters? filters,
    int page = 1,
    int perPage = 80,
  }) async {
    try {
      final queryParams = {
        'query': query,
        'per_page': perPage.toString(),
        'page': page.toString(),
        ...filters?.toQueryParameters() ?? {},
      };

      final uri = Uri.https(
        'api.pexels.com',
        '/v1/search',
        queryParams,
      );

      final response = await http.get(
        uri,
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
