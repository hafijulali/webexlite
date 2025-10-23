import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexapis/webexapis.dart';
import 'package:webexlite/init.dart';
import 'package:webexapis/routes/rooms/model.dart';
import 'rooms_event.dart';
import 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final WebexApis webexApis;

  RoomsBloc({required this.webexApis}) : super(RoomsInitial()) {
    on<LoadRooms>((event, emit) async {
      debugPrint('RoomsBloc: LoadRooms event received, forceRefresh: ${event.forceRefresh}');
      emit(RoomsLoading());

      if (!event.forceRefresh) {
        // Debug print: Attempting to load rooms from cache
        debugPrint('RoomsBloc: Attempting to load rooms from cache...');
        try {
          final cachedRoomsJson = roomsDatabase?.get('rooms');
          if (cachedRoomsJson != null) {
            final rooms = (cachedRoomsJson as List)
                .map((item) => Room.fromJson(Map<String, dynamic>.from(item)))
                .toList();
            emit(RoomsLoaded(rooms));
            debugPrint('RoomsBloc: Rooms loaded from cache. Count: ${rooms.length}');
            return;
          }
        } catch (e) {
          debugPrint('RoomsBloc: Failed to load rooms from cache: $e');
        }
      }

      debugPrint('RoomsBloc: Making API call to getRooms...');
      try {
        final response = await webexApis.getRooms(max: maxItems);
        if (response['items'] != null) {
          final rooms = (response['items'] as List)
              .map((item) => Room.fromJson(item as Map<String, dynamic>))
              .toList();
          debugPrint('RoomsBloc: Rooms received from API. Count: ${rooms.length}');
          await roomsDatabase?.put('rooms', response['items']);
          debugPrint('RoomsBloc: Rooms saved to cache.');

          emit(RoomsLoaded(rooms));
          debugPrint('RoomsBloc: RoomsLoaded emitted with new data.');
        } else {
          if (state is! RoomsLoaded) {
            emit(RoomsError(response['message']));
          }
        }
      } catch (e) {
        if (state is! RoomsLoaded) {
          emit(RoomsError(e.toString()));
        }
      }
    });
    on<BlockRoom>((event, emit) async {
      await blockDatabase?.put(event.roomId, "");
      add(const LoadRooms(forceRefresh: true)); // Reload from API
    });
  }
}