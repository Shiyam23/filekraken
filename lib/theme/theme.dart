import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
export 'package:flutter/src/material/theme_data.dart';
export 'package:bitsdojo_window/bitsdojo_window.dart';

abstract class FKTheme{
  
  ThemeData get themeData;

  // Titlebar Settings
  WindowButtonColors get windowButtonColors;
  WindowButtonColors get closeButtonColors;

  // Navigation rail
  Color get selectedNavItemColor;
  Color get selectedNavItemTextColor;
  Color get unselectedNavItemTextColor;
  Color get selectedNavItemIconColor;
  Color get unselectedNavItemIconColor;
}

class InheritedFKTheme extends InheritedWidget {

  const InheritedFKTheme({
    super.key, 
    required Widget child,
    required this.theme
  }) : super(child: child);

  final FKTheme theme;

  static InheritedFKTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedFKTheme>();
  }

  @override
  bool updateShouldNotify(InheritedFKTheme oldWidget) {
    return oldWidget.theme != theme;
  }
}
