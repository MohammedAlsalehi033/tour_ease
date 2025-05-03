import 'package:tour_ease/model/rideSharing/RideBooking/RideBooking.dart';
import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';




abstract class BookingRepository {
  /// Fetches bookings for a specific traveler.
  Future<List<TravelerBookingModel>> fetchTravelerBookings(String travelerId);

  /// Fetches bookings for a specific provider.
  Future<List<ProviderBookingModel>> fetchProviderBookings(String providerId);

  Future<void> markBookingAsComplete(String bookingId);
}



class BookingRepositoryImpl implements BookingRepository {
  final Dio dio;
  final String baseUrl;

  BookingRepositoryImpl({required APIService apiService})
      : baseUrl = apiService.baseUrl,
        dio = Dio();

  @override
  Future<List<TravelerBookingModel>> fetchTravelerBookings(
      String travelerId) async {
    final String url = "$baseUrl/api/booking/traveler/$travelerId";
    try {
      final response = await dio.get(url);
      print(response);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print("Raw response for Traveler Bookings: $responseData");

        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is List) {
          final List<dynamic> bookingsData = responseData['data'];
          return TravelerBookingModel.parseBookingList(bookingsData);
        }
        else if (responseData is List) {
          return TravelerBookingModel.parseBookingList(responseData);
        }
        else {
          final errorMessage = responseData is Map<String, dynamic>
              ? responseData['error'] ?? 'Invalid response structure for traveler bookings.'
              : 'Invalid response structure for traveler bookings.';
          print("Error: $errorMessage");
          throw Exception('Failed to fetch traveler bookings: $errorMessage');
        }
      } else {
        print("Error fetching traveler bookings: Status code ${response.statusCode}");
        throw Exception(
            'Failed to fetch traveler bookings: Server returned status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioError fetching traveler bookings: ${e.message}");
      print("DioError response: ${e.response?.data}");
      String errorMsg = e.response?.data?['error'] ?? e.message ?? 'Unknown Dio error';
      throw Exception('Failed to fetch traveler bookings: $errorMsg');
    } catch (e, stacktrace) {
      print("Error fetching traveler bookings: $e");
      print("Stacktrace: $stacktrace");
      throw Exception('Failed to fetch traveler bookings: An unexpected error occurred. $e');
    }
  }

  @override
  Future<List<ProviderBookingModel>> fetchProviderBookings(
      String providerId) async {
    final String url = "$baseUrl/api/booking/provider/$providerId";
    print("Fetching provider bookings from: $url");

    try {
      final response = await dio.get(url);

      print("objectsdaffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("Raw response for Provider Bookings: $responseData");

        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] is List) {
          final List<dynamic> bookingsData = responseData['data'];
          return ProviderBookingModel.parseBookingList(bookingsData);
        }
        else if (responseData is List) {
          return ProviderBookingModel.parseBookingList(responseData);
        }
        else {
          final errorMessage = responseData is Map<String, dynamic>
              ? responseData['error'] ?? 'Invalid response structure for provider bookings.'
              : 'Invalid response structure for provider bookings.';
          print("Error: $errorMessage");
          throw Exception('Failed to fetch provider bookings: $errorMessage');
        }
      } else {
        print("Error fetching provider bookings: Status code ${response.statusCode}");
        throw Exception(
            'Failed to fetch provider bookings: Server returned status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioError fetching provider bookings: ${e.message}");
      print("DioError response: ${e.response?.data}");
      String errorMsg = e.response?.data?['error'] ?? e.message ?? 'Unknown Dio error';
      throw Exception('Failed to fetch provider bookings: $errorMsg');
    } catch (e, stacktrace) {
      print("Error fetching provider bookings: $e");
      print("Stacktrace: $stacktrace");
      throw Exception('Failed to fetch provider bookings: An unexpected error occurred. $e');
    }
  }

  @override
  Future<void> markBookingAsComplete(String bookingId)async {
      final String url = "$baseUrl/api/booking/status?bookingId=$bookingId&status=complete";
      print(url);
      try {
        final response = await dio.post(url);
        print(response);
          final responseData = response.data;



      } on DioException catch (e) {
        print("DioError fetching traveler bookings: ${e.message}");
        print("DioError response: ${e.response?.data}");
        String errorMsg = e.response?.data?['error'] ?? e.message ?? 'Unknown Dio error';
        throw Exception('Failed to fetch traveler bookings: $errorMsg');
      } catch (e, stacktrace) {
        print("Error fetching traveler bookings: $e");
        print("Stacktrace: $stacktrace");
        throw Exception('Failed to fetch traveler bookings: An unexpected error occurred. $e');
      }
    }


}