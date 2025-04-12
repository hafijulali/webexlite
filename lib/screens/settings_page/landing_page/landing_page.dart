import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../init.dart';

List<DropdownMenuEntry> _dropdownMenuEntries() {
  return [
    DropdownMenuEntry(
      value: 0,
      label: routes.keys.toList().elementAt(0).substring(1),
    ),
    DropdownMenuEntry(
      value: 1,
      label: routes.keys.toList().elementAt(1).substring(1),
    ),
    DropdownMenuEntry(
      value: 2,
      label: routes.keys.toList().elementAt(2).substring(1),
    ),
  ];
}

ListTile landingPage(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.screenshot_outlined),
    title: const Text('Landing Page'),
    subtitle: const Text('Page to display on app launch'),
    trailing: SizedBox(
      width: Constants().settingsTileWidgetWidth,
      child: DropdownMenu<dynamic>(
        hintText: routes.keys
            .toList()
            .elementAt(settingsDatabase?.get(Constants().landingPageSettingsKey,
                defaultValue: 1))
            .substring(1),
        dropdownMenuEntries: _dropdownMenuEntries(),
        onSelected: (value) =>
            settingsDatabase!.put(Constants().landingPageSettingsKey, value),
      ),
    ),
  );
}
