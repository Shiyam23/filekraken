import 'package:file_picker/file_picker.dart';
import 'package:filekraken/components/unit.dart';
import 'package:filekraken/model/file_content.dart';
import 'package:filekraken/pages/extract_page.dart';
import 'package:filekraken/pages/insert_page.dart';
import 'package:filekraken/service/file_op.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import '../model/group_config.dart';
import '../model/modifer_parser.dart';
import '../pages/create_page.dart';
import '../pages/rename_page.dart';

class ModulePage extends StatefulWidget {
  
  ModulePage({super.key, required this.pageIndex, required this.titleBarHeight});

  final double titleBarHeight;
  final ValueNotifier pageIndex;
  final List<Widget> pages = [
    const ExtractPage(),
    const InsertPage(),
    const CreatePage(),
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

class FolderSelectionUnit extends ConsumerStatefulWidget {
  
  const FolderSelectionUnit({
    super.key, 
    required this.onDirectorySelect,
    this.depth
  });

  final ValueNotifier<int>? depth;
  final void Function(String rootPath) onDirectorySelect;

  @override
  ConsumerState<FolderSelectionUnit> createState() => _FolderSelectionUnitState();
}

class _FolderSelectionUnitState extends ConsumerState<FolderSelectionUnit> {
  
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Unit(
      title: "Select root folder",
      content: Column(
        children: [
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
                      onPressed: () => _selectDirectory(context),
                    )
                  ),
                ),
              )),
            ],
          ),
          widget.depth == null ? const SizedBox.shrink() : Row(
            children: [
              const Text("Depth"),
              SizedBox(
                width: 230,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textAlign: TextAlign.center,
                    initialValue: widget.depth!.value.toString(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateDepth,
                    onChanged: _onChange,
                    decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                )
              ),
            ],
          ),

        ],
      )
    );
  }

  String? _validateDepth(String? value) {
    if (value == null || value == "") return "Must not be empty";
    int? depth = int.tryParse(value);
    if (depth == null || depth < 0) {
      return "Must be a positive number";
    }
    return null;
  }

  void _onChange(String? value) {
    if (value == null || value == "") return;
    int? depth = int.tryParse(value);
    if (depth == null || depth < 0) {
      return;
    }
    widget.depth!.value = depth;
  }

  void _selectDirectory(BuildContext context) async {
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

class FilterFileEntityUnit extends StatelessWidget {
  FilterFileEntityUnit({
    super.key,
    required this.onEntitySelect,
    required this.title,
    this.onFileRefresh,
    required this.provider
  });

  final String title;
  final void Function(List<String> selectedDirectories) onEntitySelect;
  final void Function()? onFileRefresh;
  final StateNotifierProvider<dynamic, FileEntityState> provider;

  late final Map<String, Widget> subunits = {
    "None": FilterNone(
      key: const ValueKey(0), 
      onEntitySelect: onEntitySelect,
      provider: provider
    ),
    "By Selection": FilterBySelection(
      key: const ValueKey(1), 
      onEntitySelect: onEntitySelect,
      onRefresh: onFileRefresh,
      provider: provider
    ),
    "By Name": FilterByNameSubUnit(
      key: const ValueKey(2), onDirectorySelect: onEntitySelect,
      provider: provider,
    )
  };

  @override
  Widget build(BuildContext context) {
    return DynamicUnit(
      title: title, 
      subunits: subunits,
      onSubunitChange: (_) => onFileRefresh?.call(),
    );
  }
}

class FilterFileUnit extends FilterFileEntityUnit {
  FilterFileUnit({
    super.key, 
    required onFileSelect, 
    onFileRefresh
  }) : super(
    title: "Select files",
    onEntitySelect: onFileSelect,
    onFileRefresh: onFileRefresh,
    provider: fileListStateProvider
  );
}

class FilterDirectoryUnit extends FilterFileEntityUnit {
  FilterDirectoryUnit({
    super.key, 
    required onDirectorySelect, 
    onFileRefresh
  }) : super(
    title: "Select folders",
    onEntitySelect: onDirectorySelect,
    onFileRefresh: onFileRefresh,
    provider: directoryListStateProvider
  );
}

class FilterByNameSubUnit extends ConsumerStatefulWidget {
  const FilterByNameSubUnit({
    super.key,
    required this.onDirectorySelect,
    required this.provider
  });

  final void Function(List<String> selectedDirectories) onDirectorySelect;
  final StateNotifierProvider<dynamic, FileEntityState> provider;

  @override
  ConsumerState<FilterByNameSubUnit> createState() => _FilterByNameSubUnitState();
}

class _FilterByNameSubUnitState extends ConsumerState<FilterByNameSubUnit> {
  
  final TextEditingController _controller = TextEditingController();
  int _dropDownButtonValue = 0;

  @override
  Widget build(BuildContext context) {
    FileEntityState state = ref.watch(widget.provider);
    if (state is FileEntityLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FileEntityWaitingForInput) {
      return const Text("Waiting for directory input");
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

class FilterBySelection extends ConsumerStatefulWidget {
  
  const FilterBySelection({
    super.key,
    required this.onEntitySelect,
    this.onRefresh,
    required this.provider
  });

  final void Function(List<String> selectedDirectories) onEntitySelect;
  final void Function()? onRefresh;
  final StateNotifierProvider<dynamic, FileEntityState> provider;

  @override
  ConsumerState<FilterBySelection> createState() => _FilterBySelectionState();
}

class _FilterBySelectionState extends ConsumerState<FilterBySelection> {
  
  Map<String, bool> directorySelection = {};
  int selectedDirectories = 0;

  @override
  Widget build(BuildContext context) {
    FileEntityState state = ref.read(widget.provider);
    ref.listen(widget.provider, (previous, next) {
      if (next is FileEntityLoadedState) {
          widget.onEntitySelect([]);
          directorySelection.clear();
        }
    });
    if (state is FileEntityLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FileEntityWaitingForInput) {
      return const Text("Waiting for directory input");
    }
    else if (state is FileEntityLoadedState) {
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
                },
              );
            }
          ),
          title: Text(basename(e)),
          visualDensity: VisualDensity.compact,
        )).toList(),
      );
    } else {
      return const Text("Something went wrong!");
    }
  }
}

