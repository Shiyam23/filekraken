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

mixin ContentModeString{
  @override
  String toString() {
    switch (this) {
      case ContentMode.text: return "Text";
      case ContentMode.binary: return "File";
    }
    return super.toString();
  }
}