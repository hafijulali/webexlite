import 'package:equatable/equatable.dart';

abstract class MeetingsEvent extends Equatable {
  const MeetingsEvent();

  @override
  List<Object> get props => [];
}

class LoadMeetings extends MeetingsEvent {
  final bool forceRefresh;

  const LoadMeetings({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}
