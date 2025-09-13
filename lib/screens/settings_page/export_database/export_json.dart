import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../init.dart';

ListTile exportToJson(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.upload_file_outlined),
    title: const Text('Export To JSON'),
    onTap: () async => await _export(context),
  );
}

Future<void> _export(BuildContext context) async {
  debugPrint("Settings: exporting to json");
  final String? exportDirectory = await FilePicker.platform.getDirectoryPath();
  List<Map<String, dynamic>> history = List.empty(growable: true);

  roomsDatabase?.toMap().forEach((k, v) {
    // history.add(v.toJson());
  });

  File jsonFile =
      File('${exportDirectory!}/${Constants().roomsDatabaseFileName}.json');

  jsonFile.writeAsStringSync(history.toString());
  debugPrint("Settings: exported to ${jsonFile.path}");
}
