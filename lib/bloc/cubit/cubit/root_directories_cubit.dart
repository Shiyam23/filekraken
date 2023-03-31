import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:io';

part 'root_directories_state.dart';

class RootDirectoriesCubit extends Cubit<RootDirectoriesState> {

  RootDirectoriesCubit() : super(const RootDirectoriesLoading());

  void getDirectories(String rootPath) async {
    List<FileSystemEntity> dirs = await Directory(rootPath).list(followLinks: false).toList();
    List<String> directoryPath = dirs
      .whereType<Directory>()
      .map((FileSystemEntity fe) => fe.path).toList();
    emit(RootDirectoriesLoadedState(directories: directoryPath));
  }
}
