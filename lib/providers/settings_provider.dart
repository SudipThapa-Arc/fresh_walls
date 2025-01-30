import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  // Settings
  bool _autoWallpaperEnabled = false;
  String _wallpaperInterval = 'daily';
  bool _downloadOriginalQuality = false;
  bool _saveToGallery = false;
  String _downloadLocation = 'internal';
  bool _notificationsEnabled = true;
  String _gridLayout = 'standard'; // standard, compact, comfortable

  // Getters
  bool get isLoading => _isLoading;
  bool get autoWallpaperEnabled => _autoWallpaperEnabled;
  String get wallpaperInterval => _wallpaperInterval;
  bool get downloadOriginalQuality => _downloadOriginalQuality;
  bool get saveToGallery => _saveToGallery;
  String get downloadLocation => _downloadLocation;
  bool get notificationsEnabled => _notificationsEnabled;
  String get gridLayout => _gridLayout;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      _autoWallpaperEnabled = _prefs.getBool('autoWallpaperEnabled') ?? false;
      _wallpaperInterval = _prefs.getString('wallpaperInterval') ?? 'daily';
      _downloadOriginalQuality =
          _prefs.getBool('downloadOriginalQuality') ?? false;
      _saveToGallery = _prefs.getBool('saveToGallery') ?? false;
      _downloadLocation = _prefs.getString('downloadLocation') ?? 'internal';
      _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
      _gridLayout = _prefs.getString('gridLayout') ?? 'standard';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> updateSetting(String key, dynamic value) async {
    try {
      switch (key) {
        case 'autoWallpaperEnabled':
          _autoWallpaperEnabled = value as bool;
          await _prefs.setBool(key, value);
          break;
        case 'wallpaperInterval':
          _wallpaperInterval = value as String;
          await _prefs.setString(key, value);
          break;
        case 'downloadOriginalQuality':
          _downloadOriginalQuality = value as bool;
          await _prefs.setBool(key, value);
          break;
        case 'saveToGallery':
          _saveToGallery = value as bool;
          await _prefs.setBool(key, value);
          break;
        case 'downloadLocation':
          _downloadLocation = value as String;
          await _prefs.setString(key, value);
          break;
        case 'notificationsEnabled':
          _notificationsEnabled = value as bool;
          await _prefs.setBool(key, value);
          break;
        case 'gridLayout':
          _gridLayout = value as String;
          await _prefs.setString(key, value);
          break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating setting: $e');
    }
  }
}
