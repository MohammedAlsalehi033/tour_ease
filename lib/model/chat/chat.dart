class Chat {
  final String userId;
  final String partnerId;
  final String userName;
  final String lastMessage;
  final String timestamp;
  final String avatarUrl;
  final bool isUnread;


  //            "userId": "xeSEu67NIjZjSj92CIMjVixNQPr2",
  //             "partnerId": "xeSEu67NIjZjSj92CIMjVixNQPr2",
  Chat({
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.avatarUrl,
    required this.userId,
    required this.partnerId,
    this.isUnread = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      userId: json["userId"] ?? "",
      partnerId: json["partnerId"] ?? "",
      userName: json['userName'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      timestamp: json['timestamp'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isUnread: json['isUnread'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Chat{userName: $userName, lastMessage: $lastMessage, timestamp: $timestamp, avatarUrl: $avatarUrl, isUnread: $isUnread}';
  }
}