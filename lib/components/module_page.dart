import 'package:file_picker/file_picker.dart';
import 'package:filekraken/components/unit.dart';
import 'package:filekraken/model/file_content.dart';
import 'package:filekraken/pages/extract_page.dart';
import 'package:filekraken/pages/insert_page.dart';
import 'package:filekraken/service/file_op.dart';
import 'package:filekraken/service/textfield_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import '../service/group_config.dart';
import '../service/modifer_parser.dart';
import '../pages/create_page.dart';
import '../pages/rename_page.dart';

typedef OnFilterModeChange = void Function(FilterMode filterMode);

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
  void initState() {
    _controller.text = ref.read(rootDirectoryProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Unit(
      title: "Select root folder",
      content: Table(
        columnWidths: const {
          0: FixedColumnWidth(100),
          1: FlexColumnWidth()
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              const Text("Folder path"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: TextFormField(
                  validator: checkEmptiness,
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
              ),
            ],
          ),
          if (widget.depth != null) TableRow(
            children: [
              const Text("Depth"),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
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
                      ),
                    ],
                  ),
                ),
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
    this.onFilterModeChange,
    required this.initialFilterMode,
    required this.provider
  });

  final String title;
  final void Function(List<String> selectedDirectories) onEntitySelect;
  final OnFilterModeChange? onFilterModeChange;
  final FilterMode initialFilterMode;
  final StateNotifierProvider<dynamic, FileEntityState> provider;

  late final Map<FilterMode, Widget> subunits = {
    FilterMode.none: FilterNone(
      key: const ValueKey(0), 
      onEntitySelect: onEntitySelect,
      provider: provider
    ),
    FilterMode.bySelection: FilterBySelection(
      key: const ValueKey(1), 
      onEntitySelect: onEntitySelect,
      provider: provider
    ),
    FilterMode.byName: FilterByNameSubUnit(
      key: const ValueKey(2), 
      onEntitySelect: onEntitySelect,
      provider: provider,
    )
  };

  @override
  Widget build(BuildContext context) {
    return DynamicUnit<FilterMode>(
      title: title, 
      subunits: subunits,
      onSubunitChange: (mode) => onFilterModeChange?.call(mode),
    );
  }
}

enum FilterMode with FilterModeString{
  none,
  bySelection,
  byName
}

mixin FilterModeString on Enum implements Translatable{
  
  @override
  String toTranslatedString(BuildContext context) {
    switch (this) {
      case FilterMode.none: return "None";
      case FilterMode.bySelection: return "By Selection";
      case FilterMode.byName: return "By Name";
      default: throw UnimplementedError();
    }
  }
}

class FilterFileUnit extends FilterFileEntityUnit {
  FilterFileUnit({
    super.key, 
    required onFileSelect, 
    required FilterMode initialFilterMode,
    OnFilterModeChange? onFilterModeChange
  }) : super(
    title: "Select files",
    onEntitySelect: onFileSelect,
    initialFilterMode: initialFilterMode,
    onFilterModeChange: onFilterModeChange,
    provider: fileListStateProvider
  );
}

class FilterDirectoryUnit extends FilterFileEntityUnit {
  FilterDirectoryUnit({
    super.key, 
    required onDirectorySelect,
    required FilterMode initialFilterMode,
    OnFilterModeChange? onFilterModeChange
  }) : super(
    title: "Select folders",
    onEntitySelect: onDirectorySelect,
    initialFilterMode: initialFilterMode,
    onFilterModeChange: onFilterModeChange,
    provider: directoryListStateProvider
  );
}

class FilterByNameSubUnit extends ConsumerStatefulWidget {
  const FilterByNameSubUnit({
    super.key,
    required this.onEntitySelect,
    required this.provider
  });

  final void Function(List<String> selectedDirectories) onEntitySelect;
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
            onPressed: () => widget.onEntitySelect(filterByName(state.fileEntities, false)),
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
    required this.provider
  });

  final void Function(List<String> selectedDirectories) onEntitySelect;
  final StateNotifierProvider<dynamic, FileEntityState> provider;

  @override
  ConsumerState<FilterBySelection> createState() => _FilterBySelectionState();
}

class _FilterBySelectionState extends ConsumerState<FilterBySelection> {
  
  Map<String, bool> directorySelection = {};
  int selectedDirectories = 0;

  @override
  Widget build(BuildContext context) {
    FileEntityState state = ref.watch(widget.provider);
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
      WidgetsBinding.instance.addPostFrameCallback((_) => onEntitySelect(state.fileEntities));
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
          validator: remove ? null: validateOrder,
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

  String? validateOrder(String? orderValue) {
    if (orderValue == null || orderValue == "") {
      return "Order can not be empty";
    }
    int? order = int.tryParse(orderValue);
    if (order == null) return "Input needs to be a number";
    if (order < 1) return "Input needs to be 1 or greater";
    return null;
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
          Table(
            columnWidths: const {
              0: FixedColumnWidth(100)
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  const Text("Generator: "),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                    child: TextFormField(
                      validator: checkEmptiness,
                      initialValue: config.nameGenerator,
                      onChanged: (value) => config.nameGenerator = value,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Text("Number of files"),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                        child: SizedBox(
                          width: 80,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            initialValue: config.numberFiles.toString(),
                            onChanged: (value) {
                              config.numberFiles = int.parse(value);
                            },
                            validator: checkEmptiness,
                            decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    ContentMode.text: TextFileContentUnit(content: content),
    ContentMode.binary: BinaryFileContentUnit(content: content),
  };

  final FileContent content;
  final Map<ContentMode, Widget> subunits;

  @override
  Widget build(BuildContext context) {
    return DynamicUnit<ContentMode>(
      title: "File Content",
      subunits: subunits,
      onSubunitChange: (subunit) {
        content.mode = subunit;
      }
    );
  }
}


class TextFileContentUnit extends StatelessWidget {
  
  const TextFileContentUnit({super.key, required this.content});

  final FileContent content;
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: 5,
      validator: checkEmptiness,
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
            child: TextFormField(
              validator: checkEmptiness,
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