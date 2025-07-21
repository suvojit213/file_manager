import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/screens/category_screen.dart';

class StorageChartScreen extends StatefulWidget {
  const StorageChartScreen({super.key});

  @override
  State<StorageChartScreen> createState() => _StorageChartScreenState();
}

class _StorageChartScreenState extends State<StorageChartScreen> {
  final FileService _fileService = FileService();
  Map<String, double> _storageData = {};
  Map<String, double> _categoryData = {};
  bool _isLoading = true;
  double _totalSpace = 0;
  double _freeSpace = 0;

  @override
  void initState() {
    super.initState();
    _getStorageData();
  }

  Future<void> _getStorageData() async {
    setState(() {
      _isLoading = true;
    });

    final paths = await _fileService.getStoragePaths();
    if (paths.isNotEmpty) {
      _totalSpace = await _fileService.getTotalSpace(paths.first.path);
      _freeSpace = await _fileService.getFreeSpace(paths.first.path);
      final usedSpace = _totalSpace - _freeSpace;

      // Mock category data - in real app, you'd calculate actual sizes
      _categoryData = {
        'Apps': _totalSpace * 0.15,
        'Images': _totalSpace * 0.12,
        'Videos': _totalSpace * 0.10,
        'Audio': _totalSpace * 0.15,
        'Documents': _totalSpace * 0.05,
        'Archives': _totalSpace * 0.08,
        'Others': _totalSpace * 0.03,
      };

      setState(() {
        _storageData = {
          'Used': usedSpace,
          'Free': _freeSpace,
        };
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  
                  // Storage info
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[900]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Internal',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${_formatBytes(_freeSpace.toInt())} of ${_formatBytes(_totalSpace.toInt())} Free',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Storage bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[300],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: (_categoryData['Apps']! / _totalSpace * 100).round(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (_categoryData['Images']! / _totalSpace * 100).round(),
                                child: Container(color: Colors.orange),
                              ),
                              Expanded(
                                flex: (_categoryData['Videos']! / _totalSpace * 100).round(),
                                child: Container(color: Colors.yellow),
                              ),
                              Expanded(
                                flex: (_categoryData['Audio']! / _totalSpace * 100).round(),
                                child: Container(color: Colors.green),
                              ),
                              Expanded(
                                flex: (_categoryData['Documents']! / _totalSpace * 100).round(),
                                child: Container(color: Colors.blue),
                              ),
                              Expanded(
                                flex: (_categoryData['Archives']! / _totalSpace * 100).round(),
                                child: Container(color: Colors.purple),
                              ),
                              Expanded(
                                flex: (_categoryData['Others']! / _totalSpace * 100).round(),
                                child: Container(color: Colors.pink),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Legend
                        Row(
                          children: [
                            _buildLegendItem(Colors.red, 'Apps'),
                            const SizedBox(width: 16),
                            _buildLegendItem(Colors.green, 'Audio'),
                            const SizedBox(width: 16),
                            _buildLegendItem(Colors.grey, 'System'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Manage storage
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              const Text(
                                'Manage storage',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Category list
                  ..._buildCategoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryList() {
    final categories = [
      {'name': 'Apps', 'icon': Icons.apps, 'color': Colors.blue, 'size': _categoryData['Apps']!},
      {'name': 'Images', 'icon': Icons.image, 'color': Colors.orange, 'size': _categoryData['Images']!},
      {'name': 'Videos', 'icon': Icons.video_library, 'color': Colors.yellow, 'size': _categoryData['Videos']!},
      {'name': 'Audio', 'icon': Icons.music_note, 'color': Colors.green, 'size': _categoryData['Audio']!},
      {'name': 'Documents', 'icon': Icons.description, 'color': Colors.blue, 'size': _categoryData['Documents']!},
      {'name': 'Archives', 'icon': Icons.archive, 'color': Colors.blue, 'size': _categoryData['Archives']!},
      {'name': 'Others', 'icon': Icons.help_outline, 'color': Colors.purple, 'size': _categoryData['Others']!},
    ];

    return categories.map((category) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category['color'] as Color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category['icon'] as IconData,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            category['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatBytes((category['size'] as double).toInt()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryScreen(),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes > 0 ? (log(bytes) / log(1024)) : 0).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}