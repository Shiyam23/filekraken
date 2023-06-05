import 'package:filekraken/components/navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:filekraken/components/titlebar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/module_page.dart';

Provider<double> titlebarHeightProvider = Provider((_) => 50);

class Layout extends ConsumerWidget {
  
  const Layout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titlebarHeight = ref.watch(titlebarHeightProvider);
    return Column(
      children: [
        TitleBar(height: titlebarHeight),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FKNavigationRail(),
            ModulePage()
          ],
        ),
      ],
    );
  } 
}