
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:intl/intl.dart';
import 'dart:math' as Math;

class FileDetailsScreen extends StatefulWidget {
  final FileModel file;

  const FileDetailsScreen({super.key, required this.file});

  @override
  State<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends State<FileDetailsScreen> {
  late Future<int> _fileSizeFuture;
  final FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    _fileSizeFuture = _calculateFileSize();
  }

  Future<int> _calculateFileSize() async {
    if (widget.file.type == FileType.directory) {
      return await _fileService.getFileOrDirectorySize(widget.file.path);
    } else {
      return widget.file.size;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes > 0 ? (Math.log(bytes) / Math.log(1024)) : 0).floor();
    return '${(bytes / Math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: FutureBuilder<int>(
        future: _fileSizeFuture,
        builder: (context, snapshot) {
          String sizeText = 'Calculating...';
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              sizeText = 'Error: ${snapshot.error}';
            } else if (snapshot.hasData) {
              sizeText = _formatBytes(snapshot.data!);
            }
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.file.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.file.path,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow(context, Icons.folder_open, 'Type:', widget.file.type.toString().split('.').last),
                        _buildDetailRow(context, Icons.straighten, 'Size:', sizeText),
                        _buildDetailRow(context, Icons.calendar_today, 'Last Modified:', DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.file.lastModified)),
                        _buildDetailRow(context, Icons.visibility_off, 'Hidden:', widget.file.isHidden ? 'Yes' : 'No'),
                      ],
                    ),
                  ),
                ),
                // You can add more sections or details here
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
