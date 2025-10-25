class UserModelTempForNow {
  final String id;
  final String email;
  final String username;
  final List<String> mediaUrls;
  final String accountStatus;
  final DateTime createdAt;

  UserModelTempForNow({
    required this.id,
    required this.email,
    required this.username,
    required this.mediaUrls,
    required this.accountStatus,
    required this.createdAt,
  });

  factory UserModelTempForNow.fromJson(Map<String, dynamic> json) {
    return UserModelTempForNow(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      mediaUrls: (json['mediaUrls'] as List<dynamic>).cast<String>(),
      accountStatus: json['accountStatus'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}