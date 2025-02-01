import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/category_wallpapers.dart';

class CategoriesPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Nature',
      'icon': Icons.landscape,
      'color': Colors.green,
    },
    {
      'name': 'Abstract',
      'icon': Icons.pattern,
      'color': Colors.purple,
    },
    {
      'name': 'Architecture',
      'icon': Icons.apartment,
      'color': Colors.brown,
    },
    {
      'name': 'Space',
      'icon': Icons.stars,
      'color': Colors.indigo,
    },
    {
      'name': 'Animals',
      'icon': Icons.pets,
      'color': Colors.orange,
    },
    {
      'name': 'Minimal',
      'icon': Icons.crop_square,
      'color': Colors.grey,
    },
    {
      'name': 'Technology',
      'icon': Icons.computer,
      'color': Colors.blue,
    },
    {
      'name': 'Cars',
      'icon': Icons.directions_car,
      'color': Colors.red,
    },
    {
      'name': 'Cities',
      'icon': Icons.location_city,
      'color': Colors.teal,
    },
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': Colors.amber,
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_basketball,
      'color': Colors.deepOrange,
    },
    {
      'name': 'Art',
      'icon': Icons.palette,
      'color': Colors.pink,
    },
    // Add more categories...
  ];

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width ~/ 180,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryWallpapers(
                category: category['name'],
                color: category['color'],
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category['icon'],
              size: 48,
              color: category['color'],
            ),
            const SizedBox(height: 8),
            Text(
              category['name'],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
