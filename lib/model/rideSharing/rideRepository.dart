import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:tour_ease/model/rideSharing/RideFilterData.dart';
import 'package:tour_ease/model/rideSharing/rideModel.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;


abstract class RideRepository {
  Future<List<Ride>> fetchRides(RideFilterModel filter);
}

class RideRepositoryImpl implements RideRepository {
  final ApiService apiService;

  RideRepositoryImpl({required this.apiService});

  @override
  Future<List<Ride>> fetchRides(RideFilterModel filter) async {
    try {
      final Map<String, dynamic> params = {
        'date': filter.selectedDate?.toIso8601String(),
        'start_time': '${filter.startTime.hour}:${filter.startTime.minute}',
        'end_time': '${filter.endTime.hour}:${filter.endTime.minute}',
        'travelers': filter.numberOfTravelers,
        'luggage': filter.luggageCapacity,
        'pickup': filter.pickupLocation,
        'destination': filter.destination,
        'min_price': filter.priceRange.start,
        'max_price': filter.priceRange.end,
      };

      final response = await apiService.get('/rides', params: params);
      final List ridesData = response['rides'];
      return ridesData.map((data) => Ride.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rides: $e');
    }
  }
}




class ApiService {
  final String baseUrl;
  final Duration latency;
  final Random _random = Random();

  final List<Map<String, dynamic>> _mockRides = [
    {
      'id': '1',
      'driver': {
        'name': 'John Doe',
        'rating': 4.8,
        'profileImage': 'https://example.com/driver1.jpg'
      },
      'vehicle': {
        'model': 'Toyota Camry',
        'color': 'Black',
        'plateNumber': 'ABC123'
      },
      'price': 35.50,
      'pickup': 'Downtown Station',
      'destination': 'Airport Terminal 2',
      'departureTime': '2025-03-10T14:30:00Z',
      'availableSeats': 3,
      'availableLuggage': 2,
    },
    {
      'id': '2',
      'driver': {
        'name': 'Jane Smith',
        'rating': 4.9,
        'profileImage': 'https://example.com/driver2.jpg'
      },
      'vehicle': {
        'model': 'Honda Accord',
        'color': 'Silver',
        'plateNumber': 'XYZ789'
      },
      'price': 42.00,
      'pickup': 'Central Mall',
      'destination': 'Beach Resort',
      'departureTime': '2025-03-10T15:45:00Z',
      'availableSeats': 4,
      'availableLuggage': 3,
    },
    {
      'id': '3',
      'driver': {
        'name': 'Michael Brown',
        'rating': 4.7,
        'profileImage': 'https://example.com/driver3.jpg'
      },
      'vehicle': {
        'model': 'Tesla Model 3',
        'color': 'White',
        'plateNumber': 'EV1234'
      },
      'price': 55.75,
      'pickup': 'Tech Campus',
      'destination': 'Mountain View Hotel',
      'departureTime': '2025-03-10T16:15:00Z',
      'availableSeats': 2,
      'availableLuggage': 2,
    },
    {
      'id': '4',
      'driver': {
        'name': 'Sarah Wilson',
        'rating': 4.6,
        'profileImage': 'https://example.com/driver4.jpg'
      },
      'vehicle': {
        'model': 'Ford Explorer',
        'color': 'Blue',
        'plateNumber': 'SUV567'
      },
      'price': 65.25,
      'pickup': 'North Station',
      'destination': 'Conference Center',
      'departureTime': '2025-03-10T17:00:00Z',
      'availableSeats': 5,
      'availableLuggage': 4,
    },
    {
      'id': '5',
      'driver': {
        'name': 'Robert Johnson',
        'rating': 4.9,
        'profileImage': 'https://example.com/driver5.jpg'
      },
      'vehicle': {
        'model': 'BMW 5 Series',
        'color': 'Black',
        'plateNumber': 'LUX888'
      },
      'price': 85.00,
      'pickup': 'Financial District',
      'destination': 'Luxury Hotel',
      'departureTime': '2025-03-10T18:30:00Z',
      'availableSeats': 3,
      'availableLuggage': 3,
    },
  ];

  ApiService({
    this.baseUrl = 'https://api.tourease.example.com',
    this.latency = const Duration(milliseconds: 300),
  });

  Future<Map<String, dynamic>> get(String endpoint,
      {required Map<String, dynamic> params}) async {
    await Future.delayed(Duration(
      milliseconds: latency.inMilliseconds + _random.nextInt(200),
    ));



    switch (endpoint) {
      case '/rides':
        return _handleRidesEndpoint(params);
      default:
        throw http.ClientException('Not found', Uri.parse('$baseUrl$endpoint'));
    }
  }

  Map<String, dynamic> _handleRidesEndpoint(Map<String, dynamic> params) {
    final minPrice = params['min_price'] as double;
    final maxPrice = params['max_price'] as double;
    final travelers = params['travelers'] as int;
    final luggage = params['luggage'] as int;
    final pickup = params['pickup'] as String?;
    final destination = params['destination'] as String?;

    List<Map<String, dynamic>> filteredRides = _mockRides.toList();
    return {
      'rides': filteredRides,
      'metadata': {
        'totalCount': filteredRides.length,
        'page': 1,
        'pageSize': 20,
        'hasMore': false,
      },
      'status': 'success',
    };
  }

}