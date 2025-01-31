class WallpaperModel {
  final int id;
  final String originalUrl;
  final String photographerName;
  final String photographerUrl;
  final int photographerId;
  final Map<String, String> src;

  WallpaperModel({
    required this.id,
    required this.originalUrl,
    required this.photographerName,
    required this.photographerUrl,
    required this.photographerId,
    required this.src,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'],
      originalUrl: json['url'],
      photographerName: json['photographer'],
      photographerUrl: json['photographer_url'],
      photographerId: json['photographer_id'],
      src: Map<String, String>.from(json['src']),
    );
  }
}
