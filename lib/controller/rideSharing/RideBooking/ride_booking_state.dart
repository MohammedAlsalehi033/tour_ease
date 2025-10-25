// file: bloc/booking/booking_state.dart


abstract class BookingState  {
  const BookingState();


}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingMarkedComplete extends BookingState {
  final int bookingId;
  BookingMarkedComplete(this.bookingId);
}

class BookingCancelled extends BookingState {
  final int bookingId;
  BookingCancelled(this.bookingId);
}

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