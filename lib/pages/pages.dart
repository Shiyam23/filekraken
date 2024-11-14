import "package:filekraken/components/titlebar/history_widget.dart";
import "package:filekraken/components/titlebar/variable_widget.dart";
import "package:filekraken/pages/create_page.dart";
import "package:filekraken/pages/extract_page.dart";
import "package:filekraken/pages/insert_page.dart";
import "package:filekraken/pages/rename_page.dart";
import "package:flutter/material.dart";
import "package:riverpod/riverpod.dart";

enum MainPage {
  extract,
  insert,
  create,
  rename,
  variables,
  history
}

Map<String, Widget> pages = {
  MainPage.extract.toString() : const ExtractPage(),
  MainPage.insert.toString(): const InsertPage(),
  MainPage.create.toString(): const CreatePage(),
  MainPage.rename.toString(): const RenamePage(),
  MainPage.variables.toString(): const VariableListWidget(),
  MainPage.history.toString(): const HistoryWidget()
};

Provider<Map<String, Widget>> pageProvider = Provider((ref) => pages);
