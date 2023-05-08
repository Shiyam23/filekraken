import 'dart:io';
import 'package:path/path.dart';

import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/modifer_parser.dart';

class InjectPage extends StatefulWidget {
  const InjectPage({super.key});

  @override
  State<InjectPage> createState() => _InjectPageState();
}

class _InjectPageState extends State<InjectPage> {

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
            NameModifierUnit(
              title: "Assign directory name",
              config: config,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: injectFiles, 
                child: const Text("Inject!")
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

  void injectFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }
    for (int i = 0; i < _selectedFiles!.length; i++) {
      String selectedFilePath = _selectedFiles![i];
      String fileBasename = basenameWithoutExtension(selectedFilePath);
      String directoryName = modifyName(fileBasename, i, config, {"s":""});
      String newDirectoryPath = join(dirname(selectedFilePath), directoryName);
      Directory newDirectory = Directory(newDirectoryPath);
      if (!await newDirectory.exists()) {
        newDirectory.create();
        File selectedFile = File(selectedFilePath);
        selectedFile.rename(join(newDirectoryPath, basename(selectedFilePath)));
      }
    }
  }

  @override
  void dispose() {
    _filesCubit.close();
    super.dispose();
  }
}