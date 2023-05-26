import 'package:filekraken/model/list_variable.dart';
import 'package:filekraken/service/modifer_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StateNotifierProvider<VariableListNotifier,Map<String,Variable>> variableListProvider = StateNotifierProvider(
  (ref) => VariableListNotifier()
);

class VariableListNotifier extends StateNotifier<Map<String, Variable>> {
  VariableListNotifier() : super({
    "i": IndexVariable(),
    "d": DeleteVariable(),
  });

  void addVariable(ListVariable variable) {
    state = {...state, variable.identifier: variable};
  }

  void removeVariable(ListVariable variable) {
    state = {
      for (MapEntry element in state.entries) 
      if (element.value != variable) element.key:element.value
    };
  }

  void modify(ListVariable oldVariable, ListVariable newVariable) {
    state = {
      for (MapEntry element in state.entries) 
        if (element.value != oldVariable) element.key : element.value
        else newVariable.identifier : newVariable
    };
  }
}

class VariableButton extends StatelessWidget {
  const VariableButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: OutlinedButton(
        style: ButtonStyle(
          fixedSize: const MaterialStatePropertyAll(Size(100, 40)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          )),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          backgroundColor: const MaterialStatePropertyAll(Colors.blueGrey)
        ),
        child: const Text("Variables"),
        onPressed: () => showDialog(
          context: context, 
          useSafeArea: false,
          builder: (context) => const VariableListWidget()
        )
      ),
    );
  }
}

class VariableListWidget extends ConsumerStatefulWidget {
  const VariableListWidget({super.key});

  @override
  ConsumerState<VariableListWidget> createState() => _VariableListWidgetState();
}

class _VariableListWidgetState extends ConsumerState<VariableListWidget> {

  @override
  Widget build(BuildContext context) {
    List<Variable> variableList = ref.watch(variableListProvider).values.toList();
    return Dialog(
      alignment: Alignment.center,
      child: SizedBox(
        width: 800,
        height: 600,
        child: Stack(
          children: [
            SizedBox.expand(
              child: DataTable(
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Identifier")),
                  DataColumn(label: Text("Description")),
                ], 
                rows: variableList.map((e) => DataRow(
                  onSelectChanged: (_) => modifyVariable(context, e),
                  cells: [
                    DataCell(
                      Text(e.name), 
                      placeholder: e is IndexVariable || e is DeleteVariable
                    ),
                    DataCell(
                      Text("[${e.identifier}]"),
                      placeholder: e is IndexVariable || e is DeleteVariable
                    ),
                    DataCell(
                      Text(e.getDescription()),
                      placeholder: e is IndexVariable || e is DeleteVariable
                    ),
                  ]
                )).toList()
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => addVariable(context)
              ),
            )
          ],
        ),
      ),
    );
  }

  void modifyVariable(BuildContext context, Variable e) async {
    if (e is! ListVariable) return;
    ListVariable? result = await showDialog<ListVariable>(
      context: context, 
      builder: (context) => ListVariableEdit(
        initialName: e.name,
        initialIdentifier: e.identifier,
        initialContent: e.content,
        initialLoop: e.loop,
      )
    );
    if (result != null) {
      VariableListNotifier notifier = ref.read(variableListProvider.notifier);
      notifier.modify(e, result);
    }
  }

  void addVariable(BuildContext context) async {
    ListVariable? newVariable = await showDialog<ListVariable>(
      context: context, 
      builder: (_) => const ListVariableEdit()
    );
    if (newVariable != null) {
      VariableListNotifier notifier = ref.read(variableListProvider.notifier);
      notifier.addVariable(newVariable);
    }
  }
}

class ListVariableEdit extends StatefulWidget {
  const ListVariableEdit({
    this.initialName, 
    this.initialIdentifier, 
    this.initialContent, 
    this.initialLoop,
    super.key
  });

  final String? initialName;
  final String? initialIdentifier;
  final List<String>? initialContent;
  final bool? initialLoop;

  @override
  State<ListVariableEdit> createState() => _ListVariableEditState();
}

class _ListVariableEditState extends State<ListVariableEdit> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late bool loop = widget.initialLoop ?? false;

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
        child: Column(
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value == "") {
                  return "Can not be empty";
                }
                return null;
              },
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder()
              ),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value == "") {
                  return "Can not be empty";
                }
                return checkIdentifierSyntax(value);
              },
              controller: _idController,
              decoration: const InputDecoration(
                border: OutlineInputBorder()
              ),
            ),
            TextFormField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder()
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Checkbox(
                  value: loop,
                  onChanged: (value) => setState(() => loop = value!)
                );
              }
            ),
            Row(
              children: [
                TextButton(
                  child: const Text("Submit"),
                  onPressed: () => Navigator.pop<ListVariable>(
                    context,
                    ListVariable(
                      content: _contentController.text.trim().split("\n"),
                      identifier: _idController.text,
                      name: _nameController.text,
                      loop: loop
                    )
                  ),
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop<ListVariable>(context,null),
                ),
              ],
            )
          ],
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
}