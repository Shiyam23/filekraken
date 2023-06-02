import 'package:filekraken/service/file_op.dart';
import 'package:flutter/material.dart';

class ResultDialog extends StatefulWidget {
  const ResultDialog({
    super.key,
    required this.resultStream,
    this.onResultLoaded
  });

  final Stream<FileOperationResult> resultStream;
  final void Function()? onResultLoaded;

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<FileOperationResult> results = [];
  final ValueNotifier<bool> dismissible = ValueNotifier(false);

  @override
  void initState() {
    var sub = widget.resultStream.listen(
      (event) {
        results.add(event);
        _listKey.currentState?.insertItem(results.length - 1);
      },
    );
    sub.onDone(() {
      widget.onResultLoaded?.call();
      dismissible.value = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(40),

      child: SizedBox.expand(
        child: Column(
          children: [
            AnimatedList(
              shrinkWrap: true,
              key: _listKey,
              initialItemCount: results.length,
              itemBuilder: (context, index, animation) {
                String rootPath = results[index].rootPath;
                String source = results[index].fileSource.replaceFirst(rootPath, "");
                String target = results[index].fileTarget.replaceFirst(rootPath, "");
                ErrorType? error = results[index].error;
                return ExpansionTile(
                  expandedAlignment: Alignment.topLeft,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(".$source"),
                      const Spacer(),
                      getTextByResultType(results[index].resultType),
                    ],
                  ),
                  subtitle: Text("→ .$target"),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Root Path: $rootPath"),
                    Text("Mode: ${results[index].operationType.toString()}"),
                    if (error != null) getTextByErrorType(error)
                  ],
                );
              },
            ),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: dismissible,
              child: const Text("OK"),
              builder: (context, dismissible, child) => TextButton(
                onPressed: dismissible ? () => Navigator.pop(context) : null, 
                child: child!
              )
            )
          ],
        ),
      )
    );
  }

  Text getTextByResultType(ResultType resultType) {
    switch (resultType) {
      case ResultType.success:
        return const Text(
          "Success",
          style: TextStyle(
            color: Colors.white,
            backgroundColor: Colors.green,
          )
        );
      case ResultType.fail:
        return const Text(
          "Fail", 
          style: TextStyle(
            color: Colors.white,
            backgroundColor: Colors.red,
          )
        );
      case ResultType.dryRun:
        return const Text(
          "Dry Run", 
          style: TextStyle(
            color: Colors.white,
            backgroundColor: Colors.yellow,
          )
        );
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