import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:archive/archive_io.dart';
import 'package:external_path/external_path.dart';


// Top-level function for Isolate
Future<int> _getDirectoryItemCountIsolate(String path) async {
  int count = 0;
  try {
    final directory = Directory(path);
    if (await directory.exists()) {
      await for (var entity in directory.list(recursive: false, followLinks: false)) {
        count++;
      }
    }
  } catch (e) {
    debugPrint('Error getting directory item count in isolate: $e');
  }
  return count;
}

// Top-level function for Isolate to list files recursively
Future<List<FileModel>> _listAllFilesRecursiveIsolate(String path) async {
  List<FileModel> fileList = [];
  try {
    final directory = Directory(path);
    if (await directory.exists()) {
      await for (var entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          fileList.add(FileModel.fromFileSystemEntity(entity));
        }
      }
    }
  } catch (e) {
    debugPrint('Error listing files recursively in isolate: $e');
  }
  return fileList;
}

class FileService {
  // Request storage permissions
  static const platform = MethodChannel('com.example.flutter_file_manager/permissions');
  static const diskSpacePlatform = MethodChannel('com.example.flutter_file_manager/disk_space');

  Future<bool> requestStoragePermission() async {
    try {
      final bool? result = await platform.invokeMethod('requestStoragePermission');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to get permission: '${e.message}'");
      return false;
    }
  }

  // Get common storage paths
  Future<List<Directory>> getStoragePaths() async {
    List<Directory> paths = [];
    if (Platform.isAndroid) {
      final externalStoragePaths = await ExternalPath.getExternalStorageDirectories();
      if (externalStoragePaths != null) {
        for (var path in externalStoragePaths) {
          paths.add(Directory(path));
        }
      }
    } else if (Platform.isIOS) {
      final appDocDir = await getApplicationDocumentsDirectory();
      paths.add(appDocDir);
    }
    return paths;
  }

  // List files and directories in a given path
  Future<List<FileModel>> listFiles(String path, {bool showHidden = false}) async {
    List<FileModel> files = [];
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        debugPrint('Directory exists: $path');
        await for (var entity in directory.list(recursive: false, followLinks: false)) {
          final fileModel = FileModel.fromFileSystemEntity(entity);
          if (!fileModel.isHidden || showHidden) {
            files.add(fileModel);
          }
        }
      }
    } catch (e) {
      debugPrint('Error listing files: $e');
    }
    return files;
  }

  // Placeholder for file operations
  Future<void> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);
    } catch (e) {
      debugPrint('Error copying file: $e');
    }
  }

  Future<void> moveFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      await sourceFile.rename(destinationPath);
    } catch (e) {
      debugPrint('Error moving file: $e');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.file) {
        await File(path).delete();
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error permanently deleting: $e');
    }
  }

  Future<void> renameFile(String oldPath, String newPath) async {
    try {
      if (await File(oldPath).exists()) {
        await File(oldPath).rename(newPath);
      } else if (await Directory(oldPath).exists()) {
        await Directory(oldPath).rename(newPath);
      } else {
        debugPrint('Error renaming: $oldPath does not exist');
      }
    } catch (e) {
      debugPrint('Error renaming file: $e');
    }
  }

  Future<void> createFolder(String path) async {
    try {
      final directory = Directory(path);
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Error creating folder: $e');
    }
  }

  // Share file (requires share_plus package)
  Future<void> shareFile(String path) async {
    try {
      await Share.shareXFiles([XFile(path)]);
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  // Open file (requires open_filex package)
  Future<void> openFile(String path) async {
    try {
      await OpenFilex.open(path);
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  }

  // Zip/Unzip (requires archive package)
  Future<void> zipFiles(List<String> filePaths, String outputPath) async {
    try {
      final encoder = ZipFileEncoder();
      encoder.create(outputPath);
      for (var path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          encoder.addFile(file);
        } else if (await Directory(path).exists()) {
          encoder.addDirectory(Directory(path));
        }
      }
      encoder.close();
    } catch (e) {
      debugPrint('Error zipping files: $e');
    }
  }

  Future<void> unzipFile(String zipPath, String outputPath) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (var file in archive) {
        final filename = '${outputPath}/${file.name}';
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filename).create(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('Error unzipping file: $e');
    }
  }

  // Find large files (simplified)
  Future<List<FileModel>> findLargeFiles(String path, {int minSizeKB = 1024}) async {
    List<FileModel> largeFiles = [];
    List<FileModel> allFiles = await compute(_listAllFilesRecursiveIsolate, path);

    for (var file in allFiles) {
      if (file.type == FileType.file && file.size >= minSizeKB * 1024) {
        largeFiles.add(file);
      }
    }
    largeFiles.sort((a, b) => b.size.compareTo(a.size)); // Sort by size, largest first
    return largeFiles;
  }

  // Helper for recursive listing (used by findLargeFiles and CategoryScreen)
  // This method is now replaced by _listAllFilesRecursiveIsolate for performance
  Future<void> listAllFilesRecursive(String path, List<FileModel> fileList) async {
    // This method is no longer used directly, as recursive listing is now handled by isolates.
    // It's kept for compatibility if other parts of the code still call it, but its implementation
    // should ideally be replaced with calls to _listAllFilesRecursiveIsolate.
    debugPrint('Warning: listAllFilesRecursive is deprecated. Use _listAllFilesRecursiveIsolate via compute for better performance.');
    fileList.addAll(await compute(_listAllFilesRecursiveIsolate, path));
  }

  Future<String> readFileAsString(String path) async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (e) {
      print('Error reading file: $e');
      return ''; // Or throw an exception, depending on desired error handling
    }
  }

  Future<void> writeFileAsString(String path, String content) async {
    try {
      final file = File(path);
      await file.writeAsString(content);
    } catch (e) {
      print('Error writing file: $e');
      // Handle error appropriately
    }
  }

  Future<double> getTotalSpace(String path) async {
    try {
      final Map<dynamic, dynamic>? result = await diskSpacePlatform.invokeMethod(
        'getDiskSpace',
        {'path': path},
      );
      if (result != null && result.containsKey('totalSpace')) {
        return (result['totalSpace'] as int).toDouble();
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get total disk space: '${e.message}'");
    }
    return 0.0;
  }

  Future<double> getFreeSpace(String path) async {
    try {
      final Map<dynamic, dynamic>? result = await diskSpacePlatform.invokeMethod(
        'getDiskSpace',
        {'path': path},
      );
      if (result != null && result.containsKey('freeSpace')) {
        return (result['freeSpace'] as int).toDouble();
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get free disk space: '${e.message}'");
    }
    return 0.0;
  }

  Future<int> getFileOrDirectorySize(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.file) {
        return await File(path).length();
      } else if (entity == FileSystemEntityType.directory) {
        int totalSize = 0;
        final directory = Directory(path);
        if (await directory.exists()) {
          await for (var entity in directory.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              totalSize += await entity.length();
            }
          }
        }
        return totalSize;
      }
    } catch (e) {
      debugPrint('Error getting size: $e');
    }
    return 0;
  }

  Future<void> permanentlyDelete(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.file) {
        await File(path).delete();
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error permanently deleting: $e');
    }
  }

  static Future<List<FileModel>> listAllFilesRecursiveStatic(String path) async {
    // This method is now replaced by _listAllFilesRecursiveIsolate for performance
    return compute(_listAllFilesRecursiveIsolate, path);
  }

  Future<int> getDirectoryItemCount(String path) async {
    return compute(_getDirectoryItemCountIsolate, path);
  }
}

