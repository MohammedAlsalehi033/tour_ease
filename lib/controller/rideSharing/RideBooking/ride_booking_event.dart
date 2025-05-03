abstract class BookingEvent  {
  const BookingEvent();

}

class FetchTravelerBookingsRequested extends BookingEvent {
  final String travelerId;

  const FetchTravelerBookingsRequested({required this.travelerId});


}

class FetchProviderBookingsRequested extends BookingEvent {
  final String providerId;

  const FetchProviderBookingsRequested({required this.providerId});


}

class MarkBookingAsComplete extends BookingEvent {
  final String bookingId;

  const MarkBookingAsComplete({required this.bookingId});


}