class FilterNone extends ConsumerWidget {
  const FilterNone({
    super.key,
    required this.onEntitySelect,
    required this.provider
  });

  final void Function(List<String> selectedEntities) onEntitySelect;
  final StateNotifierProvider<dynamic, FileEntityState> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FileEntityState state = ref.watch(provider);
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
          visualDensity: VisualDensity.compact,
        )).toList(),
      );
    } else {
      return const Text("Something went wrong!");
    }
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
  late int count = widget.config.options.length;

  @override
  Widget build(BuildContext context) {
    return Unit(
      title: widget.title, 
      content: Column(
        children: [
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
              child: getRow(index, false)
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: addRow, child: const Text("Add"))
          )
        ],
      )
    );
  }

  Widget getRow(int index, bool remove) => Row(
    children: [
      Text("Match ${index+1}"),
      const SizedBox(width: 10),
      Expanded(
        flex: 3,
        child: TextFormField(
          initialValue: remove ? null : widget.config.options[index].match,
          onChanged: remove ? null : (value) => widget.config.options[index].match = value,
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
          initialValue: remove ? null : widget.config.options[index].modifier,
          onChanged: remove ? null : (value) => widget.config.options[index].modifier = value,
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
          initialValue: remove ? null : widget.config.options[index].order?.toString(),
          validator: remove ? null: (value) {
            if (value == null) return null;
            return int.tryParse(value) == null ? "Zahl!" : null;
          },
          onChanged: remove ? null: (value) {
            widget.config.options[index].order = int.tryParse(value);
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            hintStyle: TextStyle(
              inherit: true,
              fontSize: 13
            ),
          ),
        ),
      ),
      SizedBox(
        width: 50,
        child: (index != 0 || remove) ? IconButton(
          onPressed: () => removeRow(index), 
          icon: const Icon(Icons.delete),
        ) : const SizedBox.shrink(),
      )
    ],
  );

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
        child: getRow(index, true)
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

class GroupUnit extends StatefulWidget {

  const GroupUnit({
    required this.title,
    required this.config, 
    super.key
  });

  final String title;
  final GroupConfig config;

