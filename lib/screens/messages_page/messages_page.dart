import 'package:flutter/material.dart';
import 'package:packer/widgets/list.dart';
import 'package:webexlite/core/constants/constants.dart';

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
          }
          return PackerList(
            items: snapshot.data?['items'],
            itemBuilder: (room) => ListTile(
              title: Text(room['title']),
              onTap: () {},
            ),
          );
        });
  }
}
