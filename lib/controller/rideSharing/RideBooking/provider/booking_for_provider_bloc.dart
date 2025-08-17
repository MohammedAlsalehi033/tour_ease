import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBooking.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBookingRepo.dart';

part 'booking_for_provider_event.dart';
part 'booking_for_provider_state.dart';

class BookingForProviderBloc extends Bloc<BookingForProviderEvent, BookingForProviderState> {
  final BookingRepository _bookingRepository;

  BookingForProviderBloc(this._bookingRepository) : super(BookingForProviderInitial()) {
    on<BookingForProviderEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<FetchProviderBookingsRequested>(_onFetchProviderBookingsRequested);
  }
  Future<void> _onFetchProviderBookingsRequested(
      FetchProviderBookingsRequested event,
      Emitter<BookingForProviderState> emit,
      ) async {
    emit(BookingForProviderLoading()); // Indicate loading start
    try {
      final bookings = await _bookingRepository.fetchProviderBookings(event.providerId);
      emit(BookingForProviderLoadSuccess(bookings)); // Emit success with data
    } catch (e) {
      emit(BookingForProviderLoadFailure(e.toString())); // Emit failure with error
    }
  }
}
