part of 'comments_bloc.dart';

@immutable
sealed class CommentsState {}

final class CommentsInitial extends CommentsState {}
final class CommentsLoaded extends CommentsState {
  final bool hasReachedMax;
  final int currentPage;
  final List<CommentModel> comments;

  CommentsLoaded({required this.comments, required this.hasReachedMax, required this.currentPage});



  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
final class CommentsError extends CommentsState {
  final String error;

  CommentsError({required this.error});
}
final class CommentsLoading extends CommentsState {

}

