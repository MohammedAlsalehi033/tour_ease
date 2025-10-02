import 'package:tour_ease/model/rideSharing/RideBooking/RideBooking.dart';
import 'package:tour_ease/Services/ApiService.dart';

abstract class BookingRepository {
  /// Fetches bookings for a specific traveler.
  Future<List<TravelerBookingModel>> fetchTravelerBookings(String travelerId);

  /// Fetches bookings for a specific provider.
  Future<List<ProviderBookingModel>> fetchProviderBookings(String providerId);

  Future<void> markBookingAsComplete(String bookingId);
  
  Future<void> cancelBooking(String bookingId);
}

class BookingRepositoryImpl implements BookingRepository {
  final APIService apiService;

  BookingRepositoryImpl({required this.apiService});

  @override
  Future<List<TravelerBookingModel>> fetchTravelerBookings(String travelerId) async {
    try {
      return await apiService.get<List<TravelerBookingModel>>(
        path: '/api/booking/traveler/$travelerId',
        fromJson: (json) => TravelerBookingModel.parseBookingList(json),
      );
    } catch (e) {
      throw Exception('Failed to fetch traveler bookings: $e');
    }
  }

  @override
  Future<List<ProviderBookingModel>> fetchProviderBookings(String providerId) async {
    try {
      return await apiService.get<List<ProviderBookingModel>>(
        path: '/api/booking/provider/$providerId',
        fromJson: (json) => ProviderBookingModel.parseBookingList(json),
      );
    } catch (e) {
      throw Exception('Failed to fetch provider bookings: $e');
    }
  }

  @override
  Future<void> markBookingAsComplete(String bookingId) async {
    try {
      await apiService.post<void>(
        path: '/api/booking/status?bookingId=$bookingId&status=complete',
        body: {},
        fromJson: (json) {},
      );
    } catch (e) {
      throw Exception('Failed to mark booking as complete: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await apiService.post<void>(
        path: '/api/booking/status?bookingId=$bookingId&status=cancelled',
        body: {},
        fromJson: (json) {},
      );
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
}