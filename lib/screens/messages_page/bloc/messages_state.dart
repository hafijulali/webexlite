import 'package:equatable/equatable.dart';
import 'package:webexapis/routes/messages/model.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object> get props => [];
}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<Message> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class MessagesError extends MessagesState {
  final String error;

  const MessagesError(this.error);

  @override
  List<Object> get props => [error];
}
