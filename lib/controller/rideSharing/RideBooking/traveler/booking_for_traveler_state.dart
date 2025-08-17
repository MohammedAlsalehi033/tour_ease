part of 'booking_for_traveler_bloc.dart';

@immutable
sealed class BookingForTravelerState {}

final class BookingForTravelerInitial extends BookingForTravelerState {}

final class BookingForTravelerLoading extends BookingForTravelerState {}

final class BookingForTravelerLoadSuccess extends BookingForTravelerState {
  final List<TravelerBookingModel> bookings;
  BookingForTravelerLoadSuccess(this.bookings);
}

final class BookingForTravelerLoadFailure extends BookingForTravelerState {
  final String error;
  BookingForTravelerLoadFailure(this.error);
}
