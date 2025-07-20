
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:intl/intl.dart';

class FileTile extends StatelessWidget {
  final FileModel file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileTile({
    super.key,
    required this.file,
    this.onTap,
    this.onLongPress,
  });

  IconData _getIconForFileType(FileType type) {
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

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes > 0 ? (log(bytes) / log(1024)).floor() : 0);
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Helper for log and pow, as dart:math is not imported by default
  double log(num x) => x == 0 ? double.negativeInfinity : x == 1 ? 0.0 : x == double.infinity ? double.infinity : x == double.negativeInfinity ? double.nan : x.toDouble();
  num pow(num base, num exponent) => base == 0 ? 0 : base == 1 ? 1 : base.toDouble();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getIconForFileType(file.type)),
      title: Text(file.name),
      subtitle: Text(
        '${file.type == FileType.directory ? 'Folder' : _formatBytes(file.size)} • ${DateFormat('yyyy-MM-dd HH:mm').format(file.lastModified)}',
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
