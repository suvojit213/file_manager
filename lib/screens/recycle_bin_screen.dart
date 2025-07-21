import 'package:flutter/material.dart';
import 'package:flutter_file_manager/services/recycle_bin_service.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final RecycleBinService _recycleBinService = RecycleBinService();
  List<FileSystemEntity> _recycledFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecycledFiles();
  }

  Future<void> _loadRecycledFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _recycledFiles = await _recycleBinService.getRecycleBinContents();
    } catch (e) {
      debugPrint('Error loading recycled files: $e');
      // Optionally show an error message to the user
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _restoreFile(String filePathInRecycleBin) async {
    try {
      await _recycleBinService.restoreFile(filePathInRecycleBin);
      _loadRecycledFiles(); // Reload files after restoration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File restored: ${p.basename(filePathInRecycleBin)}')),
      );
    } catch (e) {
      debugPrint('Error restoring file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore file: ${p.basename(filePathInRecycleBin)}')),
      );
    }
  }

  Future<void> _deletePermanently(String filePath) async {
    try {
      await _recycleBinService.deletePermanently(filePath);
      _loadRecycledFiles(); // Reload files after permanent deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File permanently deleted: ${p.basename(filePath)}')),
      );
    } catch (e) {
      debugPrint('Error permanently deleting file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to permanently delete file: ${p.basename(filePath)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Bin'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recycledFiles.isEmpty
              ? const Center(child: Text('Recycle Bin is empty.'))
              : ListView.builder(
                  itemCount: _recycledFiles.length,
                  itemBuilder: (context, index) {
                    final entity = _recycledFiles[index];
                    final fileName = p.basename(entity.path);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: Icon(entity is File ? Icons.insert_drive_file : Icons.folder),
                        title: Text(fileName),
                        subtitle: Text(entity.path), // Show full path for context
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore, color: Colors.green),
                              onPressed: () => _restoreFile(entity.path),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => _deletePermanently(entity.path),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
