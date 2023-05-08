import 'package:file_picker/file_picker.dart';
import 'package:filekraken/bloc/cubit/cubit/filter_directories_cubit.dart';
import 'package:filekraken/pages/extract_page.dart';
import 'package:filekraken/pages/inject_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../model/modifer_parser.dart';
import '../pages/rename_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModulePage extends StatefulWidget {
  
  ModulePage({super.key, required this.pageIndex, required this.titleBarHeight});

  final double titleBarHeight;
  final ValueNotifier pageIndex;
  final List<Widget> pages = [
    const ExtractPage(),
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

class FolderSelectionUnit extends StatefulWidget {
  
  const FolderSelectionUnit({super.key, required this.onDirectorySelect});

  final void Function(String rootPath) onDirectorySelect;

  @override
  State<FolderSelectionUnit> createState() => _FolderSelectionUnitState();
}

class _FolderSelectionUnitState extends State<FolderSelectionUnit> {
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
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      _controller.text = selectedDirectory;
      widget.onDirectorySelect(selectedDirectory);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    FilterNone<FilterDirectoriesCubit>(
      key: const ValueKey(0), 
      onEntitySelect: onDirectorySelect
    ),
    FilterBySelection<FilterDirectoriesCubit>(
      key: const ValueKey(1), 
      onEntitySelect: onDirectorySelect,
      onRefresh: onFileRefresh,
    ),
    FilterByNameSubUnit<FilterDirectoriesCubit>(key: const ValueKey(2), onDirectorySelect: onDirectorySelect,)
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

class FilterByNameSubUnit<B extends Cubit<FileEntityState>> extends StatefulWidget {
  const FilterByNameSubUnit({
    super.key,
    required this.onDirectorySelect
  });

  final void Function(List<String> selectedDirectories) onDirectorySelect;

  @override
  State<FilterByNameSubUnit> createState() => _FilterByNameSubUnitState<B>();
}

class _FilterByNameSubUnitState<B extends Cubit<FileEntityState>> extends State<FilterByNameSubUnit> {
  
  final TextEditingController _controller = TextEditingController();
  int _dropDownButtonValue = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, FileEntityState>(
      builder: (context, state) {
        if (state is FileEntityLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FileEntityWaitingForInput) {
          return const Text("Waiting for input");
        } else if (state is FileEntityLoadedState) {
          return Column(
            children: [
              Row(
                children: [
                  DropdownButton(
                    value: _dropDownButtonValue,
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text("Contains"),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text("Prefix"),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Suffix"),
                      ),
                    ], 
                    onChanged: (i) => setState(() {
                      if (i != null && i != _dropDownButtonValue) {
                        _dropDownButtonValue = i;
                      }
                    })
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context, 
                      builder: (context) => SimpleDialog(
                        children: filterByName(state.fileEntities, true)
                        .map((e) => Text(e))
                        .toList(),
                      ),
                    ), 
                    icon: const Icon(Icons.info)
                  )
                ],
              ),
              TextButton(
                child: const Text("Submit"),
                onPressed: () => widget.onDirectorySelect(filterByName(state.fileEntities, false)),
              )
            ],
          );
        } else {
          return const Text("Something went wrong");
        }
      },
    );
  }

  List<String> filterByName(List<String> fileEntities, bool showOnlyBasename) {
    return fileEntities
    .map((e) => showOnlyBasename ? basename(e) : e)
    .where((element) => basename(element).contains(_controller.text))
    .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FilterBySelection<B extends Cubit<FileEntityState>> extends StatefulWidget {
  
  const FilterBySelection({
    super.key,
    required this.onEntitySelect,
    this.onRefresh
  });

  final void Function(List<String> selectedDirectories) onEntitySelect;
  final void Function()? onRefresh;

  @override
  State<FilterBySelection> createState() => _FilterBySelectionState<B>();
}

class _FilterBySelectionState<B extends Cubit<FileEntityState>> extends State<FilterBySelection> {
  
  Map<String, bool> directorySelection = {};
  int selectedDirectories = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, FileEntityState>(
      listener: (context, state) {
        if (state is FileEntityLoadedState) {
          widget.onEntitySelect([]);
          directorySelection.clear();
        }
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
            physics: const ClampingScrollPhysics(),
            children: state.fileEntities.map((e) => ListTile(
              leading: StatefulBuilder(
                builder: (context, checkBoXSetState) {
                  return Checkbox(
                    value: directorySelection[e],
                    onChanged: (value) {
                      checkBoXSetState(() => directorySelection[e] = value!);
                      widget.onEntitySelect(
                        directorySelection.keys
                        .where((element) => directorySelection[element] == true)
                        .toList()
                      );
                      selectedDirectories += value! ? 1 : -1;
                      if (selectedDirectories <= 0) {
                        widget.onRefresh?.call();
                      }
                    },
                  );
                }
              ),
              title: Text(basename(e)),
            )).toList(),
          );
        } else {
          return const Text("Something went wrong!");
        }
      },
    );
  }
}

