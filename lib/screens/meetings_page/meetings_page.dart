import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/widgets/wdigets.dart';

import '../../core/constants/constants.dart';
import '../../init.dart';
import 'bloc/meetings_bloc.dart';
import 'bloc/meetings_event.dart';
import 'bloc/meetings_state.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MeetingsBloc>().add(LoadMeetings());
  }

  @override
  Widget build(BuildContext context) {
    Constants().currentPageRoute = Constants().meetingsPageRoute;
    return BlocBuilder<MeetingsBloc, MeetingsState>(
      builder: (context, state) {
        if (state is MeetingsLoading || state is MeetingsInitial) {
          return const Center(child: SizedBox(
              width: 30, height: 30, child: CircularProgressIndicator()));
        } else if (state is MeetingsError) {
          return Center(child: Text(textAlign: TextAlign.center, state.error));
        } else if (state is MeetingsLoaded) {
          if (state.meetings.isEmpty) {
            return Center(
              child: InkWell(
                onTap: () => pageController.jumpToPage(0),
                child: const Text(
                    textAlign: TextAlign.center,
                    "No meetings found.\nClick here to open a room."),
              ),
            );
          }
          return PackerList(
            items: state.meetings,
            itemBuilder: (meeting) => ListTile(
              onLongPress: () async {
                await Clipboard.setData(
                    ClipboardData(text: "${meeting['title']}"));
                showSnackbar(
                  'Copied to clipboard',
                );
              },
              subtitle: Text("${meeting['start']} - ${meeting['end']}"),
              title: Text(
                meeting['title'],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
