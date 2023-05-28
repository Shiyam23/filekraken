import 'package:filekraken/components/navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:filekraken/components/titlebar.dart';
import 'components/module_page.dart';

class Layout extends StatelessWidget {
  
  Layout({super.key});

  final double titlebarHeight = 50;
  final ValueNotifier<int> _pageIndex = ValueNotifier(2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(height: titlebarHeight),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FKNavigationRail(pageIndex: _pageIndex),
            ModulePage(
              pageIndex: _pageIndex,
              titleBarHeight: titlebarHeight,
            )
          ],
        ),
      ],
    );
  } 
}