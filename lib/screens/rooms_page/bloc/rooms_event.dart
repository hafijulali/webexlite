import 'package:equatable/equatable.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

class LoadRooms extends RoomsEvent {}

class BlockRoom extends RoomsEvent {
  final String roomId;

  const BlockRoom(this.roomId);

  @override
  List<Object> get props => [roomId];
}
