import 'dart:io';
import 'package:file/memory.dart';
import 'package:filekraken/model/file_result.dart';
import 'package:filekraken/service/op_impl/file_op.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

class MemoryOverride extends IOOverrides {

  final MemoryFileSystem _mfs = MemoryFileSystem.test(
    style: FileSystemStyle.posix
  );

  @override
  File createFile(String path) => _mfs.file(path);

  @override
  Directory createDirectory(String path) => _mfs.directory(path);
}

void cleanSystem() {
  Directory root = Directory("/");
  for (FileSystemEntity entity in root.listSync()) {
    entity.deleteSync(recursive: true);
  }
  Directory(join(root.path, "root")).createSync();
}

void createFiles(List<String> filePaths) {
  for (String path in filePaths) {
    File(path).createSync(recursive: true);
  }
}

int entityCount(String directoryPath) => 
  Directory(directoryPath).listSync().length;

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
  MemoryOverride memoryOverride = MemoryOverride();
  setUp(() => IOOverrides.runWithIOOverrides(cleanSystem, memoryOverride));
  ProviderContainer container = ProviderContainer();
  group("Extract operation", () {
    ExtractOperation eop = container.read(operationProvider)[OperationType.extract]! as ExtractOperation;
    test("Extracts files to root folder", () {
      IOOverrides.runWithIOOverrides(() async {
        List<String> filePaths = [
          "/root/folder1/file1.txt",
          "/root/folder1/file2.txt",
          "/root/folder1/file3.txt",
          "/root/folder2/file4.txt",
          "/root/folder2/file5.txt",
          "/root/folder3/file6.txt",
        ];
        createFiles(filePaths);
        RegExp folderRegex = RegExp("folder\\d*/");
        await expectLater(eop.extractFiles(selectedFiles: filePaths, rootPath: "/root/", dryRun: false), emitsInOrder([
          for (String filePath in filePaths)
          predicate<FileOperationResult>((result) {
            return result.rootPath == "/root/" &&
              result.fileSource == filePath &&
              result.fileTarget == filePath.replaceFirst(folderRegex, "") &&
              result.operationType == OperationType.extract &&
              result.resultType == ResultType.success &&
              result.error == ErrorType.none;
          }), 
          emitsDone
        ]));

        // Files exist in root folder
        for (String oldFilePath in filePaths) {
          String newFilePath = oldFilePath.replaceAll(folderRegex, "");
          expect(File(newFilePath).existsSync(), isTrue, reason: "$newFilePath does not exist!");
        }

        // Old folders are empty
        filePaths
        .map((String filepath) => dirname(filepath))
        .toSet()
        .forEach((String folderPath) => expect(Directory(folderPath).listSync(), isEmpty));

      }, memoryOverride);
    });

    test("Leaves unselected files untouched", () {
      IOOverrides.runWithIOOverrides(() async {
        List<String> selectedFilePaths = [
          "/root/folder1/file1.txt",
          "/root/folder1/file2.txt",
          "/root/folder1/file3.txt",
          "/root/folder2/file4.txt",
          "/root/folder2/file5.txt",
          "/root/folder3/file6.txt",
        ];
        List<String> unselectedFilePaths = [
          "/root/folder1/file3N.txt",
          "/root/folder2/file5N.txt",
          "/root/folder3/file6N.txt",
        ];
        createFiles(selectedFilePaths);
        createFiles(unselectedFilePaths);
        RegExp folderRegex = RegExp("folder\\d*/");
        await expectLater(eop.extractFiles(selectedFiles: selectedFilePaths, rootPath: "/root/", dryRun: false), emitsInOrder([
          for (String filePath in selectedFilePaths)
          predicate<FileOperationResult>((result) {
            return result.rootPath == "/root/" &&
              result.fileSource == filePath &&
              result.fileTarget == filePath.replaceFirst(folderRegex, "") &&
              result.operationType == OperationType.extract &&
              result.resultType == ResultType.success &&
              result.error == ErrorType.none;
          }), 
          emitsDone
        ]));

        // Selected files should be moved into root folder
        for (String oldFilePath in selectedFilePaths) {
          expect(File(oldFilePath).existsSync(), isFalse, reason: "Selected file $oldFilePath must not exist!");
          String newFilePath = oldFilePath.replaceAll(folderRegex, "");
          expect(File(newFilePath).existsSync(), isTrue, reason: "Selected file $newFilePath does not exist!");
        }

        // Unseleceted files must not be moved into root folder
        for (String oldFilePath in unselectedFilePaths) {
          expect(File(oldFilePath).existsSync(), isTrue, reason: "Unselected file $oldFilePath does not exist!");
          String newFilePath = oldFilePath.replaceAll(folderRegex, "");
          expect(File(newFilePath).existsSync(), isFalse, reason: "Unselected file $newFilePath must exist!");
        }
      }, memoryOverride);
    });
  });
}
