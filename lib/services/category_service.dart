import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/api_keys.dart';
import '../utils/web_middleware.dart';

class CategoryService extends ChangeNotifier {
  bool _disposed = false;
  final Map<String, List<Map<String, dynamic>>> _categoryWallpapers = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errors = {};
  final Map<String, int> _currentPages = {};

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool isLoading(String category) => _loadingStates[category] ?? false;
  String? getError(String category) => _errors[category];
  List<Map<String, dynamic>> getWallpapers(String category) =>
      _categoryWallpapers[category] ?? [];

  Future<void> fetchWallpapers(String category, {bool refresh = false}) async {
    if (_loadingStates[category] ?? false) return;

    try {
      _loadingStates[category] = true;
      _errors[category] = null;
      notifyListeners();

      if (refresh) {
        _currentPages[category] = 1;
        _categoryWallpapers[category] = [];
      }

      final page = _currentPages[category] ?? 1;
      final response = await WebMiddleware.get(
        Uri.parse(
            'https://api.pexels.com/v1/search?query=$category&per_page=80&page=$page'),
        headers: {'Authorization': ApiKeys.pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final wallpapers = List<Map<String, dynamic>>.from(data['photos']);

        _categoryWallpapers[category] = [
          ...(_categoryWallpapers[category] ?? []),
          ...wallpapers,
        ];
        _currentPages[category] = page + 1;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load wallpapers: ${response.statusCode}');
      }
    } catch (e) {
      _errors[category] = e.toString();
    } finally {
      _loadingStates[category] = false;
      notifyListeners();
    }
  }

  void clearError(String category) {
    _errors[category] = null;
    notifyListeners();
  }
}
