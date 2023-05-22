import 'package:filekraken/theme/fk_dark_theme.dart';
import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1080, 720);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final FKTheme initialTheme = const FKDarkTheme();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: FKThemeWidget(
        initialTheme: initialTheme,
        child: Builder(
          builder: (context) {
            return MaterialApp(
              title: 'FileKraken',
              theme: initialTheme.themeData,
              restorationScopeId: "filekraken",
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Layout()
              )
            );
          }
        ),
      ),
    );
  }
}
