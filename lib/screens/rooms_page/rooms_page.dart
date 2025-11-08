import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:packer/widgets/wdigets.dart' hide showAlertDialog;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webexapis/routes/rooms/model.dart';
import 'package:webexapis/webexapis.dart';

import '../../core/constants/constants.dart';

import '../../custom/widgets/alert_dialog.dart';
import '../../init.dart';
import '../messages_page/bloc/messages_bloc.dart';
import '../messages_page/messages_page.dart';
import 'bloc/rooms_bloc.dart';
import 'bloc/rooms_event.dart';
import 'bloc/rooms_state.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  @override
  void initState() {
    super.initState();
    context.read<RoomsBloc>().add(const LoadRooms());
  }

  @override
  Widget build(BuildContext context) {
    currentPath = Constants().roomsPageRoute;

    return BlocBuilder<RoomsBloc, RoomsState>(
      builder: (context, state) {
        if (state is RoomsLoading || state is RoomsInitial) {
          return const Center(
              child: SizedBox(
                  width: 30, height: 30, child: CircularProgressIndicator()));
        } else if (state is RoomsError) {
          return Center(
            child: InkWell(
              onTap: () => launchUrlString(Constants().webexApiTokenUrl),
              child: Text(
                  textAlign: TextAlign.center,
                  "${state.error}\nClick here to get API token."),
            ),
          );
        } else if (state is RoomsLoaded) {
          return ValueListenableBuilder(
            valueListenable: settingsDatabase!.listenable(),
            builder: (context, _, __) {
              final items = state.rooms;

              return PackerList(
                items: items,
                itemBuilder: (Room room) {
                  if (blockDatabase != null &&
                      blockDatabase!.containsKey(room.id)) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    title: Text(
                      room.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onLongPress: () async {
                      final bloc = context.read<RoomsBloc>();
                      final result = await showAlertDialog(
                          context,
                          "Block ${room.title}",
                          "Do you want to block this chat?");
                      if (result == Constants().ok) {
                        bloc.add(BlockRoom(room.id));
                        logger?.debug("Blocked", source: 'RoomsPage');
                      }
                    },
                    onTap: () {
                      final webexApis = context.read<WebexApis>();
                      Constants().currentPageRoute =
                          "${Constants().messagesPageRoute} ${room.title}";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepositoryProvider.value(
                            value: webexApis,
                            child: BlocProvider(
                              create: (context) =>
                                  MessagesBloc(webexApis: webexApis),
                              child: MessagesPage(
                                roomTitle: room.title,
                                roomId: room.id,
                                roomType: room.type,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        }
        return Container();
      },
    );
  }
}
