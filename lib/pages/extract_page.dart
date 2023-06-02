import 'dart:async';
import 'package:filekraken/components/dialogs/error_dialogs.dart';
import 'package:filekraken/components/dialogs/result_dialog.dart';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';

class ExtractPage extends ConsumerStatefulWidget {
  const ExtractPage({super.key});

  @override
  ConsumerState<ExtractPage> createState() => _ExtractPageState();
}

class _ExtractPageState extends ConsumerState<ExtractPage> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  final ValueNotifier<int> _depth = ValueNotifier(0);
  List<String> _selectedFiles = [];
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
    return Form(
      key: _formKey,
      child: Column(
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
          Center(
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => moveFiles(dryRun: false), 
                  child: const Text("Move!")
                ),
                ElevatedButton(
                  onPressed: () => moveFiles(dryRun: true), 
                  child: const Text("DryRun!")
                ),
              ],
            ),
          )
        ],
      ),
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

  void moveFiles({required bool dryRun}) async {
    if (_formKey.currentState!.validate()) {
      return;
    }
    String rootPath = ref.read(rootDirectoryProvider);
    Stream<FileOperationResult> results = extractFiles(
      selectedFiles: _selectedFiles, 
      rootPath: rootPath,
      dryRun: dryRun
    ).asBroadcastStream();
    results.listen(
      null,
      onError: (e) => showErrorDialog(e, context)
    );
    showDialog(
      barrierDismissible: false,
      context: context, 
      useRootNavigator: false,
      builder: (context) => ResultDialog(
        resultStream: results,
        onResultLoaded: dryRun ? null : () {
          _selectedFiles.clear();
          refreshDirectories();
        },
      ),    
    );
  }
}