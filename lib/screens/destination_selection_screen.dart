
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/widgets/file_tile.dart';

class DestinationSelectionScreen extends StatefulWidget {
  const DestinationSelectionScreen({super.key});

  @override
  State<DestinationSelectionScreen> createState() => _DestinationSelectionScreenState();
}

class _DestinationSelectionScreenState extends State<DestinationSelectionScreen> {
  final FileService _fileService = FileService();
  List<FileModel> _directories = [];
  String _currentPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialDirectories();
  }

  Future<void> _loadInitialDirectories() async {
    final paths = await _fileService.getStoragePaths();
    if (paths.isNotEmpty) {
      setState(() {
        _currentPath = paths.first.path;
      });
      _loadDirectories(_currentPath);
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No accessible storage paths found.')),
      );
    }
  }

  Future<void> _loadDirectories(String path) async {
    setState(() {
      _isLoading = true;
      _currentPath = path;
    });
    final files = await _fileService.listFiles(path);
    setState(() {
      _directories = files.where((file) => file.type == FileType.directory).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Destination: ${_currentPath.split('/').last}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _currentPath); // Return selected path
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_currentPath != '/' && _currentPath.isNotEmpty) // Allow going up from root
                  ListTile(
                    leading: const Icon(Icons.arrow_upward),
                    title: const Text('..'),
                    onTap: () {
                      final parentPath = _currentPath.substring(0, _currentPath.lastIndexOf('/'));
                      _loadDirectories(parentPath.isEmpty ? '/' : parentPath);
                    },
                  ),
                Expanded(
                  child: _directories.isEmpty
                      ? const Center(child: Text('No subdirectories found.'))
                      : ListView.builder(
                          itemCount: _directories.length,
                          itemBuilder: (context, index) {
                            final directory = _directories[index];
                            return FileTile(
                              file: directory,
                              onTap: () {
                                _loadDirectories(directory.path);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
