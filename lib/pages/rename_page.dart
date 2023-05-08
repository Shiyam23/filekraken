import 'dart:io';
import 'package:path/path.dart';

import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/modifer_parser.dart';

class RenamePage extends StatefulWidget {
  const RenamePage({super.key});

  @override
  State<RenamePage> createState() => _RenamePageState();
}

class _RenamePageState extends State<RenamePage> {

  final FilterFilesCubit _filesCubit = FilterFilesCubit();
  String? _rootPath;
  List<String>? _selectedFiles;

  PathModifierConfig config = PathModifierConfig(
    options: [PathModifierOptions(order: 1)]
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _filesCubit,
        ),
      ],
      child: Column(
          children: [
            FolderSelectionUnit(
              onDirectorySelect: onRootDirectorySelected
            ),
            FilterFileUnit(
              onFileSelect: onFileSelect,
            ),
            RenameFileUnit(
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
        ),
    );
  }

  void onRootDirectorySelected(String rootPath) {
    _rootPath = rootPath;
    _filesCubit.emitFiles([rootPath]);
  }

  void refreshFiles() async {
    if (_rootPath != null) {
      _filesCubit.emitFiles([_rootPath!]);
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

  @override
  void dispose() {
    _filesCubit.close();
    super.dispose();
  }
}