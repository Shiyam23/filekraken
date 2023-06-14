import 'package:filekraken/components/dialogs/result_dialog.dart';
import 'package:filekraken/components/titlebar/variable_widget.dart';
import 'package:filekraken/model/file_result.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/file_read_op.dart';
import 'package:filekraken/service/op_impl/file_op.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey();
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
    return Form(
      key: _formKey,
      child: Column(
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
                  onPressed: () => insert(dryRun: false, shouldLog: false), 
                  child: const Text("Insert!")
                ),
                ElevatedButton(
                  onPressed: () => insert(dryRun: true, shouldLog: false), 
                  child: const Text("Dryrun!")
                ),
                ElevatedButton(
                  onPressed: () => insert(dryRun: true, shouldLog: true), 
                  child: const Text("Debug Log!")
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

  void insert({required bool dryRun, required bool shouldLog}) async {
    String rootPath = ref.read(rootDirectoryProvider);
    Map<String, Variable> variables = ref.read(variableListProvider);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      return;
    }
    InsertOperation operation 
      = ref.read(operationProvider)[OperationType.insert]! as InsertOperation;
    final (assignment, count) = operation.getAssignment(
      selectedFiles: _selectedFiles!,
      groupConfig: groupConfig,
      variables: variables,
      pathModifierConfig: pathModifierConfig,
      rootPath: rootPath,
      shouldLog: shouldLog
    );
    Stream<FileOperationResult> results = operation.insertFiles(
        selectedFiles: _selectedFiles!,
        rootPath: rootPath, 
        dryRun: dryRun, 
        assignment: assignment, 
        variables: variables
      );
    showDialog(
      barrierDismissible: false,
      context: context, 
      useRootNavigator: false,
      builder: (context) => ResultDialog(
        operationType: OperationType.insert,
        rootPath: rootPath,
        resultStream: results,
        dryRun: dryRun,
        maxNumber: count,
        onResultLoaded: dryRun ? null : () {
          refreshFiles();
        },
      ),
    );
  }
}