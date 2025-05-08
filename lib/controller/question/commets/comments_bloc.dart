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
    on<PostComment>((event, emit) {
      commentsRepo.writeComment(event.commentModel);
    },);
  }
}
