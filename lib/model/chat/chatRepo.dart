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

  // --- CORRECTED AND SIMPLIFIED initSocket METHOD ---
  IO.Socket initSocket() {
    // Always dispose of an old socket instance before creating a new one
    dispose();

    print('Attempting to connect socket to: $apiBaseUrl');

    _socket = IO.io(
      apiBaseUrl, // Pass the FULL URL, including https://
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // Prioritize websocket
          .disableAutoConnect() // IMPORTANT: We will connect manually
          .setExtraHeaders({'userId': currentUserId})
          .build()
    );

    // Attach all event listeners BEFORE connecting
    _socket!.onConnect((_) {
      print('✅ Socket connected successfully! ID: ${_socket!.id}');
      _socket!.emit('user_connected', currentUserId);
    });

    _socket!.onConnectError((data) => print('❌ Connection Error: $data'));
    _socket!.onError((error) => print('⚠️ Socket Error: $error'));
    _socket!.onDisconnect((reason) => print('🔌 Socket disconnected: $reason'));
    
    // For debugging, listen to any event
    _socket!.onAny((event, data) {
      print('📨 Event received: "$event" with data: $data');
    });

    // Manually initiate the connection
    _socket!.connect();

    return _socket!;
  }

  void emitEvent(String eventName, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket!.emit(eventName, data);
      print('Emitted event: $eventName with data: $data');
    } else {
      print('Cannot emit event: Socket not connected. Attempting to reconnect...');
      _socket?.connect(); // Try to reconnect if not connected
    }
  }
  
  // --- All other methods (fetchMessages, sendMessage, etc.) remain the same ---
  // (Your existing methods for fetching/sending messages are fine)

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
      final response = await apiService.post<Message>(
        path: '/api/messages',
        body: {
          'senderId': message.senderId,
          'receiverId': message.receiverId,
          'content': message.content,
        },
        fromJson: (json) => Message.fromJson(json['data']),
      );
      return response;
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  bool isSocketConnected() {
    return _socket?.connected ?? false;
  }

  void reconnectSocket() {
    if (_socket != null && !_socket!.connected) {
      print('Reconnecting socket...');
      _socket!.connect();
    }
  }

  void dispose() {
    if (_socket != null) {
      print('Disconnecting and disposing of socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}