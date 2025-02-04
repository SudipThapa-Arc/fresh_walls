import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/categories_service.dart';
import 'fullscreen.dart';
import '../services/image_loading_service.dart';

class CategoryWallpapers extends StatefulWidget {
  final String category;
  final Color color;

  const CategoryWallpapers({
    super.key,
    required this.category,
    required this.color,
  });

  @override
  State<CategoryWallpapers> createState() => _CategoryWallpapersState();
}

class _CategoryWallpapersState extends State<CategoryWallpapers> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _wallpapers = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!mounted) return;

    final threshold = 0.8; // Load more when 80% scrolled
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * threshold && !_isLoading && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadWallpapers() async {
    if (_isLoading || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final wallpapers = await CategoriesService.getWallpapersByCategory(
        widget.category,
        page: _currentPage,
      );
      if (mounted) {
        setState(() {
          _wallpapers = wallpapers;
          _isLoading = false;
          _hasMore = wallpapers.length == 80;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading wallpapers: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final wallpapers = await CategoriesService.getWallpapersByCategory(
        widget.category,
        page: _currentPage + 1,
      );
      setState(() {
        _wallpapers.addAll(wallpapers);
        _currentPage++;
        _isLoading = false;
        _hasMore = wallpapers.length == 80;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more wallpapers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color.withOpacity(0.7), widget.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _wallpapers.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width ~/ 300,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _wallpapers.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _wallpapers.length) {
                  return Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: _loadMore,
                            child: const Text('Load More'),
                          ),
                  );
                }

                final wallpaper = _wallpapers[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          Fullscreen(imageurl: wallpaper['src']['large2x']),
                    ),
                  ),
                  child: Hero(
                    tag: wallpaper['src']['large2x'],
                    child: ImageLoadingService.loadImage(
                      imageUrl: wallpaper['src']['large2x'],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    // Cancel any pending operations
    for (var wallpaper in _wallpapers) {
      final imageProvider = NetworkImage(wallpaper['src']['large2x']);
      imageProvider.evict();
    }
    _wallpapers.clear();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images for better performance
    for (var wallpaper in _wallpapers) {
      precacheImage(
        NetworkImage(wallpaper['src']['large2x']),
        context,
      );
    }
  }
}
