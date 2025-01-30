import 'package:flutter/material.dart';
import '../services/cache_manager.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Try to load cached content
                final cachedWallpapers = await CustomCacheManager.instance
                    .getFileFromCache('cached_wallpapers');
                if (cachedWallpapers != null) {
                  // Handle cached content
                }
              },
              child: const Text('Load Offline Content'),
            ),
          ],
        ),
      ),
    );
  }
}
