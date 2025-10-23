import 'package:equatable/equatable.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

class LoadRooms extends RoomsEvent {
  final bool forceRefresh;

  const LoadRooms({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class BlockRoom extends RoomsEvent {
  final String roomId;

  const BlockRoom(this.roomId);

  @override
  List<Object> get props => [roomId];
}
