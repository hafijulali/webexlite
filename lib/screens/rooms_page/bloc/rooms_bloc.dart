


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
      emit(RoomsLoading());

      if (!event.forceRefresh) {
    
        logger?.debug('Attempting to load rooms from cache...', source: 'RoomsBloc');
        try {
          final cachedRoomsJson = roomsDatabase?.get('rooms');
          if (cachedRoomsJson != null) {
            final rooms = (cachedRoomsJson as List).map((item) {
              try {
                return Room.fromJson(Map<String, dynamic>.from(item));
              } catch (e, st) {
                logger?.error(
                  'Error parsing cached room',
                  source: 'RoomsBloc',
                  stackTrace: st,
                  extra: {'json_data': item},
                  tags: {'parsing_context': 'cached_room'},
                );
                return null;
              }
            }).whereType<Room>().toList();
            emit(RoomsLoaded(rooms));
            return;
          }
        } catch (e, st) {
          logger?.error('Failed to load rooms from cache', source: 'RoomsBloc', stackTrace: st);
        }
      }

      try {
        final response = await webexApis.getRooms(max: maxItems);
        if (response['items'] != null) {
          final rooms = (response['items'] as List).map((item) {
            try {
              return Room.fromJson(item as Map<String, dynamic>);
            } catch (e, st) {
              logger?.error(
                                'Error parsing API room',
                                source: 'RoomsBloc',                stackTrace: st,
                extra: {'json_data': item},
                tags: {'parsing_context': 'api_room'},
              );
              return null;
            }
          }).whereType<Room>().toList();
          await roomsDatabase?.put('rooms', response['items']);
          emit(RoomsLoaded(rooms));
        } else {
          if (state is! RoomsLoaded) {
            emit(RoomsError(response['message']));
          }
        }
      } catch (e, st) {
        if (state is! RoomsLoaded) {
          logger?.error('Error during API call', source: 'RoomsBloc', stackTrace: st, extra: {'error': e.toString()});
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