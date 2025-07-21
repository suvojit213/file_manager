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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadFileContent();
  }

  @override
  void dispose() {
    _controller.dispose();
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
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveFileContent,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: HighlightView(
                    _fileContent,
                    language: _getLanguage(),
                    theme: githubTheme,
                    padding: const EdgeInsets.all(12),
                    textStyle: textStyle,
                  ),
                ),
                SingleChildScrollView(
                  child: TextField(
                    controller: _controller,
                    expands: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: textStyle.copyWith(color: Colors.transparent),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}