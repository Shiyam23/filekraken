import 'package:filekraken/components/unit.dart';
import 'package:flutter/widgets.dart';

class FileContent {

  FileContent({
    this.binaryFilePath,
    this.textContent
  });

  String? binaryFilePath;
  String? textContent;
  ContentMode mode = ContentMode.text;
  
}

enum ContentMode with ContentModeString {
  text,
  binary    
}

mixin ContentModeString implements Translatable{
  @override
  String toTranslatedString(BuildContext context) {
    switch (this) {
      case ContentMode.text: return "Text";
      case ContentMode.binary: return "File";
    }
    return super.toString();
  }
}