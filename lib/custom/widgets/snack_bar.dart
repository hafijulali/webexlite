import 'package:flutter/material.dart';
import 'package:packer/widgets/scaffold_key.dart';

import '../../core/constants/constants.dart';

SnackBar getSnackBar(String text, SnackBarAction action) {
  return SnackBar(
      margin: const EdgeInsets.all(20),
      behavior: SnackBarBehavior.floating,
      content: Text(text),
      showCloseIcon: true,
      action: action);
}

Future<void> showSnackbarX(String text, [SnackBarAction? action]) async {
  if (rootScaffoldMessengerKey.currentState != null) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => rootScaffoldMessengerKey.currentState?.showSnackBar(getSnackBar(
            text,
            action ??
                SnackBarAction(
                  label: Constants().undo,
                  onPressed: () => {},
                ))));
  }
}
