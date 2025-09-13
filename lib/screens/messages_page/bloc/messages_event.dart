import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends MessagesEvent {
  final String roomId;

  const LoadMessages(this.roomId);

  @override
  List<Object> get props => [roomId];
}
