import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:packer/utils/permissions_utils.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/constants.dart';
import '../../../custom/widgets/alert_dialog.dart';
import '../../../init.dart';

ListTile importDatabase(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.file_download_outlined),
    title: const Text('Import Database'),
    onTap: () => _import(context),
  );
}

Future<dynamic> _import(BuildContext context) async {
  try {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        checkAndroidStoragePermissions(context);
      }
      String? importFilePath;
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null) {
        importFilePath =
            '${(await getApplicationDocumentsDirectory()).path}/${Constants().appName}Export.zip';
      } else {
        importFilePath = result.files.single.path;
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
      await showAlertDialog(context, 'Database Imported Successully.',
          'Please restart app to take effect');
    } else {
      await showSnackbar('Import feature is not available on web yet');
    }
  } on Exception catch (e) {
    if (!context.mounted) return null;
    await showAlertDialog(context, 'Database Import Failed !!!', 'Error: $e');
  }
}
