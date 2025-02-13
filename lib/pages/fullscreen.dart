// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../services/web_download_service.dart';
import '../services/wallpaper_manager_service.dart';
import '../widgets/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_keys.dart';

class Fullscreen extends StatefulWidget {
  final String imageurl;
  const Fullscreen({super.key, required this.imageurl});

  @override
  State<Fullscreen> createState() => _FullscreenState();
}

class _FullscreenState extends State<Fullscreen> {
  bool _isLoading = false;
  double _progress = 0.0;
  String? _error;

  Future<void> _setWallpaper(int location) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await WallpaperManagerService.setWallpaper(
        url: widget.imageurl,
        wallpaperLocation: location,
        onProgress: (progress) {
          setState(() => _progress = progress);
        },
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper set successfully!')),
        );
      } else {
        throw Exception('Failed to set wallpaper');
      }
    } catch (e) {
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home Screen'),
            onTap: () {
              Navigator.pop(context);
              _setWallpaper(WallpaperManager.HOME_SCREEN);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Lock Screen'),
            onTap: () {
              Navigator.pop(context);
              _setWallpaper(WallpaperManager.LOCK_SCREEN);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Both Screens'),
            onTap: () {
              Navigator.pop(context);
              _setWallpaper(WallpaperManager.BOTH_SCREEN);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _downloadWallpaper() async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        await WebDownloadService.downloadImage(
          widget.imageurl,
          'wallpaper_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download started!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shareWallpaper() {
    if (kIsWeb) {
      final url = Uri.parse(widget.imageurl);
      html.window.open(url.toString(), 'Fresh Walls');
    }
  }

  Future<void> setwallpaper() async {
    setState(() => _isLoading = true);
    try {
      int location = WallpaperManager.HOME_SCREEN;
      final File file =
          await DefaultCacheManager().getSingleFile(widget.imageurl);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.imageurl,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: widget.imageurl,
                httpHeaders: {'Authorization': ApiKeys.pexelsApiKey},
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingIndicator(),
                errorWidget: (context, url, error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Error: $error'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingIndicator(value: _progress),
                    const SizedBox(height: 16),
                    Text(
                      'Setting wallpaper... ${(_progress * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Error message
          if (_error != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _showWallpaperOptions,
        label: const Text('Set Wallpaper'),
        icon: const Icon(Icons.wallpaper),
      ),
    );
  }
}
