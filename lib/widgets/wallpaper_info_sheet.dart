import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WallpaperInfoSheet extends StatelessWidget {
  final Map<String, dynamic> wallpaperData;

  const WallpaperInfoSheet({Key? key, required this.wallpaperData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildInfoTile(
            context,
            'Photographer',
            wallpaperData['photographer'] ?? 'Unknown',
            Icons.person,
          ),
          _buildInfoTile(
            context,
            'Resolution',
            '${wallpaperData['width']} x ${wallpaperData['height']}',
            Icons.aspect_ratio,
          ),
          _buildInfoTile(
            context,
            'Size',
            '${(wallpaperData['file_size'] ?? 0) ~/ 1024} KB',
            Icons.data_usage,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                'Download',
                Icons.download,
                () {/* Implement download */},
              ),
              _buildActionButton(
                context,
                'Share',
                Icons.share,
                () {/* Implement share */},
              ),
              _buildActionButton(
                context,
                'Favorite',
                Icons.favorite_border,
                () {/* Implement favorite */},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
