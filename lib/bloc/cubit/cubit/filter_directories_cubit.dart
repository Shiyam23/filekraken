import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
part 'file_entity_state.dart';

class FilterDirectoriesCubit extends Cubit<FileEntityState> {

  FilterDirectoriesCubit() : super(const FileEntityWaitingForInput());
  String? rootPath;

  Future<List<String>> emitDirectories(String rootPath, int depth) async {
    this.rootPath ??= rootPath;
    emit(const FileEntityLoading());
    List<String> fileEntityPaths = await _getFileEntityPath(rootPath, FileSystemEntityType.directory, depth);
    emit(FileEntityLoadedState(fileEntities: fileEntityPaths, type: FileSystemEntityType.directory));
    return fileEntityPaths;
  }
}

class FilterFilesCubit extends Cubit<FileEntityState> {

  FilterFilesCubit() : super(const FileEntityWaitingForInput());

  void emitFiles(List<String> directoryPaths) async {
    emit(const FileEntityLoading());
    List<String> files = [];
    for (String directory in directoryPaths) {
      files.addAll(await _getFileEntityPath(directory, FileSystemEntityType.file, 0));
    }
    emit(FileEntityLoadedState(fileEntities: files, type: FileSystemEntityType.file));
  }
}

Future<List<String>> _getFileEntityPath(String rootPath, FileSystemEntityType fileEntityType, int depth) async {
  
  if (depth < 0) throw ArgumentError.value(depth, "depth", "Must be positive");

  List<FileSystemEntity> entities = await Directory(rootPath).list(followLinks: false).toList();
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