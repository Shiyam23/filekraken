import 'package:filekraken/model/file_result.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:riverpod/riverpod.dart';

Provider<Database> database = Provider((ref) => NoOpDatabase());

abstract class Database{

  Future<void> init();

  // ListVariable operations
  Future<List<ListVariable>> getListVariables();
  Future<ListVariable> addListVariable(ListVariableData variable);
  Future<ListVariable> modifyListVariable(ListVariable oldVariable, ListVariableData newVariable);
  Future<void> deleteListVariable(ListVariable variable);
  Stream<void> onListVariableChange();

  // History
  Future<List<ModuleOperationResult>> getModuleOperationResults();
  Future<ModuleOperationResult> addModuleOperationResult(ModuleOperationResultData data);
  Future<void> deleteModuleOperationResult(ModuleOperationResult data);
  
}

class NoOpDatabase implements Database {
  @override
  Future<ListVariable> addListVariable(ListVariableData variable) async {
    throw UnsupportedError("Not supported for web");
  }

  @override
  Future<ModuleOperationResult> addModuleOperationResult(ModuleOperationResultData data) async {
    throw UnsupportedError("Not supported for web");
  }

  @override
  Future<void> deleteListVariable(ListVariable variable) async {
    
  }

  @override
  Future<void> deleteModuleOperationResult(ModuleOperationResult data) async {
    
  }

  @override
  Future<List<ListVariable>> getListVariables() async {
    return [];
  }

  @override
  Future<List<ModuleOperationResult>> getModuleOperationResults() async {
    return [
      ModuleOperationResult(
        id: 0, 
        fileResults: [
          FileOperationResult(
            rootPath: "/root",
            fileSource: "oldrootfile1",
            fileTarget: "rootfile1",
            operationType: OperationType.rename,
            resultType: ResultType.success,
            error: ErrorType.none
          ),
          FileOperationResult(
            rootPath: "/root",
            fileSource: "oldrootfile2",
            fileTarget: "rootfile2",
            operationType: OperationType.rename,
            resultType: ResultType.success,
            error: ErrorType.none
          ),
          FileOperationResult(
            rootPath: "/root",
            fileSource: "oldrootfile3",
            fileTarget: "rootfile4",
            operationType: OperationType.rename,
            resultType: ResultType.success,
            error: ErrorType.none
          ),
          FileOperationResult(
            rootPath: "/root",
            fileSource: "oldrootfile4",
            fileTarget: "rootfile4",
            operationType: OperationType.rename,
            resultType: ResultType.success,
            error: ErrorType.none
          ),
          FileOperationResult(
            rootPath: "/root",
            fileSource: "oldrootfile5",
            fileTarget: "rootfile5",
            operationType: OperationType.rename,
            resultType: ResultType.success,
            error: ErrorType.none
          ),
        ],
        dateTime: DateTime(2023, 6,29),
        operationType: OperationType.rename,
        rootPath: "/root"
      )
    ];
  }

  @override
  Future<void> init() async {
    
  }

  @override
  Future<ListVariable> modifyListVariable(ListVariable oldVariable, ListVariableData newVariable) async {
    throw UnsupportedError("Not supported for web");
  }

  @override
  Stream<void> onListVariableChange() {
    return const Stream.empty();
  }
}