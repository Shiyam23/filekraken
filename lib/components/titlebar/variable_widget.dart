import 'package:filekraken/components/module_page.dart';
import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/database.dart';
import 'package:filekraken/service/modifer_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final variableListProvider =
    StateNotifierProvider<VariableListNotifier, Map<String, Variable>>(
        (ref) => VariableListNotifier(ref)..init());

class VariableListNotifier extends StateNotifier<Map<String, Variable>> {
  VariableListNotifier(this.ref) : super(predefinedVariables);

  final StateNotifierProviderRef ref;
  static Map<String, Variable> predefinedVariables = {
    "i": IndexVariable(),
    "d": DeleteVariable(),
  };

  void init() async {
    refresh();
    ref.read(database).onListVariableChange().listen((event) => refresh());
  }

  void addVariable(ListVariableData variable) async {
    ListVariable newVariable =
        await ref.read(database).addListVariable(variable);
    state = {...state, newVariable.identifier: newVariable};
  }

  void removeVariable(ListVariable variable) async {
    await ref.read(database).deleteListVariable(variable);
    state = {
      for (MapEntry element in state.entries)
        if (element.value != variable) element.key: element.value
    };
  }

  void modify(ListVariable oldVariable, ListVariableData newData) async {
    ListVariable newVariable =
        await ref.read(database).modifyListVariable(oldVariable, newData);
    state = {
      for (MapEntry element in state.entries)
        if (element.value != oldVariable)
          element.key: element.value
        else
          newVariable.identifier: newVariable
    };
  }

  void refresh() async {
    final listVariables = await ref.read(database).getListVariables();
    state = {
      ...predefinedVariables,
      for (ListVariable lv in listVariables) lv.identifier: lv
    };
  }
}

class VariableListWidget extends ConsumerStatefulWidget {
  const VariableListWidget({super.key});

  @override
  ConsumerState<VariableListWidget> createState() => _VariableListWidgetState();
}

class _VariableListWidgetState extends ConsumerState<VariableListWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(variableListProvider.notifier).refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Variable> variableList =
        ref.watch(variableListProvider).values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Identifier")),
              DataColumn(label: Text("Description")),
              DataColumn(label: Text("")),
            ],
            rows: variableList.map((e) {
              bool isPredefined = e is IndexVariable || e is DeleteVariable;
              return DataRow(
                  onSelectChanged:
                      isPredefined ? null : (_) => modifyVariable(context, e),
                  cells: [
                    DataCell(Text(e.name), placeholder: isPredefined),
                    DataCell(Text("[${e.identifier}]"),
                        placeholder: isPredefined),
                    DataCell(Text(e.getDescription()),
                        placeholder: isPredefined),
                    DataCell(
                        isPredefined
                            ? const SizedBox.shrink()
                            : IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteVariable(e);
                                },
                              ),
                        placeholder: isPredefined),
                  ]);
            }).toList()),
        Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => addVariable(context)),
        )
      ],
    );
  }

  void modifyVariable(BuildContext context, Variable e) async {
    if (e is! ListVariable) {
      throw ArgumentError.value(e, "e", "e is not a ListVariable");
    }
    ListVariableData? result =
        await ref.read(navigatorProvider).currentState?.push(
              DialogRoute(
                  context: context,
                  builder: (context) => ListVariableEdit(
                        initialName: e.name,
                        initialIdentifier: e.identifier,
                        initialContent: e.content,
                        initialLoop: e.loop,
                      )),
            );
    if (result != null) {
      VariableListNotifier notifier = ref.read(variableListProvider.notifier);
      notifier.modify(e, result);
    }
  }

  void addVariable(BuildContext context) async {
    ListVariableData? newVariable = await ref
        .read(navigatorProvider)
        .currentState
        ?.push(DialogRoute(
            context: context, builder: (_) => const ListVariableEdit()));
    if (newVariable != null) {
      VariableListNotifier notifier = ref.read(variableListProvider.notifier);
      notifier.addVariable(newVariable);
    }
  }

  void deleteVariable(Variable selectedVariable) async {
    if (selectedVariable is! ListVariable) return;
    VariableListNotifier notifier = ref.read(variableListProvider.notifier);
    notifier.removeVariable(selectedVariable);
  }
}

class ListVariableEdit extends ConsumerStatefulWidget {
  const ListVariableEdit(
      {this.initialName,
      this.initialIdentifier,
      this.initialContent,
      this.initialLoop,
      super.key});

  final String? initialName;
  final String? initialIdentifier;
  final List<String>? initialContent;
  final bool? initialLoop;

  @override
  ConsumerState<ListVariableEdit> createState() => _ListVariableEditState();
}

class _ListVariableEditState extends ConsumerState<ListVariableEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late bool loop = widget.initialLoop ?? false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormFieldState> _identifierFieldKey = GlobalKey();
  String? errorMessage;

  @override
  void initState() {
    _nameController.text = widget.initialName ?? "";
    _idController.text = widget.initialIdentifier ?? "";
    _contentController.text = widget.initialContent?.join("\n") ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: [
              TextFormField(
                validator: checkEmpty,
                controller: _nameController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              TextFormField(
                key: _identifierFieldKey,
                validator: (value) => checkIdentifier(value),
                controller: _idController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              TextFormField(
                validator: checkEmpty,
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 5,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              StatefulBuilder(builder: (context, setState) {
                return Checkbox(
                    value: loop,
                    onChanged: (value) => setState(() => loop = value!));
              }),
              Row(
                children: [
                  TextButton(
                    child: const Text("Submit"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        return Navigator.pop<ListVariableData>(
                            context,
                            ListVariableData(
                                content:
                                    _contentController.text.trim().split("\n"),
                                identifier: _idController.text,
                                name: _nameController.text,
                                loop: loop));
                      }
                    },
                  ),
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop<ListVariable>(context, null),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _idController.dispose();
    super.dispose();
  }

  String? checkEmpty(String? value) {
    if (value == null || value == "") {
      return "Can not be empty";
    }
    return null;
  }

  String? checkIdentifier(String? value) {
    if (value == null || value == "") {
      return "Can not be empty";
    }
    String? syntaxError = checkIdentifierSyntax(value);
    if (syntaxError != null) {
      return syntaxError;
    }
    bool identifierExists = ref.read(variableListProvider).containsKey(value);
    bool identifierChanged = value != widget.initialIdentifier;
    return identifierExists && identifierChanged
        ? "Identifier already exists"
        : null;
  }
}
