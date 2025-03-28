part of 'votes_bloc.dart';

@immutable
sealed class VotesEvent {}

class UpdateVote extends VotesEvent {
  final Question question;
  final bool isUpVote;

  UpdateVote(this.question, this.isUpVote);
}
