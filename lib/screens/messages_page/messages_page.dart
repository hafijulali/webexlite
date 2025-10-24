import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/widgets/wdigets.dart';
import 'package:webexapis/routes/messages/model.dart';
import 'package:webexlite/custom/widgets/overlay.dart';
import 'package:webexlite/custom/widgets/app_bar.dart';

import '../../core/constants/constants.dart';
import '../../custom/navigation/navigate.dart';
import 'bloc/messages_bloc.dart';
import 'bloc/messages_event.dart';
import 'bloc/messages_state.dart';

import 'package:intl/intl.dart';
import 'package:webexapis/routes/people/model.dart';
import 'package:webexapis/webexapis.dart';
import '../../init.dart';

class MessagesPage extends StatefulWidget {
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
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Future<String> _getPersonDisplayName(String? personEmail) async {
    debugPrint('MessagesPage: _getPersonDisplayName called for email: $personEmail');
    if (personEmail == null || personEmail.isEmpty) {
      return "Unknown";
    }

    // Check Hive cache first
    if (personDatabase != null && personDatabase!.containsKey(personEmail)) {
      final cachedPersonJson = personDatabase!.get(personEmail);
      if (cachedPersonJson != null) {
        final cachedPerson = Person.fromJson(Map<String, dynamic>.from(cachedPersonJson));
        debugPrint('MessagesPage: Person found in cache: ${cachedPerson.displayName}');
        return cachedPerson.displayName ?? personEmail;
      }
    }

    try {
      final webexApis = context.read<WebexApis>();
      final response = await webexApis.getPeople(email: personEmail);
      debugPrint('MessagesPage: getPeople API response for $personEmail: $response');
      if (response['items'] != null && (response['items'] as List).isNotEmpty) {
        final person = Person.fromJson(response['items'][0]);
        // Store in Hive cache
        await personDatabase?.put(personEmail, person.toJson());
        debugPrint('MessagesPage: Person fetched from API and cached: ${person.displayName}');
        return person.displayName ?? personEmail;
      }
    } catch (e) {
      debugPrint('Error fetching person details for $personEmail: $e');
    }
    return personEmail;
  }

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(widget.roomId));
  }

  @override
  Widget build(BuildContext context) {
    Constants().currentPageRoute =
        "${Constants().messagesPageRoute} ${widget.roomTitle}";

    debugPrint(
        "Building room: ${widget.roomTitle} roomType: ${widget.roomType} roomId: ${widget.roomId}");

    return Builder(builder: (context) {
      return Scaffold(
        appBar: appBar(context, hintText: widget.roomTitle, onRefresh: () {
          context
              .read<MessagesBloc>()
              .add(LoadMessages(widget.roomId, forceRefresh: true));
        }),
        body: BlocBuilder<MessagesBloc, MessagesState>(
          builder: (context, state) {
            if (state is MessagesLoading || state is MessagesInitial) {
              return const Center(
                  child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator()));
            } else if (state is MessagesError) {
              return Center(
                  child: Text(textAlign: TextAlign.center, state.error));
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
                  if (messageText.isEmpty &&
                      files != null &&
                      files.isNotEmpty) {
                    titleText = files.join(" ");
                  }

                  return ListTile(
                    onTap: (files != null && files.isNotEmpty)
                        ? () => showImages(context, files.first)
                        : null,
                    onLongPress: () async {
                      await Clipboard.setData(
                          ClipboardData(text: messageText));
                      showSnackbar(
                        'Copied to clipboard',
                      );
                    },
                    subtitle: FutureBuilder<String>(
                      future: _getPersonDisplayName(message.personEmail),
                      builder: (context, snapshot) {
                        final displayName = snapshot.data ?? message.personEmail ?? message.id;
                        return Text(
                            '$displayName - ${DateFormat('MMM d, yyyy h:mm a').format(message.created?.toLocal() ?? DateTime.now())}');
                      },
                    ),
                    title: Text(titleText),
                  );
                },
              );
            }
            return Container(); // Should not happen
          },
        ),
      );
    });
  }
}

void showImages(BuildContext context, String url) {
  openOverlay(context, url);
}
