import 'package:flutter/material.dart';
import 'package:flutter_file_manager/screens/vault_screen.dart';
import 'package:flutter_file_manager/screens/settings_screen.dart';
import 'package:flutter_file_manager/screens/category_screen.dart';
import 'package:flutter_file_manager/screens/recycle_bin_screen.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () {
              // Navigate to Home/Files (already there)
            },
          ),
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
            },
          ),
          const SizedBox(width: 48.0), // The space for the FAB
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RecycleBinScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}