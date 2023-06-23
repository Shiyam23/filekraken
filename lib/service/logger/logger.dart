import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

Provider<LoggerBase?> loggerProvider = Provider((_) => LoggerImpl());

abstract class LoggerBase {
  void clear();
  void printLog();
  void logHeader(String header, String rootPath, int numberFiles);
  void logLine(String step);
  void nextSection();
  void end();
  void levelUp([int step = 1]);
  void levelDown([int step = 1]);
}

class LoggerImpl implements LoggerBase {
  
  static const int lineLength = 150;
  static const int leftPadding = 2;
  int currentLevel = 0;
  static const String topLeftCorner = "╔";
  static const String topBorder = "═";
  static const String topRightCorner = "╗";
  static const String doubleVerticalToHorizontal = "╟";
  static const String space = " ";
  static const String doubleVertical = "║";
  static const String bottomLeftCorner = "╚";
  static const String dash = "─";
  static const String indent = "   ";
  String? doubleDivider;
  String? simpleDivider;
  StringBuffer logBuffer = StringBuffer();

  @override
  void clear() => logBuffer.clear();
  
  @override
  void logHeader(String operation, String rootPath, int numberFiles) {
    logBuffer.clear();
    _logDoubleDivider(topLeftCorner);
    logLine(operation);
    String formattedDate = DateFormat().format(DateTime.now());
    logLine("Date: $formattedDate");
    logLine("No. of Files: $numberFiles");
    _logSimpleDivider();
  }

  @override
  void logLine(String line) {
    logBuffer.write(doubleVertical);
    for (int i = 0; i < leftPadding; i++) {
      logBuffer.write(space);
    }
    for (int i = 0; i < currentLevel; i++) {
      logBuffer.write(indent);
    }
    logBuffer.write("");
    logBuffer.writeln(line);
  }

  void _logDoubleDivider(String firstSymbol) {
    logBuffer.writeln(_generateDivider(topBorder, firstSymbol));
  }

  void _logSimpleDivider() {
    logBuffer.writeln(simpleDivider ??= _generateDivider(dash));
  }

  String _generateDivider(String symbol, [String? firstSymbol]) {
    StringBuffer dividerBuffer = StringBuffer();
    firstSymbol ??= doubleVerticalToHorizontal;
    dividerBuffer.write(firstSymbol);
    for (int i = 0; i < lineLength-1; i++) {
      dividerBuffer.write(symbol);
    }
    return dividerBuffer.toString();
  }

  @override
  void levelDown([int step = 1]) {
    if (currentLevel > 0) currentLevel -= step;
  }
  
  @override
  void levelUp([int step = 1]) {
    currentLevel += step;
  }

  @override
  void printLog() async {
    String exePath = Platform.script.toFilePath();
    String logDirPath = join(dirname(exePath), "logs");
    String logBasename = "fk_log";
    File logFile = File(join(logDirPath, "$logBasename.txt"));
    int i = 1;
    while (await logFile.exists()) {
      logFile = File(join(logDirPath, "$logBasename$i.txt"));
      i++;
    }
    await logFile.create(recursive: true);
    String content = logBuffer.toString();
    await logFile.writeAsString(content, flush: true);
  }

  @override
  void end() {
    _logDoubleDivider(bottomLeftCorner);
    currentLevel = 0;
  }

  @override
  void nextSection() {
    _logSimpleDivider();
  }
}