import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod/riverpod.dart';

StateNotifierProvider <FileListStateNotifier, FileEntityState> fileListStateProvider = StateNotifierProvider((_) {
  return FileListStateNotifier();
});

StateNotifierProvider<DirectoryListStateNotifier, FileEntityState> directoryListStateProvider = StateNotifierProvider((ref) {
  return DirectoryListStateNotifier(ref);
});

class FileListStateNotifier extends StateNotifier<FileEntityState> {

  FileListStateNotifier() : super(const FileEntityWaitingForInput());

  void emitFiles(List<String> directoryPaths) async {
    state = const FileEntityLoading();
    List<String> files = [];
    for (String directory in directoryPaths) {
      files.addAll(await _getFileEntityPath(directory, FileSystemEntityType.file, 0));
    }
    state = FileEntityLoadedState(fileEntities: files, type: FileSystemEntityType.file);
  }
}

class DirectoryListStateNotifier extends StateNotifier<FileEntityState> {
  DirectoryListStateNotifier(this.ref) : super(const FileEntityWaitingForInput());

  final Ref ref;

  Future<List<String>> emitDirectories(String rootPath, int depth) async {
    state = const FileEntityLoading();
    List<String> fileEntityPaths = await _getFileEntityPath(rootPath, FileSystemEntityType.directory, depth);
    state = FileEntityLoadedState(fileEntities: fileEntityPaths, type: FileSystemEntityType.directory);
    ref.read(fileListStateProvider.notifier).emitFiles(fileEntityPaths);
    return fileEntityPaths;
  }
}

Future<List<String>> _getFileEntityPath(
  String rootPath, 
  FileSystemEntityType fileEntityType, 
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
        (await _getFileEntityPath(directory.path, fileEntityType, depth-1))
        .map((e) {
          switch (fileEntityType) {
            case FileSystemEntityType.directory:
              return Directory(e);
            case FileSystemEntityType.file:
              return File(e);
            default:
              throw ArgumentError("Invalid fileSystemEntityType");
          }
        })
      );
    }
  }
  return entities
    .where((FileSystemEntity fe) => FileSystemEntity.typeSync(fe.path) == fileEntityType)
    .where((FileSystemEntity fe) => !path.basename(fe.path).startsWith("."))
    .map((FileSystemEntity fe) => fe.path)
    .toList();
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
}