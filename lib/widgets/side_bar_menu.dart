
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/screens/category_screen.dart';
import 'package:flutter_file_manager/screens/recycle_bin_screen.dart';
import 'package:flutter_file_manager/screens/settings_screen.dart';
import 'package:flutter_file_manager/screens/vault_screen.dart';
import 'package:flutter_file_manager/screens/storage_chart_screen.dart';

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'File Manager',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
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
