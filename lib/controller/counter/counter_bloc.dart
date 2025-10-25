import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial(0)) {
    on<UpCount>((event, emit) {

      emit(CounterLoading());

    for(double i= 0; i < 1000000000000000000 ; i++){}

      if(state is CounterInitial){

        final currentState = state as CounterInitial;
        emit(CounterInitial(currentState.count + 1));
      }

    });
  }
}
