// file: bloc/booking/booking_state.dart

import 'package:tour_ease/model/rideSharing/RideBooking/RideBooking.dart';

abstract class BookingState  {
  const BookingState();


}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

// class TravelerBookingLoadSuccess extends BookingState {
//   final List<TravelerBookingModel> travelerBookings;
//
//   const TravelerBookingLoadSuccess(this.travelerBookings);
//
//
// }

// class ProviderBookingLoadSuccess extends BookingState {
//   final List<ProviderBookingModel> providerBookings;
//
//   const ProviderBookingLoadSuccess(this.providerBookings);
//
//   @override
//   List<Object> get props => [providerBookings];
// }

class BookingLoadFailure extends BookingState {
  final String error;

  const BookingLoadFailure(this.error);

}