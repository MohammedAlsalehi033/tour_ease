part of 'booking_for_traveler_bloc.dart';

@immutable
sealed class BookingForTravelerEvent {}

class FetchTravelerBookingsRequested extends BookingForTravelerEvent {
  final String travelerId;
  FetchTravelerBookingsRequested(this.travelerId);

}
