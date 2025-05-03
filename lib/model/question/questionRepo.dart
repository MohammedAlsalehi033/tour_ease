import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/question/questionModel.dart';

abstract class QuestionsRepo {
  Future<List<Question>> getQuestions({int page, int limit, String sort});
  Future<Question> getQuestionById(String id);
  Future<Question> createQuestion(Question question);
  Future<Question> editQuestion(Question question);
}


class QuestionRepoFromAPI extends QuestionsRepo {
  final APIService apiService;
  final String baseUrl;
  final Dio dio = Dio();
  QuestionRepoFromAPI(this.apiService) : baseUrl = apiService.baseUrl;



  @override
  Future<List<Question>> getQuestions({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
  }) async {
    try {

      String url =  '$baseUrl/api/questions?page=$page&limit=$limit&sort=$sort';
      print(url);

      final response = await dio.get(
       url
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((question) => Question.fromJson(question))
              .toList();
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
  Future<Question> getQuestionById(String id) {
    // TODO: implement getQuestionById
    throw UnimplementedError();
  }

  @override
  Future<Question> createQuestion(Question question) async{
    String url = '$baseUrl/api/questions';
    var headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await dio.post(
        url,
        data: jsonEncode(question.toJson()),
        options: Options(headers: headers),
      );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == true) {
        return Question.fromJson(data['data']);
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
  Future<Question> editQuestion(Question question)async {
    String url = '$baseUrl/api/questions/${question.id}';
    var headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await dio.put(
        url,
        data: jsonEncode(question.toJson()),
        options: Options(headers: headers),
      );



      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return question;
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