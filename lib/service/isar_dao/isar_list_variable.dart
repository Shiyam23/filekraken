import 'package:filekraken/model/list_variable.dart';
import 'package:isar/isar.dart';

part 'isar_list_variable.g.dart';

@collection
class ListVariableDAO extends ListVariable{
  ListVariableDAO({
    required super.content,
    required super.identifier,
    required super.name,
    required super.loop, 
    super.id = Isar.autoIncrement
  });

  @override
  Id get id => Isar.autoIncrement;

  static ListVariableDAO fromData(ListVariableData data) {
    return ListVariableDAO(
      name: data.name,
      identifier: data.identifier,
      content: data.content,
      loop: data.loop,
    );
  }
}