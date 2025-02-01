import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../pages/fullscreen.dart';
import '../services/image_cache_service.dart';
import '../services/image_loading_service.dart';

class WallpaperGrid extends StatelessWidget {
  final List<Map<String, dynamic>> wallpapers;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final ScrollController? scrollController;

  const WallpaperGrid({
    super.key,
    required this.wallpapers,
    this.isLoading = false,
    this.onLoadMore,
    this.onRefresh,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (wallpapers.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wallpapers.isEmpty && !isLoading) {
      return const Center(
        child: Text('No wallpapers found'),
      );
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final crossAxisCount = _getCrossAxisCount(context, settings.gridLayout);
        final aspectRatio = _getAspectRatio(settings.gridLayout);

        Widget grid = GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: wallpapers.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == wallpapers.length) {
              if (isLoading) {
                return const _LoadingTile();
              }
              return const SizedBox.shrink();
            }

            // Preload next 5 images
            if (index + 5 < wallpapers.length) {
              ImageCacheService.preloadImage(
                wallpapers[index + 5]['src']['large2x'],
              );
            }

            return _WallpaperTile(
              wallpaper: wallpapers[index],
              layout: settings.gridLayout,
            );
          },
        );

        if (onRefresh != null) {
          grid = RefreshIndicator(
            onRefresh: onRefresh!,
            child: grid,
          );
        }

        return grid;
      },
    );
  }

  int _getCrossAxisCount(BuildContext context, String layout) {
    final width = MediaQuery.of(context).size.width;
    switch (layout) {
      case 'compact':
        return width ~/ 150;
      case 'comfortable':
        return width ~/ 300;
      default:
        return width ~/ 200;
    }
  }

  double _getAspectRatio(String layout) {
    switch (layout) {
      case 'compact':
        return 0.8;
      case 'comfortable':
        return 0.7;
      default:
        return 0.75;
    }
  }
}

class _WallpaperTile extends StatefulWidget {
  final Map<String, dynamic> wallpaper;
  final String layout;

  const _WallpaperTile({
    super.key,
    required this.wallpaper,
    required this.layout,
  });

  @override
  State<_WallpaperTile> createState() => _WallpaperTileState();
}

class _WallpaperTileState extends State<_WallpaperTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                Fullscreen(imageurl: widget.wallpaper['src']['large2x']),
          ),
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.wallpaper['src']['large2x'],
                    child: ImageLoadingService.buildImage(
                      url: widget.wallpaper['src']['large2x'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_isHovered) ...[
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Consumer<WallpaperProvider>(
                        builder: (context, provider, _) {
                          final isFavorite = provider
                              .isFavorite(widget.wallpaper['id'].toString());
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                provider.toggleFavorite(widget.wallpaper),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
