import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexlite/init.dart';
import 'package:webexapis/routes/messages/model.dart';
import 'messages_event.dart';
import 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(MessagesInitial()) {
    on<LoadMessages>((event, emit) async {
      emit(MessagesLoading());
      try {
        final response = await webexApis?.getMessages(max: maxItems, roomId: event.roomId);
        if (response != null && response['items'] != null) {
          final messages = (response['items'] as List)
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
          emit(MessagesLoaded(messages));
        } else {
          emit(MessagesError(response?['message'] as String? ?? 'Failed to load messages.'));
        }
      } catch (e) {
        emit(MessagesError(e.toString()));
      }
    });
  }
}
