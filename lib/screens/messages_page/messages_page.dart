import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:packer/widgets/wdigets.dart';

import '../../core/constants/constants.dart';
import '../../init.dart';

class MessagesPage extends StatelessWidget {
  final String roomId;
  final String roomTitle;

  const MessagesPage(
      {required this.roomId, required this.roomTitle, super.key});

  @override
  Widget build(BuildContext context) {
    Constants().currentPageRoute =
        "${Constants().messagesPageRoute} $roomTitle";

    return FutureBuilder(
        future: webexApis?.getMessages(max: maxItems, roomId: roomId),
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
                onTap: () => pageController.jumpToPage(0),
                child: Text(
                    textAlign: TextAlign.center,
                    "${snapshot.data?['message']}\nClick here to open a room."));
          }
          if (child != null) {
            return Center(child: child);
          }

          return PackerList(
            items: snapshot.data?['items'],
            itemBuilder: (message) => ListTile(
                onLongPress: () async {
                  await Clipboard.setData(
                      ClipboardData(text: "${message['text']}"));
                  showSnackbar(
                    'Copied to clipboard',
                  );
                },
                subtitle:
                    Text("${message['personEmail']} ${message['created']}"),
                title: Text(
                  message['text'],
                )),
            //onTap: () => _onRoomTap(context, room['id']),
          );
        });
  }
}
