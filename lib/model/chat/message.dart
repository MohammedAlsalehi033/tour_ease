
class Message   {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String createdAt;
  final bool read;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      createdAt: json['createdAt'] ?? json['sentAt'] ?? DateTime.now().toIso8601String(),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'createdAt': createdAt,
      'read': read,
    };
  }

  // Create a temporary message with local ID
  factory Message.createTemp({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    return Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
      read: false,
    );
  }

  @override
  String toString() {
    return 'Message{id: $id, senderId: $senderId, receiverId: $receiverId, content: $content, createdAt: $createdAt, read: $read}';
  }

  @override
  List<Object?> get props => [id, senderId, receiverId, content, createdAt, read];
}