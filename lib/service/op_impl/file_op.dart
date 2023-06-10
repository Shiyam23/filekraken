import 'dart:io';
import 'package:collection/collection.dart';
import 'package:filekraken/model/file_content.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/group_config.dart';
import 'package:filekraken/service/modifer_parser.dart';
import 'package:path/path.dart' as path;
import 'package:filekraken/model/file_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

Provider<Map<OperationType, Operation>> operationProvider = Provider(
  (ref) {
    return {
      OperationType.extract: ExtractOperation(),
      OperationType.insert: InsertOperation(),
      OperationType.create: CreateOperation(),
      OperationType.rename: RenameOperation(),
    };
  }
);

abstract class Operation {

  void revert(ModuleOperationResult moduleResult) {
    for (FileOperationResult fileResult in moduleResult.fileResults) {
      revertSingle(fileResult);
    }
  }

  void revertSingle(FileOperationResult fileResult);

  static FileOperationResult handleError({
    required FileOperationResult initialResult,
    required Object error
  }) {
    assert(error is! Exception && error is! Error);
    if (error is! FileSystemException) {
      return initialResult.copyWith(error: ErrorType.other);
    }
    ErrorType errorType;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        switch (error.osError?.errorCode) {
          case 2:
            errorType = ErrorType.fileNotFound; break;
          case 3:
            errorType = ErrorType.pathNotFound; break;
          case null:
          default:
            errorType = ErrorType.other;
        }
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        switch (error.osError?.errorCode) {
          case 1:
            errorType = ErrorType.noPermission; break;
          case 2:
            errorType = ErrorType.pathNotFound; break;
          case 17:
            errorType = ErrorType.fileAlreadyExists; break;
          case null:
          default:
            errorType = ErrorType.other;
        }
        break;
      default: throw UnsupportedError("OS not supported");
    }
    return initialResult.copyWith(error: errorType);
  }
}


class ExtractOperation extends Operation{

  Stream<FileOperationResult> extractFiles({
  required List<String> selectedFiles, 
  required String rootPath,
  required bool dryRun,
  }) async* {
    if (selectedFiles.isEmpty) {
      throw ArgumentError.value(selectedFiles, "selectedFiles", "Must not be empty");
    }
    for (String filePath in selectedFiles) {
      File selectedFile = File(filePath);
      String targetPath = path.join(rootPath, path.basename(filePath));
      FileOperationResult result = FileOperationResult(
        rootPath: rootPath,
        fileSource: selectedFile.path, 
        fileTarget: targetPath, 
        operationType: OperationType.extract, 
        resultType: ResultType.fail,
        error: ErrorType.none
      );
      if (rootPath == "") {
        yield result.copyWith(error: ErrorType.invalidRootPath);
        continue;
      }
      if (!await selectedFile.exists()) {
        yield result.copyWith(error: ErrorType.fileNotFound);
        continue;
      }
      if (dryRun) {
        yield result.copyWith(resultType: ResultType.dryRun);
        continue;
      }
      try {
        await selectedFile.rename(targetPath);
        yield result.copyWith(resultType: ResultType.success);
      } catch (e) {
        yield Operation.handleError(initialResult: result, error: e);
      }
    }
  }

  @override
  void revertSingle(FileOperationResult fileResult) async {
    File target = File(fileResult.fileTarget);
    File source = File(fileResult.fileSource);
    if (await target.exists() && !await source.exists()) {
      Directory parentDirectory = Directory(path.dirname(fileResult.fileSource));
      await parentDirectory.create(recursive: true);
      await target.rename(fileResult.fileSource);
    }
  }
}

class InsertOperation extends Operation{

  (Map<String, List<String>>, int) getAssignment({
    required List<String> selectedFiles, 
    required GroupConfig groupConfig,
    required Map<String, Variable> variables,
    required PathModifierConfig pathModifierConfig,
  }) {
    List<GroupOption> nonEmptyGroups = groupConfig.groups
    .where((group) => group.match != null && group.match != "")
    .where((group) => group.groupName != null && group.groupName != "")
    .toList();
    int count = 0;
    Map<String, List<String>> fileGroups = {
      for (GroupOption group in nonEmptyGroups) group.groupName!:[] 
    };
    if (nonEmptyGroups.isEmpty) {
      count = selectedFiles.length;
      selectedFiles.forEachIndexed((index, selectedFilePath) {
        String fileBasename = basenameWithoutExtension(selectedFilePath);
        String directoryName = modifyName(fileBasename, index, pathModifierConfig, variables);
        String newDirectoryPath = join(dirname(selectedFilePath), directoryName);
        fileGroups.putIfAbsent(newDirectoryPath, () => []).add(selectedFilePath);
      });
    } else {
      for (var selectedFilePath in selectedFiles) {
        String fileBasename = basename(selectedFilePath);
        for (GroupOption group in nonEmptyGroups) {
          String groupMatch = group.match!;
          String groupName = group.groupName!;
          List<String> matches = parseGroupMatch(groupMatch);
          for (String match in matches) {
            if (fileBasename.contains(match)) {
              fileGroups[groupName]!.add(selectedFilePath);
              count++;
              break;
            }
          }
        }
      }
    }
    return (fileGroups, count);
  }

  Stream<FileOperationResult> insertFiles({
    required List<String> selectedFiles, 
    required String rootPath,
    required bool dryRun,
    required Map<String, List<String>> assignment,
    required Map<String, Variable> variables
  }) async*{
    for (String groupName in assignment.keys) {
      if (assignment[groupName]!.isEmpty) continue;
      Directory groupDirectory = Directory(join(rootPath, groupName));
      for (String filePath in assignment[groupName]!) {
        yield await _moveFile(filePath, groupDirectory, rootPath, dryRun);
      }
    }
  }

