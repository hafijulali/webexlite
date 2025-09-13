import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexlite/init.dart';
import 'meetings_event.dart';
import 'meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  MeetingsBloc() : super(MeetingsInitial()) {
    on<LoadMeetings>((event, emit) async {
      emit(MeetingsLoading());
      try {
        final response = await webexApis?.getMeetings();
        if (response != null && response['items'] != null) {
          emit(MeetingsLoaded(response['items']));
        } else {
          emit(MeetingsError(response?['message'] as String? ?? 'Failed to load meetings.'));
        }
      } catch (e) {
        emit(MeetingsError(e.toString()));
      }
    });
  }
}
