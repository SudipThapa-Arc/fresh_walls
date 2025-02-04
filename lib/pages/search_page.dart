import 'dart:async';

import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../widgets/wallpaper_grid.dart';
import '../widgets/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_filters.dart';
import '../widgets/search_filter_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;
  List<String> _recentSearches = [];
  final List<String> _suggestedCategories = [
    'Nature',
    'Abstract',
    'Dark',
    'Minimal',
    'Colorful',
    'Space',
    'Architecture',
    'Art',
    'Pattern',
    'Landscape'
  ];

  SearchFilters _filters = SearchFilters();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = [query, ..._recentSearches.where((item) => item != query)]
      ..take(5).toList();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _performSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _error = null;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final results = await SearchService.searchWallpapers(
          query,
          filters: _filters,
        );
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
        await _saveRecentSearch(query);
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SearchFilterSheet(
            initialFilters: _filters,
            onApply: (filters) {
              setState(() => _filters = filters);
              Navigator.pop(context);
              _performSearch(_searchController.text);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search wallpapers...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: _showFilters,
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: _performSearch,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchController.text.isEmpty) {
      return _buildSuggestions();
    }

    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    return WallpaperGrid(
      wallpapers: _searchResults,
      isLoading: _isLoading,
    );
  }

  Widget _buildSuggestions() {
    return CustomScrollView(
      slivers: [
        if (_recentSearches.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildSection(
              'Recent Searches',
              _recentSearches
                  .map((query) => _buildSuggestionChip(query))
                  .toList(),
            ),
          ),
        SliverToBoxAdapter(
          child: _buildSection(
            'Popular Categories',
            _suggestedCategories
                .map((category) => _buildSuggestionChip(category))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _searchController.text = text;
        _focusNode.unfocus();
        _performSearch(text);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
