part of 'booking_for_provider_bloc.dart';

@immutable
sealed class BookingForProviderState {}

final class BookingForProviderInitial extends BookingForProviderState {}

final class BookingForProviderLoading extends BookingForProviderState {}

final class BookingForProviderLoadSuccess extends BookingForProviderState {
  final List<ProviderBookingModel> bookings;
  BookingForProviderLoadSuccess(this.bookings);
}

final class BookingForProviderLoadFailure extends BookingForProviderState {
  final String error;
  BookingForProviderLoadFailure(this.error);
}