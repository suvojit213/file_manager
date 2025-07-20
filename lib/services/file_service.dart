
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:archive/archive_io.dart';

class FileService {
  // Request storage permissions
  static const platform = MethodChannel('com.example.flutter_file_manager/permissions');

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
      final externalStorage = await getExternalStorageDirectories();
      if (externalStorage != null) {
        paths.addAll(externalStorage);
      }
      // Add more common paths if needed, e.g., Downloads, Documents
      // This might require specific platform channels or well-known paths
      // For simplicity, we'll stick to what path_provider gives directly for now.
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
        final entities = directory.listSync(recursive: false, followLinks: false);
        for (var entity in entities) {
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
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
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
      final bytes = File(zipPath).readAsBytesSync();
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
    List<FileModel> allFiles = [];
    await listAllFilesRecursive(path, allFiles);

    for (var file in allFiles) {
      if (file.type == FileType.file && file.size >= minSizeKB * 1024) {
        largeFiles.add(file);
      }
    }
    largeFiles.sort((a, b) => b.size.compareTo(a.size)); // Sort by size, largest first
    return largeFiles;
  }

  // Helper for recursive listing (used by findLargeFiles and CategoryScreen)
  Future<void> listAllFilesRecursive(String path, List<FileModel> fileList) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        final entities = directory.listSync(recursive: false, followLinks: false);
        for (var entity in entities) {
          if (entity is File) {
            fileList.add(FileModel.fromFileSystemEntity(entity));
          } else if (entity is Directory) {
            await listAllFilesRecursive(entity.path, fileList);
          }
        }
      }
    } catch (e) {
      debugPrint('Error listing files recursively: $e');
    }
  }
}
