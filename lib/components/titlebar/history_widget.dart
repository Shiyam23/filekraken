import 'dart:io';
import 'package:filekraken/model/file_result.dart';
import 'package:filekraken/service/database.dart';
import 'package:filekraken/service/isar_dao/op_impl/file_op.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier,List<ModuleOperationResult>>(
  (ref) => HistoryNotifier(ref)
);

class HistoryNotifier extends StateNotifier<List<ModuleOperationResult>> {

  HistoryNotifier(this.ref) : super([]);

  final StateNotifierProviderRef ref;
  
  void removeVariable(ModuleOperationResult entry) async {
    await ref.read(database).deleteModuleOperationResult(entry);
    state = [
      for (ModuleOperationResult element in state) if (element != entry) element
    ];
  }

  void refresh() async{
    final entries = await ref.read(database).getModuleOperationResults();
    state = entries;
  }
}

class HistoryWidget extends ConsumerStatefulWidget {
  const HistoryWidget({super.key});

  @override
  ConsumerState<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends ConsumerState<HistoryWidget> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ModuleOperationResult> entries = ref.watch(historyProvider);
    return ListView(
      children: entries
      .map((m) {
      int success = m.fileResults
      .where((f) => f.resultType == ResultType.success)
      .toList()
      .length;
      return ExpansionTile(
        title: Row(
          children: [
            Text(m.operationType.toString()),
            const SizedBox(width: 20),
            Text(DateFormat.yMd(Platform.localeName).format(m.dateTime)),
            const SizedBox(width: 20),
            Text("Success: $success / ${m.fileResults.length}"),
            const Spacer(),
            TextButton(
              onPressed: () => _onModuleRevertPressed(m), 
              child: const Text("Revert"),
            )
          ],
        ),
        children: m.fileResults
        .map((f) => ListTile(
          title: Text(f.fileSource.replaceFirst(f.rootPath, "")),
          subtitle: Text(f.fileTarget.replaceFirst(f.rootPath, "")),
          trailing: Text(f.resultType.toString()),
        ))
        .toList(),
        );
      }).toList(),
    );
  }

  void _onModuleRevertPressed(ModuleOperationResult m) {
    ref.read(operationProvider)[m.operationType]!.revert(m);
  }
}