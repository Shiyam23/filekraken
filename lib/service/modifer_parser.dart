import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/logger/logger.dart';
import 'package:petitparser/petitparser.dart';
import '../model/filename_limitations.dart';

class PathModifierOptions {
  PathModifierOptions({
    this.match,
    this.modifier,
    this.order
  });
  String? match;
  String? modifier;
  int? order;
}

class PathModifierConfig {
  List<PathModifierOptions> options;
  bool isRegex;
  PathModifierConfig({
    required this.options,
    this.isRegex = false,
  });
}

class NameGeneratorConfig {
  NameGeneratorConfig({
    required this.nameGenerator,
    required this.numberFiles,
  });
  String nameGenerator;
  int numberFiles;
}

final noBrackets = anyOf("[]$forbiddenCharacters").neg();
final identifier = escapedPar | escapedBackslash | anyOf("\\[]$forbiddenCharacters").neg();
final escapedPar = (char('\\') & anyOf("[]"));
final escapedBackslash = string('\\\\');
//final deleteVariable = string("[d]").end().map((value) => "");
//final identifierSyntax = (char("[") & identifier.plus() & char("]")).end();

String modifyName(
  String origin, 
  int index, 
  PathModifierConfig config,
  Map<String, Variable> variables,
  [LoggerBase? logger]
) {
  logger?.levelUp();
  logger?.logLine("Modifying name '$origin' with index ${index+1}");
  _validateOrder(config, logger);
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
    if (regExpMatch == null) {
      logger?.logLine("'${regExp.pattern}' has no match!");
      continue;
    }
    logger?.logLine("Match with '${regExp.pattern}' was found: ${regExpMatch.group(0)}");
    if (0 < regExpMatch.start) {
      String intermediateString = origin.substring(lastIndex, lastIndex + regExpMatch.start);
      parts.add(intermediateString);
      logger?.logLine("Intermediate string '$intermediateString' was added");
    }
    parts.add(null);
    orderIndices.add([regExpMatch.group(0), i, option.order!]);
    logger?.logLine("'${regExpMatch.group(0)}' was added with order: ${option.order!}");
    lastIndex += regExpMatch.end;
  }
  if (lastIndex < origin.length) {
    String lastString = origin.substring(lastIndex);
    parts.add(lastString);
    logger?.logLine("The rest of the name '$lastString' was added to the full name");
  }
  orderIndices.sort((a,b) => a[2].compareTo(b[2]));

  if (orderIndices.isNotEmpty) {
    String regexpOrder = orderIndices
    .map((e) => "'${e[0]}': ${e[2]}")
    .join(", ");
    logger?.logLine("The order of all matches is now: [$regexpOrder]");
  }

  int lastMatchindex = 0;
  for (int i = 0; i < parts.length; i++) {
    if (orderIndices.isEmpty) break;
    if (parts[i] != null) {
      logger?.logLine("${i+1}. part: '${parts[i]}'");
      continue;
    }
    PathModifierOptions option = config.options[orderIndices[lastMatchindex][1]];
    try {
      logger?.logLine("Evaluating modifier '${option.modifier}' with match '${orderIndices[lastMatchindex][0]}'");
      String evaluatedPart = evaluateModifier(
        orderIndices[lastMatchindex][0], 
        option.modifier, 
        index, 
        variables,
        logger
      );
      parts[i] = evaluatedPart;
      logger?.logLine("${i+1}. part: $evaluatedPart ");
    } on InvalidIdentifierException catch (e){
      e.rowIndex = orderIndices[lastMatchindex][1]+1;
      rethrow;
    } catch (e){
      throw ArgumentError("Invalid modifier in row ${orderIndices[lastMatchindex][1]+1}");
    }
    lastMatchindex++;
  }
  String concatenatedParts = parts.join("");
  logger?.logLine("Parts concatenated : '$concatenatedParts'");
  logger?.levelDown();
  return concatenatedParts;
}

void _validateOrder(PathModifierConfig config, LoggerBase? logger) {
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
  Map<String, Variable> variables,
  LoggerBase? logger
) {
  logger?.levelUp();
  if (modifier == null || modifier == "") {
    logger?.logLine("Modifier is null or empty");
    logger?.levelDown();
    return match;
  }
  InvalidIdentifierException? exception;
  final variable = (
    char('[').map((value) => "")
    & identifier.plus().flatten().map((value) {
      logger?.logLine("'[$value]' was found in $modifier");
      try {
        return _evaluateVariable(match, value, index, variables, logger);
      } on InvalidIdentifierException catch (e) {
        exception = e;
      }
    })
    & char(']').map((value) => "")
  ).map((value) => value.join());
  final term = escapedPar.flatten() | noBrackets | variable;
  final expression = term.star().map((value) => value.join()).end();
  final result = expression.parse(modifier);
  if (result.isFailure) {
    logger?.logLine("Modifier is invalid! Canceling operation...");
    logger?.levelDown();
    throw ArgumentError("Invalid modifier");
  }
  if (exception != null) {
    throw exception!;
  }
  logger?.logLine("Evaluated to '${result.value}'");
  logger?.levelDown();
  return result.value;
}

