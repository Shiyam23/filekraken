import 'package:petitparser/petitparser.dart';

import 'filename_limitations.dart';

class PathModifierOptions {
  String? match;
  String? modifier;
  int? order;

  PathModifierOptions({
    this.match,
    this.modifier,
    this.order
  });
}

class PathModifierConfig {
  
  List<PathModifierOptions> options;
  bool isRegex;

  PathModifierConfig({
    required this.options,
    this.isRegex = false,
  });
}

String modifyName(
  String origin, 
  int index, 
  PathModifierConfig config,
  Map<String, String> variables
) {
  _validateOrder(config);
  int lastIndex = 0;
  List<String?> parts = [];
  List<List<dynamic>> orderIndices = [];

  for (int i = 0; i < config.options.length; i++) {
    PathModifierOptions option = config.options[i];
    if (option.match == null) {
      continue;
    }
    RegExp regExp = RegExp(config.isRegex ? option.match! : RegExp.escape(option.match!));
    RegExpMatch? regExpMatch = regExp.firstMatch(origin.substring(lastIndex));
    if (regExpMatch == null) continue;
    if (0 < regExpMatch.start) {
      parts.add(origin.substring(lastIndex, lastIndex + regExpMatch.start));
    }
    parts.add(null);
    orderIndices.add([regExpMatch.group(0), i, option.order!]);
    lastIndex += regExpMatch.end;
  }
  if (lastIndex < origin.length) {
    parts.add(origin.substring(lastIndex));
  }
  orderIndices.sort((a,b) => a[2].compareTo(b[2]));

  int lastMatchindex = 0;
  for (int i = 0; i < parts.length; i++) {
    String? subword = parts[i];
    if (orderIndices.isEmpty) break;
    if (subword != null) continue;
    PathModifierOptions option = config.options[orderIndices[lastMatchindex][1]];
    try {
      parts[i] = evaluateModifier(orderIndices[lastMatchindex][0], option.modifier, index, variables);
    } catch (e){
      throw ArgumentError("Invalid modifier in row ${orderIndices[lastMatchindex][1]+1}");
    }
    lastMatchindex++;
  }
  return parts.join("");
}

void _validateOrder(PathModifierConfig config) {
  List<int?> orders = config.options.map((e) => e.order).toList();
  for (int i = 0; i < config.options.length; i++) {
    if (!orders.contains(i+1)) {
      throw ArgumentError(
        "The order of all modifiers has to be in range of [1,..., ${config.options.length}]"
      );
    }
  }
}

String evaluateModifier(
  String match,
  String? modifier,
  int index,
  Map<String, String> variables
) {
  if (modifier == null || modifier == "") return match;
  final noBrackets = anyOf("[]$forbiddenCharacters").neg();
  final identifier = anyOf("[]d$forbiddenCharacters").neg();
  final escapedPar = (char('\\') & anyOf("[]"));
  final variable = (
    char('[').map((value) => "")
    & identifier.plus().flatten().map((value) {
      return _applyVariable(match, value, index, variables);
    }) 
    & char(']').map((value) => "")
  ).map((value) => value.join());
  final term = escapedPar.flatten() | noBrackets | variable;
  final expression = 
    string("[d]").end().map((value) => "") 
    | term.star().map((value) => value.join()).end();
  var result = expression.parse(modifier);
  if (result.isFailure) {
    throw ArgumentError("Invalid modifier");
  }
  return result.value;
}

String _applyVariable(
  String origin, 
  String identifier, 
  int index, 
  Map<String, String> variables
) {
  int? charIndex = int.tryParse(identifier);
  if (charIndex != null) {
    if (charIndex < 1) {
      throw ArgumentError.value(
        identifier,
        "CharIndex value has to be greater than or equal to 1"
      );
    }
    return origin[charIndex-1];
  }
  if (identifier == "i") {
    return index.toString();
  }
  if (variables.containsKey(identifier)) {
    return variables[identifier]!;
  }

  final Parser startIndex = digit().plus().flatten().trim().map(int.parse);
  final Parser dash = char("-").map((value) => "");
  final Parser endIndex = digit().star().flatten().map((value) {
   int? parsedIndex = int.tryParse(value);
    return parsedIndex ?? origin.length;
  });
  final Parser expression = (startIndex & dash & endIndex);
  final Result result = expression.parse(identifier);
  if (result.isSuccess) {
    int startIndex = result.value[0];
    int endIndex = result.value[2];
    if (startIndex < 1 || endIndex < 1) {
      throw ArgumentError.value(
        identifier, 
        "value", 
        "Both start index and end index have to be greater than zero"
      );
    }
    if (result.value[0] > result.value[2]) {
      throw ArgumentError.value(
        identifier, 
        "value", 
        "Start index has to be smaller than or equal to end index"
      );
    }
    return origin.substring(result.value[0]-1, result.value[2]);
    
  }
  throw ArgumentError.value(
    identifier, 
    "value", 
    "Either value has to be a number or it must be contained in variables."
  );
}
