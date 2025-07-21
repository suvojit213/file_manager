
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:intl/intl.dart';
import 'dart:math' as Math;

class FileDetailsScreen extends StatelessWidget {
  final FileModel file;

  const FileDetailsScreen({super.key, required this.file});

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name:', file.name),
            _buildDetailRow('Path:', file.path),
            _buildDetailRow('Type:', file.type.toString().split('.').last),
            _buildDetailRow('Size:', _formatBytes(file.size)),
            _buildDetailRow('Last Modified:', DateFormat('yyyy-MM-dd HH:mm:ss').format(file.lastModified)),
            _buildDetailRow('Hidden:', file.isHidden ? 'Yes' : 'No'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
