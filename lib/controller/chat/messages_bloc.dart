import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tour_ease/model/chat/message.dart';
import 'package:tour_ease/model/chat/chatRepo.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatService chatService;
  final String currentUserId; // Pass current user ID for sending messages

  // 1. Add all necessary properties from the old BLoC
  IO.Socket? _socket;
  final _newMessageController = StreamController<Message>.broadcast();
  final _messageDeletedController = StreamController<String>.broadcast();
  StreamSubscription? _newMessageSubscription;
  StreamSubscription? _messageDeletedSubscription;

  MessagesBloc({
    required this.chatService,
    required this.currentUserId, // Inject the user ID
  }) : super(MessagesInitial()) {

    // 2. Setup socket connection right away
    _setupSocketConnection();

    // 3. Register all your event handlers
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<_MessageReceived>(_onMessageReceived);
    on<_MessageDeleted>(_onMessageDeleted);
  }

  void _setupSocketConnection() {
    _socket = chatService.initSocket();

    _socket!.on('new_message', (data) {
      try {
        final message = Message.fromJson(data);
        // Add the message to our internal stream
        if (!_newMessageController.isClosed) {
          _newMessageController.add(message);
        }
      } catch (e) {
        print('Error parsing message: $e');
      }
    });

    _socket!.on('message_deleted', (data) {
      if (data != null && data['messageId'] != null) {
        if (!_messageDeletedController.isClosed) {
          _messageDeletedController.add(data['messageId'].toString());
        }
      }
    });

    // Subscribe to the internal streams and add BLoC events
    _newMessageSubscription = _newMessageController.stream.listen((message) {
      add(_MessageReceived(message));
    });

    _messageDeletedSubscription = _messageDeletedController.stream.listen((messageId) {
      add(_MessageDeleted(messageId));
    });
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessagesState> emit) async {
    emit(MessagesLoading());
    try {
      final messages = await chatService.fetchMessages(event.otherUserId);
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MessagesState> emit) async {
    // We only perform optimistic updates if messages are already loaded
    if (state is! MessagesLoaded) return;

    final currentState = state as MessagesLoaded;
    List<Message> currentMessages = List.from(currentState.messages);

    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
      senderId: currentUserId, // Use the injected user ID
      receiverId: event.receiverId,
      content: event.content,
      createdAt: DateTime.now().toIso8601String(),
      read: false,
    );

    // Optimistic UI: Add the temporary message and emit a new state
    currentMessages.add(tempMessage);
    emit(MessagesLoaded(currentMessages));

    try {
      // Send the message to the server
      final sentMessage = await chatService.sendMessage(tempMessage);

      // Replace the temporary message with the real one from the server
      final tempIndex = currentMessages.indexWhere((m) => m.id == tempMessage.id);
      if (tempIndex != -1) {
        currentMessages[tempIndex] = sentMessage;
      }
      emit(MessagesLoaded(List.from(currentMessages))); // Emit a new list instance

    } catch (e) {
      // If sending fails, remove the temporary message and show an error
      currentMessages.removeWhere((m) => m.id == tempMessage.id);
      emit(MessagesLoaded(List.from(currentMessages)));
      // You might want to emit an error state as well or show a snackbar
      // For now, we just revert the UI
      print("Error sending message: $e");
    }
  }

  void _onMessageReceived(_MessageReceived event, Emitter<MessagesState> emit) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      // Check for duplicates before adding
      if (!currentState.messages.any((m) => m.id == event.message.id)) {
        final updatedMessages = List<Message>.from(currentState.messages)..add(event.message);
        emit(MessagesLoaded(updatedMessages));
      }
    }
  }

  void _onMessageDeleted(_MessageDeleted event, Emitter<MessagesState> emit) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      final updatedMessages = List<Message>.from(currentState.messages)
        ..removeWhere((m) => m.id == event.messageId);
      emit(MessagesLoaded(updatedMessages));
    }
  }

  // 4. Implement the close method for cleanup
  @override
  Future<void> close() {
    _newMessageSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _newMessageController.close();
    _messageDeletedController.close();
    chatService.dispose(); // This should disconnect the socket
    return super.close();
  }
}