String applyVariables({
  required String content,
  required int index,
  required Map<String, Variable> variables
}) {
  final variable = (
    char('[').map((value) => "")
    & identifier.plus().flatten().map((value) {
      String? evaluation = _evaluateListVariable(value, index, variables);
      if (evaluation != null) {
        return evaluation;
      }
      throw MissingVariableException(
        content: content,
        value: value,
        index: index,
      );
    }) 
    & char(']').map((value) => "")
  ).map((value) => value.join());
  final term = escapedPar.flatten() | noBrackets | variable;
  final expression = term.star().map((value) => value.join()).end();
  var result = expression.parse(content);
  if (result.isFailure) {
    throw ArgumentError("Invalid modifier");
  }
  return result.value;
}


String? _evaluateListVariable(
  String identifier, 
  int index, 
  Map<String, Variable> variables
) {
  int? charIndex = int.tryParse(identifier);
  assert(charIndex == null);
  if (variables.containsKey(identifier)) {
    return variables[identifier]!.getValue(index);
  }
  return null;
}

String _evaluateVariable(
  String origin, 
  String identifier, 
  int index, 
  Map<String, Variable> variables,
  LoggerBase? logger
) {
  logger?.levelUp();
  int? charIndex = int.tryParse(identifier);
  if (charIndex != null) {
    logger?.logLine("[$identifier] is an index variable");
    if (charIndex < 1) {
      logger?.logLine("$charIndex is either negative or zero! Index has to be positive!");
      logger?.levelDown();
      throw InvalidIdentifierException(
        identifier: identifier,
        type: IdentifierErrorType.charIndexNotPositive
      );
    }
    String character = origin[charIndex-1];
    logger?.logLine("$charIndex. character of $origin is $character");
    logger?.levelDown();
    return character;
  }
  logger?.logLine("'[$identifier]' is not an index!");
  String? variable = _evaluateListVariable(identifier, index, variables);
  if (variable != null) {
    logger?.logLine("'[$identifier]' is a variable! Evaluated to '$variable'");
    logger?.levelDown();
    return variable;
  }
  logger?.logLine("'[$identifier]' is not a variable!");
  final Parser startIndex = digit().plus().flatten().trim().map(int.parse);
  final Parser dash = char("-").map((value) => "");
  final Parser endIndex = digit().star().flatten().map((value) {
   int? parsedIndex = int.tryParse(value);
    return parsedIndex ?? origin.length;
  });
  final Parser expression = (startIndex & dash & endIndex);
  final Result result = expression.parse(identifier);
  if (result.isSuccess) {
    logger?.logLine("'[$identifier]' is an index range");
    int startIndex = result.value[0];
    int endIndex = result.value[2];
    if (startIndex < 1 || endIndex < 1) {
      logger?.logLine("Both start index and end index have to be greater than zero!");
      logger?.levelDown();
      throw InvalidIdentifierException(
        identifier: identifier, 
        type: IdentifierErrorType.negativeOrZeroIndex, 
      );
    }
    if (result.value[0] > result.value[2]) {
      logger?.logLine("Start index has to be smaller than or equal to end index");
      logger?.levelDown();
      throw InvalidIdentifierException(
        identifier: identifier, 
        type: IdentifierErrorType.startIndexGreaterThanEndIndex, 
      );
    }
    String subString = origin.substring(result.value[0]-1, result.value[2]);
    logger?.logLine("Substring of '$origin' with start index: ${result.value[0]} and end index: ${result.value[2]} evaluated to: '$subString'");
    logger?.levelDown();
    return subString;
    
  }
  logger?.logLine("'[$identifier]' is neither an index, an index range nor a variable!");
  logger?.levelDown();
  throw InvalidIdentifierException(
    identifier: identifier, 
    type: IdentifierErrorType.noMatchingType, 
  );
}

String? checkIdentifierSyntax(String userInput) {
  Result result = noBrackets.plus().end().parse(userInput);
  return result.isSuccess ? null : result.message;
}

class InvalidIdentifierException implements Exception{

  InvalidIdentifierException({
    required this.identifier,
    required this.type,
    this.rowIndex
  });

  final String identifier;
  final IdentifierErrorType type;
  int? rowIndex;
}

enum IdentifierErrorType {
  noMatchingType,
  startIndexGreaterThanEndIndex,
  negativeOrZeroIndex,
  charIndexNotPositive
}