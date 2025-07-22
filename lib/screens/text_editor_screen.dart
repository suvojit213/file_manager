import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

class TextEditorScreen extends StatefulWidget {
  final FileModel file;

  const TextEditorScreen({super.key, required this.file});

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  late TextEditingController _controller;
  bool _isLoading = true;
  String _fileContent = '';
  String _initialContent = '';
  bool _hasChanges = false;
  bool _isEditMode = false;
  final TextEditingController _searchController = TextEditingController();
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadFileContent();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFileContent() async {
    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      final content = await fileService.readFileAsString(widget.file.path);
      setState(() {
        _fileContent = content;
        _initialContent = content;
        _controller.text = content;
        _isLoading = false;
      });
      _controller.addListener(_onContentChanged);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _fileContent = 'Error loading file: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading file: $e')),
      );
    }
  }

  void _onContentChanged() {
    setState(() {
      _fileContent = _controller.text;
      _hasChanges = _controller.text != _initialContent;
    });
  }

  Future<void> _saveFileContent() async {
    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      await fileService.writeFileAsString(widget.file.path, _controller.text);
      setState(() {
        _initialContent = _controller.text;
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode && _hasChanges) {
        _saveFileContent();
      }
    });
  }

  void _search() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _currentSearchIndex = -1;
      });
      return;
    }
    final content = _fileContent.toLowerCase();
    final results = <int>[];
    int startIndex = 0;
    while (startIndex < content.length) {
      final index = content.indexOf(query.toLowerCase(), startIndex);
      if (index == -1) {
        break;
      }
      results.add(index);
      startIndex = index + query.length;
    }
    setState(() {
      _searchResults = results;
      _currentSearchIndex = results.isNotEmpty ? 0 : -1;
    });
  }

  void _goToNextSearchResult() {
    if (_searchResults.isNotEmpty) {
      setState(() {
        _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
      });
    }
  }

  void _goToPreviousSearchResult() {
    if (_searchResults.isNotEmpty) {
      setState(() {
        _currentSearchIndex =
            (_currentSearchIndex - 1 + _searchResults.length) % _searchResults.length;
      });
    }
  }

  String _getLanguage() {
    final extension = p.extension(widget.file.path).toLowerCase();
    switch (extension) {
      case '.dart':
        return 'dart';
      case '.java':
        return 'java';
      case '.py':
        return 'python';
      case '.js':
        return 'javascript';
      case '.ts':
        return 'typescript';
      case '.html':
        return 'html';
      case '.css':
        return 'css';
      case '.json':
        return 'json';
      case '.xml':
        return 'xml';
      case '.md':
        return 'markdown';
      default:
        return 'plaintext';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.firaMono();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'search') {
                _showSearchDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'search',
                  child: Text('Search'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _isEditMode
                      ? TextField(
                          controller: _controller,
                          expands: true,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: textStyle,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        )
                      : _buildHighlightView(textStyle),
                ),
                if (_searchResults.isNotEmpty) _buildSearchControls(),
              ],
            ),
    );
  }

  Widget _buildHighlightView(TextStyle textStyle) {
    if (_searchResults.isEmpty) {
      return SingleChildScrollView(
        child: HighlightView(
          _fileContent,
          language: _getLanguage(),
          theme: githubTheme,
          padding: const EdgeInsets.all(12),
          textStyle: textStyle,
        ),
      );
    }
    final query = _searchController.text;
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;
    for (int i = 0; i < _searchResults.length; i++) {
      final matchIndex = _searchResults[i];
      if (matchIndex > lastMatchEnd) {
        spans.add(TextSpan(text: _fileContent.substring(lastMatchEnd, matchIndex)));
      }
      spans.add(
        TextSpan(
          text: _fileContent.substring(matchIndex, matchIndex + query.length),
          style: TextStyle(
            backgroundColor: i == _currentSearchIndex ? Colors.yellow : Colors.orange,
          ),
        ),
      );
      lastMatchEnd = matchIndex + query.length;
    }
    if (lastMatchEnd < _fileContent.length) {
      spans.add(TextSpan(text: _fileContent.substring(lastMatchEnd)));
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: RichText(
          text: TextSpan(
            style: textStyle.copyWith(color: Colors.black),
            children: spans,
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search'),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter search term...'),
            onChanged: (value) => _search(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchControls() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${_currentSearchIndex + 1} of ${_searchResults.length}'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: _goToPreviousSearchResult,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: _goToNextSearchResult,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchResults = [];
                    _currentSearchIndex = -1;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}