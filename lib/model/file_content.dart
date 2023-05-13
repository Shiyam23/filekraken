class FileContent {

  FileContent({
    this.binaryFilePath,
    this.textContent
  });

  String? binaryFilePath;
  String? textContent;
  ContentMode mode = ContentMode.text;
  
}

enum ContentMode {
  text,
  binary    
}