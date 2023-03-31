import 'package:filekraken/components/module_page.dart';
import 'package:flutter/material.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {

  final ValueNotifier<String> rootDirectoryPath = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FolderSelectionUnit(rootDirectoryPath: rootDirectoryPath),
        FilterDirectoryUnit(rootDirectoryPath: rootDirectoryPath)
      ],
    );
  }
}