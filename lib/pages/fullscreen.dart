import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../services/web_download_service.dart';
import '../services/wallpaper_manager_service.dart';
import '../widgets/loading_indicator.dart';

class Fullscreen extends StatefulWidget {
  final String imageurl;
  const Fullscreen({Key? key, required this.imageurl}) : super(key: key);

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

      if (!success) throw Exception('Failed to set wallpaper');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper set successfully!')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image display with optimization
          Hero(
            tag: widget.imageurl,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.imageurl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: LoadingIndicator());
                },
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
