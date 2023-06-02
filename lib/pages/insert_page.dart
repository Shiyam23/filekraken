import 'package:filekraken/components/dialogs/error_dialogs.dart';
import 'package:filekraken/components/dialogs/result_dialog.dart';
import 'package:filekraken/components/titlebar/variable_widget.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => insert(dryRun: false), 
                child: const Text("Insert!")
              ),
              ElevatedButton(
                onPressed: () => insert(dryRun: true), 
                child: const Text("Dryrun!")
              ),
            ],
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

  void insert({required bool dryRun}) async {
    String rootPath = ref.read(rootDirectoryProvider);
    Map<String, Variable> variables = ref.read(variableListProvider);
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }
    Stream<FileOperationResult> results = insertFiles(
      selectedFiles: _selectedFiles!, 
      rootPath: rootPath, 
      dryRun: dryRun, 
      pathModifierConfig: pathModifierConfig, 
      groupConfig: groupConfig, 
      variables: variables
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
          refreshFiles();
        },
      ),
    );
  }
}