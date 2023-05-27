import 'dart:io';
import 'package:filekraken/components/dialogs/error_dialogs.dart';
import 'package:filekraken/model/file_content.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
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

  NameGeneratorConfig config = NameGeneratorConfig(
    nameGenerator: "",
    numberFiles: 1
  );
  FileContent fileContent = FileContent();

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: ElevatedButton(
            onPressed: () => createFiles(context), 
            child: const Text("Create!")
          ),
        )
      ],
    );
  }

  void onRootDirectorySelected(String rootPath) {
    ref.read(rootDirectoryProvider.notifier).state = rootPath;
  }

  void createFiles(BuildContext context) async {
    String rootPath = ref.read(rootDirectoryProvider);
    if (rootPath == "") {
      // TODO: Show error dialog
      return;
    }
    Map<String, Variable> variables = ref.read(variableListProvider);
    ContentMode mode = fileContent.mode;
    for (int i = 0; i < config.numberFiles; i++) {
      String generatedName;
      try {
        generatedName = applyVariables(
        content: config.nameGenerator, 
        index: i, 
        variables: variables
        );
      } on MissingVariableException catch (e) {
        showDialog(
          context: context, 
          builder: (context) => MissingVariableErrorDialog(
            exception: e
          )
        );
        return;
      }
      switch (mode) {
        case ContentMode.text: {
          if (fileContent.textContent == null) {
            // TODO: Show error dialog
            return;
          }
          String textContent = fileContent.textContent!;
          String modifiedContent;
          try {
            modifiedContent = applyVariables(
              content: textContent, 
              index: i, 
              variables: variables
            );
          } on MissingVariableException catch (e) {
            showDialog(
              context: context, 
              builder: (context) => MissingVariableErrorDialog(exception: e)
            );
            return;
          }
          File newFile = File(join(rootPath, "$generatedName.txt"));
          if (!await newFile.exists()) {
            await newFile.create();
            await newFile.writeAsString(modifiedContent);
          }
          break;
        }
        case ContentMode.binary: {
          if (fileContent.binaryFilePath == null) {
            // TODO: Show error dialog
            return;
          }
          List<int> fileData = await File(fileContent.binaryFilePath!).readAsBytes();
          String fileExtension = extension(fileContent.binaryFilePath!);
          File newFile = File(join(rootPath, generatedName + fileExtension));
          if (!await newFile.exists()) {
            await newFile.create();
            await newFile.writeAsBytes(fileData);
          }
          break;
        }
      }
    }
  }
}