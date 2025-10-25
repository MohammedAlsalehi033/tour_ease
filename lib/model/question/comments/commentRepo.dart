import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/model/question/comments/commentModel.dart';
import 'package:tour_ease/model/question/questionModel.dart';

abstract class CommentsRepo {
  Future<CommentModel> writeComment(CommentModel comment);
  Future<CommentModel> deleteComment(CommentModel comment, Question question);
  Future<List<CommentModel>> getAllComments(Question question, int page, int limit, String sort);
}

class CommentRepoNodeJSApi extends CommentsRepo {
  final APIService apiService;

  CommentRepoNodeJSApi(this.apiService);

  @override
  Future<List<CommentModel>> getAllComments(Question question, int page, int limit, String sort) async {
    try {
      return await apiService.get<List<CommentModel>>(
        path: '/api/commments',
        queryParams: {
          'id': question.id.toString(),
          'page': page.toString(),
          'limit': limit.toString(),
          'sort': sort,
        },
        fromJson: (json) => (json as List)
            .map((comment) => CommentModel.fromJson(comment))
            .toList(),
      );
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  @override
  Future<CommentModel> deleteComment(CommentModel comment, Question question) async {
    try {
      return await apiService.delete<CommentModel>(
        path: '/api/commments/${comment.id}',
        body: {
          'questionId': question.id,
        },
        fromJson: (json) => CommentModel.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }

  @override
  Future<CommentModel> writeComment(CommentModel comment) async {
    try {
      final response = await apiService.post<CommentModel>(
        path: '/api/commments',
        body: {
          "userId": comment.user.userid,
          "questionId": comment.questionId,
          "content": comment.content
        },
        fromJson: (json) {
          print('API Response for writeComment: $json');
          // Handle different possible response structures
          if (json is Map<String, dynamic>) {
            if (json.containsKey('data') && json['data'] != null) {
              return CommentModel.fromJson(json['data']);
            } else {
              return CommentModel.fromJson(json);
            }
          } else {
            throw Exception('Invalid response format: expected Map but got ${json.runtimeType}');
          }
        },
      );
      return response;
    } catch (e) {
      print('Error in writeComment: $e');
      throw Exception('Error writing comment: $e');
    }
  }
}

class CommentRepoGraphQlApi extends CommentsRepo {
  @override
  Future<CommentModel> deleteComment(CommentModel comment, Question question) {
    throw UnimplementedError();
  }

  @override
  Future<List<CommentModel>> getAllComments(Question question, int page, int limit, String sort) {
    throw UnimplementedError();
  }

  @override
  Future<CommentModel> writeComment(CommentModel comment) {
    throw UnimplementedError();
  }
}