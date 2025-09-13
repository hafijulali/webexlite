import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/widgets/wdigets.dart';
import 'package:webexapis/routes/messages/model.dart';
import 'package:webexlite/custom/widgets/overlay.dart';

import '../../core/constants/constants.dart';
import '../../custom/navigation/navigate.dart';
import 'bloc/messages_bloc.dart';
import 'bloc/messages_event.dart';
import 'bloc/messages_state.dart';

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

    return BlocProvider(
      create: (context) => MessagesBloc()..add(LoadMessages(roomId)),
      child: BlocBuilder<MessagesBloc, MessagesState>(
        builder: (context, state) {
          if (state is MessagesLoading || state is MessagesInitial) {
            return const Center(child: SizedBox(
                width: 30, height: 30, child: CircularProgressIndicator()));
          } else if (state is MessagesError) {
            return Center(child: Text(textAlign: TextAlign.center, state.error));
          } else if (state is MessagesLoaded) {
            if (state.messages.isEmpty) {
              return Center(
                child: InkWell(
                  onTap: () => safePop(context),
                  child: const Text(
                      textAlign: TextAlign.center,
                      "No messages found.\nClick here to go back."),
                ),
              );
            }
            debugPrint('messages loaded: ${state.messages.length}');

            return PackerList<Message>.lazy(
              separatorBuilder: (_, __) => const Divider(height: 1),
              parser: (json) => Message.fromJson(json),
              items: state.messages.map((e) => e.toJson()).toList(),
              itemBuilder: (Message message) {
                final messageText = message.text ?? "";
                final files = message.files;
                String titleText = messageText;
                if (messageText.isEmpty && files != null && files.isNotEmpty) {
                  titleText = files.join(" ");
                }

                return ListTile(
                  onTap: (files != null && files.isNotEmpty) ? () => showImages(context, files.first) : null,
                  onLongPress: () async {
                    await Clipboard.setData(
                        ClipboardData(text: messageText));
                    showSnackbar(
                      'Copied to clipboard',
                    );
                  },
                  subtitle: Text(
                      "${message.personEmail ?? message.id} - ${message.created}"),
                  title: Text(titleText),
                );
              },
            );
          }
          return Container(); // Should not happen
        },
      ),
    );
  }
}

void showImages(BuildContext context, String url) {
  openOverlay(context, url);
}