part of 'messages_bloc.dart';

@immutable
sealed class MessagesState {}

final class MessagesInitial extends MessagesState {

}

class MessagesLoaded extends MessagesState {
  final List<Message> messages;

  MessagesLoaded(this.messages);
}

class MessagesLoading extends MessagesState {

}

class MessagesError extends MessagesState {
  final String message;
  MessagesError(this.message);
}
