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
    print('CommentModel.fromJson received: $json');

    try {
      // Handle null safety and different possible response structures
      final userJson = json['user'] ?? {};
      final mediaUrls = userJson['mediaUrls'];
      
      return CommentModel(
        user: OtherUserModel(
          userid: (userJson['id'] ?? userJson['userid'] ?? '').toString(),
          mediaUrls: mediaUrls != null 
            ? List<String>.from(mediaUrls is List ? mediaUrls : [])
            : <String>[],
          userName: (userJson['username'] ?? userJson['userName'] ?? 'Anonymous').toString(),
        ),
        id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch) is int 
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? DateTime.now().millisecondsSinceEpoch,
        questionId: (json['questionId'] ?? 0) is int
          ? json['questionId'] as int  
          : int.tryParse(json['questionId'].toString()) ?? 0,
        content: (json['content'] ?? '').toString(),
        createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing CommentModel: $e');
      print('JSON data: $json');
      // Return a fallback comment instead of throwing
      return CommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        questionId: 0,
        content: 'Error loading comment',
        createdAt: DateTime.now(),
        user: OtherUserModel(
          userid: 'unknown',
          mediaUrls: [],
          userName: 'Unknown User',
        ),
      );
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