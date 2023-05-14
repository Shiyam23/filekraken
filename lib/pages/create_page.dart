import 'dart:io';
import 'package:filekraken/model/file_content.dart';
import 'package:path/path.dart';
import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/modifer_parser.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  final FilterFilesCubit _filesCubit = FilterFilesCubit();
  String? _rootPath;
  NameGeneratorConfig config = NameGeneratorConfig(
    nameGenerator: "",
    numberFiles: 1
  );
  FileContent fileContent = FileContent();

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
          NameGeneratorUnit(
            config: config,
          ),
          FileContentUnit(
            content: fileContent,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: createFiles, 
              child: const Text("Create!")
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

  void createFiles() async {
    if (_rootPath == null) {
      // TODO: Show error dialog
      return;
    }
    Map<String, String> variables = {"s": "d"};
    ContentMode mode = fileContent.mode;
    for (int i = 0; i < config.numberFiles; i++) {
      String generatedName = applyVariables(
        content: config.nameGenerator, 
        index: i, 
        variables: variables
      );
      switch (mode) {
        case ContentMode.text: {
          if (fileContent.textContent == null) {
            // TODO: Show error dialog
            return;
          }
          String textContent = fileContent.textContent!;
          String modifiedContent = applyVariables(
            content: textContent, 
            index: i, 
            variables: variables
          );
          File newFile = File(join(_rootPath!, "$generatedName.txt"));
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
          File newFile = File(join(_rootPath!, generatedName + fileExtension));
          if (!await newFile.exists()) {
            await newFile.create();
            await newFile.writeAsBytes(fileData);
          }
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _filesCubit.close();
    super.dispose();
  }
}