import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';

class FKLightTheme implements FKTheme {
  
  const FKLightTheme();

  @override
  ThemeData get themeData => ThemeData();

  // Titlebar Settings
  @override
  WindowButtonColors get closeButtonColors => WindowButtonColors(
    iconMouseOver: Colors.white,
    iconMouseDown: Colors.white,
    iconNormal: Colors.white,
    normal: const Color(0xFF18212B),
    mouseOver: const Color.fromARGB(255, 77, 42, 42),
    mouseDown: const Color.fromARGB(255, 105, 57, 57),
  );

  @override
  WindowButtonColors get windowButtonColors => WindowButtonColors(
    iconMouseOver: Colors.white,
    iconMouseDown: Colors.white,
    iconNormal: Colors.white,
    normal: const Color(0xFF18212B),
    mouseOver: const Color.fromARGB(255, 42, 58, 77),
    mouseDown: const Color.fromARGB(255, 57, 79, 105),
  );

  @override
  Color get selectedNavItemColor => const Color(0xFF67DADF);

  @override
  Color get navItemTextColor => const Color(0xFF1B1D21);
}
