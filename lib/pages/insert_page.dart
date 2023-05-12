import 'dart:io';
import 'package:path/path.dart';

import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/group_config.dart';
import '../model/modifer_parser.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {

  final FilterFilesCubit _filesCubit = FilterFilesCubit();
  String? _rootPath;
  List<String>? _selectedFiles;

  PathModifierConfig pathModifierConfig = PathModifierConfig(
    options: [PathModifierOptions(order: 1)]
  );

  GroupConfig groupConfig = GroupConfig(
    groups: []
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
            GroupUnit(
              title: "Group by", 
              config: groupConfig
            ),
            NameModifierUnit(
              title: "Assign directory name",
              config: pathModifierConfig,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: insertFiles, 
                child: const Text("Insert!")
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

  void insertFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }

    List<GroupOption> nonEmptyGroups = groupConfig.groups
    .where((group) => group.match != null && group.match != "")
    .where((group) => group.groupName != null && group.groupName != "")
    .toList();

    if (nonEmptyGroups.isNotEmpty) {
      Map<String, List<String>> fileGroups = {
      for (GroupOption group in nonEmptyGroups) group.groupName!:[] 
      };
      for (int i = 0; i < _selectedFiles!.length; i++) {
        String selectedFilePath = _selectedFiles![i];
        String fileBasename = basename(selectedFilePath);
        if (nonEmptyGroups.isNotEmpty) {
          for (GroupOption group in nonEmptyGroups) {
            String groupMatch = group.match!;
            String groupName = group.groupName!;
            List<String> matches = parseGroupMatch(groupMatch);
            for (String match in matches) {
              if (fileBasename.contains(match)) {
              fileGroups[groupName]!.add(selectedFilePath);
              break;
              }
            }
          }
        } 
      }
      for (String groupName in fileGroups.keys) {
        if (fileGroups[groupName]!.isEmpty) continue;
        Directory groupDirectory = Directory(join(_rootPath!, groupName));
        if (!await groupDirectory.exists()) groupDirectory.create();
        for (String filePath in fileGroups[groupName]!) {
          File file = File(filePath);
          file.rename(join(groupDirectory.path, basename(filePath)));
        }
      }
    }
    else {
      for (int i = 0; i < _selectedFiles!.length; i++) {
        String selectedFilePath = _selectedFiles![i];
        String fileBasename = basenameWithoutExtension(selectedFilePath);
        String directoryName = modifyName(fileBasename, i, pathModifierConfig, {"s":""});
        String newDirectoryPath = join(dirname(selectedFilePath), directoryName);
        Directory newDirectory = Directory(newDirectoryPath);
        if (!await newDirectory.exists()) {
          newDirectory.create();
          File selectedFile = File(selectedFilePath);
          selectedFile.rename(join(newDirectoryPath, basename(selectedFilePath)));
        }
      }
    }
    refreshFiles();
  }

  @override
  void dispose() {
    _filesCubit.close();
    super.dispose();
  }
}