import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexapis/webexapis.dart';

import 'screens/home_page/home_page.dart';
import 'screens/meetings_page/bloc/meetings_bloc.dart';
import 'screens/meetings_page/bloc/meetings_event.dart';
import 'screens/messages_page/bloc/messages_bloc.dart';
import 'screens/rooms_page/bloc/rooms_bloc.dart';
import 'screens/rooms_page/bloc/rooms_event.dart';
import 'screens/search_page/bloc/search_bloc.dart';
import 'screens/search_page/bloc/search_event.dart';

class AppShell extends StatelessWidget {

  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider.value(value: context.read<WebexApis>()),
        BlocProvider<RoomsBloc>(
          create: (BuildContext context) =>
              RoomsBloc(webexApis: context.read<WebexApis>())..add(LoadRooms()),
        ),
        BlocProvider<MeetingsBloc>(
          create: (BuildContext context) =>
              MeetingsBloc(webexApis: context.read<WebexApis>())
                ..add(LoadMeetings()),
        ),
        BlocProvider<MessagesBloc>(
          create: (BuildContext context) =>
              MessagesBloc(webexApis: context.read<WebexApis>()),
        ),
        BlocProvider<SearchBloc>(
          create: (BuildContext context) =>
              SearchBloc(webexApis: context.read<WebexApis>())
                ..add(const LoadRecentSearches()),
        ),
      ],
      child: const HomePage(),
    );
  }
}
