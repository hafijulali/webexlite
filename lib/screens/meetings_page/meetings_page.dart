import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packer/widgets/wdigets.dart';

import '../../core/constants/constants.dart';
import 'bloc/meetings_bloc.dart';
import 'bloc/meetings_event.dart';
import 'bloc/meetings_state.dart';

import 'package:intl/intl.dart';

class MeetingsPage extends StatefulWidget {
  final VoidCallback onGoToFirstPage;
  const MeetingsPage({super.key, required this.onGoToFirstPage});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MeetingsBloc>().add(const LoadMeetings());
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
                onTap: widget.onGoToFirstPage,
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
                    ClipboardData(text: meeting.title));
                showSnackbar(
                  'Copied to clipboard',
                );
              },
              subtitle: Text(
                  '${DateFormat('MMM d, yyyy h:mm a').format(meeting.start?.toLocal() ?? DateTime.now())} - ${DateFormat('h:mm a').format(meeting.end?.toLocal() ?? DateTime.now())}'),
              title: Text(
                meeting.title,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
