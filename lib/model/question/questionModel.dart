class Question {
  int? id;
  final String title;
  final String description;
  final String userId;
  String? userName;
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
        mediaUrls: List<String>.from(json['user']['mediaUrls'] as List) ?? [],
        votes: json['vote']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'tags': tags,
    };
  }
}
