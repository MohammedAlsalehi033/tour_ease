import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tour_ease/model/chat/chat.dart';
import 'package:tour_ease/model/chat/chatRepo.dart';
import 'package:tour_ease/model/chat/message.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService chatService;
  final String currentUserId;
  IO.Socket? _socket;

  // StreamControllers for socket events
  final _newMessageController = StreamController<Message>.broadcast();
  final _messageDeletedController = StreamController<String>.broadcast();

  // Stream subscriptions
  StreamSubscription? _newMessageSubscription;
  StreamSubscription? _messageDeletedSubscription;

  ChatBloc({
    required this.chatService,
    required this.currentUserId,
  }) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    // on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<MessageDeleted>(_onMessageDeleted);
    on<ResetChat>(_onResetChat);

    _setupSocketConnection();
  }

  void _setupSocketConnection() {
    _socket = chatService.initSocket();

    _socket!.on('new_message', (data) {
      try {
        final message = Message.fromJson(data);
        _newMessageController.add(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });

    _socket!.on('message_deleted', (data) {
      print('ChatBloc received message_deleted event: $data');
      if (data != null && data['messageId'] != null) {
        _messageDeletedController.add(data['messageId'].toString());
      }
    });

    // Subscribe to the stream controllers
    _newMessageSubscription = _newMessageController.stream.listen((message) {
      print('Processing new message in bloc: ${message.id}');
      add(MessageReceived(message));
    });

    _messageDeletedSubscription = _messageDeletedController.stream.listen((messageId) {
      print('Processing deleted message in bloc: $messageId');
      add(MessageDeleted(messageId));
    });
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      final messages = await chatService.fetchMessages(event.otherUserId);
      print(messages.toString());
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
  //   if (event.content.trim().isEmpty) return;
  //
  //   // Create temp message for optimistic UI update
  //   final tempMessage = Message.createTemp(
  //     senderId: currentUserId,
  //     receiverId: event.receiverId,
  //     content: event.content,
  //   );
  //
  //   // Copy current state messages
  //   List<Message> currentMessages = [];
  //   if (state is ChatLoaded) {
  //     currentMessages = List.from((state as ChatLoaded).messages);
  //   }
  //
  //   // Add temp message to list
  //   currentMessages.add(tempMessage);
  //   emit(MessageSending(currentMessages));
  //
  //   try {
  //     // Send the message to server
  //     final sentMessage = await chatService.sendMessage(tempMessage);
  //
  //     if (state is MessageSending || state is ChatLoaded) {
  //       // Get current messages
  //       List<Message> updatedMessages = [];
  //       if (state is MessageSending) {
  //         updatedMessages = List.from((state as MessageSending).messages);
  //       } else if (state is ChatLoaded) {
  //         updatedMessages = List.from((state as ChatLoaded).messages);
  //       }
  //
  //       // Replace temp message with actual message
  //       final tempIndex = updatedMessages.indexWhere((m) => m.id == tempMessage.id);
  //       if (tempIndex != -1) {
  //         updatedMessages[tempIndex] = sentMessage;
  //       }
  //
  //       emit(ChatLoaded(updatedMessages));
  //     }
  //   } catch (e) {
  //     // Error handling - remove temp message
  //     if (state is MessageSending || state is ChatLoaded) {
  //       List<Message> updatedMessages = [];
  //       if (state is MessageSending) {
  //         updatedMessages = List.from((state as MessageSending).messages);
  //       } else if (state is ChatLoaded) {
  //         updatedMessages = List.from((state as ChatLoaded).messages);
  //       }
  //
  //       updatedMessages.removeWhere((m) => m.id == tempMessage.id);
  //       emit(ChatLoaded(updatedMessages));
  //     }
  //
  //     emit(ChatError(e.toString()));
  //   }
  // }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    print('Processing MessageReceived event in bloc');
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      // Check if this message is already in our list to avoid duplicates
      if (!currentState.messages.any((m) => m.id == event.message.id)) {
        final updatedMessages = List<Message>.from(currentState.messages)..add(event.message);
        emit(ChatLoaded(updatedMessages));
      }
    }
  }

  void _onMessageDeleted(MessageDeleted event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedMessages = List<Message>.from(currentState.messages)
        ..removeWhere((m) => m.id == event.messageId);
      emit(ChatLoaded(updatedMessages));
    }
  }

  void _onResetChat(ResetChat event, Emitter<ChatState> emit) {
    emit(ChatInitial());
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      List<Chat> data = await chatService.fetchChat();
      emit(ChatsLoaded(chats: data));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    // Clean up all resources
    _newMessageController.close();
    _messageDeletedController.close();
    _newMessageSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    chatService.dispose();
    return super.close();
  }
}