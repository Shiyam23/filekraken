import 'package:flutter/foundation.dart';

class ModuleOperationResult {

  ModuleOperationResult({
    required this.fileResults,
    required this.dateTime,
  });
  
  final List<FileOperationResult> fileResults;
  final DateTime dateTime;

  @override
  bool operator ==(covariant ModuleOperationResult other) {
    if (identical(this, other)) return true;
  
    return 
      listEquals(other.fileResults, fileResults) &&
      other.dateTime == dateTime;
  }

  @override
  int get hashCode => fileResults.hashCode ^ dateTime.hashCode;
}

class FileOperationResult {
  
  FileOperationResult({
    required this.rootPath,
    required this.fileSource,
    required this.fileTarget,
    required this.operationType,
    required this.resultType,
    this.error,
  });

  final String rootPath;
  final String fileSource;
  final String fileTarget;
  final OperationType operationType;
  final ResultType resultType;
  final ErrorType? error;

  @override
  bool operator ==(covariant FileOperationResult other) {
    if (identical(this, other)) return true;
    return 
      other.rootPath == rootPath &&
      other.fileSource == fileSource &&
      other.fileTarget == fileTarget &&
      other.operationType == operationType &&
      other.resultType == resultType &&
      other.error == error;
  }

  @override
  int get hashCode {
    return rootPath.hashCode ^
      fileSource.hashCode ^
      fileTarget.hashCode ^
      operationType.hashCode ^
      resultType.hashCode ^
      error.hashCode;
  }

  FileOperationResult copyWith({
    String? rootPath,
    String? fileSource,
    String? fileTarget,
    OperationType? operationType,
    ResultType? resultType,
    ErrorType? error,
  }) {
    return FileOperationResult(
      rootPath: rootPath ?? this.rootPath,
      fileSource: fileSource ?? this.fileSource,
      fileTarget: fileTarget ?? this.fileTarget,
      operationType: operationType ?? this.operationType,
      resultType: resultType ?? this.resultType,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'FileOperationResult(fileSource: $fileSource, fileTarget: $fileTarget, operationType: $operationType, resultType: $resultType, error: $error)';
  }
}

enum ResultType {
  success,
  fail,
  dryRun
}

enum OperationType {
  extract,
  insert,
  create,
  rename,
}

enum ErrorType {
  invalidRootPath,
  invalidSource,
  invalidTarget,
  fileNotFound,
  pathNotFound,
  fileAlreadyExists,
  pathAlreadyExists,
  other, 
  noPermission
}