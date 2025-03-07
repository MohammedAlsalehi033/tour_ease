class Chat {
  final String userName;
  final String lastMessage;
  final String timestamp;
  final String avatarUrl;
  final bool isUnread;

  Chat({
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.avatarUrl,
    this.isUnread = false,
  });
}