import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerRepository.dart';

// EVENTS
abstract class TripPlannerEvent {
  const TripPlannerEvent();
}

class GenerateTripPlan extends TripPlannerEvent {
  final TripSearchParams request;

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
  final BookingRequest request;

  const ConfirmBooking({required this.request});
}

class SaveTripPlan extends TripPlannerEvent {
  final SavePlanRequest request;

  const SaveTripPlan({required this.request});
}

class GetSavedPlans extends TripPlannerEvent {
  final String? status;
  final String? tag;
  final String? sortBy;
  final String? order;

  const GetSavedPlans({
    this.status,
    this.tag,
    this.sortBy,
    this.order,
  });
}

class DeleteSavedPlan extends TripPlannerEvent {
  final int planId;

  const DeleteSavedPlan({required this.planId});
}

class ClearTripPlan extends TripPlannerEvent {}

// STATE
class TripPlannerState {
  final TripPlannerResponse? tripPlan;
  final TripSearchParams? originalRequest;
  final bool isLoading;
  final String? error;
  final BookingConfirmation? bookingConfirmation;
  final SavedPlan? savedPlan;
  final List<SavedPlan>? savedPlans;

  const TripPlannerState({
    this.tripPlan,
    this.originalRequest,
    this.isLoading = false,
    this.error,
    this.bookingConfirmation,
    this.savedPlan,
    this.savedPlans,
  });

  TripPlannerState copyWith({
    TripPlannerResponse? tripPlan,
    TripSearchParams? originalRequest,
    bool? isLoading,
    String? error,
    BookingConfirmation? bookingConfirmation,
    SavedPlan? savedPlan,
    List<SavedPlan>? savedPlans,
  }) {
    return TripPlannerState(
      tripPlan: tripPlan ?? this.tripPlan,
      originalRequest: originalRequest ?? this.originalRequest,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bookingConfirmation: bookingConfirmation ?? this.bookingConfirmation,
      savedPlan: savedPlan ?? this.savedPlan,
      savedPlans: savedPlans ?? this.savedPlans,
    );
  }

  factory TripPlannerState.initial() {
    return const TripPlannerState();
  }

  @override
  int get hashCode =>
      tripPlan.hashCode ^
      originalRequest.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      bookingConfirmation.hashCode ^
      savedPlan.hashCode ^
      savedPlans.hashCode;
}

// BLOC
class TripPlannerBloc extends Bloc<TripPlannerEvent, TripPlannerState> {
  final TripPlannerRepository tripPlannerRepository;

  TripPlannerBloc({required this.tripPlannerRepository})
      : super(TripPlannerState.initial()) {
    on<GenerateTripPlan>(_onGenerateTripPlan);
    on<RefineTripPlan>(_onRefineTripPlan);
    on<ConfirmBooking>(_onConfirmBooking);
    on<SaveTripPlan>(_onSaveTripPlan);
    on<GetSavedPlans>(_onGetSavedPlans);
    on<DeleteSavedPlan>(_onDeleteSavedPlan);
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
        originalRequest: event.request,
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
      final bookingResult = await tripPlannerRepository.confirmBooking(event.request);

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

  Future<void> _onSaveTripPlan(
    SaveTripPlan event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final savedPlan = await tripPlannerRepository.savePlan(event.request);

      emit(state.copyWith(
        savedPlan: savedPlan,
        isLoading: false,
      ));
    } catch (e) {
      print('Error saving trip plan: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onGetSavedPlans(
    GetSavedPlans event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final savedPlans = await tripPlannerRepository.getSavedPlans(
        status: event.status,
        tag: event.tag,
        sortBy: event.sortBy,
        order: event.order,
      );

      emit(state.copyWith(
        savedPlans: savedPlans,
        isLoading: false,
      ));
    } catch (e) {
      print('Error fetching saved plans: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteSavedPlan(
    DeleteSavedPlan event,
    Emitter<TripPlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await tripPlannerRepository.deleteSavedPlan(event.planId);

      // Refresh the list after deletion
      final savedPlans = await tripPlannerRepository.getSavedPlans();

      emit(state.copyWith(
        savedPlans: savedPlans,
        isLoading: false,
      ));
    } catch (e) {
      print('Error deleting saved plan: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
