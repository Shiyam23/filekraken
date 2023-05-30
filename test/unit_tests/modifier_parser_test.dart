import 'package:filekraken/components/titlebar/variable_widget.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/modifer_parser.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
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
      String result = evaluateModifier(match, modifier, index, variables);
      expect(result, "ehllo");
    });

    test('Delete match', () {
      String match = "hello";
      String modifier = "[d]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables);
      expect(result, "");
    });

    test('Complete replacement', () {
      String match = "hello";
      String modifier = "test";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables);
      expect(result, "test");
    });

    test('Replace with variable', () {
      String match = "hello";
      String modifier = "he[s]lo";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables);
      expect(result, "hedlo");
    });

    test('Ignore escaped bracket', () {
      String match = "hello";
      String modifier = "he\\[slo";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables);
      expect(result, "he\\[slo");
    });

    test('Ignore escaped bracket with normal brackets', () {
      String match = "hello";
      String modifier = "he\\[lo[s]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables);
      expect(result, "he\\[lod");
    });

    test('Fails on index out of range', () {
      String match = "hello";
      String modifier = "[1][2][10]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<RangeError>()));
    });

    test('Fails on negative index', () {
      String match = "hello";
      String modifier = "[-1][2][3]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on missing closing brackets', () {
      String match = "hello";
      String modifier = "[[test]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on missing opening brackets', () {
      String match = "hello";
      String modifier = "[test]]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on escape bracket with closing bracket', () {
      String match = "hello";
      String modifier = "\\[test]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on escape bracket with opening bracket', () {
      String match = "hello";
      String modifier = "[test\\]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on recursive brackets', () {
      String match = "hello";
      String modifier = "[[test]]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Fails on brackets without identifier', () {
      String match = "hello";
      String modifier = "hell[]";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });
    
    test('Mixing delete and character modifier', () {
      String match = "hello";
      String modifier = "[d]test";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables);
      expect("test", result);
    });

    test('Fails on non-existing variable', () {
      String match = "hello";
      String modifier = "he[l]lo";
      int index = 0;
      evaluateF() => evaluateModifier(match, modifier, index, variables);
      expect(evaluateF, throwsA(isA<ArgumentError>()));
    });

    test('Evaluate index', () {
      String match = "hello";
      String modifier = "hello[i]";
      int index = 0;
      String result = evaluateModifier(match, modifier, index, variables);
      expect(result, "hello1");
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
      String result = modifyName(origin, index, config, variables);
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
      String result = modifyName(origin, index, config, variables);
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
      String result = modifyName(origin, index, config, variables);
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
      String result = modifyName(origin, index, config, variables);
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
      String result = modifyName(origin, index, config, variables);
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
      String result = modifyName(origin, index, config, variables);
      expect(result, "3-2-1");
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
