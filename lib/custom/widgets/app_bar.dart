import 'package:flutter/material.dart';
import 'package:packer/widgets/snack_bar.dart';

import '../../../init.dart';
import '../../core/constants/constants.dart';
import '../navigation/navigate.dart';
import 'search_bar.dart';

AppBar appBar(BuildContext context, {String? hintText, VoidCallback? onRefresh}) {
  return AppBar(
    title: Center(
        child: searchBar(context, () {
      showSnackbar(searchTextController.text);
    }, searchTextController,
            hintText: hintText ?? Constants().currentPageRoute.substring(1))),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_outlined),
      onPressed: () {
        safePop(context);
      },
    ),
    actions: actions(context, onRefresh: onRefresh),
  );
}

List<IconButton> actions(BuildContext context, {VoidCallback? onRefresh}) {
  return <IconButton>[
    IconButton(
      onPressed: onRefresh,
      icon: const Icon(Icons.refresh_outlined),
    ),
    IconButton(
      onPressed: () async => safePush(context, '/SettingsPage'),
      icon: const Icon(Icons.settings_outlined),
    ),
  ];
}