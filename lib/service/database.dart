import 'dart:io' show Directory;
import 'package:filekraken/model/list_variable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';

Provider<Database> database = Provider((ref) => IsarDatabase());

abstract class Database{

  Future<void> init();

  // ListVariable operations
  Future<List<ListVariable>> getListVariables();
  Future<void> addListVariable(ListVariable variable);
  Future<void> modifyListVariable(ListVariable oldVariable, ListVariable newVariable);
  Future<void> deleteListVariable(ListVariable variable);
  Stream<void> onListVariableChange();
}

class IsarDatabase implements Database {

  late final Isar isar;

  @override
  Future<void> init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ListVariableSchema], directory: dir.path);
  }

  @override
  Stream<void> onListVariableChange() => isar.listVariables.watchLazy();

  @override
  Future<List<ListVariable>> getListVariables() async {
    return await isar
      .listVariables
      .where()
      .findAll();
  }

  @override
  Future<void> addListVariable(ListVariable variable) async{
    await isar.writeTxn(() => isar.listVariables.put(variable));
  }

  @override
  Future<void> deleteListVariable(ListVariable variable) async {
    isar.writeTxn(() => isar.listVariables.delete(variable.id));
  }

  @override
  Future<void> modifyListVariable(ListVariable oldVariable, ListVariable newVariable) async {
    isar.writeTxn(() => isar.listVariables.put(newVariable));
  }
}