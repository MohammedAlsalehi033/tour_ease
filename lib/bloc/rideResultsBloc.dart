import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';
import 'package:tour_ease/model/rideSharing/rideModel.dart';
import 'package:tour_ease/model/rideSharing/rideRepository.dart';

// Import your filter model

// EVENTS
abstract class RideResultEvent {
  const RideResultEvent();

  @override
  List<Object?> get props => [];
}

class FetchRideResults extends RideResultEvent {
  final RideFilterModel filterModel;

  const FetchRideResults({
    required this.filterModel,
  });

  @override
  List<Object?> get props => [filterModel];
}

class ClearResults extends RideResultEvent {}



// STATE
class RideResultState {
  final List<Ride> rides;
  final bool isLoading;
  final String? error;

  const RideResultState({
    this.rides = const [],
    this.isLoading = false,
    this.error,
  });

  RideResultState copyWith({
    List<Ride>? rides,
    bool? isLoading,
    String? error,
  }) {
    return RideResultState(
      rides: rides ?? this.rides,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory RideResultState.initial() {
    return const RideResultState();
  }



  @override
  int get hashCode => rides.hashCode ^ isLoading.hashCode ^ error.hashCode;
}

class RideResultBloc extends Bloc<RideResultEvent, RideResultState> {
  final RideRepository rideRepository;

  RideResultBloc({required this.rideRepository}) : super(RideResultState.initial()) {
    on<FetchRideResults>(_onFetchRideResults);
    on<ClearResults>(_onClearResults);
  }

  Future<void> _onFetchRideResults(FetchRideResults event, Emitter<RideResultState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {

      final List<Ride> rides = await rideRepository.fetchRides(event.filterModel);

      emit(state.copyWith(
        rides: rides,
        isLoading: false,
      ));
    } catch (e) {
      print(e);
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onClearResults(ClearResults event, Emitter<RideResultState> emit) {
    emit(RideResultState.initial());
  }
}