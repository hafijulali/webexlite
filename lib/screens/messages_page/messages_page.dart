import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:packer/widgets/wdigets.dart';
import 'package:webexapis/routes/messages/model.dart';
import 'package:webexlite/custom/widgets/overlay.dart';

import '../../core/constants/constants.dart';
import '../../custom/navigation/navigate.dart';
import '../../init.dart';

class MessagesPage extends StatelessWidget {
  final String roomId;
  final String roomTitle;
  final String roomType;

  const MessagesPage({
    required this.roomId,
    required this.roomTitle,
    required this.roomType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Constants().currentPageRoute =
        "${Constants().messagesPageRoute} $roomTitle";

    debugPrint("Building room: $roomTitle roomType: $roomType roomId: $roomId");

    return FutureBuilder<Map<String, dynamic>>(
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
                onTap: () => safePop(context),
                child: Text(
                    textAlign: TextAlign.center,
                    "${snapshot.data?['message']}\nClick here to open a room."));
          }
          if (child != null) {
            return Center(child: child);
          }
          debugPrint('message data: ${snapshot.data?['items']}');

          return PackerList<Message>.lazy(
            separatorBuilder: (_, __) => const Divider(height: 1),
            parser: (json) => Message.fromJson(json),
            items: snapshot.data?['items'],
            itemBuilder: (Message message) => ListTile(
                onTap: () => showImages(context, message.files!.first),
                onLongPress: () async {
                  await Clipboard.setData(
                      ClipboardData(text: message.text ?? "-"));
                  showSnackbar(
                    'Copied to clipboard',
                  );
                },
                subtitle: Text(
                    "${message.personEmail ?? message.id} - ${message.created}"),
                title: Text(
                  message.text == "" ? message.files!.join(" ") : message.text!,
                )),
            //onTap: () => _onRoomTap(context, room['id']),
          );
        });
  }
}

void showImages(BuildContext context, String url) {
  openOverlay(context, url);
}
