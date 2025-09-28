
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tour_ease/model/question/questionModel.dart';
import 'package:tour_ease/model/question/questionRepo.dart';
import 'package:tour_ease/model/userManagment/user.dart';

abstract class QuestionState  {
  const QuestionState();

  @override
  List<Object> get props => [];
}

class QuestionInitial extends QuestionState {}

class QuestionLoadInProgress extends QuestionState {}

class QuestionLoadSuccess extends QuestionState {
  final List<Question> questions;
  final bool hasReachedMax;
  final int currentPage;

  const QuestionLoadSuccess({
    required this.questions,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [questions, hasReachedMax, currentPage];

  QuestionLoadSuccess copyWith({
    List<Question>? questions,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return QuestionLoadSuccess(
      questions: questions ?? this.questions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class QuestionLoadFailure extends QuestionState {
  final String error;

  const QuestionLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

abstract class QuestionEvent {

  @override
  List<Object> get props => [];
}

class FetchQuestions extends QuestionEvent {
  final bool refresh;
  final String sort;

   FetchQuestions({this.refresh = false, this.sort = 'newest'});

  @override
  List<Object> get props => [refresh, sort];
}

class PostQuestion extends QuestionEvent{
  final Question question;

  PostQuestion({required this.question});
}

class EditQuestion extends QuestionEvent{
  final Question question;

  EditQuestion({required this.question});
}

class DeleteQuestion extends QuestionEvent{
  final Question question;
  DeleteQuestion({required this.question});
}

class SearchQuestions extends QuestionEvent {
  final String query;
  SearchQuestions({required this.query});
}

class VoteQuestion extends QuestionEvent {
  final Question question;
  final String voteType; // 'UPVOTE' or 'DOWNVOTE'
  
  VoteQuestion({required this.question, required this.voteType});
}

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuestionsRepo questionRepository;
  final int itemsPerPage = 10;

  QuestionBloc({required this.questionRepository}) : super(QuestionInitial()) {
    on<FetchQuestions>(_onFetchQuestions);
    on<PostQuestion>(_onPostQuestion);
    on<EditQuestion>(_onEditQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
    on<SearchQuestions>(_onSearchQuestions);
    on<VoteQuestion>(_onVoteQuestion);
  }

  Future<void> _onFetchQuestions(
      FetchQuestions event,
      Emitter<QuestionState> emit,
      ) async {
    try {
      if (event.refresh) {
        emit(QuestionLoadInProgress());
      }

      final currentState = state;
      int nextPage = 1;

      if (currentState is QuestionLoadSuccess && !event.refresh) {
        nextPage = currentState.currentPage + 1;
      }

      final questions = await questionRepository.getQuestions(
        page: nextPage,
        limit: itemsPerPage,
        sort: event.sort,
      );


      if (questions.isEmpty) {
        if (currentState is QuestionLoadSuccess) {
          emit(currentState.copyWith(hasReachedMax: true));
          return;
        }
      }

      if (currentState is QuestionLoadSuccess && !event.refresh) {
        emit(QuestionLoadSuccess(
          questions: currentState.questions + questions,
          currentPage: nextPage,
          hasReachedMax: questions.length < itemsPerPage,
        ));
      } else {
        emit(QuestionLoadSuccess(
          questions: questions,
          currentPage: nextPage,
          hasReachedMax: questions.length < itemsPerPage,
        ));
      }
    } catch (e) {
      emit(QuestionLoadFailure(e.toString()));
    }
  }

  Future<void> _onPostQuestion(PostQuestion event, Emitter<QuestionState> emit) async {
  emit(QuestionLoadInProgress());
  try{
    emit(QuestionLoadInProgress());

    final response = await questionRepository.createQuestion(event.question);
    emit(QuestionLoadSuccess(questions: [response]));
  }catch(e){
    emit(QuestionLoadFailure(e.toString()));
  }


  }
  Future<void> _onEditQuestion(EditQuestion event, Emitter<QuestionState> emit) async {


    try{
      emit(QuestionLoadInProgress());
      await questionRepository.editQuestion(event.question);

      final allQuestions = await questionRepository.getQuestions();

      emit(QuestionLoadSuccess(questions: allQuestions));
    }catch(e){

      emit(QuestionLoadFailure(e.toString()));
    }
  }
  Future<void> _onDeleteQuestion(DeleteQuestion event, Emitter<QuestionState> emit) async {
    try{
      emit(QuestionLoadInProgress());
      await questionRepository.deleteQuestion(event.question);
      final allQuestions = await questionRepository.getQuestions();
      emit(QuestionLoadSuccess(questions: allQuestions));
    }catch(e){
      emit(QuestionLoadFailure(e.toString()));
    }

  }
  Future<void> _onSearchQuestions(SearchQuestions event, Emitter<QuestionState> emit) async {
    try{
      emit(QuestionLoadInProgress());
      final response = await questionRepository.searchQuestions(event.query);
      emit(QuestionLoadSuccess(questions: response));
    }catch(e){
      emit(QuestionLoadFailure(e.toString()));
    }
  }

  Future<void> _onVoteQuestion(VoteQuestion event, Emitter<QuestionState> emit) async {
    final currentState = state;
    if (currentState is! QuestionLoadSuccess) return;
    
    try {
      // Import UserModel to get the current user ID
      final currentUserId = UserModel().id; // Get the actual current user's ID
      
      // Find the question in the current list
      final updatedQuestions = currentState.questions.map((q) {
        if (q.id == event.question.id) {
          return _updateQuestionVote(q, currentUserId, event.voteType);
        }
        return q;
      }).toList();
      
      // Emit the optimistic update first
      emit(currentState.copyWith(questions: updatedQuestions));
      
      // Make the API call
      await questionRepository.voteQuestion(
        event.question.id!,
        currentUserId,
        event.voteType == 'UPVOTE'
      );
      
    } catch (e) {
      // If the API call fails, revert the optimistic update
      emit(currentState);
      emit(QuestionLoadFailure('Failed to vote: ${e.toString()}'));
    }
  }
  
  Question _updateQuestionVote(Question question, String currentUserId, String newVoteType) {
    // Create a copy of the question
    final updatedQuestion = Question(
      id: question.id,
      title: question.title,
      description: question.description,
      userId: question.userId,
      userName: question.userName,
      user: question.user,
      upvotes: question.upvotes,
      downvotes: question.downvotes,
      createdAt: question.createdAt,
      updatedAt: question.updatedAt,
      tags: question.tags,
      commentCount: question.commentCount,
      mediaUrls: question.mediaUrls,
      votes: List.from(question.votes ?? []),
    );
    
    // Find the user's existing vote, if any
    final existingVoteIndex = updatedQuestion.votes?.indexWhere((vote) => vote['userId'] == currentUserId) ?? -1;
    String? previousVoteType;
    
    if (existingVoteIndex != -1) {
      previousVoteType = updatedQuestion.votes?[existingVoteIndex]['type'];
    }
    
    // Handle the vote logic
    if (previousVoteType == newVoteType) {
      // User is canceling their vote
      updatedQuestion.votes?.removeAt(existingVoteIndex);
      if (newVoteType == 'UPVOTE') {
        updatedQuestion.upvotes = (updatedQuestion.upvotes ?? 0) - 1;
      } else {
        updatedQuestion.downvotes = (updatedQuestion.downvotes ?? 0) - 1;
      }
    } else if (previousVoteType != null) {
      // User is changing their vote
      updatedQuestion.votes?[existingVoteIndex]['type'] = newVoteType;
      if (newVoteType == 'UPVOTE') {
        updatedQuestion.upvotes = (updatedQuestion.upvotes ?? 0) + 1;
        updatedQuestion.downvotes = (updatedQuestion.downvotes ?? 0) - 1;
      } else {
        updatedQuestion.downvotes = (updatedQuestion.downvotes ?? 0) + 1;
        updatedQuestion.upvotes = (updatedQuestion.upvotes ?? 0) - 1;
      }
    } else {
      // User is casting a new vote
      updatedQuestion.votes?.add({'userId': currentUserId, 'type': newVoteType});
      if (newVoteType == 'UPVOTE') {
        updatedQuestion.upvotes = (updatedQuestion.upvotes ?? 0) + 1;
      } else {
        updatedQuestion.downvotes = (updatedQuestion.downvotes ?? 0) + 1;
      }
    }
    
    return updatedQuestion;
  }


}