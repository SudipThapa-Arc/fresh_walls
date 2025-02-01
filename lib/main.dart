import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/services/theme_service.dart';
import 'package:wallpaper_app/services/connectivity_service.dart';
import 'package:wallpaper_app/pages/offline_page.dart';
// import 'package:wallpaper_app/pages/main_screen.dart';
import 'package:wallpaper_app/pages/wallpaper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wallpaper_app/providers/wallpaper_provider.dart';
import 'package:wallpaper_app/pages/categories_page.dart';
import 'package:wallpaper_app/pages/favorites_page.dart';
import 'widgets/page_transitions.dart';
import 'pages/search_page.dart';
import 'package:wallpaper_app/services/navigation_service.dart';
import 'package:wallpaper_app/services/image_cache_service.dart';
import 'package:wallpaper_app/widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  ImageCacheService.initCache();

  runApp(
    MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeService()),
          ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ChangeNotifierProvider(create: (_) => WallpaperProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Consumer2<ThemeService, ConnectivityService>(
        builder: (context, themeService, connectivityService, _) {
          if (!connectivityService.hasConnection) {
            return MaterialApp(
              theme: themeService.theme,
              home: const OfflinePage(),
            );
          }

          return MaterialApp(
            title: 'Fresh Walls',
            theme: themeService.theme,
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.blue,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Wallpaperwid(),
    CategoriesPage(),
    FavoritesPage(),
  ];

  void _navigateToSearch() {
    Navigator.push(
      context,
      FadePageRoute(
        child: const SearchPage(),
        routeName: '/search',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: _currentIndex == 1 ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: _navigateToSearch,
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}
