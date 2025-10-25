part of 'booking_for_provider_bloc.dart';

@immutable
sealed class BookingForProviderEvent {}

class FetchProviderBookingsRequested extends BookingForProviderEvent {
  final String providerId;

  FetchProviderBookingsRequested(this.providerId);
}


