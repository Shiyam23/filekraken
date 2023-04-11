import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExtractPage extends StatefulWidget {
  const ExtractPage({super.key});

  @override
  State<ExtractPage> createState() => _ExtractPageState();
}

class _ExtractPageState extends State<ExtractPage> {

  final FilterDirectoriesCubit _directoriesCubit = FilterDirectoriesCubit();
  final FilterFilesCubit _filesCubit = FilterFilesCubit();
  String? _rootPath;
  List<String>? _selectedFiles;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _directoriesCubit,
        ),
        BlocProvider.value(
          value: _filesCubit,
        ),
      ],
      child: Column(
          children: [
            FolderSelectionUnit(onDirectorySelect: onRootDirectorySelected),
            FilterDirectoryUnit(
              onDirectorySelect: onDirectorySelect,
              onFileRefresh: refreshFiles,
            ),
            FilterFileUnit(
              onFileSelect: onFileSelect,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: moveFiles, child: Text("Move!")),
            )
          ],
        ),
    );
  }

  void onRootDirectorySelected(String rootPath) {
    _rootPath = rootPath;
    _directoriesCubit.emitDirectories(rootPath);
  }

  void onDirectorySelect(List<String> directories) {
    _filesCubit.emitFiles(directories);
  }

  void refreshFiles() async {
    if (_rootPath != null) {
      List<String> directories = await _directoriesCubit.emitDirectories(_rootPath!);
      _filesCubit.emitFiles(directories);
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
    refreshFiles();
  }

  @override
  void dispose() {
    _directoriesCubit.close();
    _filesCubit.close();
    super.dispose();
  }
}