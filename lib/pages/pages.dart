import "package:filekraken/model/file_result.dart";
import "package:filekraken/pages/create_page.dart";
import "package:filekraken/pages/extract_page.dart";
import "package:filekraken/pages/insert_page.dart";
import "package:filekraken/pages/rename_page.dart";
import "package:flutter/material.dart";
import "package:riverpod/riverpod.dart";

Map<String, Widget> pages = {
  OperationType.extract.toString(): const ExtractPage(),
  OperationType.insert.toString(): const InsertPage(),
  OperationType.create.toString(): const CreatePage(),
  OperationType.rename.toString(): const RenamePage(),
};

Provider<Map<String, Widget>> pageProvider = Provider((ref) => pages);