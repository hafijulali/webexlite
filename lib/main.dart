import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:packer/utils/theme_utils.dart';
import 'package:packer/widgets/scaffold_key.dart';

import 'init.dart';
import 'screens/login_page/login_page.dart';

Future<dynamic> main() async {
  await initApp();

  runApp(
    StreamBuilder<BoxEvent>(
      stream: settingsDatabase!.watch(),
      builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) {
        return MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: LoginPage(),
          routes: routes,
          theme: getTheme(appThemeMode),
        );
      },
    ),
  );
}
