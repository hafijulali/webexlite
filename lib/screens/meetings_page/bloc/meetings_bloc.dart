import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexapis/routes/meetings/model.dart';
import 'package:webexapis/webexapis.dart';
import 'package:webexlite/init.dart';

import 'meetings_event.dart';
import 'meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  final WebexApis webexApis;

  MeetingsBloc({required this.webexApis}) : super(MeetingsInitial()) {
    on<LoadMeetings>((event, emit) async {
      emit(MeetingsLoading());

      if (!event.forceRefresh) {
        // Debug print: Attempting to load meetings from cache
        debugPrint('MeetingsBloc: Attempting to load meetings from cache...');
        try {
          final cachedItems = meetingsDatabase?.get('meetings');
          if (cachedItems != null) {
            final meetings = (cachedItems as List)
                .map((item) => Meeting.fromJson(Map<String, dynamic>.from(item))) // Fix: Explicitly convert to Map<String, dynamic>
                .toList();
            emit(MeetingsLoaded(meetings));
            // Debug print: Meetings loaded from cache
            debugPrint('MeetingsBloc: Meetings loaded from cache.');
            return;
          }
        } catch (e) {
          debugPrint('MeetingsBloc: Failed to load meetings from cache: $e');
        }
      }

      try {
        final response = await webexApis.getMeetings();
        if (response['items'] != null) {
          final meetings = (response['items'] as List)
              .map((item) => Meeting.fromJson(item as Map<String, dynamic>))
              .toList();
          await meetingsDatabase?.put('meetings', response['items']);
          // Debug print: Meetings saved to cache
          debugPrint('MeetingsBloc: Meetings saved to cache.');
          emit(MeetingsLoaded(meetings));
        } else {
          emit(MeetingsError(
              response['message'] as String? ?? 'Failed to load meetings.'));
        }
      } catch (e) {
        emit(MeetingsError(e.toString()));
      }
    });
  }
}