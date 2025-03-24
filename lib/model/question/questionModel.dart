class Question {
  final String id;
  final String title;
  final String description;
  final String authorName;
  final String authorAvatarUrl;
  final String timestamp;
  final List<String> tags;
  final int answers;
  final int views;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timestamp,
    required this.tags,
    required this.answers,
    required this.views,
  });
}
