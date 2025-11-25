import '../../Services/ApiService.dart';
import '../../model/accommodation/accommodation_model.dart';
import '../../model/accommodation/booking_model.dart' hide Room, Accommodation;

class AccommodationService {
  final APIService _apiService;

  AccommodationService(this._apiService);

  /// Get all accommodations with optional filters
  /// Supports: page, pageSize, location, minPrice, maxPrice
  Future<List<Accommodation>> getAllAccommodations({
    int page = 1,
    int pageSize = 10,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice;
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice;
    }

    return await _apiService.get(
      path: '/accommodations',
      queryParams: queryParams,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Accommodation.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Search accommodations by location
  Future<List<Accommodation>> searchAccommodations({
    required String location,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _apiService.get(
      path: '/accommodations/search',
      queryParams: {
        'location': location,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Accommodation.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Get accommodation by ID with rooms
  Future<Accommodation?> getAccommodationById(int accommodationId) async {
    try {
      return await _apiService.get(
        path: '/accommodations/$accommodationId',
        fromJson: (json) => Accommodation.fromJson(json),
      );
    } catch (e) {
      print('Error getting accommodation: $e');
      return null;
    }
  }

  /// Get rooms for a specific accommodation
  Future<List<Room>> getRoomsByAccommodationId(int accommodationId) async {
    return await _apiService.get(
      path: '/rooms',
      queryParams: {
        'accommodationId': accommodationId,
      },
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => Room.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Search available rooms with date and capacity filters
  /// Uses production API with booking conflict detection
  Future<List<Room>> searchAvailableRooms({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? capacity,
  }) async {
    final queryParams = <String, dynamic>{
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
    };

    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice;
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice;
    }
    if (capacity != null) {
      queryParams['capacity'] = capacity;
    }

    try {
      print('🔍 Calling searchAvailableRooms (PRODUCTION) with dates: ${checkInDate.toIso8601String()} to ${checkOutDate.toIso8601String()}');
      
      final List<Room> result = await _apiService.get<List<Room>>(
        path: '/rooms/search/available',
        queryParams: queryParams,
        fromJson: (json) {
          if (json is List) {
            print('✅ Got ${json.length} available rooms from production API');
            return json.map((item) => Room.fromJson(item)).toList();
          }
          print('⚠️ API returned non-list response');
          return <Room>[];
        },
      );
      
      return result;
    } catch (e) {
      print('❌ Error in searchAvailableRooms: $e');
      rethrow;
    }
  }

  /// Create a booking
  Future<AccommodationBooking> createBooking({
    required String travelerId,
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPrice,
  }) async {
    return await _apiService.post(
      path: '/accommodation-bookings',
      body: {
        'travelerId': travelerId,
        'roomId': roomId,
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate.toIso8601String(),
        'totalPrice': totalPrice,
      },
      fromJson: (json) => AccommodationBooking.fromJson(json['data']),
    );
  }

  /// Get traveler's bookings
  Future<List<AccommodationBooking>> getTravelerBookings({
    required String travelerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _apiService.get(
      path: '/accommodation-bookings/traveler/$travelerId',
      queryParams: {
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => AccommodationBooking.fromJson(item))
              .toList();
        }
        return [];
      },
    );
  }

  /// Confirm booking after payment
  Future<AccommodationBooking> confirmBooking({
    required int bookingId,
    required int paymentId,
  }) async {
    return await _apiService.post(
      path: '/accommodation-bookings/$bookingId/confirm',
      body: {
        'paymentId': paymentId,
      },
      fromJson: (json) => AccommodationBooking.fromJson(json['data']),
    );
  }

  /// Cancel booking (before payment)
  Future<AccommodationBooking> cancelUnpaidBooking(int bookingId) async {
    return await _apiService.post(
      path: '/accommodation-bookings/$bookingId/cancel-unpaid',
      body: {},
      fromJson: (json) => AccommodationBooking.fromJson(json['data']),
    );
  }

  /// Request refund (after payment)
  Future<AccommodationBooking> requestRefund(int bookingId) async {
    return await _apiService.post(
      path: '/accommodation-bookings/$bookingId/refund',
      body: {},
      fromJson: (json) => AccommodationBooking.fromJson(json['data']),
    );
  }

  /// Create payment
  Future<Payment> createPayment({
    required int accommodationBookingId,
    required double amount,
    required String paymentMethod,
    required String transactionId,
    String status = 'completed',
  }) async {
    return await _apiService.post(
      path: '/payments',
      body: {
        'accommodationBookingId': accommodationBookingId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'status': status,
      },
      fromJson: (json) => Payment.fromJson(json['data']),
    );
  }
}
