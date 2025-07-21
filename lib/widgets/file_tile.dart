
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_file_manager/utils/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getIconForFileType(file.type)),
      title: Text(file.name),
      subtitle: Text(
        '${file.type == FileType.directory ? 'Folder' : AppThemes.formatBytes(file.size)} • ${DateFormat('yyyy-MM-dd HH:mm').format(file.lastModified)}',
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
