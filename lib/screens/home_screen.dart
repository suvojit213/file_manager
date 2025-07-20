
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/widgets/floating_navbar.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/widgets/file_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_file_manager/screens/destination_selection_screen.dart';
import 'package:flutter_file_manager/screens/file_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();
  List<FileModel> _files = [];
  List<FileModel> _filteredFiles = [];
  String _currentPath = '';
  bool _isLoading = true;
  bool _showHidden = false;
  bool _isSearching = false;
  bool _isGridView = false; // New state for grid/list view
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadFiles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterFiles(_searchController.text);
  }

  void _filterFiles(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFiles = _files;
      });
      return;
    }
    setState(() {
      _filteredFiles = _files
          .where((file) =>
              file.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _requestPermissionsAndLoadFiles() async {
    bool granted = await _fileService.requestStoragePermission();
    if (granted) {
      final paths = await _fileService.getStoragePaths();
      if (paths.isNotEmpty) {
        setState(() {
          _currentPath = paths.first.path;
        });
        _loadFiles(_currentPath);
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle case where no storage paths are found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No accessible storage paths found.')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
    }
  }

  Future<void> _loadFiles(String path) async {
    setState(() {
      _isLoading = true;
      _currentPath = path;
    });
    final files = await _fileService.listFiles(path, showHidden: _showHidden);
    setState(() {
      _files = files;
      _filteredFiles = files; // Initialize filtered files with all files
      _isLoading = false;
    });
  }

  // Dialogs for file operations
  Future<void> _showRenameDialog(FileModel file) async {
    TextEditingController _renameController = TextEditingController(text: file.name);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename'),
          content: TextField(
            controller: _renameController,
            decoration: const InputDecoration(hintText: "New name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () async {
                final newPath = '${file.path.substring(0, file.path.lastIndexOf('/'))}/${_renameController.text}';
                await _fileService.renameFile(file.path, newPath);
                _loadFiles(_currentPath); // Refresh list
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(FileModel file) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: Text('Are you sure you want to delete ${file.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _fileService.deleteFile(file.path);
                _loadFiles(_currentPath); // Refresh list
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateFolderDialog() async {
    TextEditingController _folderNameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: _folderNameController,
            decoration: const InputDecoration(hintText: "Folder name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                final newFolderPath = '${_currentPath}/${_folderNameController.text}';
                await _fileService.createFolder(newFolderPath);
                _loadFiles(_currentPath); // Refresh list
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showZipDialog(FileModel file) async {
    TextEditingController _zipNameController = TextEditingController(text: '${file.name}.zip');
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zip File'),
          content: TextField(
            controller: _zipNameController,
            decoration: const InputDecoration(hintText: "Archive name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Zip'),
              onPressed: () async {
                final outputPath = '${_currentPath}/${_zipNameController.text}';
                await _fileService.zipFiles([file.path], outputPath);
                _loadFiles(_currentPath); // Refresh list
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUnzipDialog(FileModel file) async {
    TextEditingController _unzipPathController = TextEditingController(text: _currentPath);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unzip File'),
          content: TextField(
            controller: _unzipPathController,
            decoration: const InputDecoration(hintText: "Destination path"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Unzip'),
              onPressed: () async {
                await _fileService.unzipFile(file.path, _unzipPathController.text);
                _loadFiles(_currentPath); // Refresh list
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCopyMove(FileModel file, bool isCopy) async {
    final selectedDestination = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const DestinationSelectionScreen(),
      ),
    );

    if (selectedDestination != null) {
      final newPath = '${selectedDestination}/${file.name}';
      if (isCopy) {
        await _fileService.copyFile(file.path, newPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied ${file.name} to $selectedDestination')),
        );
      } else {
        await _fileService.moveFile(file.path, newPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved ${file.name} to $selectedDestination')),
        );
      }
      _loadFiles(_currentPath); // Refresh current directory
    }
  }

  void _showFileOptions(FileModel file) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  _handleCopyMove(file, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_move),
                title: const Text('Move'),
                onTap: () {
                  Navigator.pop(context);
                  _handleCopyMove(file, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _fileService.shareFile(file.path);
                },
              ),
              if (file.type != FileType.directory) // Only show for files
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Zip'),
                  onTap: () {
                    Navigator.pop(context);
                    _showZipDialog(file);
                  },
                ),
              if (file.type == FileType.archive) // Only show for archive files
                ListTile(
                  leading: const Icon(Icons.unarchive),
                  title: const Text('Unzip'),
                  onTap: () {
                    Navigator.pop(context);
                    _showUnzipDialog(file);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Details'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FileDetailsScreen(file: file)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search files...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18.0),
                autofocus: true,
              )
            : Text(_currentPath.split('/').last.isEmpty ? 'File Manager' : _currentPath.split('/').last),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(_showHidden ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showHidden = !_showHidden;
              });
              _loadFiles(_currentPath);
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredFiles.isEmpty
              ? const Center(child: Text('No files or folders found.'))
              : _isGridView
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Adjust as needed
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _filteredFiles.length,
                      itemBuilder: (context, index) {
                        final file = _filteredFiles[index];
                        return GestureDetector(
                          onTap: () {
                            if (file.type == FileType.directory) {
                              _loadFiles(file.path);
                            } else {
                              _fileService.openFile(file.path);
                            }
                          },
                          onLongPress: () {
                            _showFileOptions(file);
                          },
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _fileTileIcon(file.type), // Helper function for icon
                                  size: 48.0,
                                ),
                                Text(
                                  file.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: _filteredFiles.length,
                      itemBuilder: (context, index) {
                        final file = _filteredFiles[index];
                        return FileTile(
                          file: file,
                          onTap: () {
                            if (file.type == FileType.directory) {
                              _loadFiles(file.path);
                            } else {
                              _fileService.openFile(file.path);
                            }
                          },
                          onLongPress: () {
                            _showFileOptions(file);
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateFolderDialog();
        },
        child: const Icon(Icons.create_new_folder),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const FloatingNavBar(),
    );
  }

  IconData _fileTileIcon(FileType type) {
    switch (type) {
      case FileType.directory:
        return Icons.folder;
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.video_file;
      case FileType.audio:
        return Icons.audio_file;
      case FileType.document:
        return Icons.description;
      case FileType.archive:
        return Icons.archive;
      case FileType.file:
      case FileType.other:
      default:
        return Icons.insert_drive_file;
    }
  }
}
