import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/pages/fullscreen.dart';
import 'package:wallpaper_app/config/api_keys.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/wallpaper_grid.dart';

class Wallpaperwid extends StatefulWidget {
  const Wallpaperwid({super.key});

  @override
  State<Wallpaperwid> createState() => _WallpaperwidState();
}

class _WallpaperwidState extends State<Wallpaperwid> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _refreshWallpapers();
  }

  Future<void> _refreshWallpapers() async {
    final provider = Provider.of<WallpaperProvider>(context, listen: false);
    await provider.fetchWallpapers(page: 1);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final provider = Provider.of<WallpaperProvider>(context, listen: false);
    if (!provider.state.isLoading) {
      _currentPage++;
      await provider.fetchWallpapers(page: _currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Fresh Walls'),
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, _) {
          if (provider.state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.state.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      _refreshWallpapers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return WallpaperGrid(
            wallpapers: provider.state.wallpapers,
            isLoading: provider.state.isLoading,
            onLoadMore: _loadMore,
            onRefresh: _refreshWallpapers,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
