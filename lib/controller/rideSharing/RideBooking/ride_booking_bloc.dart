// file: bloc/booking/booking_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_event.dart';
import 'package:tour_ease/controller/rideSharing/RideBooking/ride_booking_state.dart';
import 'package:tour_ease/model/rideSharing/RideBooking/RideBookingRepo.dart';



class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(BookingInitial()) { // Set initial state
    // Register event handlers
    on<FetchTravelerBookingsRequested>(_onFetchTravelerBookingsRequested);
    on<FetchProviderBookingsRequested>(_onFetchProviderBookingsRequested);
    on<MarkBookingAsComplete>((event, emit) async{
      emit(BookingLoading());
      try{
        final bookings = await _bookingRepository.markBookingAsComplete(event.bookingId);
      }catch(e){


      }
    },);
  }

  // Handler for FetchTravelerBookingsRequested event
  Future<void> _onFetchTravelerBookingsRequested(
      FetchTravelerBookingsRequested event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading()); // Indicate loading start
    try {
      final bookings = await _bookingRepository.fetchTravelerBookings(event.travelerId.toString());
      emit(TravelerBookingLoadSuccess(bookings)); // Emit success with data
    } catch (e) {
      emit(BookingLoadFailure(e.toString())); // Emit failure with error
    }
  }

  // Handler for FetchProviderBookingsRequested event
  Future<void> _onFetchProviderBookingsRequested(
      FetchProviderBookingsRequested event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading()); // Indicate loading start
    try {
      final bookings = await _bookingRepository.fetchProviderBookings(event.providerId);
      emit(ProviderBookingLoadSuccess(bookings)); // Emit success with data
    } catch (e) {
      emit(BookingLoadFailure(e.toString())); // Emit failure with error
    }
  }
}