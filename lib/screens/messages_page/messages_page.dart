import 'package:flutter/material.dart';
import 'package:packer/widgets/list.dart';
import 'package:packer/widgets/wdigets.dart';

import '../../core/constants/constants.dart';
import '../../init.dart';

class MessagesPage extends StatelessWidget {
  final String roomId;

  const MessagesPage({required this.roomId, super.key});

  @override
  Widget build(BuildContext context) {
    currentPath = Constants().messagesPageRoute;

    return FutureBuilder(
        future: webexApis?.getMessages(max: maxItems, roomId: roomId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: SizedBox(
                    width: 30, height: 30, child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            PackerSnackBar(content: "Error loading messages");
            return PackerSnackBar(content: "Error loading messages");
          }
          return PackerList(
            items: snapshot.data?['items'],
            itemBuilder: (message) => ListTile(
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
