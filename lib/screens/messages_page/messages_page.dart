import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/widgets/wdigets.dart';
import 'package:webexapis/routes/messages/model.dart';
import 'package:webexlite/custom/widgets/overlay.dart';
import 'package:webexlite/custom/widgets/app_bar.dart';

import '../../core/constants/constants.dart';
import 'package:packer/navigation/navigate.dart';
import 'bloc/messages_bloc.dart';
import 'bloc/messages_event.dart';
import 'bloc/messages_state.dart';
import 'send_messages_page.dart';

import 'package:webexapis/routes/people/model.dart';
import 'package:webexapis/webexapis.dart';
import '../../init.dart';

String _formatDateTime(DateTime dateTime) {
  final year = dateTime.year;
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  return '$year-$month-$day $hour:$minute';
}

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
    logger?.debug(
        '_getPersonDisplayName called for email: $personEmail',
        source: 'MessagesPage');
    if (personEmail == null || personEmail.isEmpty) {
      return "Unknown";
    }


    if (personDatabase != null && personDatabase!.containsKey(personEmail)) {
      final cachedPersonJson = personDatabase!.get(personEmail);
      if (cachedPersonJson != null) {
        final cachedPerson =
            Person.fromJson(Map<String, dynamic>.from(cachedPersonJson));
        logger?.debug(
            'Person found in cache: ${cachedPerson.displayName}',
            source: 'MessagesPage');
        return cachedPerson.displayName ?? personEmail;
      }
    }

          try {
          final webexApis = context.read<WebexApis>();
          final response = await webexApis.getPeople(email: personEmail);
          logger?.debug(
              'getPeople API response for $personEmail: $response',
              source: 'MessagesPage');      if (response['items'] != null && (response['items'] as List).isNotEmpty) {
        final person = Person.fromJson(response['items'][0]);
    
        await personDatabase?.put(personEmail, person.toJson());
        logger?.debug(
            'Person fetched from API and cached: ${person.displayName}',
            source: 'MessagesPage');
        return person.displayName ?? personEmail;
      }
    } catch (e) {
      logger?.error('Error fetching person details for $personEmail: $e', source: 'MessagesPage');
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

    logger?.debug(
        "Building room: ${widget.roomTitle} roomType: ${widget.roomType} roomId: ${widget.roomId}",
        source: 'MessagesPage');

    return Builder(builder: (context) {
      return Scaffold(
        appBar: appBar(context, hintText: widget.roomTitle, onRefresh: () {
          context
              .read<MessagesBloc>()
              .add(LoadMessages(widget.roomId, forceRefresh: true));
        }),
        floatingActionButton: FloatingActionButton(
          heroTag: 'message_fab_${widget.roomId}', // Unique tag
          onPressed: () {
            final useOverlay = settingsDatabase?.get(Constants().messageOverlaySettingsKey) ?? false;
            if (useOverlay) {
              openSendMessagesOverlay(context, widget.roomId);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SendMessagesPage(roomId: widget.roomId)));
            }
          },
          child: const Icon(Icons.message),
        ),
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
              logger?.debug('messages loaded: ${state.messages.length}', source: 'MessagesPage');

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
                        ? () => showImages(context, files, initialIndex: 0)
                        : null,
                    onLongPress: () async {
                      await Clipboard.setData(ClipboardData(text: messageText));
                      showSnackbar(
                        'Copied to clipboard',
                      );
                    },
                    subtitle: FutureBuilder<String>(
                      future: _getPersonDisplayName(message.personEmail),
                      builder: (context, snapshot) {
                        final displayName =
                            snapshot.data ?? message.personEmail ?? message.id;
                        return Text(
                            '$displayName - ${_formatDateTime(message.created?.toLocal() ?? DateTime.now())}');
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

void showImages(BuildContext context, List<String> urls, {int initialIndex = 0}) {
  openOverlay(context, urls, initialIndex: initialIndex);
}
