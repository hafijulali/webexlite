import 'dart:convert';
import 'dart:io';


import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';


import 'package:path_provider/path_provider.dart';
import 'package:webexlite/core/constants/constants.dart';
import 'package:webexlite/init.dart';


ListTile importDatabase(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.file_download_outlined),
    title: const Text('Import Database'),
    onTap: () => _import(context),
  );
}

Future<dynamic> _import(BuildContext context) async {
        logger?.debug("Settings: importing database");  try {
    if (!kIsWeb) {
      if (Platform.isAndroid) {

      }
      String? importFilePath;
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null) {
        importFilePath =
            '${(await getApplicationDocumentsDirectory()).path}/${Constants().appName}Export.zip';
      if (result != null) {
        logger?.debug("Settings: selected files: ${result.files}");
        final importFilePath = result.files.single.path;
        if (importFilePath != null) {
          logger?.debug("Settings: importing from: $importFilePath");
          try {
            final file = File(importFilePath);
            final jsonString = await file.readAsString();
            final jsonMap = json.decode(jsonString);

            for (var entry in jsonMap.entries) {
              final boxName = entry.key;
              final boxData = entry.value;
              final box = await Hive.openBox(boxName);
              await box.putAll(boxData);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database imported successfully')),
            );
          } catch (e) {
            logger?.error("Settings: database import failed, error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Database import failed: $e')),
            );
          }
        }
      }
      } else {
        importFilePath = result.files.single.path;
        logger?.debug("Settings: importing from: $importFilePath");
      }

      final Uint8List databaseBundleZip =
          File(importFilePath!).readAsBytesSync();
      final Archive databaseBundle =
          ZipDecoder().decodeBytes(databaseBundleZip);
      for (final file in databaseBundle) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File('${databaseDirectory?.path}/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('out/$filename').create(recursive: true);
        }
      }
      if (!context.mounted) return null;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Database Imported Successully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import feature is not available on web yet')),
      );
    }
  } on Exception catch (e) {
    if (!context.mounted) return null;
          logger?.error("Settings: database import failed, error: $e");
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Database Import Failed !!!'),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
  }
}