import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filekraken/components/unit.dart';
import 'package:filekraken/layout.dart';
import 'package:filekraken/model/file_content.dart';
import 'package:filekraken/model/file_result.dart';
import 'package:filekraken/pages/pages.dart';
import 'package:filekraken/service/file_read_op.dart';
import 'package:filekraken/service/textfield_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../service/group_config.dart';
import '../service/modifer_parser.dart';

typedef OnFilterModeChange = void Function(FilterMode filterMode);

Provider<GlobalKey<NavigatorState>> navigatorProvider = Provider((_) => GlobalKey<NavigatorState>());

class ModulePage extends ConsumerWidget {
  
  const ModulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double titleBarHeight = ref.watch(titlebarHeightProvider);
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - titleBarHeight,
        child: Navigator(
          key: ref.watch(navigatorProvider),
          initialRoute: OperationType.extract.toString(),
          onGenerateRoute: (settings) {
            Widget? module = ref.read(pageProvider)[settings.name!];
            if (module == null) {
              throw ArgumentError("Unknown operation type");
            }
            return PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, a, aa) => SingleChildScrollView(child: module),
              settings: settings
            );
          },
        ),
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

enum FilterMode implements Translatable{
  none,
  bySelection,
  byName;

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
  StringMatchMode stringMatchMode = StringMatchMode.contains;

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
              DropdownButton<StringMatchMode>(
                value: stringMatchMode,
                items: const [
                  DropdownMenuItem(
                    value: StringMatchMode.contains,
                    child: Text("Contains"),
                  ),
                  DropdownMenuItem(
                    value: StringMatchMode.prefix,
                    child: Text("Prefix"),
                  ),
                  DropdownMenuItem(
                    value: StringMatchMode.suffix,
                    child: Text("Suffix"),
                  ),
                ], 
                onChanged: (i) => setState(() {
                  if (i != null && i != stringMatchMode) {
                    stringMatchMode = i;
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
    .map((e) => showOnlyBasename ? path.basename(e) : e)
    .where((element) {
      return switch (stringMatchMode) {
        StringMatchMode.contains => path.basename(element).contains(_controller.text),
        StringMatchMode.prefix => path.basename(element).startsWith(_controller.text),
        StringMatchMode.suffix => path.basename(element).endsWith(_controller.text),
      };
    })
    .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

enum StringMatchMode {
  prefix,
  suffix,
  contains
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
  
  List<(String, ValueNotifier<bool>)> directorySelection = [];
  int selectedDirectories = 0;
  final FocusNode _focusNode = FocusNode(
    skipTraversal: true
  );
  bool holdingShift = false;
  int lastToggledCheckbox = 0;

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
      directorySelection = [
        for (String path in state.fileEntities)
        (path, ValueNotifier(false))
      ];
      return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
      holdingShift = event is RawKeyDownEvent;
            }
          },
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: directorySelection.mapIndexed((i,e) => ValueListenableBuilder(
      valueListenable: directorySelection[i].$2,
      child: Text(path.basename(e.$1)),
      builder: (context, value, child) {
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: child,
          selected: value,
          visualDensity: VisualDensity.compact,
          value: value,
          onChanged: (value) => onChanged(value, i),
        );
      }
            )).toList(),
          ),
        );
    } else {
      return const Text("Something went wrong!");
    }
  }

  void _togglePreviousCheckbox(int index, bool value) {
    if (index == lastToggledCheckbox) return;
    bool upwards = lastToggledCheckbox > index;
    int start = upwards ? lastToggledCheckbox : index;
    int upperBound = upwards ? index : lastToggledCheckbox;
    for (int i = start -1; i > upperBound; i--) {
      directorySelection[i].$2.value = value;
    }
  }

  void onChanged(bool? value, int i) {
    _focusNode.requestFocus();
    directorySelection[i].$2.value = value!;
    selectedDirectories += value ? 1 : -1;
    if (holdingShift) {
      _togglePreviousCheckbox(i, value);
    }
    lastToggledCheckbox = i;
    widget.onEntitySelect([
      for (var (path, notifier) in directorySelection)
      if (notifier.value) path
    ]);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
        children: state.fileEntities.map((e) => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 2.0
          ),
          child: SelectableText(
            path.basename(e),
            style: const TextStyle(
              fontSize: 17
            ),
          ),
        )).toList(),
      );
    } else {
      return const Text("Something went wrong!");
    }
  }
}
class NameModifierUnit extends StatelessWidget {

  const NameModifierUnit({
    required this.title,
    required this.config,
    super.key
  });

  final String title;
  final PathModifierConfig config;
  
  @override
  Widget build(BuildContext context) {
    return Unit(
      title: title,
      content: NameModifierSubUnit(
        config: config,
      ),
    );
  }
}

class NameModifierSubUnit extends StatefulWidget {

  const NameModifierSubUnit({
    required this.config, 
    super.key
  });

  final PathModifierConfig config;

  @override
  State<NameModifierSubUnit> createState() => _NameModifierSubUnitState();
}

class _NameModifierSubUnitState extends State<NameModifierSubUnit> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  late int count = widget.config.options.length;

  @override
  Widget build(BuildContext context) {
    return Column(
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

class DirectoryNameAssignUnit extends StatelessWidget {
  
  const DirectoryNameAssignUnit({
    super.key,
    required this.title,
    required this.pathModifierConfig,
    required this.groupConfig,
    this.onChange,
    this.initialMode
  });

  final String title;
  final PathModifierConfig pathModifierConfig;  
  final GroupConfig groupConfig;
  final DirectoryNameAssignmentMode? initialMode;
  final void Function(DirectoryNameAssignmentMode selectedMode)? onChange;

  @override
  Widget build(BuildContext context) {
    return DynamicUnit<DirectoryNameAssignmentMode>(
      title: title, 
      onSubunitChange: onChange,
      initialSubunit: initialMode,
      subunits: {
        DirectoryNameAssignmentMode.basic: GroupSubUnit(config: groupConfig),
        DirectoryNameAssignmentMode.advanced: NameModifierSubUnit(
          config: pathModifierConfig
        )
      }
    );
  }
}

enum DirectoryNameAssignmentMode implements Translatable{
  basic,
  advanced;

  @override
  String toTranslatedString(BuildContext context) {
    return switch(this) {
      DirectoryNameAssignmentMode.basic => "Basic",
      DirectoryNameAssignmentMode.advanced => "Advanced"
    };
  }
}

class GroupSubUnit extends StatefulWidget {

  const GroupSubUnit({
    required this.config, 
    super.key
  });

  final GroupConfig config;

  @override
  State<GroupSubUnit> createState() => _GroupSubUnitState();
}

class _GroupSubUnitState extends State<GroupSubUnit> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  String? _errorText;
  late int count = widget.config.groups.length;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          validator: checkEmptiness,
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
          validator: checkEmptiness,
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
        child: (!remove && index != 0) ? IconButton(
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