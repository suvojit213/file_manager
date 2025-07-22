'''import 'package:flutter/material.dart';
import 'package:flutter_file_manager/models/file_model.dart';
import 'package:flutter_file_manager/services/file_service.dart';

class DirectoryItemCount extends StatefulWidget {
  final FileModel file;

  const DirectoryItemCount({super.key, required this.file});

  @override
  State<DirectoryItemCount> createState() => _DirectoryItemCountState();
}

class _DirectoryItemCountState extends State<DirectoryItemCount> {
  int? _itemCount;

  @override
  void initState() {
    super.initState();
    _getItemCount();
  }

  Future<void> _getItemCount() async {
    if (widget.file.type == FileType.directory) {
      final count = await FileService().getDirectoryItemCount(widget.file.path);
      if (mounted) {
        setState(() {
          _itemCount = count;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.file.type != FileType.directory) {
      return const SizedBox.shrink();
    }
    return Text(
      _itemCount == null ? '... items' : '$_itemCount items',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[600],
      ),
    );
  }
}
'''