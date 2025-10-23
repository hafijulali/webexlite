import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexapis/webexapis.dart';

import 'screens/home_page/home_page.dart';

class AppShell extends StatelessWidget {
  final WebexApis webexApis;

  const AppShell({super.key, required this.webexApis});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: webexApis,
      child: const HomePage(),
    );
  }
}
