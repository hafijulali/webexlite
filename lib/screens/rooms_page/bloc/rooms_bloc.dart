import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexlite/init.dart';
import 'package:webexapis/routes/rooms/model.dart';
import 'rooms_event.dart';
import 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  RoomsBloc() : super(RoomsInitial()) {
    on<LoadRooms>((event, emit) async {
      emit(RoomsLoading());
      try {
        final response = await webexApis?.getRooms(max: maxItems);
        if (response != null && response['items'] != null) {
          final rooms = (response['items'] as List)
              .map((item) => Room.fromJson(item as Map<String, dynamic>))
              .toList();
          emit(RoomsLoaded(rooms));
        } else {
          emit(RoomsError(response?['message'] as String? ?? 'Failed to load rooms.'));
        }
      } catch (e) {
        emit(RoomsError(e.toString()));
      }
    });
    on<BlockRoom>((event, emit) async {
      blockDatabase?.put(event.roomId, "");
      // After blocking, we might want to reload the rooms to reflect the change
      add(LoadRooms());
    });
  }
}
