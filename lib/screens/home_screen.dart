import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/widgets/file_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_file_manager/screens/destination_selection_screen.dart';
import 'package:flutter_file_manager/screens/file_details_screen.dart';
import 'package:flutter_file_manager/screens/text_editor_screen.dart';
import 'package:flutter_file_manager/screens/image_viewer_screen.dart';
import 'package:flutter_file_manager/widgets/directory_item_count.dart';
import 'package:flutter_file_manager/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialPath;
  const HomeScreen({super.key, this.initialPath});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FileService _fileService = FileService();
  List<FileModel> _files = [];
  List<FileModel> _filteredFiles = [];
  String _currentPath = '';
  bool _isLoading = true;
  bool _showHidden = false;
  bool _isSearching = false;
  bool _isGridView = false; // New state for grid/list view
  List<Directory> _storagePaths = []; // New state for storing available storage paths
  Directory? _selectedStoragePath;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialPath != null) {
      _currentPath = widget.initialPath!;
      _loadFiles(_currentPath);
    } else {
      _requestPermissionsAndLoadFiles();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFiles(_currentPath);
    }
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
          _storagePaths = paths;
          if (_currentPath.isEmpty) { // Only set if not already set by initialPath
            _currentPath = paths.first.path;
          }
          _selectedStoragePath = paths.first;
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
          title: const Text('Delete Permanently'),
          content: Text('Are you sure you want to permanently delete "${file.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _fileService.permanentlyDelete(file.path);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${file.name}" permanently deleted.')),
                );
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                final newFolderPath = '$_currentPath/${_folderNameController.text}';
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Zip'),
              onPressed: () async {
                final outputPath = '$_currentPath/${_zipNameController.text}';
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
      final newPath = '$selectedDestination/${file.name}';
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
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontSize: 18.0,
                ),
                autofocus: true,
              )
            : const Text('Files'),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (String result) {
              if (result == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              } else if (result == 'toggle_hidden') {
                setState(() {
                  _showHidden = !_showHidden;
                });
                _loadFiles(_currentPath);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'settings',
                child: const Text('Settings'),
              ),
              PopupMenuItem<String>(
                value: 'toggle_hidden',
                child: Text(_showHidden ? 'Stop showing hidden files' : 'Show hidden files'),
              ),
            ],
          ),
        ],
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                
                
                
                
                
                // Storage selection dropdown
                if (_storagePaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Directory>(
                              value: _selectedStoragePath,
                              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface),
                              onChanged: (Directory? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedStoragePath = newValue;
                                  });
                                  _loadFiles(newValue.path);
                                }
                              },
                              items: _storagePaths.map<DropdownMenuItem<Directory>>((Directory dir) {
                                return DropdownMenuItem<Directory>(
                                  value: dir,
                                  child: Text(
                                    dir.path.split('/').last.isEmpty ? "Internal Storage" : dir.path.split('/').last,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentPath,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _filteredFiles.isEmpty
                      ? const Center(child: Text('No files or folders found.'))
                      : _isGridView
                          ? RefreshIndicator(
                              onRefresh: () => _loadFiles(_currentPath),
                              child: Scrollbar(
                                controller: _scrollController,
                                child: GridView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16.0),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemCount: _filteredFiles.length,
                                  itemBuilder: (context, index) {
                                    final file = _filteredFiles[index];
                                    return GestureDetector(
                                      onTap: () => _handleFileTap(file),
                                      onLongPress: () => _showFileOptions(file),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: _getFolderColor(file.type),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              child: Icon(
                                                _fileTileIcon(file.type),
                                                size: 48.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            file.name,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          if (file.type == FileType.directory)
                                            DirectoryItemCount(file: file),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _loadFiles(_currentPath),
                              child: Scrollbar(
                                controller: _scrollController,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _filteredFiles.length,
                                  itemBuilder: (context, index) {
                                    final file = _filteredFiles[index];
                                    return ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _getFolderColor(file.type),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Icon(
                                          _fileTileIcon(file.type),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(file.name),
                                      subtitle: file.type == FileType.directory
                                          ? DirectoryItemCount(file: file)
                                          : Text(_getFileInfo(file)),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: () => _handleFileTap(file),
                                      onLongPress: () => _showFileOptions(file),
                                    );
                                  },
                                ),
                              ),
                            ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateFolderDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleFileTap(FileModel file) {
    if (file.type == FileType.directory) {
      _loadFiles(file.path);
    }
    else if (file.type == FileType.image) {
      final imagePaths = _filteredFiles
          .where((f) => f.type == FileType.image)
          .map((f) => f.path)
          .toList();
      final initialIndex = imagePaths.indexOf(file.path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(
            imagePaths: imagePaths,
            initialIndex: initialIndex,
          ),
        ),
      );
    } else if (file.path.endsWith('.txt') ||
       file.path.endsWith('.md') ||
       file.path.endsWith('.json') ||
       file.path.endsWith('.xml') ||
       file.path.endsWith('.log') ||
       file.path.endsWith('.csv') ||
       file.path.endsWith('.dart') ||
       file.path.endsWith('.yaml') ||
       file.path.endsWith('.kts') ||
       file.path.endsWith('.gradle') ||
       file.path.endsWith('.properties') ||
       file.path.endsWith('.swift') ||
       file.path.endsWith('.h') ||
       file.path.endsWith('.m') ||
       file.path.endsWith('.c') ||
       file.path.endsWith('.cpp') ||
       file.path.endsWith('.java') ||
       file.path.endsWith('.js') ||
       file.path.endsWith('.ts') ||
       file.path.endsWith('.html') ||
       file.path.endsWith('.css') ||
       file.path.endsWith('.py') ||
       file.path.endsWith('.sh') ||
       file.path.endsWith('.bat') ||
       file.path.endsWith('.ps1')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextEditorScreen(file: file),
        ),
      );
    } else {
      _fileService.openFile(file.path);
    }
  }

  Color _getFolderColor(FileType type) {
    switch (type) {
      case FileType.directory:
        return const Color(0xFF81C784); // Light green
      case FileType.image:
        return Colors.orange;
      case FileType.video:
        return Colors.yellow[700]!;
      case FileType.audio:
        return Colors.green;
      case FileType.document:
        return Colors.blue;
      case FileType.archive:
        return Colors.blue[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getFileInfo(FileModel file) {
    if (file.type == FileType.directory) {
      return '${file.lastModified.day}.${file.lastModified.month.toString().padLeft(2, '0')}.${file.lastModified.year}, ${file.lastModified.hour.toString().padLeft(2, '0')}:${file.lastModified.minute.toString().padLeft(2, '0')}';
    } else {
      return '${file.lastModified.day}.${file.lastModified.month.toString().padLeft(2, '0')}.${file.lastModified.year}, ${file.lastModified.hour.toString().padLeft(2, '0')}:${file.lastModified.minute.toString().padLeft(2, '0')}';
    }
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