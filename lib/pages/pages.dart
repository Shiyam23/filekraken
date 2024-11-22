import "package:filekraken/components/navigation_rail.dart" as nav;
import "package:filekraken/components/titlebar/history_widget.dart";
import "package:filekraken/components/titlebar/variable_widget.dart";
import "package:filekraken/pages/create_page.dart";
import "package:filekraken/pages/extract_page.dart";
import "package:filekraken/pages/insert_page.dart";
import "package:filekraken/pages/rename_page.dart";
import "package:flutter/material.dart";
import "package:riverpod/riverpod.dart";

Provider<Widget> pageProvider = Provider((ref) {
  var activePage = ref.watch(nav.activePageProvider);
  switch (activePage) {
    case nav.Page.extract:
      return const ExtractPage();
    case nav.Page.insert:
      return const InsertPage();
    case nav.Page.create:
      return const CreatePage();
    case nav.Page.rename:
      return const RenamePage();
    case nav.Page.variables:
      return const VariableListWidget();
    case nav.Page.history:
      return const HistoryWidget();
    }
});