class FilterNone<B extends Cubit<FileEntityState>> extends StatelessWidget {
  const FilterNone({
    super.key,
    required this.onEntitySelect
  });

  final void Function(List<String> selectedEntities) onEntitySelect;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, FileEntityState>(
      listener: (context, state) {
        if (state is FileEntityLoadedState) {
          onEntitySelect(state.fileEntities);
        }
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
            physics: const ClampingScrollPhysics(),
            children: state.fileEntities.map((e) => ListTile(
              title: Text(basename(e)),
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
  FilterFileUnit({super.key, required this.onFileSelect});

  final void Function(List<String> selectedFiles) onFileSelect;

  late final List<Widget> subUnits = [
    FilterNone<FilterFilesCubit>(
      key: const ValueKey(0), 
      onEntitySelect: onFileSelect
    ),
    FilterBySelection<FilterFilesCubit>(
      key: const ValueKey(1), 
      onEntitySelect: onFileSelect,
    ),
    FilterByNameSubUnit<FilterFilesCubit>(
      key: const ValueKey(2), 
      onDirectorySelect: onFileSelect
    )
  ];


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
                        if (filterMode != null && filterMode != filterModeIndex) {
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

class NameModifierUnit extends StatefulWidget {

  const NameModifierUnit({
    required this.title,
    required this.config, 
    super.key
  });

  final String title;
  final PathModifierConfig config;

  @override
  State<NameModifierUnit> createState() => _NameModifierUnitState();
}

class _NameModifierUnitState extends State<NameModifierUnit> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  String? _errorText;
  int count = 1;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                inherit: true,
                fontSize: 30
              ),
            ),
            Row(
              children: [
                const Text("Regular Expression"),
                StatefulBuilder(
                  builder: (BuildContext context, setState) {
                    return Checkbox(
                      value: widget.config.isRegex,
                      onChanged: (value) {
                        setState(() => widget.config.isRegex = value!);
                      }
                    );
                  },
                ),
              ],
            ),
            AnimatedList(
              key: _listKey,
              shrinkWrap: true,
              initialItemCount: count,
              itemBuilder: (context, index, animation) => SizeTransition(
                sizeFactor: animation,
                child: Row(
                  children: [
                    Text("Match ${index+1}"),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: widget.config.options[index].match,
                        onChanged: (value) => widget.config.options[index].match = value,
                        decoration: const InputDecoration(
                          hintText: "(unmodified)",
                          hintStyle: TextStyle(
                            inherit: true,
                            fontSize: 13
                          )
                        ),
                      ),
                    ),
                    Text("Modifier ${index+1}"),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: widget.config.options[index].modifier,
                        onChanged: (value) => widget.config.options[index].modifier = value,
                        decoration: const InputDecoration(
                          hintText: "(unmodified)",
                          hintStyle: TextStyle(
                            inherit: true,
                            fontSize: 13
                          )
                        ),
                      ),
                    ),
                    Text("Order ${index+1}"),
                    const SizedBox(width: 10),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        initialValue: widget.config.options[index].order?.toString(),
                        validator: (value) {
                          if (value == null) return null;
                          return int.tryParse(value) == null ? "Zahl!" : null;
                        },
                        onChanged: (value) {
                          widget.config.options[index].order = int.tryParse(value);
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: "(unmodified)",
                          hintStyle: TextStyle(
                            inherit: true,
                            fontSize: 13
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: index != 0 ? IconButton(
                        onPressed: () => removeRow(index), 
                        icon: const Icon(Icons.delete),
                      ) : const SizedBox.shrink(),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: addRow, child: const Text("Add"))
            )
          ],
        ),
      ),
    );
  }

  String? validatePathModifier(String? pathModifier) {
    return _errorText;
  }

  void addRow() {
    _listKey.currentState!.insertItem(count);
    widget.config.options.add(PathModifierOptions(
      order: count+1
    ));
    count++;
  }

  void removeRow(int index) {
    _listKey.currentState!.removeItem(
      index, 
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Row(
          children: [
            Text("Match ${index+1}"),
            const SizedBox(width: 10),
            const Expanded(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "(unmodified)",
                  hintStyle: TextStyle(
                    inherit: true,
                    fontSize: 13
                  )
                ),
              ),
            ),
            Text("Modifier ${index+1}"),
            const SizedBox(width: 10),
            const Expanded(
              flex: 3,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "(unmodified)",
                  hintStyle: TextStyle(
                    inherit: true,
                    fontSize: 13
                  )
                ),
              ),
            ),
            Text("Order ${index+1}"),
            const SizedBox(width: 10),
            const Flexible(
              flex: 1,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "(unmodified)",
                  hintStyle: TextStyle(
                    inherit: true,
                    fontSize: 13
                  )
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: index != 0 ? IconButton(
                onPressed: () => removeRow(index), 
                icon: const Icon(Icons.delete),
              ) : const SizedBox.shrink(),
            )
          ],
        ),
      )
    );
    widget.config.options.removeAt(index);
    count--;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

