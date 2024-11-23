import 'package:filekraken/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Page { extract, insert, create, rename, variables, history }

final activePageProvider = StateProvider<Page>((ref) => Page.extract);
const logoFilePath = "img/logsdsdo.jpg";

class FKNavigationRail extends StatelessWidget {
  const FKNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage("images/logo.png"),
          ),
          NavigationMenuItem(
              onPressed: () => {},
              leadingIcon: const Icon(Icons.drive_folder_upload_rounded),
              title: "Extract Files",
              page: Page.extract),
          NavigationMenuItem(
              title: "Insert Files",
              leadingIcon: const Icon(Icons.drive_file_move_rounded),
              onPressed: () => {},
              page: Page.insert),
          NavigationMenuItem(
              title: "Create Files",
              leadingIcon: const Icon(Icons.file_copy),
              onPressed: () => {},
              page: Page.create),
          NavigationMenuItem(
              onPressed: () => {},
              leadingIcon: const Icon(Icons.edit_document),
              title: "Rename Files",
              page: Page.rename),
          const Divider(),
          NavigationMenuItem(
              onPressed: () => {},
              leadingIcon: const Icon(Icons.abc),
              title: "Variables",
              page: Page.variables),
          NavigationMenuItem(
              onPressed: () => {},
              leadingIcon: const Icon(Icons.history),
              title: "History",
              page: Page.history),
        ],
      ),
    );
  }
}

class NavigationMenuItem extends ConsumerStatefulWidget {
  const NavigationMenuItem(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.leadingIcon,
      required this.page});

  final void Function() onPressed;
  final String title;
  final Icon leadingIcon;
  final Page page;

  @override
  ConsumerState<NavigationMenuItem> createState() => _NavigationMenuItemState();
}

class _NavigationMenuItemState extends ConsumerState<NavigationMenuItem> {
  @override
  Widget build(BuildContext context) {
    FKTheme theme = InheritedFKTheme.of(context)!.theme;
    var active = ref.watch(activePageProvider) == widget.page;
    return SizedBox(
      width: 225,
      child: MenuItemButton(
          onPressed: () {
            widget.onPressed.call();
            ref.read(activePageProvider.notifier).state = widget.page;
          },
          style: MenuItemButton.styleFrom(
              iconColor: active ? theme.selectedNavItemIconColor : theme.unselectedNavItemIconColor,
              padding: const EdgeInsets.all(20),
              overlayColor: active ? null : theme.selectedNavItemColor,
              backgroundColor: active ? theme.selectedNavItemColor : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          leadingIcon: widget.leadingIcon,
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              widget.title,
              style: TextStyle(
                color: active ? theme.selectedNavItemTextColor : theme.unselectedNavItemTextColor,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500 
              ),
            ),
          )),
    );
  }
}

class NavigationItem extends StatelessWidget {
  const NavigationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
