import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/question/questionModel.dart';

abstract class VoteRepo {
  Future<String> updateVote(bool isUpvote, Question question);
}

class VotesRepoNodeAPI extends VoteRepo {
  final APIService apiService;

  VotesRepoNodeAPI(this.apiService);

  @override
  Future<String> updateVote(bool isUpvote, Question question) async {
    try {
      return await apiService.post<String>(
        path: '/api/questions/vote',
        body: {
          'id': question.id,
          'userId': question.userId,
          'isUpvote': isUpvote,
        },
        fromJson: (json) => "Done",
      );
    } catch (e) {
      throw Exception('Error updating vote: $e');
    }
  }
}