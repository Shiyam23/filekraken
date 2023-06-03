import 'package:filekraken/model/file_result.dart';
import 'package:isar/isar.dart';

part 'isar_file_result.g.dart';

@Collection(ignore: {'fileResults'})
class IsarModuleOperationResult implements ModuleOperationResult {
  IsarModuleOperationResult({
    Id id = Isar.autoIncrement,
    required this.isarFileResults,
    required this.dateTime,
    required this.operationType,
    required this.rootPath
  });

  @override
  Id id = Isar.autoIncrement;
  final List<IsarFileOperationResult> isarFileResults;
  
  @override
  List<FileOperationResult> get fileResults => isarFileResults.map((e) => e.toFileResult()).toList();
  
  @override
  final DateTime dateTime;
  
  @override
  @enumerated
  final OperationType operationType;
  
  @override
  final String rootPath;

  static IsarModuleOperationResult fromData(ModuleOperationResultData data) {
    List<IsarFileOperationResult> fileOperationResults = data
    .fileResults
    .map((e) => IsarFileOperationResult(
      rootPath: e.rootPath,
      fileSource: e.fileSource,
      fileTarget: e.fileTarget,
      operationType: e.operationType,
      resultType: e.resultType)
    ).toList();
    return IsarModuleOperationResult(
      isarFileResults: fileOperationResults,
      dateTime: data.dateTime,
      operationType: data.operationType,
      rootPath: data.rootPath
    );
  }
}

@embedded
class IsarFileOperationResult {
  IsarFileOperationResult({
    this.rootPath,
    this.fileSource, 
    this.fileTarget, 
    this.operationType = OperationType.extract, 
    this.resultType = ResultType.success,
    this.error = ErrorType.other
  });

  String? rootPath;
  String? fileSource;
  String? fileTarget;
  @enumerated
  OperationType operationType;
  @enumerated
  ResultType resultType;
  @enumerated
  ErrorType error;

  FileOperationResult toFileResult() {
    return FileOperationResult(
      rootPath: rootPath!,
      fileSource: fileSource!,
      fileTarget: fileTarget!,
      operationType: operationType,
      resultType: resultType,
      error: error
    );
  }

  static IsarFileOperationResult fromFileResult(FileOperationResult fs) {
    return IsarFileOperationResult(
      rootPath: fs.rootPath,
      fileSource: fs.fileSource,
      fileTarget: fs.fileTarget,
      operationType: fs.operationType,
      resultType: fs.resultType,
      error: fs.error
    );
  }
}