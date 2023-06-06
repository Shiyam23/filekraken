import 'dart:async';
import 'dart:io';
import 'package:filekraken/model/file_result.dart';
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
    state = const FileEntityLoading();
    List<String> files = [];
    for (String directory in directoryPaths) {
      files.addAll(await getFileEntityPath(directory, FileSystemEntityType.file, depth));
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
    List<String> fileEntityPaths = await getFileEntityPath(rootPath, FileSystemEntityType.directory, depth);
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

Future<List<String>> getFileEntityPath(
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
        (await getFileEntityPath(directory.path, fileEntityType, depth-1))
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

  @override
  operator==(covariant FileEntityLoadedState other) {
    return other.type == type &&
    listEquals(other.fileEntities, fileEntities);
  }

  @override
  int get hashCode => Object.hashAll([...fileEntities, type]);
}

FileOperationResult _handleError({
  required FileOperationResult initialResult,
  required Object error
}) {
  if (error is! Exception && error is! Error) {
    throw ArgumentError.value(error, "error", "error must be of type Error or Exception");
  }
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