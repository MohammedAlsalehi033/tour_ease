class UserModel {
  static final UserModel _instance = UserModel._internal();

  factory UserModel() {
    return _instance;
  }

  UserModel._internal({
    this.id = '',
    this.username = '',
    this.email = '',
    this.passwordHash = '',
    this.mediaUrls = const [],
    this.accountStatus = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.roles = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String id;
  String username;
  String email;
  String passwordHash;
  List<String> mediaUrls;
  String accountStatus;
  DateTime createdAt;
  DateTime updatedAt;
  List<Role> roles;

  void updateUser({
    String? id,
    String? username,
    String? email,
    String? passwordHash,
    List<String>? mediaUrls,
    String? accountStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Role>? roles,
  }) {
    this.id = id ?? this.id;
    this.username = username ?? this.username;
    this.email = email ?? this.email;
    this.passwordHash = passwordHash ?? this.passwordHash;
    this.mediaUrls = mediaUrls ?? this.mediaUrls;
    this.accountStatus = accountStatus ?? this.accountStatus;
    this.createdAt = createdAt ?? this.createdAt;
    this.updatedAt = updatedAt ?? this.updatedAt;
    this.roles = roles ?? this.roles;
    print(this.id);

  }

  static UserModel fromJson(Map<String, dynamic> json) {
    try {
      // Store the current ID to compare later
      final String previousId = _instance.id;
      final String newId = json['id'] ?? '';
      
      // Log if the user ID is changing
      if (previousId.isNotEmpty && newId != previousId) {
        print('WARNING: UserModel ID changing from $previousId to $newId');
      }

      _instance.id = newId;
      _instance.username = json['username'] ?? '';
      _instance.email = json['email'] ?? '';
      _instance.passwordHash = json['passwordHash'] ?? '';


      if (json['mediaUrls'] != null) {
        _instance.mediaUrls = List<String>.from(json['mediaUrls']);
      } else {
        _instance.mediaUrls = [];
      }

      _instance.accountStatus = json['accountStatus'] ?? 'active';

      _instance.createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now();

      _instance.updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now();

      _instance.roles = [];
      if (json['roles'] != null) {
        if (json['roles'] is List<String> ||
            (json['roles'] is List && json['roles'].isNotEmpty && json['roles'][0] is String)) {
          // If roles is a list of strings
          _instance.roles = (json['roles'] as List)
              .map((role) => Role(id: role, roleName: role))
              .toList();
        } else if (json['roles'] is List) {
          // If roles is a list of objects
          _instance.roles = (json['roles'] as List)
              .map((role) => Role.fromJson(role is Map<String, dynamic>
              ? role
              : {'id': role.toString(), 'roleName': role.toString()}))
              .toList();
        }
      }

      return _instance;
    } catch (e) {
      print("Error parsing user JSON: $e");
      print("JSON content: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'mediaUrls': mediaUrls,
      'accountStatus': accountStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }

  void addRole(Role role) {
    roles = [...roles, role];
  }

  void removeRole(Role role) {
    roles = roles.where((r) => r.id != role.id).toList();
  }

  void clear() {
    id = '';
    username = '';
    email = '';
    passwordHash = '';
    mediaUrls = [];
    accountStatus = 'active';
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    roles = [];
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, roles: $roles}';
  }
}

class Role {
  final String id;
  final String roleName;

  Role({required this.id, required this.roleName});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      roleName: json['roleName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleName': roleName,
    };
  }

  @override
  String toString() {
    return 'Role{id: $id, roleName: $roleName}';
  }
}

