import 'package:flutter/material.dart';
import 'package:flutter_file_manager/screens/home_screen.dart';
import 'package:flutter_file_manager/screens/recent_files_screen.dart';
import 'package:flutter_file_manager/screens/storage_chart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Start with Files tab

  final List<Widget> _screens = [
    const RecentFilesScreen(),
    const HomeScreen(initialPath: null),
    const StorageChartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Storage',
          ),
        ],
      ),
    );
  }
}

