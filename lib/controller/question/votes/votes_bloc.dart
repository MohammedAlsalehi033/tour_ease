import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tour_ease/model/question/questionModel.dart';
import 'package:tour_ease/model/question/votes/voteModel.dart';
import 'package:tour_ease/model/question/votes/votesRepo.dart';

part 'votes_event.dart';
part 'votes_state.dart';

class VotesBloc extends Bloc<VotesEvent, VotesState> {
  final VoteRepo voteRepo;
  VotesBloc(this.voteRepo) : super(VotesInitial()) {
    on<UpdateVote>((event, emit) {
      emit(VotesLoading());
      try{
        voteRepo.updateVote(event.isUpVote, event.question);
        emit(VotesLoaded());
      }catch(e) {
        emit(VotesError(e.toString()));
        throw e;
      }
    });
  }
}
