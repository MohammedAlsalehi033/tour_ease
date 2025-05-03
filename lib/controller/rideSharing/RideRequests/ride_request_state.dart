part of 'ride_request_bloc.dart';

@immutable
sealed class RideRequestState {}

// Initial state before any action
final class RideRequestInitial extends RideRequestState {}

// State indicating an operation is in progress
final class RideRequestLoading extends RideRequestState {}

// State indicating an error occurred during an operation
final class RideRequestError extends RideRequestState {
  final String error;

  RideRequestError({required this.error});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideRequestError && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

// State indicating successful creation of a ride request
final class RideRequestCreationSuccess extends RideRequestState {}

// State indicating successful fetching of ride requests, holding the data
final class RideRequestLoaded extends RideRequestState {
  final List<TravelerRideRequestModel> rideRequests;

  RideRequestLoaded({required this.rideRequests});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // Consider using collection equality if order doesn't matter
    return other is RideRequestLoaded &&
        ListEquality().equals(other.rideRequests, rideRequests);
  }

  @override
  int get hashCode => ListEquality().hash(rideRequests);
}