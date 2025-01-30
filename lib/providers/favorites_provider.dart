import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  static const String _key = 'favorites';
  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList(_key) ?? [];
    _favorites =
        favList.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> toggleFavorite(Map<String, dynamic> wallpaper) async {
    final prefs = await SharedPreferences.getInstance();
    final exists = _favorites.any((f) => f['id'] == wallpaper['id']);

    if (exists) {
      _favorites.removeWhere((f) => f['id'] == wallpaper['id']);
    } else {
      _favorites.add(wallpaper);
    }

    await prefs.setStringList(
      _key,
      _favorites.map((e) => json.encode(e)).toList(),
    );
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((f) => f['id'].toString() == id);
  }
}
