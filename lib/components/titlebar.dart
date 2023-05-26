import 'dart:io';
import 'package:filekraken/components/titlebar/variable_widget.dart';
import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  
  const TitleBar({super.key, required this.height});

  final double height;
  @override
  Widget build(BuildContext context) {

    FKTheme theme = FKThemeWidget.of(context)!.theme;

    return SizedBox(
      height: height,
      child: WindowTitleBarBox(
        child: Container(
          padding: Platform.isMacOS ? const EdgeInsets.only(left: 70) : EdgeInsets.zero,
          color: const Color(0xFF18212B),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VariableButton(),
              Expanded(
                child: MoveWindow(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    alignment: Platform.isMacOS ? Alignment.center : Alignment.centerLeft,
                  ),
                )
              ),
              MinimizeWindowButton(colors: theme.windowButtonColors),
              appWindow.isMaximized ? 
                RestoreWindowButton(colors: theme.windowButtonColors) : 
                MaximizeWindowButton(colors: theme.windowButtonColors),
              CloseWindowButton(colors: theme.closeButtonColors,)
            ]
          ),
        ),
      ),
    );
  }
}