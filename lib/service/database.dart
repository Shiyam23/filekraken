import 'dart:io' show Directory;
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/isar_dao/isar_list_variable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';

Provider<Database> database = Provider((ref) => IsarDatabase());

abstract class Database{

  Future<void> init();

  // ListVariable operations
  Future<List<ListVariable>> getListVariables();
  Future<ListVariable> addListVariable(ListVariableData variable);
  Future<ListVariable> modifyListVariable(ListVariable oldVariable, ListVariableData newVariable);
  Future<void> deleteListVariable(ListVariable variable);
  Stream<void> onListVariableChange();
}

class IsarDatabase implements Database {

  late final Isar isar;

  @override
  Future<void> init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ListVariableDAOSchema], directory: dir.path);
  }

  @override
  Stream<void> onListVariableChange() => isar.listVariableDAOs.watchLazy();

  @override
  Future<List<ListVariable>> getListVariables() async {
    return await isar
      .listVariableDAOs
      .where()
      .findAll();
  }

  @override
  Future<ListVariable> addListVariable(ListVariableData variable) async{
    ListVariableDAO newVariable = ListVariableDAO.fromData(variable);
    int id = await isar.writeTxn<int>(() {
      return isar.listVariableDAOs.put(newVariable);
    });
    return newVariable..id = id;
  }

  @override
  Future<void> deleteListVariable(ListVariable variable) async {
    isar.writeTxn(() => isar.listVariableDAOs.delete(variable.id));
  }

  @override
  Future<ListVariable> modifyListVariable(ListVariable oldVariable, ListVariableData newData) async {
    ListVariableDAO newVariable = ListVariableDAO(
      id: oldVariable.id,
      name: newData.name,
      content: newData.content,
      identifier: newData.identifier,
      loop: newData.loop
    );
    isar.writeTxn(() => isar.listVariableDAOs.put(newVariable));
    return newVariable;
  }
}