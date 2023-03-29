import 'package:filekraken/components/navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:filekraken/components/titlebar.dart';

import 'components/module_page.dart';

class Layout extends StatelessWidget {
  
  Layout({super.key});

  final ValueNotifier<int> _pageIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleBar(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FKNavigationRail(pageIndex: _pageIndex),
            ModulePage(pageIndex: _pageIndex)
          ],
        ),
      ],
    );
  }
}