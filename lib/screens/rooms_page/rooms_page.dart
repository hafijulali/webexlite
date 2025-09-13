import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:packer/widgets/wdigets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webexapis/routes/rooms/model.dart';

import '../../core/constants/constants.dart';
import '../../custom/widgets/app_bar.dart';
import '../../init.dart';
import '../messages_page/messages_page.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    currentPath = Constants().roomsPageRoute;

    return FutureBuilder<Map<String, dynamic>>(
        future: webexApis?.getRooms(max: maxItems),
        builder: (context, snapshot) {
          Widget? child;
          if (snapshot.connectionState == ConnectionState.waiting) {
            child = SizedBox(
                width: 30, height: 30, child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            child = Text(textAlign: TextAlign.center, "${snapshot.error}");
          } else if (snapshot.data?['items'] == null) {
            child = InkWell(
                onTap: () => launchUrlString(Constants().webexApiTokenUrl),
                child: Text(
                    textAlign: TextAlign.center,
                    "${snapshot.data?['message']}\nClick here to get API token."));
          }
          if (child != null) {
            return Center(child: child);
          }
          return ValueListenableBuilder(
              valueListenable: settingsDatabase!.listenable(),
              builder: (context, _, __) {
                final items = (snapshot.data?['items'] as List?)
                        ?.map((e) => Room.fromJson(e as Map<String, dynamic>))
                        .toList() ??
                    [];

                return PackerList(
                    items: items,
                    itemBuilder: (Room room) {
                      if (blockDatabase != null) {
                        if (blockDatabase!.containsKey(room.id)) {
                          return SizedBox.shrink();
                        }
                      }
                      return ListTile(
                        title: Text(
                          room.title,
                          style: TextStyle(fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onLongPress: () async {
                          final result = await showAlertDialog(
                              context,
                              "Block ${room.title}",
                              "Do you want to block this chat?");
                          if (result == Constants().ok) {
                            blockDatabase?.put(room.id, "");
                            debugPrint("Blocked");
                          }
                        },
                        onTap: () {
                          Constants().currentPageRoute =
                              "${Constants().messagesPageRoute} ${room.title}";
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: appBar(context, hintText: room.title),
                                  body: MessagesPage(
                                    roomTitle: room.title,
                                    roomId: room.id,
                                    roomType: room.type,
                                  ),
                                ),
                              ));
                        },
                      );
                    });
              });
        });
  }
}
