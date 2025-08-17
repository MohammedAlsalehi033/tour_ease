import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBooking.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBookingRepo.dart';

part 'booking_for_traveler_event.dart';
part 'booking_for_traveler_state.dart';

class BookingForTravelerBloc extends Bloc<BookingForTravelerEvent, BookingForTravelerState> {
  final BookingRepository _bookingRepository;

  BookingForTravelerBloc(this._bookingRepository) : super(BookingForTravelerInitial()) {
    on<BookingForTravelerEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<FetchTravelerBookingsRequested>(_onFetchTravelerBookingsRequested);


  }

  Future<void> _onFetchTravelerBookingsRequested(
      FetchTravelerBookingsRequested event,
      Emitter<BookingForTravelerState> emit,
      ) async {
    emit(BookingForTravelerLoading());
    try {
      final bookings = await _bookingRepository.fetchTravelerBookings(event.travelerId.toString());
      emit(BookingForTravelerLoadSuccess(bookings));
    } catch (e) {
      emit(BookingForTravelerLoadFailure(e.toString()));
    }
  }
}
