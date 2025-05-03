import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // For ListEquality

// Assuming these models and repository are correctly imported
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideRepository.dart';
import 'package:tour_ease/model/rideSharing/rideRequest/rideRequestModel.dart';
import 'package:tour_ease/model/userManagment/user.dart'; // Assuming RideRepository is defined here
// import 'package:tour_ease/model/userManagment/user.dart'; // Assuming UserModel exists and provides ID

part 'ride_request_event.dart';
part 'ride_request_state.dart';

class RideRequestBloc extends Bloc<RideRequestEvent, RideRequestState> {
  final RideRepository rideRepository;

  RideRequestBloc({required this.rideRepository}) : super(RideRequestInitial()) {

    // Handler for Creating a Ride Request
    on<CreateRideRequest>((event, emit) async { // Make handler async
      emit(RideRequestLoading());
      try {

        TravelerRideRequestModel rideRequestModel = TravelerRideRequestModel(
          startLocationLng: event.startLocationLng,
          startLocationLat: event.startLocationLat,
          endLocationLng: event.endLocationLng,
          endLocationLat: event.endLocationLat,
          startLocationText: event.startLocationText,
          endLocationText: event.endLocationText,
          departureTime: event.departureTime,
          budget: event.budget,
          seatsNeeded: event.seatsNeeded,
          id: 0, // Usually assigned by backend
          travelerId: UserModel().id, // Get actual user ID from auth state/service
          createdAt: DateTime.now(), // Usually set by backend
          distanceKm: null, // Usually calculated by backend
        );

        print("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv: $rideRequestModel"); // Log error
        await rideRepository.createRidesRequest(rideRequestModel);

        // Emit success *after* the operation completes successfully
        emit(RideRequestCreationSuccess());

      } catch (e) {
        print("Error creating ride request: $e"); // Log error
        emit(RideRequestError(error: "Failed to create ride request: ${e.toString()}"));
      }
    });

    // Handler for Fetching Ride Requests
    on<FetchRideRequests>((event, emit) async { // Make handler async
      emit(RideRequestLoading());
      try {
        // Call the repository method with the filter from the event
        final List<TravelerRideRequestModel> requests =
        await rideRepository.fetchRideRequests(event.filter);

        // Emit the loaded state with the fetched data
        emit(RideRequestLoaded(rideRequests: requests));

      } catch (e) {
        print("Error fetching ride requests: $e"); // Log error
        // Emit error state
        emit(RideRequestError(error: "Failed to fetch ride requests: ${e.toString()}"));
      }
    });
  }
}