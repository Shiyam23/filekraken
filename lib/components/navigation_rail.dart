import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';

class FKNavigationRail extends StatefulWidget {
  const FKNavigationRail({super.key, required this.pageIndex});

  final ValueNotifier pageIndex;

  @override
  State<FKNavigationRail> createState() => _FKNavigationRailState();
}

class _FKNavigationRailState extends State<FKNavigationRail> {

  bool extended = false;

  @override
  Widget build(BuildContext context) {

    FKTheme theme = FKThemeWidget.of(context)!.theme;

    return SizedBox(
      height: MediaQuery.of(context).size.height - 50,
      child: NavigationRail(
        backgroundColor: theme.navBarBackgroundColor,
        extended: extended,
        selectedLabelTextStyle: theme.navBarSelectedTextStyle,
        selectedIconTheme: theme.navBarSelectedIconStyle,
        unselectedLabelTextStyle: theme.navBarUnselectedTextStyle,
        unselectedIconTheme: theme.navBarUnselectedIconStyle,
        selectedIndex: widget.pageIndex.value,
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
            label: Text("Inject")
          ),
          NavigationRailDestination(
            icon: Icon(Icons.edit_document),
            label: Text("Rename"),
          ),
        ],
        onDestinationSelected: (value) => setState(() {
          widget.pageIndex.value = value;
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