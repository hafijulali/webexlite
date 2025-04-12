import 'package:flutter/material.dart';

import '../navigation/navigate.dart';

Future<String?> showAlertDialog(
  BuildContext context,
  String title,
  String message,
) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => safePopWithResult(context, 'CANCEL'),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => safePopWithResult(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
