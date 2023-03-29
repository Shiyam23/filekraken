import 'package:file_picker/file_picker.dart';
import 'package:filekraken/pages/extract_page.dart';
import 'package:filekraken/pages/inject_page.dart';
import 'package:flutter/material.dart';
import '../pages/rename_page.dart';

class ModulePage extends StatefulWidget {
  
  ModulePage({super.key, required this.pageIndex});

  final ValueNotifier pageIndex;
  final List<Widget> pages = [
    const ExportPage(),
    const InjectPage(),
    const RenamePage(),
  ];

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: widget.pageIndex,
        builder: (BuildContext context, Widget? child) {
          return widget.pages[widget.pageIndex.value];
        },
      ),
    );
  }
}

class FolderSelectionUnit extends StatelessWidget {
  
  FolderSelectionUnit({super.key});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            margin: const EdgeInsets.all(10),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select folder",
                    style: TextStyle(
                      inherit: true,
                      fontSize: 30
                    ),
                  ),
                  Row(
                    children: [
                      const Text("Folder path"),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                        child: TextField(
                          controller: _controller,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            prefixIcon: IconButton(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              icon: const Icon(Icons.folder),
                              enableFeedback: true,
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: selectDirectory,
                            )
                          ),
                          
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      _controller.text = selectedDirectory.toString();
    }
  }
}