part of 'messages_bloc.dart';

@immutable
sealed class MessagesEvent {

}

// class SendMessage extends MessagesEvent {
// final String content;
// final String receiverId;
// SendMessage({required this.content, required this.receiverId});
// }

class LoadMessages extends MessagesEvent{
  final String otherUserId;
  LoadMessages({required this.otherUserId});
}
