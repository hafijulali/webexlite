import 'package:flutter/material.dart';
import 'package:packer/widgets/list.dart';
import 'package:packer/widgets/wdigets.dart';
import '../../custom/widgets/app_bar.dart';
import '../messages_page/messages_page.dart';

import '../../core/constants/constants.dart';
import '../../custom/navigation/navigate.dart';
import '../../custom/widgets/nav_bar.dart';
import '../../init.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    currentPath = Constants().roomsPageRoute;

    return FutureBuilder(
        future: webexApis?.getRooms(max: maxItems),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: SizedBox(
                    width: 30, height: 30, child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            PackerSnackBar(content: "Error loading rooms");
            return PackerSnackBar(content: "Error loading rooms");
          }

          return PackerList(
            items: snapshot.data?['items'],
            itemBuilder: (room) => ListTile(
              title: Text(
                room['title'],
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Constants().currentPageRoute = Constants().messagesPageRoute;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: appBar(context),
                        body: MessagesPage(
                          roomId: room['id'],
                        ),
                        bottomNavigationBar: PackerNavBar(
                            items: navBarsItems(),
                            currentIndex: 2,
                            onItemTapped: (_) => safePop(context)),
                      ),
                    ));
              },
            ),
          );
        });
  }
}