  @override
  State<GroupUnit> createState() => _GroupUnitState();
}

class _GroupUnitState extends State<GroupUnit> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  String? _errorText;
  late int count = widget.config.groups.length;

  @override
  Widget build(BuildContext context) {
    return Unit(
      title: widget.title, 
      content: Column(
        children: [
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            initialItemCount: count,
            itemBuilder: (context, index, animation) => SizeTransition(
              sizeFactor: animation,
              child: getRow(index, false)
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: addRow, child: const Text("Add"))
          )
        ],
      )
    );
  }

  Widget getRow(int index, bool remove) => Row(
    children: [
      Text("Group Match ${index+1}"),
      const SizedBox(width: 10),
      Expanded(
        flex: 3,
        child: TextFormField(
          initialValue: remove ? null : widget.config.groups[index].match,
          onChanged: remove ? null : (value) => widget.config.groups[index].match = value,
          decoration: const InputDecoration(
            hintText: "(unmodified)",
            hintStyle: TextStyle(
              inherit: true,
              fontSize: 13
            )
          ),
        ),
      ),
      Text("Group Name ${index+1}"),
      const SizedBox(width: 10),
      Expanded(
        flex: 3,
        child: TextFormField(
          initialValue: remove ? null : widget.config.groups[index].groupName,
          onChanged: remove ? null : (value) => widget.config.groups[index].groupName = value,
          decoration: const InputDecoration(
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
        child: !remove ? IconButton(
          onPressed: () => removeRow(index), 
          icon: const Icon(Icons.delete),
        ) : const SizedBox.shrink(),
      )
    ],
  );

  String? validatePathModifier(String? pathModifier) {
    return _errorText;
  }

  void addRow() {
    _listKey.currentState!.insertItem(count);
    widget.config.groups.add(GroupOption());
    count++;
  }

  void removeRow(int index) {
    _listKey.currentState!.removeItem(
      index, 
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: getRow(index, true)
      )
    );
    widget.config.groups.removeAt(index);
    count--;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class NameGeneratorUnit extends StatelessWidget {
  
  const NameGeneratorUnit({
    super.key, 
    required this.config
  });
  
  final NameGeneratorConfig config;

  @override
  Widget build(BuildContext context) {
    return Unit(
      title: "Choose name for files",
      content: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  const Text("Generator: "),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                    child: TextFormField(
                      initialValue: config.nameGenerator,
                      onChanged: (value) => config.nameGenerator = value,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              Row(
                children: [
                  const Text("Number of files"),
                  SizedBox(
                    width: 230,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        initialValue: config.numberFiles.toString(),
                        onChanged: (value) {
                          config.numberFiles = int.parse(value);
                        },
                        decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        ]
      )
    );
  }
}

class FileContentUnit extends StatelessWidget {
  FileContentUnit({
    super.key,
    required this.content
  }) : subunits = {
    "Text": TextFileContentUnit(content: content),
    "File": BinaryFileContentUnit(content: content),
  };

  final FileContent content;
  final Map<String, Widget> subunits;

  @override
  Widget build(BuildContext context) {
    return DynamicUnit(
      title: "File Content",
      subunits: subunits,
      onSubunitChange: (subunit) {
        switch (subunit) {
          case "Text": content.mode = ContentMode.text;break;
          case "File": content.mode = ContentMode.binary;break;
        }
      },
    );
  }
}

class TextFileContentUnit extends StatelessWidget {
  
  const TextFileContentUnit({super.key, required this.content});

  final FileContent content;
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: 5,
      maxLines: 10,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      onChanged: (value) {
        content.textContent = value;
      },
    );
  }
}

class BinaryFileContentUnit extends StatefulWidget {
  
  const BinaryFileContentUnit({super.key, required this.content});

  final FileContent content;

  @override
  State<BinaryFileContentUnit> createState() => _BinaryFileContentUnitState();
}

class _BinaryFileContentUnitState extends State<BinaryFileContentUnit> {
  
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("File path"),
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
                  onPressed: () => _selectFile(context),
                )
              ),
            ),
          )
        ),
      ],
    );
  }

  void _selectFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? path = result.files.first.path;
      if (path != null) {
        _controller.text = path;
        widget.content.binaryFilePath = path;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}