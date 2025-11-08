import 'package:flutter/material.dart';
import 'package:packer/utils/theme_utils.dart';
import 'package:packer/widgets/scaffold_key.dart';
import 'package:webexapis/webexapis.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'init.dart';
import 'screens/login_page/login_page.dart';
import 'core/constants/constants.dart';
import 'package:webexapis/core/apicontract.dart';

Future<dynamic> main() async {
  await initApp();
  final initialWebexApis = await initServices();

  logger?.debug('before runApp - settingsDatabase is null: ${settingsDatabase == null}', source: 'main');
  runApp(
    StreamBuilder<WebexApis?>(
      initialData: initialWebexApis,
      stream: settingsDatabase
              ?.watch(key: Constants().tokenSettingsKey)
              .asyncExpand((event) async* {
            logger?.debug('StreamBuilder - event received: ${event.value != null ? "token changed" : "token removed"}', source: 'main');
            if (event.value != null) {
              final storedToken = Map<String, dynamic>.from(event.value);
              token = Token.fromStorage(storedToken);
              accessToken = token!.accessToken;
              yield await initServices();
            } else {
              token = null;
              accessToken = null;
              yield null;
            }
          }) ??
          Stream.value(
              null), // Provide a default stream if settingsDatabase is null
      builder: (context, snapshot) {
        final currentWebexApis = snapshot.data;
        logger?.debug('StreamBuilder builder - snapshot.hasData: ${snapshot.hasData}, currentWebexApis: $currentWebexApis', source: 'main');

        if (currentWebexApis != null) {
          return Provider<WebexApis?>(
            create: (_) => currentWebexApis,
            child: const MyApp(),
          );
        } else {
          return MaterialApp(
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            home: const LoginPage(),
            theme: getTheme(appThemeMode),
          );
        }
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: const AppShell(),
      routes: routes,
      theme: getTheme(appThemeMode),
    );
  }
}
