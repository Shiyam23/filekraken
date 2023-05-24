import 'dart:io';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';

class ExtractPage extends ConsumerStatefulWidget {
  const ExtractPage({super.key});

  @override
  ConsumerState<ExtractPage> createState() => _ExtractPageState();
}

class _ExtractPageState extends ConsumerState<ExtractPage> {

  final ValueNotifier<int> _depth = ValueNotifier(0);
  String? _rootPath;
  List<String>? _selectedFiles;
  String? mode;

  @override
  void initState() {
    _depth.addListener(refreshDirectories);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FolderSelectionUnit(
          onDirectorySelect: onRootDirectorySelected,
          depth: _depth,
        ),
        FilterDirectoryUnit(
          onDirectorySelect: onDirectorySelect,
          onFilterModeChange: _onDirFilterModeChange,
        ),
        FilterFileUnit(
          onFileSelect: onFileSelect,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(onPressed: moveFiles, child: const Text("Move!")),
        )
      ],
    );
  }

  void onRootDirectorySelected(String rootPath) {
    _rootPath = rootPath;
    ref.read(directoryListStateProvider.notifier).emitDirectories(
      rootPath: rootPath, 
      depth: _depth.value
    );
  }

  void onDirectorySelect(List<String> directories) {
    ref.read(fileListStateProvider.notifier).emitFiles(directories, 0);
  }

  void refreshDirectories() async {
    if (_rootPath != null) {
      ref.read(directoryListStateProvider.notifier).emitDirectories(
        rootPath: _rootPath!, 
        depth: _depth.value,
        shouldRefreshFiles: mode == "None"
      );
    }
  }

  void _onDirFilterModeChange(String mode) {
    if (_rootPath == null) return;
    this.mode = mode;
    switch (mode) {
      case "None":
        ref.read(fileListStateProvider.notifier).emitFiles([_rootPath!], _depth.value + 1);
        break;
      case "By Selection":
      case "By Name":
        ref.read(fileListStateProvider.notifier).reset();
    }
  }

  void onFileSelect(List<String> selectedFiles) {
    _selectedFiles = selectedFiles;
  }

  void moveFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }
    for (String filePath in _selectedFiles!) {
      File selectedFile = File(filePath);
      if (_rootPath != null && await selectedFile.exists()) {
        await selectedFile.rename(path.join(_rootPath!, path.basename(filePath)));
      }
    }
    _selectedFiles?.clear();
    refreshDirectories();
  }
}