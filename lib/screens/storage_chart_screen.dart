
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/models/file_model.dart';

class StorageInfo {
  final String category;
  final int size;
  final charts.Color color;

  StorageInfo(this.category, this.size, this.color);
}

class StorageChartScreen extends StatefulWidget {
  const StorageChartScreen({super.key});

  @override
  State<StorageChartScreen> createState() => _StorageChartScreenState();
}

class _StorageChartScreenState extends State<StorageChartScreen> {
  final FileService _fileService = FileService();
  List<charts.Series<StorageInfo, String>> _seriesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    setState(() {
      _isLoading = true;
    });

    Map<FileType, int> categorySizes = {
      FileType.image: 0,
      FileType.video: 0,
      FileType.audio: 0,
      FileType.document: 0,
      FileType.archive: 0,
      FileType.other: 0,
    };

    List<FileModel> allFiles = [];
    final paths = await _fileService.getStoragePaths();
    if (paths.isNotEmpty) {
      await _fileService._listAllFilesRecursive(paths.first.path, allFiles);
    }

    for (var file in allFiles) {
      if (file.type == FileType.file) {
        categorySizes[file.type] = (categorySizes[file.type] ?? 0) + file.size;
      }
    }

    final data = [
      StorageInfo('Images', categorySizes[FileType.image]!, charts.MaterialPalette.blue.shadeDefault),
      StorageInfo('Videos', categorySizes[FileType.video]!, charts.MaterialPalette.red.shadeDefault),
      StorageInfo('Audio', categorySizes[FileType.audio]!, charts.MaterialPalette.green.shadeDefault),
      StorageInfo('Documents', categorySizes[FileType.document]!, charts.MaterialPalette.purple.shadeDefault),
      StorageInfo('Archives', categorySizes[FileType.archive]!, charts.MaterialPalette.deepOrange.shadeDefault),
      StorageInfo('Other', categorySizes[FileType.other]!, charts.MaterialPalette.teal.shadeDefault),
    ];

    setState(() {
      _seriesList = [
        charts.Series<StorageInfo, String>(
          id: 'Storage Usage',
          domainFn: (StorageInfo info, _) => info.category,
          measureFn: (StorageInfo info, _) => info.size,
          colorFn: (StorageInfo info, _) => info.color,
          data: data,
        )
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Usage'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: charts.PieChart<String>(
                _seriesList,
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.auto)
                  ],
                ),
              ),
            ),
    );
  }
}
