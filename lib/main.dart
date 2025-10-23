import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:packer/utils/theme_utils.dart';
import 'package:packer/widgets/scaffold_key.dart';
import 'package:webexapis/webexapis.dart';

import 'app_shell.dart';
import 'init.dart';
import 'screens/login_page/login_page.dart';

Future<dynamic> main() async {
  await initApp();

  runApp(MyApp(webexApis: webexApis));
}

class MyApp extends StatelessWidget {
  final WebexApis? webexApis;
  const MyApp({super.key, this.webexApis});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BoxEvent>(
      stream: settingsDatabase!.watch(),
      builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) {
        return MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: webexApis != null
              ? AppShell(webexApis: webexApis!)
              : LoginPage(),
          routes: routes,
          theme: getTheme(appThemeMode),
        );
      },
    );
  }
}

