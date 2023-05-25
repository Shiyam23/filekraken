import 'dart:io';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
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
          child: ElevatedButton(
            onPressed: renameFiles, 
            child: const Text("Rename!")
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

  void renameFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }
    for (int i = 0; i < _selectedFiles!.length; i++) {
      String selectedFilePath = _selectedFiles![i];
      String fileBasename = basenameWithoutExtension(selectedFilePath);
      String fileExtension = extension(selectedFilePath);
      String newFileName = modifyName(fileBasename, i, config, {"s":""});
      String newFilePath = join(dirname(selectedFilePath), newFileName+fileExtension);
      File oldFile = File(selectedFilePath);
      await oldFile.rename(newFilePath);
    }
    refreshFiles();
  }
}