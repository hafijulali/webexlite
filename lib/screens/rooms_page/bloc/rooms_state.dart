import 'package:equatable/equatable.dart';
import 'package:webexapis/routes/rooms/model.dart';

abstract class RoomsState extends Equatable {
  const RoomsState();

  @override
  List<Object> get props => [];
}

class RoomsInitial extends RoomsState {}

class RoomsLoading extends RoomsState {}

class RoomsLoaded extends RoomsState {
  final List<Room> rooms;

  const RoomsLoaded(this.rooms);

  @override
  List<Object> get props => [rooms];
}

class RoomsError extends RoomsState {
  final String error;

  const RoomsError(this.error);

  @override
  List<Object> get props => [error];
}
