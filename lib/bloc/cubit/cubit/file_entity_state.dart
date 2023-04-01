part of 'filter_directories_cubit.dart';

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

class FileEntityRefresh extends FileEntityState {
  const FileEntityRefresh();
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
