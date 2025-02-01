import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/theme_service.dart';
import '../widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: Consumer2<SettingsProvider, ThemeService>(
        builder: (context, settings, theme, _) {
          if (settings.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              _buildSection(
                context,
                'Appearance',
                [
                  SwitchListTile(
                    value: theme.isDarkMode,
                    onChanged: (_) => theme.toggleTheme(),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark theme'),
                  ),
                  ListTile(
                    title: const Text('Grid Layout'),
                    subtitle: Text(settings.gridLayout.toUpperCase()),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showGridLayoutPicker(context, settings),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Wallpaper Settings',
                [
                  SwitchListTile(
                    value: settings.autoWallpaperEnabled,
                    onChanged: (value) =>
                        settings.updateSetting('autoWallpaperEnabled', value),
                    title: const Text('Auto Change Wallpaper'),
                    subtitle: const Text('Automatically change wallpaper'),
                  ),
                  if (settings.autoWallpaperEnabled)
                    ListTile(
                      title: const Text('Change Interval'),
                      subtitle: Text(settings.wallpaperInterval.toUpperCase()),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showIntervalPicker(context, settings),
                    ),
                ],
              ),
              _buildSection(
                context,
                'Download Settings',
                [
                  SwitchListTile(
                    value: settings.downloadOriginalQuality,
                    onChanged: (value) => settings.updateSetting(
                        'downloadOriginalQuality', value),
                    title: const Text('Original Quality'),
                    subtitle: const Text('Download in original quality'),
                  ),
                  SwitchListTile(
                    value: settings.saveToGallery,
                    onChanged: (value) =>
                        settings.updateSetting('saveToGallery', value),
                    title: const Text('Save to Gallery'),
                    subtitle: const Text('Save wallpapers to gallery'),
                  ),
                  ListTile(
                    title: const Text('Download Location'),
                    subtitle: Text(settings.downloadLocation.toUpperCase()),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showLocationPicker(context, settings),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Notifications',
                [
                  SwitchListTile(
                    value: settings.notificationsEnabled,
                    onChanged: (value) =>
                        settings.updateSetting('notificationsEnabled', value),
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Get notified about new wallpapers'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showGridLayoutPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Standard'),
            trailing: settings.gridLayout == 'standard'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('gridLayout', 'standard');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Compact'),
            trailing: settings.gridLayout == 'compact'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('gridLayout', 'compact');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Comfortable'),
            trailing: settings.gridLayout == 'comfortable'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('gridLayout', 'comfortable');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Daily'),
            trailing: settings.wallpaperInterval == 'daily'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('wallpaperInterval', 'daily');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Weekly'),
            trailing: settings.wallpaperInterval == 'weekly'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('wallpaperInterval', 'weekly');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Monthly'),
            trailing: settings.wallpaperInterval == 'monthly'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('wallpaperInterval', 'monthly');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Internal Storage'),
            trailing: settings.downloadLocation == 'internal'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('downloadLocation', 'internal');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('External Storage'),
            trailing: settings.downloadLocation == 'external'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              settings.updateSetting('downloadLocation', 'external');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
