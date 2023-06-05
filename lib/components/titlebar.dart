import 'dart:io';
import 'package:filekraken/components/module_page.dart';
import 'package:filekraken/components/navigation_rail.dart';
import 'package:filekraken/components/titlebar/history_widget.dart';
import 'package:filekraken/components/titlebar/variable_widget.dart';
import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleBar extends StatelessWidget {
  
  const TitleBar({super.key, required this.height});

  final double height;
  @override
  Widget build(BuildContext context) {

    FKTheme theme = FKThemeWidget.of(context)!.theme;

    return SizedBox(
      height: height,
      child: WindowTitleBarBox(
        child: ColoredBox(
          color: const Color(0xFF18212B),
          child: Stack(
            children: [
              Expanded(
                child: MoveWindow(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    alignment: Platform.isMacOS ? Alignment.center : Alignment.centerLeft,
                  ),
                )
              ),
              Padding(
                padding: Platform.isMacOS ? const EdgeInsets.only(left: 70) : EdgeInsets.zero,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitleBarMenuButton(
                      route: VariableListWidget(),
                      title: Text("Variables"),
                    ),
                    const TitleBarMenuButton(
                      route: HistoryWidget(),
                      title: Text("History"),
                    ),
                    MinimizeWindowButton(colors: theme.windowButtonColors),
                    appWindow.isMaximized ? 
                      RestoreWindowButton(colors: theme.windowButtonColors) : 
                      MaximizeWindowButton(colors: theme.windowButtonColors),
                    CloseWindowButton(colors: theme.closeButtonColors,)
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleBarMenuButton extends ConsumerWidget {
  const TitleBarMenuButton({
    super.key,
    required this.title,
    required this.route
  });

  final Widget title;
  final Widget route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: title,
        onPressed: () {
          final GlobalKey<NavigatorState> navigatorKey = ref.read(navigatorProvider);
          navigatorKey.currentState?.pushReplacement(
            PageRouteBuilder(
              reverseTransitionDuration: Duration.zero,
              transitionDuration: Duration.zero,
              pageBuilder: (context, a, aa) => route
            )
          );
          ref.read(navigationRailSelectedIndexProvider.notifier).state = null;
        }
      ),
    );
  }
}