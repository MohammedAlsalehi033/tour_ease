import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';



// EVENTS
abstract class RideFilterEvent {
  const RideFilterEvent();

  @override
  List<Object?> get props => [];
}

class InitializeFilter extends RideFilterEvent {}

class UpdatePickupLocation extends RideFilterEvent {
  final String location;
  final LatLng locationCo;
  const UpdatePickupLocation(this.location, this.locationCo);

  @override
  List<Object?> get props => [location];
}

class UpdateDestination extends RideFilterEvent {
  final String destination;
  final LatLng destinationCo;

  const UpdateDestination(this.destination, this.destinationCo);

  @override
  List<Object?> get props => [destination];
}

class UpdateDate extends RideFilterEvent {
  final DateTime? date;
  const UpdateDate(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateStartTime extends RideFilterEvent {
  final Time time;
  const UpdateStartTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdateEndTime extends RideFilterEvent {
  final Time time;
  const UpdateEndTime(this.time);

  @override
  List<Object?> get props => [time];
}

class UpdatePriceRange extends RideFilterEvent {
  final RangeValues range;
  const UpdatePriceRange(this.range);

  @override
  List<Object?> get props => [range.start, range.end];
}

class IncrementTravelers extends RideFilterEvent {}

class DecrementTravelers extends RideFilterEvent {}

class IncrementLuggage extends RideFilterEvent {}

class DecrementLuggage extends RideFilterEvent {}

class ApplyFilters extends RideFilterEvent {}

class ResetFilters extends RideFilterEvent {}

// STATE
class RideFilterState {
  final RideFilterModel filterModel;
  final bool isLoading;
  final bool isApplied;
  final String? error;

  const RideFilterState({
    required this.filterModel,
    this.isLoading = false,
    this.isApplied = false,
    this.error,
  });

  RideFilterState copyWith({
    RideFilterModel? filterModel,
    bool? isLoading,
    bool? isApplied,
    String? error,
  }) {
    return RideFilterState(
      filterModel: filterModel ?? this.filterModel,
      isLoading: isLoading ?? this.isLoading,
      isApplied: isApplied ?? this.isApplied,
      error: error,
    );
  }

  factory RideFilterState.initial() {
    return RideFilterState(
      filterModel: RideFilterModel.initial(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RideFilterState &&
        other.filterModel == filterModel &&
        other.isLoading == isLoading &&
        other.isApplied == isApplied &&
        other.error == error;
  }

  @override
  int get hashCode {
    return filterModel.hashCode ^
    isLoading.hashCode ^
    isApplied.hashCode ^
    error.hashCode;
  }
}

// BLOC
class RideFilterBloc extends Bloc<RideFilterEvent, RideFilterState> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  RideFilterBloc() : super(RideFilterState.initial()) {
    on<InitializeFilter>(_onInitialize);
    on<UpdatePickupLocation>(_onUpdatePickupLocation);
    on<UpdateDestination>(_onUpdateDestination);
    on<UpdateDate>(_onUpdateDate);
    on<UpdateStartTime>(_onUpdateStartTime);
    on<UpdateEndTime>(_onUpdateEndTime);
    on<UpdatePriceRange>(_onUpdatePriceRange);
    on<IncrementTravelers>(_onIncrementTravelers);
    on<DecrementTravelers>(_onDecrementTravelers);
    on<IncrementLuggage>(_onIncrementLuggage);
    on<DecrementLuggage>(_onDecrementLuggage);
    on<ApplyFilters>(_onApplyFilters);
    on<ResetFilters>(_onResetFilters);


  }

  void _onInitialize(InitializeFilter event, Emitter<RideFilterState> emit) {
    emit(state);
  }

  void _onUpdatePickupLocation(UpdatePickupLocation event, Emitter<RideFilterState> emit) {
    print(event.locationCo);

    final updatedModel = state.filterModel.copyWith(
      pickupLocation: event.location,
      pickupLocationCoordinates: event.locationCo
    );
    print(updatedModel.pickupLocationCoordinates);
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onUpdateDestination(UpdateDestination event, Emitter<RideFilterState> emit) {
    final updatedModel = state.filterModel.copyWith(
      destination: event.destination,
      destinationCoordinates: event.destinationCo
    );
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onUpdateDate(UpdateDate event, Emitter<RideFilterState> emit) {
    final updatedModel = state.filterModel.copyWith(
      selectedDate: event.date,
    );
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onUpdateStartTime(UpdateStartTime event, Emitter<RideFilterState> emit) {
    final updatedModel = state.filterModel.copyWith(
      startTime: event.time,
    );
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onUpdateEndTime(UpdateEndTime event, Emitter<RideFilterState> emit) {
    final updatedModel = state.filterModel.copyWith(
      endTime: event.time,
    );
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onUpdatePriceRange(UpdatePriceRange event, Emitter<RideFilterState> emit) {
    final updatedModel = state.filterModel.copyWith(
      priceRange: event.range,
    );
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onIncrementTravelers(IncrementTravelers event, Emitter<RideFilterState> emit) {
    final updatedModel = state.filterModel.copyWith(
      numberOfTravelers: state.filterModel.numberOfTravelers + 1,
    );
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onDecrementTravelers(DecrementTravelers event, Emitter<RideFilterState> emit) {
    if (state.filterModel.numberOfTravelers > 1) {
      final updatedModel = state.filterModel.copyWith(
        numberOfTravelers: state.filterModel.numberOfTravelers - 1,
      );
      emit(state.copyWith(filterModel: updatedModel));
    }
  }

  void _onIncrementLuggage(IncrementLuggage event, Emitter<RideFilterState> emit) {
    final updatedModel = state.filterModel.copyWith(
      luggageCapacity: state.filterModel.luggageCapacity + 1,
    );
    emit(state.copyWith(filterModel: updatedModel));
  }

  void _onDecrementLuggage(DecrementLuggage event, Emitter<RideFilterState> emit) {
    if (state.filterModel.luggageCapacity > 0) {
      final updatedModel = state.filterModel.copyWith(
        luggageCapacity: state.filterModel.luggageCapacity - 1,
      );
      emit(state.copyWith(filterModel: updatedModel));
    }
  }

  void _onApplyFilters(ApplyFilters event, Emitter<RideFilterState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {

      await Future.delayed(const Duration(seconds: 1));



      emit(state.copyWith(
        isLoading: false,
        isApplied: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onResetFilters(ResetFilters event, Emitter<RideFilterState> emit) {
    pickupController.text = '';
    destinationController.text = '';

    emit(RideFilterState.initial());
  }



  @override
  Future<void> close() {
    pickupController.dispose();
    destinationController.dispose();
    return super.close();
  }
}