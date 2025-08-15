import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/chat/chat.dart';
import 'package:tour_ease/model/chat/message.dart';

class ChatService {
  final String apiBaseUrl;
  final APIService apiService;
  final String currentUserId;
  IO.Socket? _socket;

  ChatService({
    required this.apiBaseUrl,
    required this.currentUserId,
    required this.apiService
  });

  IO.Socket initSocket() {
    print('Connecting to socket at: $apiBaseUrl');
    _socket = IO.io(
        apiBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .enableAutoConnect()
            .setExtraHeaders({'userId': currentUserId})
            .build()
    );

    _socket!.onConnect((_) {
      _socket!.emit('user_connected', currentUserId);
      print('Emitted user_connected event with userId: $currentUserId');
    });

    _socket!.onConnectError((data) => print('Connection error: $data'));
    _socket!.onDisconnect((_) => print('Socket disconnected'));
    _socket!.onError((error) => print('Socket error: $error'));
    _socket!.onAny((event, data) {
      print('Received socket event: $event');
      print('Event data: $data');
    });

    _socket!.connect();
    return _socket!;
  }

  void emitEvent(String eventName, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(eventName, data);
      print('Emitted event: $eventName');
      print('Event data: $data');
    } else {
      print('Cannot emit event: Socket not connected');
      _socket?.connect();
    }
  }

  void emitTyping(String receiverId, bool isTyping) {
    emitEvent('typing', {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'isTyping': isTyping
    });
  }

  Future<List<Message>> fetchMessages(String otherUserId) async {
    try {
      final response = await apiService.get<List<Message>>(
        path: '/api/messages',
        queryParams: {
          'senderId': currentUserId,
          'receiverId': otherUserId,
          'sort': 'oldest',
        },
        fromJson: (json) => (json as List).map((e) => Message.fromJson(e)).toList(),
      );
      return response;
    } catch (e) {
      print('Error loading messages: $e');
      throw Exception('Error loading messages: $e');
    }
  }

  Future<List<Chat>> fetchChat() async {
    try {
      print('Fetching chats for user: $currentUserId');
      final response = await apiService.get<List<Chat>>(
        path: '/api/chats/$currentUserId',
        fromJson: (json) => (json as List).map((e) => Chat.fromJson(e)).toList(),
      );
      print('Successfully fetched ${response.length} chats');
      return response;
    } catch (e) {
      print('Error loading Chats: $e');
      throw Exception('Error loading Chats: $e');
    }
  }

  Future<Message> sendMessage(Message message) async {
    try {
      print('Sending message from ${message.senderId} to ${message.receiverId}');
      print('Message content: ${message.content}');

      final response = await apiService.post<Message>(
        path: '/api/messages',
        body: {
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'content': message.content,
        },
        fromJson: (json) => Message.fromJson(json['data']),
      );

      print('Message sent successfully');
      return response;
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  bool isSocketConnected() {
    return _socket != null && _socket!.connected;
  }

  void reconnectSocket() {
    if (_socket != null && !_socket!.connected) {
      print('Reconnecting socket...');
      _socket!.connect();
    }
  }

  void dispose() {
    if (_socket != null) {
      print('Disconnecting socket');
      _socket!.disconnect();
      _socket!.dispose();
      print('Socket disposed');
    }
  }
}