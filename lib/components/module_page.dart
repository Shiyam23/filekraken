import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
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
  
  FolderSelectionUnit({super.key, required this.onDirectorySelect});

  final TextEditingController _controller = TextEditingController();
  final void Function(String rootPath) onDirectorySelect;

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
    FilterDirectoriesCubit cubit = BlocProvider.of<FilterDirectoriesCubit>(context);
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      _controller.text = selectedDirectory.toString();
      onDirectorySelect(_controller.text);
      cubit.emitDirectories(selectedDirectory);
    }
  }
}

class FilterDirectoryUnit extends StatefulWidget {
  FilterDirectoryUnit({
    super.key,
    required this.onDirectorySelect,
    required this.onFileRefresh
  });

  final void Function(List<String> selectedDirectories) onDirectorySelect;
  final void Function() onFileRefresh;

  late final List<Widget> subUnits = [
    FilterDirectoryNone(key: const ValueKey(0), onDirectorySelect: onDirectorySelect,),
    FilterDirectoryBySelection(
      key: const ValueKey(1), 
      onDirectorySelect: onDirectorySelect,
      onRefresh: onFileRefresh,
    ),
    FilterDirectoryByNameSubUnit(key: const ValueKey(2), onDirectorySelect: onDirectorySelect,)
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
                  width: 130,
                  child: ButtonTheme(
                    alignedDropdown: true,
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
                        if (filterMode != null && filterModeIndex != filterMode) {
                          widget.onFileRefresh();
                          setState(() => filterModeIndex = filterMode);
                        }
                      }
                    ),
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
  const FilterDirectoryByNameSubUnit({
    super.key,
    required this.onDirectorySelect
  });

  final void Function(List<String> selectedDirectories) onDirectorySelect;

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
  
  const FilterDirectoryBySelection({
    super.key,
    required this.onDirectorySelect,
    required this.onRefresh
  });

  final void Function(List<String> selectedDirectories) onDirectorySelect;
  final void Function() onRefresh;

  @override
  State<FilterDirectoryBySelection> createState() => _FilterDirectoryBySelectionState();
}

class _FilterDirectoryBySelectionState extends State<FilterDirectoryBySelection> {
  
  Map<String, bool> directorySelection = {};
  int selectedDirectories = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FilterDirectoriesCubit, FileEntityState>(
      listener: (context, state) {
        if (state is FileEntityLoadedState) {
          widget.onDirectorySelect([]);
        }
      },
      buildWhen: (previous, current) {
        return (current is! FileEntityLoadedState) || (current.type == FileSystemEntityType.directory);
      },
      builder: (context, state) {
        if (state is FileEntityLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FileEntityLoadedState) {
          for (String path in state.fileEntities) {
            directorySelection[path] = false;
          }
          return ListView(
            shrinkWrap: true,
            children: state.fileEntities.map((e) => ListTile(
              leading: StatefulBuilder(
                builder: (context, checkBoXSetState) {
                  return Checkbox(
                    value: directorySelection[e],
                    onChanged: (value) {
                      checkBoXSetState(() => directorySelection[e] = value!);
                      widget.onDirectorySelect(
                        directorySelection.keys
                        .where((element) => directorySelection[element] == true)
                        .toList()
                      );
                      selectedDirectories += value! ? 1 : -1;
                      if (selectedDirectories <= 0) {
                        widget.onRefresh();
                      }
                    },
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
  const FilterDirectoryNone({
    super.key,
    required this.onDirectorySelect
  });

  final void Function(List<String> selectedDirectories) onDirectorySelect;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FilterDirectoriesCubit, FileEntityState>(
      listener: (context, state) {
        if (state is FileEntityLoadedState) {
          onDirectorySelect(state.fileEntities);
        }
      },
      buildWhen: (previous, current) {
        return (current is! FileEntityLoadedState) || (current.type == FileSystemEntityType.directory);
      },
      builder: (context, state) {
        if (state is FileEntityWaitingForInput) {
          return const Text("Waiting for directory input");
        } 
        else if (state is FileEntityLoading) {
          return const Center(child: CircularProgressIndicator());
        } 
        else if (state is FileEntityLoadedState) {
          return ListView(
            shrinkWrap: true,
            children: state.fileEntities.map((e) => ListTile(
              title: Text(
                e.toString(),
                overflow: TextOverflow.fade,
              ),
            )).toList(),
          );
        } else {
          return const Text("Something went wrong!");
        }
      },
    );
  }
}

class FilterFileUnit extends StatefulWidget {
  const FilterFileUnit({super.key});

  @override
  State<FilterFileUnit> createState() => _FilterFileUnitState();
}

class _FilterFileUnitState extends State<FilterFileUnit> {

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
                  "Filter files",
                  style: TextStyle(
                    inherit: true,
                    fontSize: 30
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 130,
                  child: ButtonTheme(
                    alignedDropdown: true,
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
                  ),
                )
              ],
            ),
            BlocBuilder<FilterFilesCubit, FileEntityState>(
              buildWhen: (previous, current) {
                return (current is! FileEntityLoadedState) || (current.type == FileSystemEntityType.file);
              },
              builder: (context, state) {
                if (state is FileEntityWaitingForInput) {
                  return const Text("Waiting for directory input");
                } 
                else if (state is FileEntityLoading) {
                  return const Center(child: CircularProgressIndicator());
                } 
                else if (state is FileEntityLoadedState) {
                  return ListView(
                    shrinkWrap: true,
                    children: state.fileEntities.map((e) => ListTile(
                      title: Text(
                        e.toString(),
                        overflow: TextOverflow.fade,
                      ),
                    )).toList(),
                  );
                } else {
                  return const Text("Something went wrong!");
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

