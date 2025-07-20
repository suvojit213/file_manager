
import 'package:flutter/material.dart';

import 'package:flutter_file_manager/services/file_service.dart';
import 'package:flutter_file_manager/models/file_model.dart';



class StorageChartScreen extends StatefulWidget {
  const StorageChartScreen({super.key});

  @override
  State<StorageChartScreen> createState() => _StorageChartScreenState();
}

class _StorageChartScreenState extends State<StorageChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Usage'),
      ),
      body: const Center(
        child: Text('Chart functionality removed due to deprecated library.'),
      ),
    );
  }
}
