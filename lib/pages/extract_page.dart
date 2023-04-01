import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {

  final FilterDirectoriesCubit _directoriesCubit = FilterDirectoriesCubit();
  final FilterFilesCubit _filesCubit = FilterFilesCubit();
  String? rootPath;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _directoriesCubit,
          child: Container(),
        ),
        BlocProvider.value(
          value: _filesCubit,
          child: Container(),
        ),
      ],
      child: Column(
          children: [
            FolderSelectionUnit(onDirectorySelect: onRootDirectorySelected),
            FilterDirectoryUnit(
              onDirectorySelect: onDirectorySelect,
              onFileRefresh: refreshFiles,
            ),
            const FilterFileUnit()
          ],
        ),
    );
  }

  void onRootDirectorySelected(String rootPath) {
    this.rootPath = rootPath;
  }

  void onDirectorySelect(List<String> directories) {
    _filesCubit.emitFiles(directories);
  }

  void refreshFiles() async {
    if (rootPath != null) {
      List<String> directories = await _directoriesCubit.emitDirectories(rootPath!);
      _filesCubit.emitFiles(directories);
    }
  }

  @override
  void dispose() {
    _directoriesCubit.close();
    _filesCubit.close();
    super.dispose();
  }
}