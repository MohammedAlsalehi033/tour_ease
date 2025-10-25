

import 'package:tour_ease/model/chat/message.dart';

abstract class ChatEvent  {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadChats extends ChatEvent {

}

class LoadMessages extends ChatEvent {
  final String otherUserId;

  const LoadMessages(this.otherUserId);

  @override
  List<Object> get props => [otherUserId];
}



class MessageReceived extends ChatEvent {
  final Message message;

  const MessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class MessageDeleted extends ChatEvent {
  final String messageId;

  const MessageDeleted(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class ResetChat extends ChatEvent {}