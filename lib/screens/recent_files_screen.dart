
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/widgets/file_tile.dart';

class RecentFilesScreen extends StatefulWidget {
  const RecentFilesScreen({super.key});

  @override
  State<RecentFilesScreen> createState() => _RecentFilesScreenState();
}

class _RecentFilesScreenState extends State<RecentFilesScreen> {
  final FileService _fileService = FileService();
  List<FileModel> _recentFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    setState(() {
      _isLoading = true;
    });
    // This is a placeholder. In a real app, you would maintain a list
    // of recently opened files, perhaps in shared preferences or a database.
    // For now, let's just get some files from a common directory and sort by modified date.
    List<FileModel> allFiles = [];
    final paths = await _fileService.getStoragePaths();
    if (paths.isNotEmpty) {
      await _fileService._listAllFilesRecursive(paths.first.path, allFiles);
    }

    allFiles.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    setState(() {
      _recentFiles = allFiles.take(20).toList(); // Take top 20 recent files
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Files'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentFiles.isEmpty
              ? const Center(child: Text('No recent files found.'))
              : ListView.builder(
                  itemCount: _recentFiles.length,
                  itemBuilder: (context, index) {
                    final file = _recentFiles[index];
                    return FileTile(
                      file: file,
                      onTap: () {
                        _fileService.openFile(file.path);
                      },
                      onLongPress: () {
                        // Show file options
                      },
                    );
                  },
                ),
    );
  }
}