  Future<FileOperationResult> _moveFile(
    String filePath, 
    Directory groupDirectory, 
    String rootPath, 
    bool dryRun
  ) async {
    File file = File(filePath);
    String target = join(groupDirectory.path, basename(filePath));
    FileOperationResult result = FileOperationResult(
      rootPath: rootPath, 
      fileSource: file.path, 
      fileTarget: target, 
      operationType: OperationType.insert, 
      resultType: ResultType.fail,
      error: ErrorType.none
    );
    if (await File(target).exists()) {
      return result.copyWith(error: ErrorType.fileAlreadyExists);
    }
    if (rootPath == "") {
      return result.copyWith(error: ErrorType.invalidRootPath);
    }
    if (dryRun) {
      return result.copyWith(resultType: ResultType.dryRun);
    } else {
      try {
        if (!await groupDirectory.exists()) await groupDirectory.create();
        await file.rename(target);
        return result.copyWith(resultType: ResultType.success);
      } catch (e) {
        return Operation.handleError(initialResult: result, error: e);
      }
    }
  }

  @override
  void revertSingle(FileOperationResult fileResult) async {
    File insertedFile = File(fileResult.fileTarget);
    File sourceFile = File(fileResult.fileSource);
    if (await insertedFile.exists() && !await sourceFile.exists()) {
      insertedFile.rename(fileResult.fileSource);
    }
    Directory parentDirectory = Directory(path.dirname(fileResult.fileTarget));
    if ((await parentDirectory.list().toList()).isEmpty) {
      await parentDirectory.delete();
    }
  }
}

class CreateOperation extends Operation{

  Stream<FileOperationResult> createFiles({
    required FileContent fileContent, 
    required NameGeneratorConfig config,
    required String rootPath,
    required bool dryRun,
    required Map<String, Variable> variables
  }) async*{
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
          String target = join(rootPath, "$generatedName.txt");
          File newFile = File(target);
          FileOperationResult result = FileOperationResult(
            rootPath: rootPath, 
            fileSource: rootPath, 
            fileTarget: target, 
            operationType: OperationType.create, 
            resultType: ResultType.fail,
            error: ErrorType.none
          );
          if (await newFile.exists()) {
            yield result.copyWith(error: ErrorType.fileAlreadyExists);
            continue;
          }
          if (dryRun) {
            yield result.copyWith(resultType: ResultType.dryRun);
            continue;
          } 
          try {
            await newFile.create();
            await newFile.writeAsString(modifiedContent);
            yield result.copyWith(resultType: ResultType.success);
          } catch (e) {
            yield Operation.handleError(initialResult: result, error: e);
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
          String target = join(rootPath, generatedName + fileExtension);
          File newFile = File(target);
          FileOperationResult result = FileOperationResult(
            rootPath: rootPath, 
            fileSource: rootPath, 
            fileTarget: target, 
            operationType: OperationType.create, 
            resultType: ResultType.fail,
            error: ErrorType.none
          );
          if (await newFile.exists()) {
            yield result.copyWith(error: ErrorType.fileAlreadyExists);
            continue;
          }
          if (dryRun) {
            yield result.copyWith(resultType: ResultType.dryRun);
            continue;
          } 
          try {
            await newFile.create();
            await newFile.writeAsBytes(fileData);
            yield result.copyWith(resultType: ResultType.success);
          } catch (e) {
            yield Operation.handleError(initialResult: result, error: e);
          }
          break;
        }
      }
    }
  }

  @override
  void revertSingle(FileOperationResult fileResult) async {
    File createdFile = File(fileResult.fileTarget);
    if (await createdFile.exists()) {
      await createdFile.delete();
    }
  }
}

class RenameOperation extends Operation{

  Stream<FileOperationResult> renameFiles({
    required List<String> selectedFiles,
    required Map<String, Variable> variables,
    required PathModifierConfig config,
    required String rootPath,
    required bool dryRun
  }) async* {
    for (int i = 0; i < selectedFiles.length; i++) {
      String selectedFilePath = selectedFiles[i];
      String fileBasename = basenameWithoutExtension(selectedFilePath);
      String fileExtension = extension(selectedFilePath);
      String newFileName = modifyName(fileBasename, i, config, variables);
      String newFilePath = join(dirname(selectedFilePath), newFileName+fileExtension);
      File oldFile = File(selectedFilePath);
      FileOperationResult result = FileOperationResult(
        fileSource: selectedFilePath,
        fileTarget: newFilePath,
        operationType: OperationType.rename,
        resultType: ResultType.fail,
        rootPath: rootPath,
        error: ErrorType.none
      );
      if (!await oldFile.exists()) {
        yield result.copyWith(error: ErrorType.fileNotFound);
        continue;
      }
      if (await File(newFilePath).exists()) {
        yield result.copyWith(error: ErrorType.fileAlreadyExists);
        continue;
      }
      if (dryRun) {
        yield result.copyWith(resultType: ResultType.dryRun);
        continue;
      }
      try {
        await oldFile.rename(newFilePath);
        yield result.copyWith(resultType: ResultType.success);
      } catch (e) {
        yield Operation.handleError(initialResult: result, error: e);
      }
    }
  }

  @override
  void revertSingle(FileOperationResult fileResult) async {
    File target = File(fileResult.fileTarget);
    File source = File(fileResult.fileSource);
    if (await target.exists() && !await source.exists()) {
      target.rename(fileResult.fileSource);
    }
  }
}