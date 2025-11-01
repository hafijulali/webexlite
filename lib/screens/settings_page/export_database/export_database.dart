import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:packer/utils/permissions_utils.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/constants.dart';
import '../../../custom/widgets/alert_dialog.dart';
import '../../../init.dart';

ListTile exportDatabase(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.file_upload_outlined),
    title: const Text('Export Database'),
    onTap: () async => await _export(context),
  );
}

Future<dynamic> _export(BuildContext context) async {
        logger?.log('Settings: Exporting Database...');  try {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        checkStoragePermissions(context);
      }
      String? exportDirectory = await FilePicker.platform.getDirectoryPath();
      if (exportDirectory == null) {
        exportDirectory = (await getApplicationDocumentsDirectory()).path;
        logger?.log('Settings: Using default export location $exportDirectory');
      }
      final ZipFileEncoder encoder = ZipFileEncoder();
      encoder.zipDirectory(databaseDirectory!,
          filename:
              path.join(exportDirectory, '${Constants().appName}Export.zip'),
          onProgress: (percent) =>
              logger?.log("Settings: database export progress: $percent%"));

      if (!context.mounted) return;
      await showAlertDialog(
        context,
        'Database Exported Successully',
        'Path: $exportDirectory',
      );
    } else {
      await showSnackbar('Export feature is not available on web yet');
    }
  } on Exception catch (e) {
          logger?.log("Settings: database export failed, error: $e");    await showSnackbar('Database Export Failed !!!');
  }
}
