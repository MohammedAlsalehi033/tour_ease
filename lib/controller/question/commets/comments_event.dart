part of 'comments_bloc.dart';

@immutable
sealed class CommentsEvent {}

class FetchComments extends CommentsEvent {
  final bool refresh;
  final int page;
  final int limit;
  final String sort;
  final Question question;

  FetchComments({required this.page, required this.limit, required this.sort, required this.refresh, required this.question});
}

class PostComment extends CommentsEvent{
  final CommentModel commentModel;

  PostComment( this.commentModel);
}
