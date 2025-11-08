import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:webexapis/webexapis.dart';
import 'package:webexlite/init.dart';
import 'package:webexapis/routes/messages/model.dart';
import 'messages_event.dart';
import 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final int maxItems = 50;
  final WebexApis webexApis;

  MessagesBloc({required this.webexApis}) : super(MessagesInitial()) {
    on<LoadMessages>((event, emit) async {
      emit(MessagesLoading());

      if (!event.forceRefresh) {
        // Debug print: Attempting to load messages from cache
        logger?.debug(
            'MessagesBloc: Attempting to load messages from cache for room ${event.roomId}...');
        try {
          final cachedItems = messagesDatabase?.get(event.roomId);
          if (cachedItems != null) {
            final messages = (cachedItems as List)
                .map((item) {
                  try {
                    return Message.fromJson(Map<String, dynamic>.from(item));
                  } catch (e, st) {
                    logger?.error(
                      'MessagesBloc: Error parsing cached message',
                      source: 'MessagesBloc',
                      stackTrace: st,
                      extra: {'json_data': item, 'room_id': event.roomId},
                      tags: {'parsing_context': 'cached_message'},
                    );
                    return null;
                  }
                })
                .whereType<Message>()
                .toList();
            emit(MessagesLoaded(messages));
            return;
          }
        } catch (e, st) {
          logger?.error('MessagesBloc: Failed to load messages from cache',
              stackTrace: st, extra: {'room_id': event.roomId});
        }
      }

      try {
        final response =
            await webexApis.getMessages(max: maxItems, roomId: event.roomId);
        if (response['items'] != null) {
          final messages = (response['items'] as List)
              .map((item) {
                try {
                  return Message.fromJson(item as Map<String, dynamic>);
                } catch (e, st) {
                  logger?.error(
                    'MessagesBloc: Error parsing API message',
                    stackTrace: st,
                    extra: {'json_data': item},
                    tags: {'parsing_context': 'api_message'},
                  );
                  return null;
                }
              })
              .whereType<Message>()
              .toList();

          await messagesDatabase?.put(event.roomId, response['items']);
          emit(MessagesLoaded(messages));
        } else {
          if (state is! MessagesLoaded) {
            emit(MessagesError(
                response['message'] as String? ?? 'Failed to load messages.'));
          }
        }
      } catch (e, st) {
        if (state is! MessagesLoaded) {
          logger?.error('MessagesBloc: Error during API call',
              stackTrace: st, extra: {'room_id': event.roomId});
          emit(MessagesError(e.toString()));
        }
      }
    });
  }
}
