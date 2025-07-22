import 'package:flutter/material.dart';
import 'package:flutter_file_manager/screens/category_screen.dart';
import 'package:flutter_file_manager/screens/recycle_bin_screen.dart';
import 'package:flutter_file_manager/screens/settings_screen.dart';
import 'package:flutter_file_manager/screens/vault_screen.dart';
import 'package:flutter_file_manager/screens/storage_chart_screen.dart';
import 'package:flutter_file_manager/utils/app_theme.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SideBarMenu extends StatefulWidget {
  final ValueChanged<String> onStorageSelected;
  const SideBarMenu({super.key, required this.onStorageSelected});

  @override
  State<SideBarMenu> createState() => _SideBarMenuState();
}

class _SideBarMenuState extends State<SideBarMenu> {
  final FileService _fileService = FileService();
  List<Directory> _storagePaths = [];
  Directory? _selectedStoragePath;
  double _totalSpace = 0.0;
  double _freeSpace = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('selectedStoragePath');

    final paths = await _fileService.getStoragePaths();
    setState(() {
      _storagePaths = paths;
      if (savedPath != null && paths.any((dir) => dir.path == savedPath)) {
        _selectedStoragePath = paths.firstWhere((dir) => dir.path == savedPath);
      } else if (paths.isNotEmpty) {
        _selectedStoragePath = paths.first;
      }
      if (_selectedStoragePath != null) {
        _updateSpaceInfo();
        widget.onStorageSelected(_selectedStoragePath!.path);
      }
    });
  }

  Future<void> _updateSpaceInfo() async {
    if (_selectedStoragePath != null) {
      final total = await _fileService.getTotalSpace(_selectedStoragePath!.path);
      final free = await _fileService.getFreeSpace(_selectedStoragePath!.path);
      setState(() {
        _totalSpace = total;
        _freeSpace = free;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedStoragePath', _selectedStoragePath!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250.0, // Adjust this value as needed
      child: RepaintBoundary(
        child: ListView(
          padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor, // Dynamic background color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File Manager',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, // Use onSurface for text color
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                if (_storagePaths.isNotEmpty)
                  DropdownButton<Directory>(
                    value: _selectedStoragePath,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    onChanged: (Directory? newValue) {
                      setState(() {
                        _selectedStoragePath = newValue;
                        _updateSpaceInfo();
                      });
                      if (newValue != null) {
                        widget.onStorageSelected(newValue.path);
                      }
                    },
                    items: _storagePaths.map<DropdownMenuItem<Directory>>((Directory dir) {
                      return DropdownMenuItem<Directory>(
                        value: dir,
                        child: Text(
                          dir.path.split('/').last.isEmpty ? "Internal Storage" : dir.path.split('/').last,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${AppThemes.formatBytes(_totalSpace.toInt())}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Free: ${AppThemes.formatBytes(_freeSpace.toInt())}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.folder, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Files', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.security, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Vault', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Recycle Bin', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RecycleBinScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.category, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Categories', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.data_usage, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Storage Usage', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StorageChartScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
            title: Text('Settings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}