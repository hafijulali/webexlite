import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/widgets/nav_bar.dart';
import 'package:packer/widgets/snack_bar.dart';

import '../../core/constants/constants.dart';
import '../../custom/widgets/app_bar.dart';
import '../../custom/widgets/nav_bar.dart';
import '../../init.dart';
import '../meetings_page/bloc/meetings_bloc.dart';
import '../meetings_page/bloc/meetings_event.dart';
import '../rooms_page/bloc/rooms_bloc.dart';
import '../rooms_page/bloc/rooms_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<int, GlobalKey<NavigatorState>> navigatorKey =
      <int, GlobalKey<NavigatorState>>{
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
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

  void _onRefresh() {
    debugPrint("HomePage: refreshing page $currentPageIndex");
    switch (currentPageIndex) {
      case 0:
        context.read<RoomsBloc>().add(LoadRooms());
        break;
      case 1:
        // This is the placeholder messages page, nothing to refresh.
        break;
      case 2:
        context.read<MeetingsBloc>().add(LoadMeetings());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building HomePage");
    return Scaffold(
      appBar: appBar(context, onRefresh: _onRefresh),
      body: PageView(
        controller: pageController,
        children: tabs.values.toList(),
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
    );
  }

  Navigator navigateTo() => Navigator(
        key: navigatorKey[currentPageIndex],
        onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
          builder: routes.values.toList().elementAt(currentPageIndex),
        ),
      );
}