import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod/riverpod.dart';

StateProvider<String> rootDirectoryProvider = StateProvider((ref) => "");

StateNotifierProvider <FileListStateNotifier, FileEntityState> fileListStateProvider = StateNotifierProvider((_) {
  return FileListStateNotifier();
});

StateNotifierProvider<DirectoryListStateNotifier, FileEntityState> directoryListStateProvider = StateNotifierProvider((ref) {
  return DirectoryListStateNotifier(ref);
});

class FileListStateNotifier extends StateNotifier<FileEntityState> {

  FileListStateNotifier() : super(const FileEntityWaitingForInput());

  void emitFiles(List<String> directoryPaths, int depth) async {
    List<String> initialFiles = [
      "/root/rootfile1.txt",
      "/root/rootfile2.txt",
      "/root/rootfile3.txt",
      "/root/rootfile4.txt",
      "/root/folder1/file1.txt",
      "/root/folder1/file2.txt",
      "/root/folder2/file3.txt",
      "/root/folder2/file4.txt",
      "/root/folder3/file5.txt",
    ];
    List<String> files = [];
    for (String directoryPath in directoryPaths) {
      for (String filePath in initialFiles) {
        if (directoryPath.endsWith("/")) directoryPath = directoryPath.substring(0,directoryPath.length-1);
        if (path.dirname(filePath) == directoryPath) files.add(filePath);
      }
    }
    state = FileEntityLoadedState(fileEntities: files, type: FileSystemEntityType.file);
  }

  void reset() {
    state = const FileEntityWaitingForInput();
  }
}

class DirectoryListStateNotifier extends StateNotifier<FileEntityState> {
  DirectoryListStateNotifier(this.ref) : super(const FileEntityWaitingForInput());

  final Ref ref;

  Future<List<String>> emitDirectories({
    required String rootPath, 
    required int depth,
    bool shouldRefreshFiles = true
  }) async {
    state = const FileEntityLoading();
    List<String> fileEntityPaths = [
      "/root/folder1/",
      "/root/folder2/",
      "/root/folder3/",
    ];
    state = FileEntityLoadedState(fileEntities: fileEntityPaths, type: FileSystemEntityType.directory);
    if (shouldRefreshFiles) {
      ref.read(fileListStateProvider.notifier).emitFiles(fileEntityPaths, 0);
    }
    return fileEntityPaths;
  }

  void reset() {
    state = const FileEntityWaitingForInput();
  }
}

Future<List<String>> getFileEntityPath<T extends FileSystemEntity>(
  String rootPath, 
  int depth
) async {
  if (depth < 0) {
    throw ArgumentError.value(depth, "depth", "Must be positive");
  }
  List<FileSystemEntity> entities = await Directory(rootPath)
  .list(followLinks: false)
  .toList();
  List<Directory> directories = entities.whereType<Directory>().toList();
  if (depth > 0 && directories.isNotEmpty) {
    for (Directory directory in directories) {
      entities.addAll(
        (await getFileEntityPath<T>(directory.path, depth-1))
        .map((e) {
          switch (T) {
            case Directory:
              return Directory(e);
            case File:
              return File(e);
            default:
              throw ArgumentError("Invalid fileSystemEntityType");
          }
        })
      );
    }
  }
  List<String> newEntities = entities
    .whereType<T>()
    .where((T fe) => !path.basename(fe.path).startsWith("."))
    .map((T fe) => fe.path)
    .toList();
  return newEntities;
}

@immutable
class FileEntityState {
  const FileEntityState();
}

class FileEntityWaitingForInput extends FileEntityState {
  const FileEntityWaitingForInput();
}

class FileEntityLoading extends FileEntityState {
  const FileEntityLoading();
}

class FileEntityLoadedState extends FileEntityState {

  FileEntityLoadedState({required this.fileEntities, required this.type}) {
    if (type != FileSystemEntityType.file && type != FileSystemEntityType.directory) {
      throw UnsupportedError("FileSystemEntityType $type not supported");
    }
  }
  final List<String> fileEntities;
  final FileSystemEntityType type;

  @override
  operator==(covariant FileEntityLoadedState other) {
    return other.type == type &&
    listEquals(other.fileEntities, fileEntities);
  }

  @override
  int get hashCode => Object.hashAll([...fileEntities, type]);
}