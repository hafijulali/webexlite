import 'package:flutter/material.dart';
import 'package:packer/widgets/snack_bar.dart';

import '../../../core/constants/constants.dart';
import '../../../init.dart';

ListTile auth(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.security_outlined),
    title: const Text('API Key'),
    subtitle: const Text('API key to authenticate with webex backend'),
    trailing: SizedBox(
      width: Constants().settingsTileWidgetWidth,
      child: TextFormField(
        onEditingComplete: () {
          try {
            settingsDatabase?.put(
                Constants().tokenSettingsKey, apiKeyTextController.text);
            showSnackbar(Constants().apiKeySaved, null);
            apiKeyTextController.text = '';
          } catch (e) {
            showSnackbar(Constants().apiKeySaveError, null);
          }
        },
        decoration: InputDecoration(
          hintText: (apiKey != null) ? '*********' : '',
          border: OutlineInputBorder(),
        ),
        controller: apiKeyTextController,
        validator: (String? text) =>
            text!.isEmpty ? 'API key must not be empty' : null,
      ),
    ),
  );
}
