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
  List<String>? _selectedFiles;
  FilterMode directoryFilterMode = FilterMode.none;

  @override
  void initState() {
    _depth.addListener(refreshDirectories);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      String rootPath = ref.read(rootDirectoryProvider);
      if (rootPath != "") {
        ref.read(directoryListStateProvider.notifier).emitDirectories(
          rootPath: rootPath, depth: 0
        );
      }
    });
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
          initialFilterMode: directoryFilterMode,
          onDirectorySelect: onDirectorySelect,
          onFilterModeChange: _onDirFilterModeChange,
        ),
        FilterFileUnit(
          onFileSelect: onFileSelect,
          initialFilterMode: FilterMode.none,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(onPressed: moveFiles, child: const Text("Move!")),
        )
      ],
    );
  }

  void onRootDirectorySelected(String rootPath) {
    ref.read(rootDirectoryProvider.notifier).state = rootPath;
    ref.read(directoryListStateProvider.notifier).emitDirectories(
      rootPath: rootPath, 
      depth: _depth.value
    );
  }

  void onDirectorySelect(List<String> directories) {
    ref.read(fileListStateProvider.notifier).emitFiles(directories, 0);
  }

  void refreshDirectories() async {
    String rootPath = ref.read(rootDirectoryProvider);
    if (rootPath != "") {
      ref.read(directoryListStateProvider.notifier).emitDirectories(
        rootPath: rootPath, 
        depth: _depth.value,
        shouldRefreshFiles: directoryFilterMode == FilterMode.none
      );
    }
  }

  void _onDirFilterModeChange(FilterMode mode) {
    String rootPath = ref.read(rootDirectoryProvider);
    if (rootPath == "") return;
    directoryFilterMode = mode;
    switch (mode) {
      case FilterMode.none:
        ref.read(fileListStateProvider.notifier).emitFiles([rootPath], _depth.value + 1);
        break;
      case FilterMode.bySelection:
      case FilterMode.byName:
        ref.read(fileListStateProvider.notifier).reset();
    }
  }

  void onFileSelect(List<String> selectedFiles) {
    _selectedFiles = selectedFiles;
  }

  void moveFiles() async {
    String rootPath = ref.read(rootDirectoryProvider);
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }
    for (String filePath in _selectedFiles!) {
      File selectedFile = File(filePath);
      if (rootPath != "" && await selectedFile.exists()) {
        await selectedFile.rename(path.join(rootPath, path.basename(filePath)));
      }
    }
    _selectedFiles?.clear();
    refreshDirectories();
  }
}