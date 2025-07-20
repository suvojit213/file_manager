
import 'dart:io';
import 'package:mime/mime.dart';

enum FileType {
  file,
  directory,
  image,
  video,
  audio,
  document,
  archive,
  other,
}

class FileModel {
  final String name;
  final String path;
  final FileType type;
  final int size;
  final DateTime lastModified;
  final bool isHidden;

  FileModel({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.lastModified,
    this.isHidden = false,
  });

  factory FileModel.fromFileSystemEntity(FileSystemEntity entity) {
    final stat = entity.statSync();
    final isHidden = entity.uri.pathSegments.last.startsWith('.');

    FileType determineFileType(FileSystemEntity entity) {
      if (entity is Directory) {
        return FileType.directory;
      } else if (entity is File) {
        final String mimeType = lookupMimeType(entity.path) ?? '';
        if (mimeType.startsWith('image/')) {
          return FileType.image;
        } else if (mimeType.startsWith('video/')) {
          return FileType.video;
        } else if (mimeType.startsWith('audio/')) {
          return FileType.audio;
        } else if (mimeType == 'application/pdf' ||
            mimeType == 'application/msword' ||
            mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
            mimeType == 'application/vnd.ms-excel' ||
            mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
            mimeType == 'application/vnd.ms-powerpoint' ||
            mimeType == 'application/vnd.openxmlformats-officedocument.presentationml.presentation' ||
            mimeType == 'text/plain') {
          return FileType.document;
        } else if (mimeType == 'application/zip' ||
            mimeType == 'application/x-rar-compressed' ||
            mimeType == 'application/x-7z-compressed') {
          return FileType.archive;
        }
      }
      return FileType.other;
    }

    return FileModel(
      name: entity.uri.pathSegments.last,
      path: entity.path,
      type: determineFileType(entity),
      size: stat.size,
      lastModified: stat.modified,
      isHidden: isHidden,
    );
  }
}
