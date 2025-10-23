import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends MessagesEvent {
  final String roomId;
  final bool forceRefresh;

  const LoadMessages(this.roomId, {this.forceRefresh = false});

  @override
  List<Object> get props => [roomId, forceRefresh];
}
