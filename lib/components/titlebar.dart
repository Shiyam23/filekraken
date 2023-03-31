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
          color: const Color(0xFF18212B),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MoveWindow(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "App", 
                      style: TextStyle(
                        color: Colors.white,
                      )
                    ),
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