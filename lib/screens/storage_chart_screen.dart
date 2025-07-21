import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_file_manager/services/file_service.dart';

class StorageChartScreen extends StatefulWidget {
  const StorageChartScreen({super.key});

  @override
  State<StorageChartScreen> createState() => _StorageChartScreenState();
}

class _StorageChartScreenState extends State<StorageChartScreen> {
  final FileService _fileService = FileService();
  Map<String, double> _storageData = {};
  bool _isLoading = true;

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
      final totalSpace = await _fileService.getTotalSpace(paths.first.path);
      final freeSpace = await _fileService.getFreeSpace(paths.first.path);
      final usedSpace = totalSpace - freeSpace;

      setState(() {
        _storageData = {
          'Used': usedSpace,
          'Free': freeSpace,
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
        title: const Text('Storage Usage'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _storageData.isEmpty
              ? const Center(child: Text('Could not retrieve storage data.'))
              : Center(
                  child: PieChart(
                    PieChartData(
                      sections: _storageData.entries.map((entry) {
                        return PieChartSectionData(
                          color: entry.key == 'Used' ? Colors.red : Colors.green,
                          value: entry.value,
                          title: '${entry.key}\n(${_formatBytes(entry.value.toInt())})',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes > 0 ? (log(bytes) / log(1024)) : 0).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}