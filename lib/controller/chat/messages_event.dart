part of 'messages_bloc.dart';

@immutable
abstract class MessagesEvent {}

class LoadMessages extends MessagesEvent {
  final String otherUserId;
  LoadMessages({required this.otherUserId});
}

class SendMessage extends MessagesEvent {
  final String content;
  final String receiverId;
  SendMessage({required this.content, required this.receiverId});
}

// Internal event for when a message is received from the socket
class _MessageReceived extends MessagesEvent {
  final Message message;
  _MessageReceived(this.message);
}

// Internal event for when a message is deleted via the socket
class _MessageDeleted extends MessagesEvent {
  final String messageId;
  _MessageDeleted(this.messageId);
}