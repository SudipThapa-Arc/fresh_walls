import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/pages/fullscreen.dart';
import 'package:wallpaper_app/config/api_keys.dart';
import 'package:wallpaper_app/models/wallpaper_model.dart';
import 'package:wallpaper_app/utils/refresh_controller.dart';
import '../utils/web_middleware.dart';
import '../services/image_loading_service.dart';

class Wallpaperwid extends StatefulWidget {
  const Wallpaperwid({super.key});

  @override
  State<Wallpaperwid> createState() => _WallpaperwidState();
}

class _WallpaperwidState extends State<Wallpaperwid> {
  List<WallpaperModel> images = [];
  int page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    fetchapi();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      page = 1;
      images.clear();
      _hasMore = true;
      _error = null;
    });
    await fetchapi();
    _refreshController.refreshCompleted();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMore) {
        loadmore();
      }
    }
  }

  Future<void> fetchapi() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=30&page=$page'),
        headers: {
          'Authorization': ApiKeys.pexelsApiKey,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          if (page == 1) {
            images = (result['photos'] as List)
                .map((photo) => WallpaperModel.fromJson(photo))
                .toList();
          } else {
            images.addAll((result['photos'] as List)
                .map((photo) => WallpaperModel.fromJson(photo))
                .toList());
          }
          _hasMore = images.length == 30;
          _isLoading = false;
        });
      } else {
        throw 'Failed to load images: ${response.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> loadmore() async {
    if (!_hasMore || _isLoading) return;
    page++;
    await fetchapi();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => fetchapi(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallpapers')),
      body: _error != null && images.isEmpty
          ? _buildErrorWidget()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= images.length) {
                          return _isLoading ? _buildLoadingIndicator() : null;
                        }
                        return _buildImageCard(images[index]);
                      },
                      childCount: images.length + (_hasMore ? 1 : 0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageCard(WallpaperModel image) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Fullscreen(imageurl: image.src['original'] ?? ''),
          ),
        ),
        child: Hero(
          tag: image.id.toString(),
          child: CachedNetworkImage(
            imageUrl: image.src['medium'] ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
