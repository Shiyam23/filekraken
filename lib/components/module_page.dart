import 'package:file_picker/file_picker.dart';
import 'package:filekraken/bloc/cubit/cubit/root_directories_cubit.dart';
import 'package:filekraken/pages/extract_page.dart';
import 'package:filekraken/pages/inject_page.dart';
import 'package:flutter/material.dart';
import '../pages/rename_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModulePage extends StatefulWidget {
  
  ModulePage({super.key, required this.pageIndex, required this.titleBarHeight});

  final double titleBarHeight;
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
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - widget.titleBarHeight,
                  child: SingleChildScrollView(
                    child: widget.pages[widget.pageIndex.value]
                  ),
                )
              ),
            ],
          );
        },
      ),
    );
  }
}

class FolderSelectionUnit extends StatelessWidget {
  
  FolderSelectionUnit({super.key, required this.rootDirectoryPath});

  final ValueNotifier<String> rootDirectoryPath;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      margin: const EdgeInsets.all(20),
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
                        onPressed: () => selectDirectory(context),
                      )
                    ),
                    
                  ),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  void selectDirectory(BuildContext context) async {
    RootDirectoriesCubit cubit = BlocProvider.of<RootDirectoriesCubit>(context);
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      _controller.text = selectedDirectory.toString();
      cubit.getDirectories(selectedDirectory);
    }
  }
}

class FilterDirectoryUnit extends StatefulWidget {
  const FilterDirectoryUnit({super.key, required this.rootDirectoryPath});

  final ValueNotifier<String> rootDirectoryPath;
  final List<Widget> subUnits = const [
    FilterDirectoryNone(key: ValueKey(0)),
    FilterDirectoryBySelection(key: ValueKey(1)),
    FilterDirectoryByNameSubUnit(key: ValueKey(2))
  ];

  @override
  State<FilterDirectoryUnit> createState() => _FilterDirectoryUnitState();
}

class _FilterDirectoryUnitState extends State<FilterDirectoryUnit> {

  int filterModeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      margin: const EdgeInsets.all(20),
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Filter folder",
                  style: TextStyle(
                    inherit: true,
                    fontSize: 30
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  child: DropdownButton(
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    value: filterModeIndex,
                    alignment: Alignment.center,
                    borderRadius: BorderRadius.circular(20),
                    style: const TextStyle(
                      inherit: true,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, alignment: Alignment.center, child: Text("None")),
                      DropdownMenuItem(value: 1, alignment: Alignment.center, child: Text("By Selection"),),
                      DropdownMenuItem(value: 2, alignment: Alignment.center, child: Text("By Name"),),
                    ],
                    onChanged: (filterMode) {
                      if (filterMode != null) {
                        setState(() => filterModeIndex = filterMode);
                      }
                    }
                  ),
                )
              ],
            ),
            widget.subUnits[filterModeIndex]
          ],
        ),
      ),
    );
  }
}

class FilterDirectoryByNameSubUnit extends StatefulWidget {
  const FilterDirectoryByNameSubUnit({super.key});

  @override
  State<FilterDirectoryByNameSubUnit> createState() => _FilterDirectoryByNameSubUnitState();
}

class _FilterDirectoryByNameSubUnitState extends State<FilterDirectoryByNameSubUnit> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FilterDirectoryBySelection extends StatefulWidget {
  
  const FilterDirectoryBySelection({super.key});

  @override
  State<FilterDirectoryBySelection> createState() => _FilterDirectoryBySelectionState();
}

class _FilterDirectoryBySelectionState extends State<FilterDirectoryBySelection> {
  
  Map<String, bool> directorySelection = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootDirectoriesCubit, RootDirectoriesState>(
      builder: (context, state) {
        if (state is RootDirectoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RootDirectoriesLoadedState) {
          for (String path in state.directories) {
            directorySelection[path] = false;
          }
          return ListView(
            shrinkWrap: true,
            children: state.directories.map((e) => ListTile(
              leading: StatefulBuilder(
                builder: (context, checkBoXSetState) {
                  return Checkbox(
                    value: directorySelection[e],
                    onChanged: (value) => checkBoXSetState(() => directorySelection[e] = value!),
                  );
                }
              ),
              title: Text(e.toString()),
            )).toList(),
          );
        } else {
          return const Text("Something went wrong!");
        }
      },
    );
  }
}

class FilterDirectoryNone extends StatelessWidget {
  const FilterDirectoryNone({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootDirectoriesCubit, RootDirectoriesState>(
      builder: (context, state) {
        if (state is RootDirectoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RootDirectoriesLoadedState) {
          return SizedBox(
            height: 500,
            child: ListView(
              shrinkWrap: true,
              children: state.directories.map((e) => ListTile(
                title: Text(
                  e.toString(),
                  overflow: TextOverflow.fade,
                ),
              )).toList(),
            ),
          );
        } else {
          return const Text("Something went wrong!");
        }
      },
    );
  }
}