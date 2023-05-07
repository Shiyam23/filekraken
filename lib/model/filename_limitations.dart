import 'package:flutter/foundation.dart';

String get forbiddenCharacters {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
      return "\\/:*?\"<>|";
    case TargetPlatform.macOS:
      return ":";
    case TargetPlatform.linux:
      throw UnimplementedError("Not implemented yet");
    default:
      throw UnsupportedError("OS not supported");
  }
}