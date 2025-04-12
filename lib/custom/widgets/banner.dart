import 'package:flutter/material.dart';
import 'package:packer/widgets/scaffold_key.dart';

Future<void> showMaterialBanner(String text, [List<Widget>? actions]) async {
  if (rootScaffoldMessengerKey.currentState != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => rootScaffoldMessengerKey
        .currentState
        ?.showMaterialBanner(MaterialBanner(
            content: Text('OK'),
            actions: actions ??
                [
                  IconButton.outlined(
                      onPressed: () => {},
                      icon: Icon(Icons.notification_add_outlined))
                ])));
  }
}
