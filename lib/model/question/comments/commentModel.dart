import 'package:flutter/foundation.dart';
import 'package:tour_ease/model/otherUser/otherUserModel.dart';

class CommentModel {
  final int id;
  final int questionId;
  final String content;
  final DateTime createdAt;
  final OtherUserModel user;

  CommentModel({
    required this.id,
    required this.questionId,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
  print(json);

    try {
      return CommentModel(
        user: OtherUserModel(
          userid: json['user']['id'] as String,
          mediaUrls: List<String>.from(json['user']['mediaUrls'] as List),
          userName: json["user"]['username'] as String,
        ),
        id: json['id'] as int,
        questionId: json['questionId'] as int,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, questionId: $questionId, content: "$content", createdAt: $createdAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommentModel &&
        other.id == id &&
        other.questionId == questionId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.user == user;
  }

  @override
  int get hashCode {
    return id.hashCode ^ questionId.hashCode ^ content.hashCode ^ createdAt.hashCode ^ user.hashCode;
  }
}