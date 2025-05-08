import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tour_ease/model/chat/chat.dart';
import 'package:tour_ease/model/chat/message.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class ChatService {
  final String apiBaseUrl;
  final String currentUserId;
  IO.Socket? _socket;
  final Dio dio = Dio();

  ChatService({
    required this.apiBaseUrl,
    required this.currentUserId,
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

    _socket!.onConnectError((data) {
      print('Connection error: $data');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });

    // Log all incoming events
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
      // Try to reconnect
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
      print('Fetching messages between $currentUserId and $otherUserId');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/messages?senderId=$currentUserId&receiverId=$otherUserId&sort=oldest'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesData = data['data'];
        print('Successfully fetched ${messagesData.length} messages');
        return messagesData.map((msg) => Message.fromJson(msg)).toList();
      } else {
        print('Failed to load messages: ${response.statusCode}');
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading messages: $e');
      throw Exception('Error loading messages: $e');
    }
  }

  Future<List<Chat>> fetchChat() async {
    try {
      print('Fetching chats for user: ${UserModel().id}');
      var dio = Dio();
      final endpoint = '$apiBaseUrl/api/chats/${UserModel().id}';
      print('Making GET request to: $endpoint');

      final response = await dio.request(
        endpoint,
        options: Options(
          method: 'GET',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> chatData = data['data'];
        print('Successfully fetched ${chatData.length} chats');
        return chatData.map((msg) => Chat.fromJson(msg)).toList();
      } else {
        print('Failed to load Chats: ${response.statusCode}');
        throw Exception('Failed to load Chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading Chats: $e');
      throw Exception('Error loading Chats: $e');
    }
  }

  Future<Message> sendMessage(Message message) async {
    try {
      print('Sending message from ${message.senderId} to ${message.receiverId}');
      print('Message content: ${message.content}');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'content': message.content,
        }),
      );

      if (response.statusCode == 201) {
        print('Message sent successfully');
        final data = json.decode(response.body);
        return Message.fromJson(data['data']);
      } else {
        print('Failed to send message: ${response.statusCode}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  // Check if socket is connected
  bool isSocketConnected() {
    return _socket != null && _socket!.connected;
  }

  // Reconnect socket if disconnected
  void reconnectSocket() {
    if (_socket != null && !_socket!.connected) {
      print('Reconnecting socket...');
      _socket!.connect();
    }
  }

  // Clean up socket connection
  void dispose() {
    if (_socket != null) {
      print('Disconnecting socket');
      _socket!.disconnect();
      _socket!.dispose();
      print('Socket disposed');
    }
  }
}