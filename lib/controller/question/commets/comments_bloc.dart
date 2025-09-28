import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/otherUser/otherUserModel.dart';
import 'package:tour_ease/model/question/comments/commentModel.dart';
import 'package:tour_ease/model/question/comments/commentRepo.dart';
import 'package:tour_ease/model/question/questionModel.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsRepo commentsRepo;
  CommentsBloc(this.commentsRepo) : super(CommentsInitial()) {
    on<FetchComments>((event, emit)async {
      try {
        if (event.refresh) {
          emit(CommentsLoading());
        }
        final currentState = state;
        int nextPage = 1;
        if (currentState is CommentsLoaded && !event.refresh) {
          nextPage = currentState.currentPage + 1;
        }
        final comments = await commentsRepo.getAllComments(event.question,
          nextPage,
          10,
          event.sort,
        );
        if (comments.isEmpty) {
          if (currentState is CommentsLoaded) {
            emit(currentState.copyWith(hasReachedMax: true));
            return;
          }
        }
        if (currentState is CommentsLoaded && !event.refresh) {
          emit(CommentsLoaded(
            comments: currentState.comments + comments,
            currentPage: nextPage,
            hasReachedMax: comments.length < 10,
          ));
        } else {
          emit(CommentsLoaded(
            comments: comments,
            currentPage: nextPage,
            hasReachedMax: comments.length < 10,
          ));
        }}
      catch(e){
        emit(CommentsError(error: e.toString()));
      }
    });

    on<PostComment>((event, emit) async {
      try {
        // Save current state to handle state restoration
        final currentState = state;
        
        // Emit posting state for loading indicator
        if (currentState is CommentsLoaded) {
          emit(CommentsPosting(
            comments: currentState.comments,
            currentPage: currentState.currentPage,
            hasReachedMax: currentState.hasReachedMax,
          ));
        }

        // Post the comment asynchronously
        final response = await commentsRepo.writeComment(event.commentModel);
        
        print('Comment posted successfully: ${response.toString()}');

        // Add the new comment to the current list if we're in loaded state
        if (currentState is CommentsLoaded) {
          // Add the new comment to the list (at the beginning for immediacy)
          final updatedComments = [response, ...currentState.comments];

          emit(CommentsLoaded(
            comments: updatedComments,
            currentPage: currentState.currentPage,
            hasReachedMax: currentState.hasReachedMax,
          ));
        } else {
          // If not in loaded state, emit with just the new comment
          emit(CommentsLoaded(
            comments: [response],
            currentPage: 1,
            hasReachedMax: false,
          ));
        }

        // No explicit success state, UI can detect success from state changes
      } catch (e) {
        print('Error posting comment: $e');
        
        // Restore previous state before emitting error
        final currentState = state;
        if (currentState is CommentsPosting) {
          emit(CommentsLoaded(
            comments: currentState.comments,
            currentPage: currentState.currentPage,
            hasReachedMax: currentState.hasReachedMax,
          ));
        }
        
        // Handle posting error with a specific error state
        emit(CommentsPostError(error: "Failed to post comment: ${e.toString()}"));
        
        // Auto-recover to loaded state after brief error display
        if (currentState is CommentsLoaded) {
          Future.delayed(const Duration(seconds: 2), () {
            if (!isClosed) {
              emit(CommentsLoaded(
                comments: currentState.comments,
                currentPage: currentState.currentPage,
                hasReachedMax: currentState.hasReachedMax,
              ));
            }
          });
        }
      }
    });
  }
}