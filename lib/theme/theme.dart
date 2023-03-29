import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
export 'package:flutter/src/material/theme_data.dart';
export 'package:bitsdojo_window/bitsdojo_window.dart';


abstract class FKTheme{
  
  ThemeData get themeData;

  // Titlebar Settings
  WindowButtonColors get windowButtonColors;
  WindowButtonColors get closeButtonColors;

  // Navigation Bar Settings
  Color get navBarBackgroundColor;
  TextStyle get navBarSelectedTextStyle;
  IconThemeData get navBarSelectedIconStyle;
  TextStyle get navBarUnselectedTextStyle;
  IconThemeData get navBarUnselectedIconStyle;
}

class FKThemeWidget extends InheritedWidget {

  FKThemeWidget({
    super.key, 
    required Widget child,
    required this.initialTheme
  }) : super(child: child);

  final FKTheme initialTheme;
  late final FKThemeContainer _themeContainer = FKThemeContainer(theme: initialTheme);
  FKTheme get theme => _themeContainer.theme;

  static FKThemeWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FKThemeWidget>();
  }

  @override
  bool updateShouldNotify(FKThemeWidget oldWidget) {
    return _themeContainer.theme != oldWidget._themeContainer.theme;
  }
}

class FKThemeContainer {

  FKTheme theme;
  FKThemeContainer({required this.theme});
}