
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
            leading: const Icon(Icons.folder),
            title: const Text('Files'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Vault'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Recycle Bin'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RecycleBinScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Storage Usage'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StorageChartScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}
