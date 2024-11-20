import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';

class FKLightTheme implements FKTheme {
  
  const FKLightTheme();

  @override
  ThemeData get themeData => ThemeData();
  

  // Navigation Bar Settings
  @override
  Color get navBarBackgroundColor => const Color(0xFF18212B);

  // Selected Item Settings
  @override
  TextStyle get navBarSelectedTextStyle => const TextStyle(
    inherit: true,
    color: Colors.blue,
    fontWeight: FontWeight.w500
  );

  @override
  IconThemeData get navBarSelectedIconStyle => const IconThemeData(
    color: Colors.blue,
  );

  // Unselected Item Settings
 @override
  TextStyle get navBarUnselectedTextStyle => const TextStyle(
    inherit: true,
    color: Colors.white,
    fontWeight: FontWeight.w500
  );

  @override
  IconThemeData get navBarUnselectedIconStyle => const IconThemeData(
    color: Colors.white,
  );

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
}
