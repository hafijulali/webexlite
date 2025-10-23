import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/widgets/nav_bar.dart';
import 'package:packer/widgets/snack_bar.dart';
import 'package:webexapis/webexapis.dart';

import '../../core/constants/constants.dart';
import '../../custom/widgets/app_bar.dart';
import '../../custom/widgets/nav_bar.dart';
import '../../init.dart';
import '../meetings_page/bloc/meetings_bloc.dart';
import '../meetings_page/bloc/meetings_event.dart';
import '../meetings_page/meetings_page.dart';
import '../messages_page/bloc/messages_bloc.dart';
import '../messages_page/messages_page.dart';
import '../rooms_page/bloc/rooms_bloc.dart';
import '../rooms_page/bloc/rooms_event.dart';
import '../rooms_page/rooms_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController pageController;
  Map<int, GlobalKey<NavigatorState>> navigatorKey =
      <int, GlobalKey<NavigatorState>>{
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPageIndex);
    debugPrint("HomePage: initState");
    if (accessToken == null || accessToken!.isEmpty) {
      PackerSnackBar(content: Constants().apiKeyNotSet).show();
    } else {}
  }

  @override
  void dispose() {
    debugPrint("HomePage: dispose");
    pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int gotoIndex) {
    setState(() {
      currentPageIndex = gotoIndex;
      currentPath = routes.keys.toList().elementAt(currentPageIndex);
      pageController.jumpToPage(currentPageIndex);
    });
    debugPrint("HomePage: bottom nav tapped, index: $gotoIndex $currentPath");
  }

  void _onRefresh(BuildContext refreshContext) {
    debugPrint("HomePage: refreshing page $currentPageIndex");
    switch (currentPageIndex) {
      case 0:
        refreshContext.read<RoomsBloc>().add(const LoadRooms(forceRefresh: true));
        break;
      case 1:
        // This is the placeholder messages page, nothing to refresh.
        break;
      case 2:
        refreshContext.read<MeetingsBloc>().add(const LoadMeetings(forceRefresh: true));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building HomePage");
    debugPrint("HomePage: webexApis is null: ${context.read<WebexApis>() == null}");

    final tabs = [
      const RoomsPage(),
      Builder(
        builder: (context) => const MessagesPage(roomId: '', roomTitle: '', roomType: ''),
      ),
      MeetingsPage(onGoToFirstPage: () => pageController.jumpToPage(0)),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<RoomsBloc>(
          create: (BuildContext context) =>
              RoomsBloc(webexApis: context.read<WebexApis>())..add(LoadRooms()),
        ),
        BlocProvider<MeetingsBloc>(
          create: (BuildContext context) =>
              MeetingsBloc(webexApis: context.read<WebexApis>())..add(LoadMeetings()),
        ),
        BlocProvider<MessagesBloc>(
          create: (BuildContext context) =>
              MessagesBloc(webexApis: context.read<WebexApis>()),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: appBar(context, onRefresh: () => _onRefresh(context)),
          body: PageView(
            controller: pageController,
            children: tabs,
            onPageChanged: (value) {
              debugPrint("HomePage: page changed to $value");
              setState(() {
                currentPageIndex = value;
                currentPath = routes.keys.toList().elementAt(currentPageIndex);
              });
            },
          ),
          bottomNavigationBar: PackerNavBar(
            items: navBarsItems(),
            currentIndex: currentPageIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Navigator navigateTo() => Navigator(
        key: navigatorKey[currentPageIndex],
        onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
          builder: routes.values.toList().elementAt(currentPageIndex),
        ),
      );
}