import 'package:flutter/material.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/constants/constants.dart';
import '../../../init.dart';

ListTile auth(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.security_outlined),
    title: const Text('API Key'),
    subtitle: InkWell(
        onTap: () {
          debugPrint("Settings: opening webex api token url");
          launchUrlString(Constants().webexApiTokenUrl);
        },
        child: const Text(
            'API key to authenticate with webex backend. Click here to get your token')),
    trailing: SizedBox(
      width: Constants().settingsTileWidgetWidth,
      child: TextFormField(
        onEditingComplete: () {
          debugPrint("Settings: saving api key");
          try {
            settingsDatabase?.put(
                Constants().tokenSettingsKey, apiKeyTextController.text);
            showSnackbar(Constants().apiKeySaved, null);
            apiKeyTextController.text = '';
          } catch (e) {
            debugPrint("Settings: failed to save api key, error: $e");
            showSnackbar(Constants().apiKeySaveError, null);
          }
        },
        decoration: InputDecoration(
          hintText: (accessToken != null) ? '*********' : '',
          border: OutlineInputBorder(),
        ),
        controller: apiKeyTextController,
        validator: (String? text) =>
            text!.isEmpty ? 'API key must not be empty' : null,
      ),
    ),
  );
}
