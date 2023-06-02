import 'dart:io';
import 'package:filekraken/components/dialogs/result_dialog.dart';
import 'package:filekraken/components/titlebar/variable_widget.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import '../service/modifer_parser.dart';

class RenamePage extends ConsumerStatefulWidget {
  const RenamePage({super.key});

  @override
  ConsumerState<RenamePage> createState() => _RenamePageState();
}

class _RenamePageState extends ConsumerState<RenamePage> {

  List<String>? _selectedFiles;

  PathModifierConfig config = PathModifierConfig(
    options: [PathModifierOptions(order: 1)]
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      String rootPath = ref.read(rootDirectoryProvider);
      if (rootPath != "") {
        ref.read(fileListStateProvider.notifier).emitFiles([rootPath],0);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FolderSelectionUnit(
          onDirectorySelect: onRootDirectorySelected
        ),
        FilterFileUnit(
          initialFilterMode: FilterMode.none,
          onFileSelect: onFileSelect,
        ),
        NameModifierUnit(
          title: "Assign file name",
          config: config,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => rename(dryRun: false), 
                child: const Text("Rename!")
              ),
              ElevatedButton(
                onPressed: () => rename(dryRun: true), 
                child: const Text("DryRun!")
              ),
            ],
          ),
        )
      ],
    );
  }

  void onRootDirectorySelected(String rootPath) {
    ref.read(rootDirectoryProvider.notifier).state = rootPath;
    ref.read(fileListStateProvider.notifier).emitFiles([rootPath], 0);
  }

  void refreshFiles() async {
    String rootPath = ref.read(rootDirectoryProvider);
    if (rootPath != "") {
      ref.read(fileListStateProvider.notifier).emitFiles([rootPath], 0);
    }
  }

  void onFileSelect(List<String> selectedFiles) {
    _selectedFiles = selectedFiles;
  }

  void rename({required bool dryRun}) async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }
    String rootPath = ref.read(rootDirectoryProvider);
    Map<String, Variable> variables = ref.read(variableListProvider);
    Stream<FileOperationResult> results = renameFiles(
      selectedFiles: _selectedFiles!,
      variables: variables,
      config: config,
      rootPath: rootPath,
      dryRun: dryRun
    );
    showDialog(
      context: context, 
      builder: (context) => ResultDialog(
        resultStream: results,
        onResultLoaded: dryRun ? null : refreshFiles,
      )
    );
  }
}