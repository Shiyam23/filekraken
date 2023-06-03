import 'dart:async';
import 'package:filekraken/components/dialogs/error_dialogs.dart';
import 'package:filekraken/model/file_result.dart';
import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';

class ResultDialog extends StatefulWidget {
  const ResultDialog(
      {super.key,
      required this.resultStream,
      required this.operationType,
      required this.rootPath,
      required this.maxNumber,
      this.onResultLoaded});

  final OperationType operationType;
  final String rootPath;
  final int maxNumber;
  final Stream<FileOperationResult> resultStream;
  final void Function()? onResultLoaded;

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<FileOperationResult> results = [];
  final ValueNotifier<bool> dismissible = ValueNotifier(false);
  final ValueNotifier<int> progress = ValueNotifier(0);
  late final StreamSubscription<FileOperationResult> sub;

  @override
  void initState() {
    sub = widget.resultStream.listen(
      (event) {
        results.add(event);
        if (event.resultType != ResultType.fail) {
          progress.value++;
        }
        _listKey.currentState?.insertItem(results.length - 1);
      },
      onDone: () {
        widget.onResultLoaded?.call();
        dismissible.value = true;
      },
      onError: (e) => showErrorDialog(e, context),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Dialog(
        insetPadding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: MoveWindow(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                color: Colors.red[700],
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Text(
                      widget.operationType.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: progress,
                        builder: (_, progress, __) =>
                          Text("Success: $progress/${widget.maxNumber}")
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: results.length,
              itemBuilder: (context, index, animation) {
                String rootPath = results[index].rootPath;
                String source =
                    results[index].fileSource.replaceFirst(rootPath, "");
                String target =
                    results[index].fileTarget.replaceFirst(rootPath, "→ .");
                ErrorType? error = results[index].error;
                return ExpansionTile(
                  expandedAlignment: Alignment.topLeft,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          ".$source",
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                      const SizedBox(width: 20),
                      getTextByResultType(results[index].resultType),
                    ],
                  ),
                  subtitle: Text(target),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Root Path: $rootPath"),
                    Text("Mode: ${results[index].operationType.toString()}"),
                    if (error != null) getTextByErrorType(error)
                  ],
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: dismissible,
            child: const Text("OK"),
            builder: (context, dismissible, child) => TextButton(
              onPressed: dismissible ? () { 
                sub.cancel();
                Navigator.pop(context);
              } : null,
              child: child!
            )
          ),
        ],
    ),
      ),
    );
  }

  Text getTextByResultType(ResultType resultType) {
    switch (resultType) {
      case ResultType.success:
        return const Text("Success",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.green,
            ));
      case ResultType.fail:
        return Text("Fail",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.red[800],
            ));
      case ResultType.dryRun:
        return Text("Dry Run",
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.green[800],
            ));
    }
  }

  Text getTextByErrorType(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.invalidRootPath:
        return const Text("Invalid Root Path");
      case ErrorType.invalidSource:
        return const Text("Invalid Source");
      case ErrorType.invalidTarget:
        return const Text("Invalid Target");
      case ErrorType.fileNotFound:
        return const Text("File was not found");
      case ErrorType.pathNotFound:
        return const Text("Path was not found");
      case ErrorType.fileAlreadyExists:
        return const Text("File already exists");
      case ErrorType.pathAlreadyExists:
        return const Text("Path already exists");
      case ErrorType.other:
        return const Text("Other error");
      case ErrorType.noPermission:
        return const Text("No Permission");
    }
  }
}
