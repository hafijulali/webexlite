import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:packer/utils/theme_utils.dart';
import 'package:packer/widgets/scaffold_key.dart';

import 'init.dart';
import 'screens/home_page/home_page.dart';
import 'screens/meetings_page/bloc/meetings_bloc.dart';
import 'screens/rooms_page/bloc/rooms_bloc.dart';

Future<dynamic> main() async {
  await initApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<RoomsBloc>(
          create: (BuildContext context) => RoomsBloc(),
        ),
        BlocProvider<MeetingsBloc>(
          create: (BuildContext context) => MeetingsBloc(),
        ),
      ],
      child: StreamBuilder<BoxEvent>(
        stream: settingsDatabase!.watch(),
        builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) {
          return MaterialApp(
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            home: HomePage(),
            routes: routes,
            theme: getTheme(appThemeMode),
          );
        },
      ),
    ),
  );
}