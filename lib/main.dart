import 'package:filekraken/service/database/database.dart';
import 'package:filekraken/theme/fk_dark_theme.dart';
import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ProviderContainer container = ProviderContainer();
  await initializeDateFormatting('de_DE', null);
  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
  container.read(database).init();

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
              home: const Scaffold(
                body: Layout()
              )
            );
          }
        ),
      ),
    );
  }
}
