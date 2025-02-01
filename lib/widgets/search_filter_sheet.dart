import 'package:flutter/material.dart';
import '../models/search_filters.dart';

class SearchFilterSheet extends StatefulWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onApply;

  const SearchFilterSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  Widget _buildFilterSection(
    String title,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = value == option;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    label: Text(option.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) => onChanged(option),
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : null,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Filter Wallpapers'),
            actions: [
              TextButton(
                onPressed: () => widget.onApply(_filters),
                child: const Text('Apply'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                _buildFilterSection(
                  'Orientation',
                  _filters.orientation,
                  SearchFilters.orientations,
                  (value) => setState(() {
                    _filters = _filters.copyWith(orientation: value);
                  }),
                ),
                _buildFilterSection(
                  'Color',
                  _filters.color,
                  SearchFilters.colors,
                  (value) => setState(() {
                    _filters = _filters.copyWith(color: value);
                  }),
                ),
                _buildFilterSection(
                  'Size',
                  _filters.size,
                  SearchFilters.sizes,
                  (value) => setState(() {
                    _filters = _filters.copyWith(size: value);
                  }),
                ),
                _buildFilterSection(
                  'Sort By',
                  _filters.sortBy,
                  SearchFilters.sortOptions,
                  (value) => setState(() {
                    _filters = _filters.copyWith(sortBy: value);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
