import 'dart:io';
import 'package:filekraken/components/module_page.dart';
import 'package:filekraken/components/navigation_rail.dart';
import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    FKTheme theme = FKThemeWidget.of(context)!.theme;
    return SizedBox(
      child: WindowTitleBarBox(
        child: ColoredBox(
          color: Colors.white,
          child: Stack(
            children: [
              MoveWindow(
                child: Container(
                  color: const Color(0xFF221644),
                  padding: const EdgeInsets.only(left: 15.0),
                  alignment: Platform.isMacOS
                      ? Alignment.center
                      : Alignment.centerLeft,
                ),
              ),
              Padding(
                padding: Platform.isMacOS
                    ? const EdgeInsets.only(left: 70)
                    : EdgeInsets.zero,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MinimizeWindowButton(colors: theme.windowButtonColors),
                      appWindow.isMaximized
                          ? RestoreWindowButton(
                              colors: theme.windowButtonColors)
                          : MaximizeWindowButton(
                              colors: theme.windowButtonColors),
                      CloseWindowButton(
                        colors: theme.closeButtonColors,
                      )
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleBarMenuButton extends ConsumerWidget {
  const TitleBarMenuButton(
      {super.key, required this.title, required this.route});

  final Widget title;
  final Widget route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: OutlinedButton(
          style: ButtonStyle(
              fixedSize: const WidgetStatePropertyAll(Size(120, 40)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
              backgroundColor: const WidgetStatePropertyAll(Colors.blueGrey)),
          child: title,
          onPressed: () {
            final GlobalKey<NavigatorState> navigatorKey =
                ref.read(navigatorProvider);
            navigatorKey.currentState?.pushReplacement(PageRouteBuilder(
                reverseTransitionDuration: Duration.zero,
                transitionDuration: Duration.zero,
                pageBuilder: (context, a, aa) => route));
          }),
    );
  }
}
