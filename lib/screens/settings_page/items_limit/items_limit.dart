import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../init.dart';

List<DropdownMenuEntry> _dropdownMenuEntries() {
  final List<dynamic> font = List.generate(50, (index) => index += 5);
  final List<DropdownMenuEntry> menuItems = List.empty(growable: true);
  for (final int element in font) {
    menuItems.add(
      DropdownMenuEntry(
        value: element,
        label: element.toString(),
      ),
    );
  }
  return menuItems;
}

ListTile maxItemsLimit(BuildContext context) {
  return ListTile(
    leading: const Icon(Icons.list_outlined),
    title: const Text('Item Limit'),
    subtitle: const Text('Number of rooms/messages to show'),
    trailing: SizedBox(
      width: Constants().settingsTileWidgetWidth,
      child: DropdownMenu<dynamic>(
        hintText: maxItems.toString(),
        dropdownMenuEntries: _dropdownMenuEntries(),
        onSelected: (value) {
          maxItems = value;
          settingsDatabase!.put(Constants().maxItemsSettingsKey, value);
        },
      ),
    ),
  );
}
