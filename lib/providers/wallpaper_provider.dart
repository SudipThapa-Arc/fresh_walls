import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_keys.dart';

class WallpaperState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> wallpapers;
  final List<Map<String, dynamic>> favorites;

  WallpaperState({
    this.isLoading = false,
    this.error,
    this.wallpapers = const [],
    this.favorites = const [],
  });

  WallpaperState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? wallpapers,
    List<Map<String, dynamic>>? favorites,
  }) {
    return WallpaperState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      wallpapers: wallpapers ?? this.wallpapers,
      favorites: favorites ?? this.favorites,
    );
  }
}

class WallpaperProvider with ChangeNotifier {
  WallpaperState _state = WallpaperState();
  WallpaperState get state => _state;

  WallpaperProvider() {
    loadFavorites();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers({int page = 1}) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=80&page=$page'),
        headers: {'Authorization': ApiKeys.pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newWallpapers = List<Map<String, dynamic>>.from(data['photos']);

        _state = _state.copyWith(
          wallpapers: page == 1
              ? newWallpapers
              : [..._state.wallpapers, ...newWallpapers],
          isLoading: false,
        );
      } else {
        throw Exception('Failed to load wallpapers');
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorites') ?? [];
      final favorites =
          favList.map((e) => json.decode(e) as Map<String, dynamic>).toList();

      _state = _state.copyWith(favorites: favorites);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to load favorites');
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> wallpaper) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exists = _state.favorites.any((f) => f['id'] == wallpaper['id']);

      List<Map<String, dynamic>> updatedFavorites;
      if (exists) {
        updatedFavorites =
            _state.favorites.where((f) => f['id'] != wallpaper['id']).toList();
      } else {
        updatedFavorites = [..._state.favorites, wallpaper];
      }

      await prefs.setStringList(
        'favorites',
        updatedFavorites.map((e) => json.encode(e)).toList(),
      );

      _state = _state.copyWith(favorites: updatedFavorites);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to update favorites');
      notifyListeners();
    }
  }

  bool isFavorite(String id) {
    return _state.favorites.any((f) => f['id'].toString() == id);
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }
}
