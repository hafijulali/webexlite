import 'package:flutter/material.dart';
import 'package:packer/widgets/nav_bar.dart';
import 'package:packer/widgets/snack_bar.dart';

import '../../core/constants/constants.dart';
import '../../custom/widgets/app_bar.dart';
import '../../custom/widgets/nav_bar.dart';
import '../../init.dart';

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
    if (apiKey == null || apiKey!.isEmpty) {
      PackerSnackBar(content: Constants().apiKeyNotSet).show();
    } else {}
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int gotoIndex) {
    setState(() {
      currentPageIndex = gotoIndex;
      currentPath = routes.keys.toList().elementAt(currentPageIndex);
      pageController.jumpToPage(currentPageIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: PageView(
        controller: pageController,
        children: tabs.values.toList(),
        onPageChanged: (value) {
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
