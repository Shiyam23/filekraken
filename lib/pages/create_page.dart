import 'package:filekraken/components/dialogs/result_dialog.dart';
import 'package:filekraken/model/file_content.dart';
import 'package:filekraken/model/file_result.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/file_read_op.dart';
import 'package:filekraken/service/op_impl/file_op.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import '../components/titlebar/variable_widget.dart';
import '../service/modifer_parser.dart';

class CreatePage extends ConsumerStatefulWidget {
  const CreatePage({super.key});

  @override
  ConsumerState<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends ConsumerState<CreatePage> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  NameGeneratorConfig config = NameGeneratorConfig(
    nameGenerator: "",
    numberFiles: 1
  );
  FileContent fileContent = FileContent();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          FolderSelectionUnit(
            onDirectorySelect: onRootDirectorySelected
          ),
          NameGeneratorUnit(
            config: config,
          ),
          FileContentUnit(
            content: fileContent,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => create(dryRun: false, shouldLog: false), 
                  child: const Text("Create")
                ),
                ElevatedButton(
                  onPressed: () => create(dryRun: true, shouldLog: false), 
                  child: const Text("DryRun")
                ),
                ElevatedButton(
                  onPressed: () => create(dryRun: true, shouldLog: true), 
                  child: const Text("Debug Log")
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
  }

  void create({required bool dryRun, required bool shouldLog}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String rootPath = ref.read(rootDirectoryProvider);
    if (rootPath == "") {
      // TODO: Show error dialog
      return;
    }
    Map<String, Variable> variables = ref.read(variableListProvider);
    CreateOperation operation 
      = ref.read(operationProvider)[OperationType.create]! as CreateOperation;
    Stream<FileOperationResult> results = operation.createFiles(
      fileContent: fileContent,
      config: config,
      rootPath: rootPath,
      dryRun: dryRun,
      variables: variables,
      shouldLog: shouldLog
    );
    await showDialog(
      barrierDismissible: false,
      context: context, 
      useRootNavigator: false,
      builder: (context) => ResultDialog(
        resultStream: results,
        maxNumber: config.numberFiles,
        operationType: OperationType.create,
        rootPath: rootPath,
        dryRun: dryRun,
      ),
    );
  }
}