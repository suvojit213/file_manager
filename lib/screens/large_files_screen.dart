
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/widgets/file_tile.dart';

class LargeFilesScreen extends StatefulWidget {
  const LargeFilesScreen({super.key});

  @override
  State<LargeFilesScreen> createState() => _LargeFilesScreenState();
}

class _LargeFilesScreenState extends State<LargeFilesScreen> {
  final FileService _fileService = FileService();
  List<FileModel> _largeFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLargeFiles();
  }

  Future<void> _loadLargeFiles() async {
    setState(() {
      _isLoading = true;
    });
    // For simplicity, scanning the first storage path. In a real app,
    // you might want to scan all accessible storage or allow user to select.
    final paths = await _fileService.getStoragePaths();
    if (paths.isNotEmpty) {
      final files = await _fileService.findLargeFiles(paths.first.path);
      setState(() {
        _largeFiles = files;
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
        title: const Text('Large Files'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _largeFiles.isEmpty
              ? const Center(child: Text('No large files found.'))
              : ListView.builder(
                  itemCount: _largeFiles.length,
                  itemBuilder: (context, index) {
                    final file = _largeFiles[index];
                    return FileTile(
                      file: file,
                      onTap: () {
                        _fileService.openFile(file.path);
                      },
                      onLongPress: () {
                        // Show file options (copy, move, delete, etc.)
                      },
                    );
                  },
                ),
    );
  }
}
