import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/model/question/comments/commentModel.dart';
import 'package:tour_ease/model/question/questionModel.dart';

abstract class CommentsRepo {
  Future<CommentModel> writeComment(CommentModel comment);
  Future<CommentModel> deleteComment(CommentModel comment, Question question);
  Future<List<CommentModel>> getAllComments(Question question , int page, int limit, String sort);
}

class CommentRepoNodeJSApi extends CommentsRepo {
  final APIService apiService;
  final String baseUrl;
  final Dio dio = Dio();
  CommentRepoNodeJSApi(this.apiService) : baseUrl = apiService.baseUrl;

  @override
  Future<List<CommentModel>> getAllComments(Question question, int page, int limit, String sort) async {
    try {
      String url = '$baseUrl/api/commments?page=$page&limit=$limit&id=${question.id}';
      print(url);

      final response = await dio.get(
          url,
          options: Options(contentType: "application/json"),

          data: {
          "questionId": question.id
        }

      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {

          final data2 = (data['data'] as List)
              .map((comment) => CommentModel.fromJson(comment))
              .toList();

          return data2;
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {

      throw Exception('Error fetching questions: $e');
    }
  }

  @override
  Future<CommentModel> deleteComment(CommentModel comment, Question question) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<CommentModel> writeComment(CommentModel comment)async {
    try {
      String url = '$baseUrl/api/commments';
      final response = await dio.post(
          url,
          options: Options(contentType: "application/json"),

          data: {
            "userId": comment.user.userid,
            "questionId": comment.questionId,
            "content": comment.content
          }

      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {

          final data2 = data['data'];

          return data2;
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {

      throw Exception('Error fetching questions: $e');
    }
  }
}

class CommentRepoGraphQlApi extends CommentsRepo {
  @override
  Future<CommentModel> deleteComment(CommentModel comment, Question question) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<List<CommentModel>> getAllComments(Question question, int page, int limit, String sort) {
    // TODO: implement getAllComments
    throw UnimplementedError();
  }

  @override
  Future<CommentModel> writeComment(CommentModel comment) {
    // TODO: implement writeComment
    throw UnimplementedError();
  }
}
