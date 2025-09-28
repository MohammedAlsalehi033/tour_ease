import 'package:tour_ease/model/otherUser/otherUserModel.dart';

class Question {
  int? id;
  final String title;
  final String description;
  final String userId;
  String? userName;
  OtherUserModel user;  // Change from UserModel to OtherUserModel
  int? upvotes;
  int? downvotes;
  DateTime? createdAt;
  DateTime? updatedAt;
  final List<String> tags;
  int? commentCount;
  List<String> mediaUrls;
  List<dynamic>? votes;

  Question({
    this.id,
    required this.title,
    required this.description,
    required this.userId,
    this.userName,
    required this.user,  // Now OtherUserModel
    this.upvotes = 0,
    this.downvotes = 0,
    this.createdAt,
    this.updatedAt,
    required this.tags,
    this.commentCount = 0,
    required this.mediaUrls,
    this.votes,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      return Question(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          userId: json['userId'],
          userName: json['user']['username'],
          upvotes: json['upvotes'],
          downvotes: json['downvotes'],
          createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
          updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
          tags: List<String>.from(json['tags'] ?? []),
          commentCount: json['_count']?['comments'] ?? 0,
          mediaUrls: List<String>.from(json['user']['mediaUrls'] as List? ?? []),
          votes: json['vote'] != null ? List<Map<String, dynamic>>.from(json['vote']) : [],
          user: OtherUserModel.fromJson(json['user'])  // Use OtherUserModel instead!
      );
    }catch(e) {
      print(json);
    rethrow;
    }

  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'Question{id: $id, title: $title, description: $description, userId: $userId, userName: $userName, upvotes: $upvotes, downvotes: $downvotes, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, commentCount: $commentCount, mediaUrls: $mediaUrls, votes: $votes}';
  }
}
