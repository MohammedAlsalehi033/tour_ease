import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'loc_and_dis_map_event.dart';
part 'loc_and_dis_map_state.dart';

class LocAndDisMapBloc extends Bloc<LocAndDisMapEvent, LocAndDisMapState> {
  LocAndDisMapBloc() : super(LocAndDisMapInitial()) {
    on<LocAndDisMapEvent>((event, emit) {
    });
  }
}
