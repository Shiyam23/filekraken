import 'dart:io';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import '../service/group_config.dart';
import '../service/modifer_parser.dart';

class InsertPage extends ConsumerStatefulWidget {
  const InsertPage({super.key});

  @override
  ConsumerState<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends ConsumerState<InsertPage> {

  List<String>? _selectedFiles;
  PathModifierConfig pathModifierConfig = PathModifierConfig(
    options: [PathModifierOptions(order: 1)]
  );
  GroupConfig groupConfig = GroupConfig(
    groups: []
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      String rootPath = ref.read(rootDirectoryProvider);
      if (rootPath != "") {
        ref.read(fileListStateProvider.notifier).emitFiles([rootPath], 0);
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
    );
  }

  void onRootDirectorySelected(String rootPath) {
    ref.read(rootDirectoryProvider.notifier).state = rootPath;
    ref.read(directoryListStateProvider.notifier).emitDirectories(
      rootPath: rootPath,
      depth: 0
    );
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

  void insertFiles() async {
    String rootPath = ref.read(rootDirectoryProvider);
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
        Directory groupDirectory = Directory(join(rootPath, groupName));
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
}