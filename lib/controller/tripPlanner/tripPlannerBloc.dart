import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerRepository.dart';

// EVENTS
abstract class TripPlannerEvent {
  const TripPlannerEvent();
}

class GenerateTripPlan extends TripPlannerEvent {
  final TripPlanRequest request;

  const GenerateTripPlan({required this.request});
}

class RefineTripPlan extends TripPlannerEvent {
  final Map<String, dynamic> originalRequest;
  final Map<String, dynamic> currentResults;
  final String userMessage;

  const RefineTripPlan({
    required this.originalRequest,
    required this.currentResults,
    required this.userMessage,
  });
}

class ConfirmBooking extends TripPlannerEvent {
  final String optionId;
  final int? outboundTransportId;
  final int? returnTransportId;
  final int seatsNeeded;
  final int? accommodationId;
  final List<Map<String, int>>? selectedRoomAllocations;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String? specialRequests;

  const ConfirmBooking({
    required this.optionId,
    this.outboundTransportId,
    this.returnTransportId,
    required this.seatsNeeded,
    this.accommodationId,
    this.selectedRoomAllocations,
    required this.checkInDate,
    required this.checkOutDate,
    this.specialRequests,
  });
}

class ClearTripPlan extends TripPlannerEvent {}

// STATE
class TripPlannerState {
  final TripPlanResponse? tripPlan;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? bookingConfirmation;

  const TripPlannerState({
    this.tripPlan,
    this.isLoading = false,
    this.error,
    this.bookingConfirmation,
  });

  TripPlannerState copyWith({
    TripPlanResponse? tripPlan,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? bookingConfirmation,
  }) {
    return TripPlannerState(
      tripPlan: tripPlan ?? this.tripPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bookingConfirmation: bookingConfirmation ?? this.bookingConfirmation,
    );
  }

  factory TripPlannerState.initial() {
    return const TripPlannerState();
  }

  @override
  int get hashCode =>
      tripPlan.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      bookingConfirmation.hashCode;
}

// BLOC
class TripPlannerBloc extends Bloc<TripPlannerEvent, TripPlannerState> {
  final TripPlannerRepository tripPlannerRepository;

  TripPlannerBloc({required this.tripPlannerRepository})
      : super(TripPlannerState.initial()) {
    on<GenerateTripPlan>(_onGenerateTripPlan);
    on<RefineTripPlan>(_onRefineTripPlan);
    on<ConfirmBooking>(_onConfirmBooking);
    on<ClearTripPlan>(_onClearTripPlan);
  }

  Future<void> _onGenerateTripPlan(
    GenerateTripPlan event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final tripPlan = await tripPlannerRepository.generatePlan(event.request);

      emit(state.copyWith(
        tripPlan: tripPlan,
        isLoading: false,
      ));
    } catch (e) {
      print('Error generating trip plan: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRefineTripPlan(
    RefineTripPlan event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final refinedPlan = await tripPlannerRepository.refinePlan(
        originalRequest: event.originalRequest,
        currentResults: event.currentResults,
        userMessage: event.userMessage,
      );

      emit(state.copyWith(
        tripPlan: refinedPlan,
        isLoading: false,
      ));
    } catch (e) {
      print('Error refining trip plan: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final bookingResult = await tripPlannerRepository.confirmBooking(
        optionId: event.optionId,
        outboundTransportId: event.outboundTransportId,
        returnTransportId: event.returnTransportId,
        seatsNeeded: event.seatsNeeded,
        accommodationId: event.accommodationId,
        selectedRoomAllocations: event.selectedRoomAllocations,
        checkInDate: event.checkInDate,
        checkOutDate: event.checkOutDate,
        specialRequests: event.specialRequests,
      );

      emit(state.copyWith(
        bookingConfirmation: bookingResult,
        isLoading: false,
      ));
    } catch (e) {
      print('Error confirming booking: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onClearTripPlan(
    ClearTripPlan event,
    Emitter<TripPlannerState> emit,
  ) {
    emit(TripPlannerState.initial());
  }
}
