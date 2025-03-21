class User {
  static final User _instance = User._internal();

  String id;
  String userName;
  String email;
  List<String> mediaUrls;
  String accountStatus;
  DateTime createdAt;
  DateTime updatedAt;

  User._internal({
    this.id = '',
    this.userName = '',
    this.email = '',
    this.mediaUrls = const [],
    this.accountStatus = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory User() {
    return _instance;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    _instance.id = json['id'];
    _instance.userName = json['userName'];
    _instance.email = json['email'];
    _instance.mediaUrls = List<String>.from(json['mediaUrls']);
    _instance.accountStatus = json['accountStatus'];
    _instance.createdAt = DateTime.parse(json['createdAt']);
    _instance.updatedAt = DateTime.parse(json['updatedAt']);
    return _instance;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'mediaUrls': mediaUrls,
      'accountStatus': accountStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  void updateUser({
    String? id,
    String? userName,
    String? email,
    List<String>? mediaUrls,
    String? accountStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? this.id;
    this.userName = userName ?? this.userName;
    this.email = email ?? this.email;
    this.mediaUrls = mediaUrls ?? this.mediaUrls;
    this.accountStatus = accountStatus ?? this.accountStatus;
    this.createdAt = createdAt ?? this.createdAt;
    this.updatedAt = updatedAt ?? this.updatedAt;
  }
}