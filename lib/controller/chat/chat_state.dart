
import 'package:tour_ease/model/chat/chat.dart';
import 'package:tour_ease/model/chat/message.dart';

abstract class ChatState  {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<Chat> chats;

  ChatsLoaded({required this.chats});
}

class ChatLoaded extends ChatState {
  final List<Message> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];

  ChatLoaded copyWith({
    List<Message>? messages,
  }) {
    return ChatLoaded(
      messages ?? this.messages,
    );
  }
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSending extends ChatState {
  final List<Message> messages;

  const MessageSending(this.messages);

  @override
  List<Object> get props => [messages];
}