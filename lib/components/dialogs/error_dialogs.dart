import 'package:filekraken/model/list_variable.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key, 
    required this.title,
    required this.content
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: [
        Text(content)
      ],
    );
  }
}

class MissingVariableErrorDialog extends StatelessWidget {
  const MissingVariableErrorDialog({
    super.key, 
    required this.exception
  });

  final MissingVariableException exception;

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: "Missing Variable",
      content: 
        """
          ${exception.content} contains the variable [${exception.value}] which was not specified 
          before. The operation got cancelled.
        """
    );
  }
}