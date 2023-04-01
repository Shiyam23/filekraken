import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:io';
part 'file_entity_state.dart';

class FilterDirectoriesCubit extends Cubit<FileEntityState> {

  FilterDirectoriesCubit() : super(const FileEntityWaitingForInput());
  String? rootPath;

  Future<List<String>> emitDirectories(String rootPath) async {
    this.rootPath ??= rootPath;
    emit(const FileEntityLoading());
    List<String> fileEntityPaths = await _getFileEntityPath(rootPath, FileSystemEntityType.directory);
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
      files.addAll(await _getFileEntityPath(directory, FileSystemEntityType.file));
    }
    emit(FileEntityLoadedState(fileEntities: files, type: FileSystemEntityType.file));
  }
}

Future<List<String>> _getFileEntityPath(String rootPath, FileSystemEntityType fileEntityType) async {
  List<FileSystemEntity> entities = await Directory(rootPath).list(followLinks: false).toList();
  return entities
    .where((FileSystemEntity fe) => FileSystemEntity.typeSync(fe.path) == fileEntityType)
    .map((FileSystemEntity fe) => fe.path)
    .toList();
}