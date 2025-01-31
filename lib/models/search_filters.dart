class SearchFilters {
  final String orientation;
  final String color;
  final String size;
  final String sortBy;

  SearchFilters({
    this.orientation = 'all',
    this.color = 'all',
    this.size = 'all',
    this.sortBy = 'popular',
  });

  SearchFilters copyWith({
    String? orientation,
    String? color,
    String? size,
    String? sortBy,
  }) {
    return SearchFilters(
      orientation: orientation ?? this.orientation,
      color: color ?? this.color,
      size: size ?? this.size,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (orientation != 'all') params['orientation'] = orientation;
    if (color != 'all') params['color'] = color;
    if (size != 'all') params['size'] = size;
    params['sort'] = sortBy;
    return params;
  }

  static const List<String> orientations = [
    'all',
    'portrait',
    'landscape',
    'square'
  ];
  static const List<String> colors = [
    'all',
    'red',
    'orange',
    'yellow',
    'green',
    'blue',
    'purple',
    'pink',
    'brown',
    'black',
    'white',
    'gray'
  ];
  static const List<String> sizes = ['all', 'large', 'medium', 'small'];
  static const List<String> sortOptions = ['popular', 'newest', 'relevant'];
}
