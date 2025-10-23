import 'package:webexapis/routes/meetings/model.dart';
import 'package:equatable/equatable.dart';

abstract class MeetingsState extends Equatable {
  const MeetingsState();

  @override
  List<Object> get props => [];
}

class MeetingsInitial extends MeetingsState {}

class MeetingsLoading extends MeetingsState {}

class MeetingsLoaded extends MeetingsState {
  final List<Meeting> meetings;

  const MeetingsLoaded(this.meetings);

  @override
  List<Object> get props => [meetings];
}

class MeetingsError extends MeetingsState {
  final String error;

  const MeetingsError(this.error);

  @override
  List<Object> get props => [error];
}
