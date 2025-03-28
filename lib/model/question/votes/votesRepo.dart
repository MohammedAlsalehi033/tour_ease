import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/question/questionModel.dart';

abstract class VoteRepo {
  Future<String> updateVote(bool isUpvote, Question question);
}

class VotesRepoNodeAPI extends VoteRepo {
  final APIService apiService;
  final String baseUrl;
  final Dio dio = Dio();


  VotesRepoNodeAPI(this.apiService) : baseUrl = apiService.baseUrl;

  @override
  Future<String> updateVote(bool isUpvote, Question question) async {
    try {
      String url = '$baseUrl/api/questions/vote';
      final response = await Dio().post(
        url,
        options: Options(contentType: "application/json"),
        data: {
          'id': question.id,
          'userId': question.userId,
          'isUpvote': isUpvote,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return "Done";
        } else {
          throw Exception('API request was not successful: ${data['message']}'); // Added message from the API response
        }
      } else {
        throw Exception('Failed to update vote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating vote: $e');
    }
  }
}