import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideListingModel.dart';
import 'package:tour_ease/model/rideSharing/rideRequest/rideRequestModel.dart';

abstract class RideRepository {
  Future<List<RideListingModel>> fetchRidesListing(RideFilterModel filter);
  Future<RideListingModel> createRidesListing(RideListingModel rideListing);
  Future<void> createRidesRequest(TravelerRideRequestModel rideRequest);
  Future<List<TravelerRideRequestModel>> fetchRideRequests(RideFilterModel filter);
}

class RideRepositoryImpl implements RideRepository {
  final APIService apiService;

  RideRepositoryImpl({required this.apiService});

  @override
  Future<List<RideListingModel>> fetchRidesListing(RideFilterModel filter) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (filter.pickupLocationCoordinates != null) {
        final coordinates = filter.pickupLocationCoordinates!;
        queryParameters['lat'] = coordinates.latitude;
        queryParameters['lng'] = coordinates.longitude;
      }
      if (filter.numberOfTravelers > 0) {
        queryParameters['minSeats'] = filter.numberOfTravelers;
      }
      if (filter.priceRange.end > 0) {
        queryParameters['maxPrice'] = filter.priceRange.end;
      }
      if (filter.selectedDate != null) {
        final departureAfterDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.startTime.hour,
          filter.startTime.minute,
        );
        queryParameters['departureAfter'] = departureAfterDateTime.toIso8601String();

        final departureBeforeDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.endTime.hour,
          filter.endTime.minute,
        );
        queryParameters['departureBefore'] = departureBeforeDateTime.toIso8601String();
      }

      return await apiService.get<List<RideListingModel>>(
        path: "/api/searchForNearByListing",
        queryParams: queryParameters,
        fromJson: (json) => (json as List)
            .map((data) => RideListingModel.fromJson(data as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to fetch ride listings: $e');
    }
  }

  @override
  Future<RideListingModel> createRidesListing(RideListingModel rideListing) async {
    try {
      final requestData = <String, dynamic>{
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
      };
      requestData.removeWhere((key, value) => value == null);

      return await apiService.post<RideListingModel>(
        path: "/api/createRideSharingListing",
        body: requestData,
        fromJson: (json) => RideListingModel.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Failed to create ride listing: $e');
    }
  }

  @override
  Future<void> createRidesRequest(TravelerRideRequestModel rideRequest) async {
    try {
      final requestData = <String, dynamic>{
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
      requestData.removeWhere((key, value) => value == null);

      await apiService.post<void>(
        path: "/api/createRideSharingRequest",
        body: requestData,
        fromJson: (json) {},
      );
    } catch (e) {
      throw Exception('Failed to create ride request: $e');
    }
  }

  @override
  Future<List<TravelerRideRequestModel>> fetchRideRequests(RideFilterModel filter) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (filter.pickupLocationCoordinates != null) {
        final coordinates = filter.pickupLocationCoordinates!;
        queryParameters['lat'] = coordinates.latitude;
        queryParameters['lng'] = coordinates.longitude;
      }
      if (filter.numberOfTravelers > 0) {
        queryParameters['minSeats'] = filter.numberOfTravelers;
      }
      if (filter.priceRange.end > 0) {
        queryParameters['maxBudget'] = filter.priceRange.end;
      }
      if (filter.selectedDate != null) {
        final departureAfterDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.startTime.hour,
          filter.startTime.minute,
        );
        queryParameters['departureAfter'] = departureAfterDateTime.toIso8601String();

        final departureBeforeDateTime = DateTime(
          filter.selectedDate!.year,
          filter.selectedDate!.month,
          filter.selectedDate!.day,
          filter.endTime.hour,
          filter.endTime.minute,
        );
        queryParameters['departureBefore'] = departureBeforeDateTime.toIso8601String();
      }

      return await apiService.get<List<TravelerRideRequestModel>>(
        path: "/api/searchForNearByRequests",
        queryParams: queryParameters,
        fromJson: (json) => (json as List)
            .map((data) => TravelerRideRequestModel.fromJson(data as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to fetch ride requests: $e');
    }
  }
}