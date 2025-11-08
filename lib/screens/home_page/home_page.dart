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

import '../messages_page/messages_page.dart';
import '../rooms_page/bloc/rooms_bloc.dart';
import '../rooms_page/bloc/rooms_event.dart';
import '../rooms_page/rooms_page.dart';
import '../search_page/bloc/search_bloc.dart';
import '../search_page/search_page.dart';
import '../search_page/bloc/search_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController pageController;
  final TextEditingController _searchController = TextEditingController();
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
    logger?.debug("initState", source: 'HomePage');
    if (accessToken == null || accessToken!.isEmpty) {
      PackerSnackBar(content: Constants().apiKeyNotSet).show();
    } else {}

  }

  @override
  void dispose() {
    logger?.debug("dispose", source: 'HomePage');
    pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int gotoIndex) {
    setState(() {
      currentPageIndex = gotoIndex;
      currentPath = routes.keys.toList().elementAt(currentPageIndex);
      pageController.jumpToPage(currentPageIndex);
    });
    logger?.debug("bottom nav tapped, index: $gotoIndex $currentPath", source: 'HomePage');
  }

  void _onRefresh(BuildContext refreshContext) {
    logger?.debug("refreshing page $currentPageIndex", source: 'HomePage');
    switch (currentPageIndex) {
      case 0:
        logger?.debug("refreshing rooms", source: 'HomePage');
        refreshContext
            .read<RoomsBloc>()
            .add(const LoadRooms(forceRefresh: true));
        break;
      case 1:
    
        logger?.debug("skipping refresh for messages page", source: 'HomePage');
        break;
      case 2:
        logger?.debug("refreshing meetings", source: 'HomePage');
        refreshContext
            .read<MeetingsBloc>()
            .add(const LoadMeetings(forceRefresh: true));
        break;
    }
    logger?.debug("refresh complete", source: 'HomePage');
  }

  @override
  Widget build(BuildContext context) {
    logger?.debug("Building", source: 'HomePage');
        logger?.debug("webexApis is null: ${context.read<WebexApis>()}", source: 'HomePage');

    final tabs = [
      Builder(
        builder: (context) => RoomsPage(),
      ),
      Builder(
        builder: (context) =>
            const MessagesPage(roomId: '', roomTitle: '', roomType: ''),
      ),
      Builder(
        builder: (context) =>
            MeetingsPage(onGoToFirstPage: () => pageController.jumpToPage(0)),
      ),
    ];

    return Scaffold(
          appBar: appBar(
            context,
            onRefresh: () => _onRefresh(context),
            searchController: _searchController,
            onSearchEditingComplete: () {
              logger?.debug("onSearchEditingComplete triggered", source: 'HomePage');
              final query = _searchController.text;
              if (query.isNotEmpty) {
                context.read<SearchBloc>().add(PerformSearch(query));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (routeContext) => BlocProvider.value(
                      value: routeContext.read<SearchBloc>(),
                      child: const SearchPage(),
                    ),
                  ),
                );
              }
            },
          ),
          body: PageView(
            controller: pageController,
            children: tabs,
            onPageChanged: (value) {
              logger?.debug("page changed to $value", source: 'HomePage');
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
        );
  }

  Navigator navigateTo() => Navigator(
        key: navigatorKey[currentPageIndex],
        onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
          builder: routes.values.toList().elementAt(currentPageIndex),
        ),
      );
}
