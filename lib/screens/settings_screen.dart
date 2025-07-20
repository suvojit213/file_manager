
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_file_manager/utils/app_theme.dart';
import 'package:flutter_file_manager/screens/large_files_screen.dart';
import 'package:flutter_file_manager/screens/recent_files_screen.dart';
import 'package:flutter_file_manager/screens/storage_chart_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<AppThemeMode>(
              value: themeNotifier.currentThemeMode,
              onChanged: (AppThemeMode? newValue) {
                if (newValue != null) {
                  themeNotifier.setTheme(newValue);
                }
              },
              items: const <DropdownMenuItem<AppThemeMode>>[
                DropdownMenuItem<AppThemeMode>(
                  value: AppThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem<AppThemeMode>(
                  value: AppThemeMode.dark,
                  child: Text('Dark'),
                ),
                DropdownMenuItem<AppThemeMode>(
                  value: AppThemeMode.amoledBlack,
                  child: Text('AMOLED Black'),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Show Hidden Files'),
            trailing: Switch(
              value: false, // This state should be managed by a provider or similar
              onChanged: (bool value) {
                // Implement logic to show/hide hidden files
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Show Hidden Files: $value')),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Recent Files'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RecentFilesScreen()));
            },
          ),
          ListTile(
            title: const Text('Large Files'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LargeFilesScreen()));
            },
          ),
          ListTile(
            title: const Text('Storage Usage'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StorageChartScreen()));
            },
          ),
          // Add more settings options here
        ],
      ),
    );
  }
}
