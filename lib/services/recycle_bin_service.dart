import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RecycleBinService {
  static const String _recycleBinDirName = '.recycle_bin';
  
  Future<String> _getRecycleBinPath() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception("Could not get external storage directory.");
    }
    final recycleBinPath = p.join(directory.path, _recycleBinDirName);
    final recycleBinDir = Directory(recycleBinPath);
    if (!await recycleBinDir.exists()) {
      await recycleBinDir.create(recursive: true);
    }
    return recycleBinPath;
  }

  Future<void> moveToRecycleBin(String filePath) async {
    final recycleBinPath = await _getRecycleBinPath();
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException("File not found", filePath);
    }

    final fileName = p.basename(filePath);
    final newPath = p.join(recycleBinPath, fileName);

    final metadata = {'originalPath': filePath};
    final metadataFilePath = p.join(recycleBinPath, '$fileName.json');
    await File(metadataFilePath).writeAsString(jsonEncode(metadata));

    await file.rename(newPath);
  }

  Future<void> restoreFile(String filePathInRecycleBin) async {
    final metadataFilePath = '$filePathInRecycleBin.json';
    final metadataFile = File(metadataFilePath);
    if (!await metadataFile.exists()) {
      throw Exception("Metadata file not found for $filePathInRecycleBin");
    }
    final metadataContent = await metadataFile.readAsString();
    final metadata = jsonDecode(metadataContent);
    final originalPath = metadata['originalPath'];

    final file = File(filePathInRecycleBin);
    if (!await file.exists()) {
      throw FileSystemException("File not found in recycle bin", filePathInRecycleBin);
    }
    await file.rename(originalPath);
    await metadataFile.delete(); // Delete metadata after restoring
  }

  Future<void> deletePermanently(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    final metadataFilePath = '$filePath.json';
    final metadataFile = File(metadataFilePath);
    if (await metadataFile.exists()) {
      await metadataFile.delete();
    }
  }

  Future<List<FileSystemEntity>> getRecycleBinContents() async {
    final recycleBinPath = await _getRecycleBinPath();
    final directory = Directory(recycleBinPath);
    if (await directory.exists()) {
      return directory.list().toList();
    }
    return [];
  }
}
