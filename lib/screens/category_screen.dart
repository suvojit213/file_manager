
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/widgets/file_tile.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FileService _fileService = FileService();
  Map<FileType, List<FileModel>> _categorizedFiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _categorizeFiles();
  }

  Future<void> _categorizeFiles() async {
    setState(() {
      _isLoading = true;
    });

    // This is a simplified approach. In a real app, you'd scan specific directories
    // or use a background service to build this index.
    // For demonstration, let's assume we get all files from a common storage path.
    List<FileModel> allFiles = [];
    final paths = await _fileService.getStoragePaths();
    if (paths.isNotEmpty) {
      // Recursively list files from the first storage path
      // This can be very slow for large storage, consider optimizing
      await _fileService.listAllFilesRecursive(paths.first.path, allFiles);
    }

    Map<FileType, List<FileModel>> tempCategories = {
      FileType.image: [],
      FileType.video: [],
      FileType.audio: [],
      FileType.document: [],
      FileType.archive: [],
      FileType.other: [],
    };

    for (var file in allFiles) {
      if (file.type == FileType.file) { // Only categorize actual files, not directories
        if (tempCategories.containsKey(file.type)) {
          tempCategories[file.type]!.add(file);
        } else {
          tempCategories[FileType.other]!.add(file);
        }
      }
    }

    setState(() {
      _categorizedFiles = tempCategories;
      _isLoading = false;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _categorizedFiles.entries.map((entry) {
                if (entry.value.isEmpty) return const SizedBox.shrink();
                return ExpansionTile(
                  title: Text('${entry.key.toString().split('.').last} (${entry.value.length})'),
                  children: entry.value.map((file) => FileTile(
                    file: file,
                    onTap: () {
                      _fileService.openFile(file.path);
                    },
                    onLongPress: () {
                      // Show file options
                    },
                  )).toList(),
                );
              }).toList(),
            ),
    );
  }
}
