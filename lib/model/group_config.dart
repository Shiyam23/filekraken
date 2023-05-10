import 'package:petitparser/petitparser.dart';

class GroupConfig {
  GroupConfig({
    required this.groups
  });
  final List<GroupOption> groups;
}

class GroupOption {
  GroupOption({
    this.match,
    this.groupName
  });
  String? match;
  String? groupName;
}

Parser _match = anyOf(",").neg().plus().flatten().map((value) => value.trimLeft());
Parser _separator = char(",").map((value) => "");
Parser _expression = _match & (_separator & _match).map((value) => value[1]).star();

List<String> parseGroupMatch(String groupMatch) {
  Result result = _expression.parse(groupMatch);
  if (result.isSuccess) {
    return [result.value[0], ...result.value[1]];
  }
  throw ArgumentError("Invalid groupmatch identifier");
}