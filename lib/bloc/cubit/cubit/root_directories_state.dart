part of 'root_directories_cubit.dart';

@immutable
class RootDirectoriesState {
  const RootDirectoriesState();
}

class RootDirectoriesWaitingForInput extends RootDirectoriesState {
  const RootDirectoriesWaitingForInput();
}

class RootDirectoriesLoading extends RootDirectoriesState {
  const RootDirectoriesLoading();
}

class RootDirectoriesLoadedState extends RootDirectoriesState {

  const RootDirectoriesLoadedState({required this.directories});
  final List<String> directories;
}
