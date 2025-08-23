import 'dart:convert';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/question/questionModel.dart';

abstract class QuestionsRepo {
  Future<List<Question>> getQuestions({int page, int limit, String sort});
  Future<Question> getQuestionById(String id);
  Future<Question> createQuestion(Question question);
  Future<Question> editQuestion(Question question);
  Future<void> deleteQuestion(Question question);
}

class QuestionRepoFromAPI extends QuestionsRepo {
  final APIService apiService;

  QuestionRepoFromAPI(this.apiService);

  @override
  Future<List<Question>> getQuestions({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
  }) async {
    try {
      return await apiService.get<List<Question>>(
        path: '/api/questions',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
          'sort': sort,
        },
        fromJson: (json) => (json as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList(),
      );
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  @override
  Future<Question> getQuestionById(String id) async {
    try {
      return await apiService.get<Question>(
        path: '/api/questions/$id',
        fromJson: (json) => Question.fromJson(json),
      );
    } catch (e) {
      throw Exception('Error fetching question with id $id: $e');
    }
  }

  @override
  Future<Question> createQuestion(Question question) async {
    try {
      return await apiService.post<Question>(
        path: '/api/questions',
        body: question.toJson(),
        fromJson: (json) => Question.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Error creating question: $e');
    }
  }

  @override
  Future<Question> editQuestion(Question question) async {
    try {
      return await apiService.put<Question>(
        path: '/api/questions/${question.id}',
        body: question.toJson(),
        fromJson: (json) => Question.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Error editing question: $e');
    }
  }

  @override
  Future<void> deleteQuestion(Question question) {
    try{
      return apiService.delete<void>(
        path: '/api/questions/${question.id}', fromJson: (json) {  },
      );
    }
        catch(e){
          throw Exception('Error deleting question: $e');
        }
  }


}