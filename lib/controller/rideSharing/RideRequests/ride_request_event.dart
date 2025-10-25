part of 'ride_request_bloc.dart';

@immutable
sealed class RideRequestEvent {}

// Event to trigger the creation of a new ride request
class CreateRideRequest extends RideRequestEvent {
  // Using TravelerRideRequestModel directly might be cleaner if all data is available upfront
  // Or keep individual fields if they come from different UI parts
  final String startLocationText;
  final String endLocationText;
  final double? startLocationLat; // Made nullable if sometimes unavailable
  final double? startLocationLng; // Made nullable
  final double? endLocationLat;   // Made nullable
  final double? endLocationLng;   // Made nullable
  final DateTime departureTime;
  final int seatsNeeded;
  final double budget;
  final int luggageCount;

  CreateRideRequest({
    required this.startLocationText,
    required this.endLocationText,
    this.startLocationLat,
    this.startLocationLng,
    this.endLocationLat,
    this.endLocationLng,
    required this.departureTime,
    required this.seatsNeeded,
    required this.budget,
    this.luggageCount = 0,
  });
}

// Event to trigger fetching ride requests based on filter criteria
class FetchRideRequests extends RideRequestEvent {
  final RideFilterModel filter; // Pass the complete filter model

  FetchRideRequests({required this.filter});
}