import 'package:filekraken/components/titlebar/variable_widget.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/modifer_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/foundation.dart';

void main() {
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.macOS);
  final container = ProviderContainer(
    overrides: [
      variableListProvider.overrideWith((ref) => VariableListMockNotifier({
        "i": IndexVariable(),
        "d": DeleteVariable(),
        "s": ListVariable(id: 0, name: "Test", identifier: "s", content: ["d"], loop: true)
      }))
    ]
  );
  var variables = container.read(variableListProvider);
  group('Modifier evaluation', () {
    test('Swap characters', () {
      String match = "hello";
      String modifier = "[2][1][3][4][5]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "ehllo");
    });

    test('Strip characters with index range', () {
      String match = "hello";
      String modifier = "[2-5]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "ello");
    });

    test('Strip characters with missing end index', () {
      String match = "hello";
      String modifier = "[3-]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "llo");
    });

    test('Fail on index range greater than string length', () {
      String match = "hello";
      String modifier = "[2-7]";
      int index = 0;
      evaluateFn() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateFn, throwsA(isA<RangeError>()));
    });

    test('Fail on index range lower than 1', () {
      String match = "hello";
      String modifier = "[0-4]";
      int index = 0;
      evaluateFn() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateFn, throwsA(predicate<InvalidIdentifierException>((e) {
        return e.type == IdentifierErrorType.negativeOrZeroIndex; 
      })));
    });

    test('Fail on start index greater than end index', () {
      String match = "hello";
      String modifier = "[3-1]";
      int index = 0;
      evaluateFn() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateFn, throwsA(predicate<InvalidIdentifierException>((e) {
        return e.type == IdentifierErrorType.startIndexGreaterThanEndIndex; 
      })));
    });

    test('Delete match', () {
      String match = "hello";
      String modifier = "[d]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "");
    });

    test('Complete replacement', () {
      String match = "hello";
      String modifier = "test";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "test");
    });

    test('Replace with variable', () {
      String match = "hello";
      String modifier = "he[s]lo";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "hedlo");
    });

    test('Ignore escaped bracket', () {
      String match = "hello";
      String modifier = "he\\[slo";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "he\\[slo");
    });

    test('Ignore escaped bracket with normal brackets', () {
      String match = "hello";
      String modifier = "he\\[lo[s]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "he\\[lod");
    });

    test('Fails on index out of range', () {
      String match = "hello";
      String modifier = "[1][2][10]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(isA<RangeError>()));
    });

    test('Fails on negative index', () {
      String match = "hello";
      String modifier = "[-1][2][3]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(predicate<InvalidIdentifierException>((e) {
        return e.type == IdentifierErrorType.charIndexNotPositive; 
      })));
    });

    test('Fails on missing closing brackets', () {
      String match = "hello";
      String modifier = "[[test]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on missing opening brackets', () {
      String match = "hello";
      String modifier = "[i]]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on escape bracket with closing bracket', () {
      String match = "hello";
      String modifier = "\\[i]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on escape bracket with opening bracket', () {
      String match = "hello";
      String modifier = "[i\\]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(predicate<ArgumentError>((e) => e.message == "Invalid modifier")));
    });

    test('Fails on recursive brackets', () {
      String match = "hello";
      String modifier = "[[test]]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on brackets without identifier', () {
      String match = "hello";
      String modifier = "hell[]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });
    
    test('Mixing delete and character modifier', () {
      String match = "hello";
      String modifier = "[d]test";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect("test", result);
    });

    test('Fails on non-existing variable', () {
      String match = "hello";
      String modifier = "he[l]lo";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables, null);
      expect(evaluateF, throwsA(predicate<InvalidIdentifierException>((e) {
        return e.type == IdentifierErrorType.noMatchingType; 
      })));
    });

    test('Evaluate index', () {
      String match = "hello";
      String modifier = "hello[i]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables, null);
      expect(result, "hello1");
    });

    test('Apply index variable', () {
      String content = "hello[i]";
      int index = 0;
      String result = applyVariables(
        content: content, 
        index: index, 
        variables: variables
      );
      expect(result, "hello1");
    });

    test('Fails on missing closing bracket', () {
      String content = "hello[i";
      int index = 0;
      fn() => applyVariables(
        content: content, 
        index: index, 
        variables: variables
      );
      expect(fn, throwsArgumentError);
    });

    test('Fails on missing opening bracket', () {
      String content = "helloi]";
      int index = 0;
      fn() => applyVariables(
        content: content, 
        index: index, 
        variables: variables
      );
      expect(fn, throwsArgumentError);
    });

    test('Apply list variable', () {
      String content = "hello[s]";
      int index = 0;
      String result = applyVariables(
        content: content, 
        index: index, 
        variables: variables
      );
      expect(result, "hellod");
    });

    test('Apply delete variable', () {
      String content = "hello[d]";
      int index = 0;
      String result = applyVariables(
        content: content, 
        index: index, 
        variables: variables
      );
      expect(result, "hello");
    });
    
    test('Apply delete variable', () {
      String content = "hello[d]";
      int index = 0;
      String result = applyVariables(
        content: content, 
        index: index, 
        variables: variables
      );
      expect(result, "hello");
    });
    
    test('Fails on index placeholder', () {
      String content = "hello[4]";
      int index = 0;
      fn() => applyVariables(
        content: content, 
        index: index, 
        variables: variables
      );
      expect(fn, throwsAssertionError);
    });
  });
  
  group('Name modifier', () {
    int index = 0;
    test("Replace subwords", () {
      PathModifierConfig config = PathModifierConfig(
        isRegex: false,
        options: [
          PathModifierOptions(
            match: "one",
            modifier: "1",
            order: 1
          ),
          PathModifierOptions(
            match: "two",
            modifier: "2",
            order: 2
          ),
          PathModifierOptions(
            match: "three",
            modifier: "3",
            order: 3
          ),
        ],
      );
      String origin = "one-two-three";
      String result = modifyName(origin, index, config, variables, null);
      expect(result, "1-2-3");
    });

    test("Replace subwords with regex", () {
      PathModifierConfig config = PathModifierConfig(
        isRegex: true,
        options: [
          PathModifierOptions(
            match: "\\w{3}",
            modifier: "1",
            order: 1
          ),
          PathModifierOptions(
            match: "\\w{3}",
            modifier: "2",
            order: 2
          ),
          PathModifierOptions(
            match: "\\w{5}",
            modifier: "3",
            order: 3
          ),
        ],
      );
      String origin = "one-two-three";
      String result = modifyName(origin, index, config, variables, null);
      expect(result, "1-2-3");
    });

    test("Reorder subwords", () {
      PathModifierConfig config = PathModifierConfig(
        isRegex: false,
        options: [
          PathModifierOptions(
            match: "one",
            order: 3
          ),
          PathModifierOptions(
            match: "two",
            order: 2
          ),
          PathModifierOptions(
            match: "three",
            order: 1
          ),
        ],
      );
      String origin = "one-two-three";
      String result = modifyName(origin, index, config, variables, null);
      expect(result, "three-two-one");
    });

    test("Reorder subwords with regex", () {
      PathModifierConfig config = PathModifierConfig(
        isRegex: true,
        options: [
          PathModifierOptions(
            match: "\\w{3}",
            order: 3
          ),
          PathModifierOptions(
            match: "\\w{3}",
            order: 2
          ),
          PathModifierOptions(
            match: "\\w{5}",
            order: 1
          ),
        ],
      );
      String origin = "one-two-three";
      String result = modifyName(origin, index, config, variables, null);
      expect(result, "three-two-one");
    });

    test("Reorder and replace subwords", () {
      PathModifierConfig config = PathModifierConfig(
        isRegex: false,
        options: [
          PathModifierOptions(
            match: "one",
            modifier: "1",
            order: 3
          ),
          PathModifierOptions(
            match: "two",
            modifier: "2",
            order: 2
          ),
          PathModifierOptions(
            match: "three",
            modifier: "3",
            order: 1
          ),
        ],
      );
      String origin = "one-two-three";
      String result = modifyName(origin, index, config, variables, null);
      expect(result, "3-2-1");
    });

    test("Reorder and replace subwords with regex", () {
      PathModifierConfig config = PathModifierConfig(
        isRegex: true,
        options: [
          PathModifierOptions(
            match: "\\w{3}",
            modifier: "1",
            order: 3
          ),
          PathModifierOptions(
            match: "\\w{3}",
            modifier: "2",
            order: 2
          ),
          PathModifierOptions(
            match: "\\w{5}",
            modifier: "3",
            order: 1
          ),
        ],
      );
      String origin = "one-two-three";
      String result = modifyName(origin, index, config, variables, null);
      expect(result, "3-2-1");
    });
  });

  group("Identifier syntax", () {
    test("No brackets", () {
      String identifierName = "tsa";
      String? result = checkIdentifierSyntax(identifierName);
      expect(result, null);
    });

    test("Returns an error message on argument containing opening bracket ", () {
      String identifierName = "[sa";
      String? result = checkIdentifierSyntax(identifierName);
      expect(result, isNotNull);
    });

    test("Returns an error message on argument containing closing bracket ", () {
      String identifierName = "sa]";
      String? result = checkIdentifierSyntax(identifierName);
      expect(result, isNotNull);
    });

    test("Returns an error message on argument containing both opening and closing bracket ", () {
      String identifierName = "s[a]";
      String? result = checkIdentifierSyntax(identifierName);
      expect(result, isNotNull);
    });
  });
}

class VariableListMockNotifier extends StateNotifier<Map<String, Variable>> implements VariableListNotifier {
  VariableListMockNotifier(
    Map<String, Variable> variables
  ) : super(variables);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
