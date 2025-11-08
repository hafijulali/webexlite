import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../init.dart';

List<DropdownMenuEntry> _dropdownMenuEntries() {
  final List<String> themes = <String>[
    Constants().systemTheme,
    Constants().lightTheme,
    Constants().darkTheme,
  ];
  final List<DropdownMenuEntry> fontMenuItem = List.empty(growable: true);
  for (final String element in themes) {
    fontMenuItem.add(
      DropdownMenuEntry(
        value: element,
        label: element,
      ),
    );
  }
  return fontMenuItem;
}

ListTile appTheme(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.font_download_outlined),
    title: const Text('App Theme'),
    subtitle: const Text('Theme to use across app'),
    trailing: SizedBox(
      width: Constants().settingsTileWidgetWidth,
      child: DropdownMenu<dynamic>(
        hintText: appThemeMode.toString(),
        dropdownMenuEntries: _dropdownMenuEntries(),
        onSelected: (value) {
                          logger?.debug("Settings: app theme changed to $value");          appThemeMode = value;
          settingsDatabase!.put(Constants().appThemeSettingsKey, appThemeMode);
        },
      ),
    ),
  );
}
