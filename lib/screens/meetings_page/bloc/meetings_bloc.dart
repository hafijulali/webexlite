import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexapis/routes/meetings/model.dart';
import 'package:webexapis/webexapis.dart';
import 'package:webexlite/init.dart';

import 'meetings_event.dart';
import 'meetings_state.dart';

class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  final WebexApis webexApis;
  Timer? _timer;

  MeetingsBloc({required this.webexApis}) : super(MeetingsInitial()) {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      logger?.log('MeetingsBloc: Cache expired, forcing refresh');
      add(const LoadMeetings(forceRefresh: true));
    });

    on<LoadMeetings>((event, emit) async {
      emit(MeetingsLoading());

      if (!event.forceRefresh) {
        try {
          final cachedItems = meetingsDatabase?.get('meetings');
          if (cachedItems != null) {
            final meetings = (cachedItems as List).map((item) {
              try {
                return Meeting.fromJson(Map<String, dynamic>.from(item));
              } catch (e, st) {
                logger?.error(
                  'MeetingsBloc: Error parsing cached meeting',
                  stackTrace: st,
                  extra: {'json_data': item},
                  tags: {'parsing_context': 'cached_meeting'},
                );
                return null;
              }
            }).whereType<Meeting>().toList();
            emit(MeetingsLoaded(meetings));
            return;
          }
        } catch (e, st) {
          logger?.error('MeetingsBloc: Failed to load meetings from cache', stackTrace: st);
        }
      }

      try {
        final response = await webexApis.getMeetings();
        if (response['items'] != null) {
          final meetings = (response['items'] as List).map((item) {
            try {
              return Meeting.fromJson(item as Map<String, dynamic>);
            } catch (e, st) {
              logger?.error(
                'MeetingsBloc: Error parsing API meeting',
                stackTrace: st,
                extra: {'json_data': item},
                tags: {'parsing_context': 'api_meeting'},
              );
              return null;
            }
          }).whereType<Meeting>().toList();
          await meetingsDatabase?.put('meetings', response['items']);
          emit(MeetingsLoaded(meetings));
        } else {
          emit(MeetingsError(
              response['message'] as String? ?? 'Failed to load meetings.'));
        }
      } catch (e, st) {
        logger?.error('MeetingsBloc: Error during API call', stackTrace: st);
        emit(MeetingsError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
