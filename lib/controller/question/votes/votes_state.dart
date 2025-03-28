part of 'votes_bloc.dart';

@immutable
sealed class VotesState {}

final class VotesInitial extends VotesState {}

final class VotesLoading extends VotesState {}

final class VotesLoaded extends VotesState {}

final class VotesError extends VotesState {
  final String error;

  VotesError(this.error);
}

