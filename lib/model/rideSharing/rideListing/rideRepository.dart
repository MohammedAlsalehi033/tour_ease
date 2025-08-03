import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Keep for RangeValues if used in RideFilterModel
import 'package:tour_ease/Services/ApiService.dart'; // Assuming APIService is defined here
import 'package:tour_ease/model/rideSharing/RideFilterData.dart'; // Assuming RideFilterModel is defined here
import 'package:tour_ease/model/rideSharing/rideListing/rideListingModel.dart';
import 'package:tour_ease/model/rideSharing/rideRequest/rideRequestModel.dart'; // For existing methods

abstract class RideRepository {
  Future<List<RideListingModel>> fetchRidesListing(RideFilterModel filter);

  Future<RideListingModel> createRidesListing(RideListingModel rideListing);

  Future<void> createRidesRequest(TravelerRideRequestModel rideRequest); // Use TravelerRideRequestModel for creation if needed, or a dedicated creation model

  Future<List<TravelerRideRequestModel>> fetchRideRequests(RideFilterModel filter); // Added method signature
}

class RideRepositoryImpl implements RideRepository {
  final APIService apiService;
  final String baseUrl;
  final Dio dio = Dio();

  RideRepositoryImpl({required this.apiService}) : baseUrl = apiService.baseUrl;

  @override
  Future<List<RideListingModel>> fetchRidesListing(
      RideFilterModel filter) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      if (filter.pickupLocationCoordinates != null) {
        final coordinates = filter.pickupLocationCoordinates!;
        queryParameters['lat'] = coordinates.latitude;
        queryParameters['lng'] = coordinates.longitude;
      }

      // Add minimum seats filter
      if (filter.numberOfTravelers > 0) {
        queryParameters['minSeats'] = filter.numberOfTravelers;
      }

      // Add maximum price filter
      if (filter.priceRange.end > 0) {
        queryParameters['maxPrice'] = filter.priceRange.end;
      }

      // Add departure time window filter
      if (filter.selectedDate != null) {
        final departureAfterDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.startTime.hour,
          filter.startTime.minute,
        );
        queryParameters['departureAfter'] =
            departureAfterDateTime.toIso8601String();

