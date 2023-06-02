abstract class Variable {
  Variable({
    required this.identifier,
    required this.name,
  });
  final String identifier;
  final String name;

  String getValue(int index);

  String getDescription();
}

class ListVariable extends Variable{
  ListVariable({
    required this.content,
    required super.identifier,
    required super.name,
    required this.loop,
    required this.id
  });

  int id;
  final List<String> content;
  final bool loop;

  @override
  String getDescription() => content.join(", ");

  @override
  String getValue(int index) {
    if (index < content.length) {
      return content[index];
    } else if (loop) {
      return content[index % content.length];
    }
    return "";
  }
}

class ListVariableData {

  ListVariableData({
    required this.identifier, 
    required this.name, 
    required this.content, 
    required this.loop
  });

  final String identifier;
  final String name;
  final List<String> content;
  final bool loop;
}

class IndexVariable extends Variable{
  IndexVariable() : super(identifier: "i", name: "Index");

  @override
  String getDescription() => "Index";

  @override
  String getValue(int index) => (index + 1).toString();
}

class DeleteVariable extends Variable{
  DeleteVariable() : super(identifier: "d", name: "Delete");

  @override
  String getDescription() => "Delete";

  @override
  String getValue(int index) => "";
}

class MissingVariableException implements Exception{

  MissingVariableException({
    required this.content,
    required this.value,
    required this.index
  });

  final String content;
  final String value;
  final int index;
}