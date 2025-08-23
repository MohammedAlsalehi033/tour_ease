
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tour_ease/model/question/questionModel.dart';
import 'package:tour_ease/model/question/questionRepo.dart';

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

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuestionsRepo questionRepository;
  final int itemsPerPage = 10;

  QuestionBloc({required this.questionRepository}) : super(QuestionInitial()) {
    on<FetchQuestions>(_onFetchQuestions);
    on<PostQuestion>(_onPostQuestion);
    on<EditQuestion>(_onEditQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
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
      final response = await questionRepository.editQuestion(event.question);

      final allQuestions = await questionRepository.getQuestions();

      emit(QuestionLoadSuccess(questions: allQuestions));
    }catch(e){

      emit(QuestionLoadFailure(e.toString()));
    }
  }
  Future<void> _onDeleteQuestion(DeleteQuestion event, Emitter<QuestionState> emit) async {
    try{
      emit(QuestionLoadInProgress());
      final response = await questionRepository.deleteQuestion(event.question);
      final allQuestions = await questionRepository.getQuestions();
      emit(QuestionLoadSuccess(questions: allQuestions));
    }catch(e){
      emit(QuestionLoadFailure(e.toString()));
    }

  }


}