        final departureBeforeDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.endTime.hour,
          filter.endTime.minute,
        );
        queryParameters['departureBefore'] =
            departureBeforeDateTime.toIso8601String();
      }

      // Make the GET request to the ride listing endpoint
      // Example URL was hardcoded, using queryParameters now
      final response = await dio.get(
        "$baseUrl/api/searchForNearByListing",
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null, // Pass parameters if any
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final responseData = response.data;
        // Validate response structure
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> ridesData = responseData['data'];
          // Parse the list of ride listings
          return ridesData
              .map((data) =>
              RideListingModel.fromJson(data as Map<String, dynamic>))
              .toList();
        } else {
          final errorMessage = responseData['error'] ??
              'Backend returned success=false or invalid data format for listings.';
          throw Exception('Failed to fetch ride listings: $errorMessage');
        }
      } else {
        throw Exception(
            'Failed to fetch ride listings: Server returned status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      print("DioError fetching ride listings: ${e.message}");
      print("DioError response: ${e.response?.data}");
      throw Exception('Failed to fetch ride listings: ${e.message}');
    } catch (e) {
      // Handle other potential errors
      print("Error fetching ride listings: $e");
      throw Exception('Failed to fetch ride listings: $e');
    }
  }

  // Implementation to create a ride listing
  @override
  Future<RideListingModel> createRidesListing(
      RideListingModel rideListing) async {
    try {
      // Prepare the request data from the RideListingModel
      final Map<String, dynamic> requestData = {
        // Ensure all required fields for creation are included
        'providerId': rideListing.providerId,
        'startLocationText': rideListing.startLocationText,
        'endLocationText': rideListing.endLocationText,
        'departureTime': rideListing.departureTime.toIso8601String(),
        'pricePerSeat': rideListing.pricePerSeat,
        'seatsAvailable': rideListing.seatsAvailable,
        'startLocationLat': rideListing.startLocationLat,
        'startLocationLng': rideListing.startLocationLng,
        'endLocationLat': rideListing.endLocationLat,
        'endLocationLng': rideListing.endLocationLng,
        // 'mediaUrls': rideListing.mediaUrls, // Uncomment if needed
        // 'status': rideListing.status, // Usually set by backend
      };
      // Remove null values to avoid sending them if the API doesn't expect them
      requestData.removeWhere((key, value) => value == null);


      // Make the POST request to create a ride listing
      final response = await dio.post(
        "$baseUrl/api/createRideSharingListing",
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Check for successful creation (usually 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        // Validate response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // Parse the created ride listing data
          return RideListingModel.fromJson(responseData['data']);
        } else {
          final errorMessage = responseData['error'] ??
              'Backend returned success=false or invalid data format on listing creation.';
          throw Exception('Failed to create ride listing: $errorMessage');
        }
      } else {
        throw Exception(
            'Failed to create ride listing: Server returned status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      print("DioError creating ride listing: ${e.message}");
      print("DioError response: ${e.response?.data}");
      throw Exception('Failed to create ride listing: ${e.message}');
    } catch (e) {
      // Handle other potential errors
      print("Error creating ride listing: $e");
      throw Exception('Failed to create ride listing: $e');
    }
  }

  // Implementation to create a ride request
  // Consider using a dedicated model for creation if fields differ significantly
  @override
  Future<void> createRidesRequest(TravelerRideRequestModel rideRequest) async { // Parameter type updated
    try {

      final Map<String, dynamic> requestData = {
        'travelerId': rideRequest.travelerId,
        'startLocationText': rideRequest.startLocationText,
        'endLocationText': rideRequest.endLocationText,
        'departureTime': rideRequest.departureTime.toIso8601String(),
        'budget': rideRequest.budget,
        'seatsNeeded': rideRequest.seatsNeeded,
        'startLocationLat': rideRequest.startLocationLat,
        'startLocationLng': rideRequest.startLocationLng,
        'endLocationLat': rideRequest.endLocationLat,
        'endLocationLng': rideRequest.endLocationLng,
      };
      // Remove null values
      requestData.removeWhere((key, value) => value == null);

      print("Creating Ride Request with data: $requestData"); // Log request data

      // Make the POST request to create a ride request
      final response = await dio.post(
        "$baseUrl/api/createRideSharingRequest",
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );


      // Check for successful creation
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        // Validate response structure
        if (responseData['success'] == true) {
          print("Ride request created successfully: $responseData");
          return; // Indicate success
        } else {
          final errorMessage = responseData['error'] ??
              'Backend returned success=false on request creation.';
          throw Exception('Failed to create ride request: $errorMessage');
        }
      } else {
        throw Exception(
            'Failed to create ride request: Server returned status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      print("DioError creating ride request: ${e.message}");
      print("DioError response: ${e.response?.data}");
      // Provide more specific error message if possible
      String errorMsg = e.response?.data?['error'] ?? e.message ?? 'Unknown Dio error';
      throw Exception('Failed to create ride request: $errorMsg');
    } catch (e) {
      // Handle other potential errors
      print("Error creating ride request: $e");
      throw Exception('Failed to create ride request: $e');
    }
  }


  // --- NEW METHOD ---
  // Implementation to fetch ride requests
  @override
  Future<List<TravelerRideRequestModel>> fetchRideRequests(
      RideFilterModel filter) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      // --- Filter Parameters ---
      // Location and Radius (Mandatory for the example endpoint)
      if (filter.pickupLocationCoordinates != null) {
        final coordinates = filter.pickupLocationCoordinates!;
        queryParameters['lat'] = coordinates.latitude;
        queryParameters['lng'] = coordinates.longitude;
        // **IMPORTANT**: Add radiusKm. Using a default or from filter.
        // Let's assume filter has a radiusKm property or use a default.
      } else {
        // Handle case where location is required but not provided
        // Option 1: Throw error
        // throw Exception('Pickup location coordinates are required to fetch ride requests.');
        // Option 2: Use default coordinates (less ideal)
        // queryParameters['lat'] = 33.7197; // Default example
        // queryParameters['lng'] = 73.0440; // Default example
        // queryParameters['radiusKm'] = 50; // Default example
        // Choose the appropriate handling based on your app's logic
        print("Warning: Fetching ride requests without specific coordinates.");
      }


      // Seats Needed (Optional)
      if (filter.numberOfTravelers > 0) {
        // Assuming the API parameter is 'minSeats' or similar based on listing search
        // Adjust if the parameter name for requests is different (e.g., 'seatsNeeded')
        queryParameters['minSeats'] = filter.numberOfTravelers;
      }

      // Budget (Optional - Max Budget)
      if (filter.priceRange.end > 0) {
        // Assuming the API parameter is 'maxBudget'
        queryParameters['maxBudget'] = filter.priceRange.end;
      }

      // Departure Time Window (Optional)
      if (filter.selectedDate != null) {
        final departureAfterDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.startTime.hour,
          filter.startTime.minute,
        );
        queryParameters['departureAfter'] =
            departureAfterDateTime.toIso8601String();

        final departureBeforeDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.endTime.hour,
          filter.endTime.minute,
        );
        queryParameters['departureBefore'] =
            departureBeforeDateTime.toIso8601String();
      }
      // --- End Filter Parameters ---


      print("Fetching Ride Requests with params: $queryParameters"); // Log parameters

      // Make the GET request to the ride request search endpoint
      final response = await dio.get(
        "$baseUrl/api/searchForNearByRequests", // Endpoint for requests
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("Raw Response Data for Requests: $responseData"); // Log raw response

        // Validate response structure - Use the static parser from the model
        // Assuming parseApiResponse handles the {'success': true, 'data': [...]} structure
        // If the API returns just the list directly, adjust the parser accordingly.
        // The parser provided earlier handles both list and wrapped structure.
        return TravelerRideRequestModel.parseApiResponse(responseData);

      } else {
        throw Exception(
            'Failed to fetch ride requests: Server returned status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      print("DioError fetching ride requests: ${e.message}");
      print("DioError response: ${e.response?.data}");
      String errorMsg = e.response?.data?['error'] ?? e.message ?? 'Unknown Dio error';
      throw Exception('Failed to fetch ride requests: $errorMsg');
    } catch (e, stacktrace) {
      // Handle other potential errors, including parsing errors
      print("Error fetching ride requests: $e");
      print("Stacktrace: $stacktrace"); // Print stacktrace for debugging parsing issues
      throw Exception('Failed to fetch ride requests: An unexpected error occurred. $e');
    }
  }
}
