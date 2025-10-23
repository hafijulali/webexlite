import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
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
        debugPrint('MessagesBloc: Attempting to load messages from cache for room ${event.roomId}...');
        try {
          final cachedItems = messagesDatabase?.get(event.roomId);
          if (cachedItems != null) {
            final messages = (cachedItems as List)
                .map((item) => Message.fromJson(Map<String, dynamic>.from(item))) // Fix: Explicitly convert to Map<String, dynamic>
                .toList();
            emit(MessagesLoaded(messages));
            debugPrint('MessagesBloc: Messages loaded from cache for room ${event.roomId}. Count: ${messages.length}');
            return;
          }
        } catch (e) {
          debugPrint('MessagesBloc: Failed to load messages from cache: $e');
        }
      }

      debugPrint('MessagesBloc: Making API call to getMessages for room ${event.roomId}...');
      try {
        final response =
            await webexApis.getMessages(max: maxItems, roomId: event.roomId);
        if (response['items'] != null) {
          final messages = (response['items'] as List)
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
          debugPrint('MessagesBloc: Messages received from API for room ${event.roomId}. Count: ${messages.length}');
          await messagesDatabase?.put(event.roomId, response['items']);
          debugPrint('MessagesBloc: Messages saved to cache for room ${event.roomId}.');
          emit(MessagesLoaded(messages));
          debugPrint('MessagesBloc: MessagesLoaded emitted with new data.');
        } else {
          if (state is! MessagesLoaded) {
            emit(MessagesError(
                response['message'] as String? ?? 'Failed to load messages.'));
          }
        }
      } catch (e) {
        if (state is! MessagesLoaded) {
          emit(MessagesError(e.toString()));
        }
      }
    });
  }
}