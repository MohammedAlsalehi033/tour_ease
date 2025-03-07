class Message {
  final String text;
  final String sender;
  final String timestamp;
  final bool isMe;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.isMe,
  });
}