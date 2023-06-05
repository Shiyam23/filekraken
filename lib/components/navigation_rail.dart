import 'package:filekraken/components/module_page.dart';
import 'package:filekraken/layout.dart';
import 'package:filekraken/pages/pages.dart';
import 'package:filekraken/service/file_op.dart';
import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StateProvider<int?> navigationRailSelectedIndexProvider = StateProvider(
  (ref) => 0
);

class FKNavigationRail extends ConsumerStatefulWidget {
  
  const FKNavigationRail({super.key});

  @override
  ConsumerState<FKNavigationRail> createState() => _FKNavigationRailState();
}

class _FKNavigationRailState extends ConsumerState<FKNavigationRail> {

  bool extended = false;

  @override
  Widget build(BuildContext context) {
    FKTheme theme = FKThemeWidget.of(context)!.theme;
    final titlebarHeight = ref.watch(titlebarHeightProvider);
    return SizedBox(
      height: MediaQuery.of(context).size.height - titlebarHeight,
      child: NavigationRail(
        backgroundColor: theme.navBarBackgroundColor,
        extended: extended,
        selectedLabelTextStyle: theme.navBarSelectedTextStyle,
        selectedIconTheme: theme.navBarSelectedIconStyle,
        unselectedLabelTextStyle: theme.navBarUnselectedTextStyle,
        unselectedIconTheme: theme.navBarUnselectedIconStyle,
        selectedIndex: ref.watch(navigationRailSelectedIndexProvider),
        minWidth: 60,
        minExtendedWidth: 200,
        destinations: const [
          NavigationRailDestination(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.drive_folder_upload_rounded),
            label: Text("Extract"),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.drive_file_move_rounded),
            label: Text("Insert")
          ),
          NavigationRailDestination(
            icon: Icon(Icons.file_copy),
            label: Text("Create")
          ),
          NavigationRailDestination(
            icon: Icon(Icons.edit_document),
            label: Text("Rename"),
          ),
        ],
        onDestinationSelected: (value) => setState(() {
          final selectedIndexNotifier = ref.read(navigationRailSelectedIndexProvider.notifier);
          if (value != selectedIndexNotifier.state) {
            ref.read(navigatorProvider).currentState?.pushReplacementNamed(
              ref.read(pageProvider).keys.toList()[value]     
            );
            ref.read(fileListStateProvider.notifier).reset();
            ref.read(directoryListStateProvider.notifier).reset();
            selectedIndexNotifier.state = value;
          }
        }),
        trailing: Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: 
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: IconTheme(
                  data: theme.navBarUnselectedIconStyle,
                  child: IconButton(
                    icon: Icon(extended ? Icons.arrow_back : Icons.arrow_forward),
                    onPressed: () {
                      setState(() => extended = !extended);
                    },
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}