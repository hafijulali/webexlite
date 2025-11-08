import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../init.dart';

List<DropdownMenuEntry> _dropdownMenuEntries() {
  final List<dynamic> font = List.generate(50, (index) => index += 5);
  final List<DropdownMenuEntry> fontMenuItem = List.empty(growable: true);
  for (final int element in font) {
    fontMenuItem.add(
      DropdownMenuEntry(
        value: element.toDouble(),
        label: element.toString(),
      ),
    );
  }
  return fontMenuItem;
}

ListTile changeFontSize(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.font_download_outlined),
    title: const Text('Font Size'),
    subtitle: const Text('Font size to use across app'),
    trailing: SizedBox(
      width: Constants().settingsTileWidgetWidth,
      child: DropdownMenu<dynamic>(
        hintText: fontSize.toInt().toString(),
        dropdownMenuEntries: _dropdownMenuEntries(),
        onSelected: (value) {
                          logger?.debug("font size changed to $value", source: 'FontSizeSettings');          fontSize = value;
          settingsDatabase!.put('FontSize', value);
        },
      ),
    ),
  );
}
