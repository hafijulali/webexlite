import 'package:flutter/material.dart';
import 'package:packer/widgets/list.dart';
import 'package:packer/widgets/wdigets.dart';

import '../../core/constants/constants.dart';
import '../../init.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});
  void _onRoomTap(BuildContext context, String roomId) async {
    try {
      final messages = (await webexApis?.getMessages(
          roomId: roomId, max: maxItems))?['items'];
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (_) => ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return ListTile(
              title: Text(msg['text']),
              subtitle: Text("${msg['personEmail']} ${msg['created']}"),
            );
          },
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      PackerSnackBar(content: "Error loading messages");
    }
  }

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
            debugPrint("Error loading rooms");
            return PackerSnackBar(content: "Error loading rooms");
          }

          return PackerList(
            items: snapshot.data?['items'],
            itemBuilder: (room) => ListTile(
              title: Text(
                room['title'],
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () => _onRoomTap(context, room['id']),
            ),
          );
        });
  }
}
