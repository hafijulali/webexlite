import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/navigation/navigate.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:webexapis/webexapis.dart';

import '../../../init.dart';
import '../../core/constants/constants.dart';
import '../../screens/search_page/bloc/search_bloc.dart';
import '../../screens/search_page/bloc/search_event.dart';
import 'search_bar.dart';

AppBar appBar(
  BuildContext context, {
  String? hintText,
  VoidCallback? onRefresh,
  TextEditingController? searchController,
  void Function()? onSearchEditingComplete,
}) {
  final webexApis = context.watch<WebexApis?>();

  if (webexApis == null) {
    return AppBar(
      title: Text(hintText ?? ''),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        onPressed: () {
          safePop(context);
        },
      ),
    );
  }

  return AppBar(
    title: Center(
        child: BlocProvider<SearchBloc>(
      create: (context) => SearchBloc(webexApis: context.read<WebexApis>())..add(const LoadRecentSearches()),
      child: SearchBarWidget(
        onEditingComplete: onSearchEditingComplete ??
            () {
              showSnackbar(searchController?.text ?? '');
            },
        searchTextController: searchController ?? searchTextController,
        hintText: hintText ?? Constants().currentPageRoute.substring(1),
      ),
    )),
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
      onPressed: () async =>
          safePushNamed(context, Constants().settingsPageRoute),
      icon: const Icon(Icons.settings_outlined),
    ),
  ];
}
